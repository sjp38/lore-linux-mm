Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2626B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 05:22:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i9-v6so4091142qtj.3
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 02:22:11 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0114.outbound.protection.outlook.com. [104.47.0.114])
        by mx.google.com with ESMTPS id e190-v6si1923238qkc.339.2018.08.09.02.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Aug 2018 02:22:10 -0700 (PDT)
Subject: Re: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
 <20180809071418.GA24884@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <cf7ba095-8be9-ead8-5422-59fa1f3bb07d@virtuozzo.com>
Date: Thu, 9 Aug 2018 12:21:58 +0300
MIME-Version: 1.0
In-Reply-To: <20180809071418.GA24884@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 09.08.2018 10:14, Michal Hocko wrote:
> On Wed 08-08-18 16:20:54, Kirill Tkhai wrote:
>> [Added two more places needed srcu_dereference(). All ->shrinker_map
>>  dereferences must be under SRCU, and this v2 adds missed in previous]
>>
>> The patch makes shrinker list and shrinker_idr SRCU-safe
>> for readers. This requires synchronize_srcu() on finalize
>> stage unregistering stage, which waits till all parallel
>> shrink_slab() are finished
>>
>> Note, that patch removes rwsem_is_contended() checks from
>> the code, and this does not result in delays during
>> registration, since there is no waiting at all. Unregistration
>> case may be optimized by splitting unregister_shrinker()
>> in tho stages, and this is made in next patches.
>>     
>> Also, keep in mind, that in case of SRCU is not allowed
>> to make unconditional (which is done in previous patch),
>> it is possible to use percpu_rw_semaphore instead of it.
>> percpu_down_read() will be used in shrink_slab_memcg()
>> and in shrink_slab(), and consecutive calls
>>
>>         percpu_down_write(percpu_rwsem);
>>         percpu_up_write(percpu_rwsem);
>>
>> will be used instead of synchronize_srcu().
> 
> An obvious question. Why didn't you go that way? What are pros/cons of
> both approaches?

1)After percpu_rw_semaphore is introduced, shrink_slab() will be not able
  to do successful percpu_down_read_trylock() for longer time in comparison
  to current behavior:

  [cpu0]                                                               [cpu1]
  {un,}register_shrinker();                                            shrink_slab()
    percpu_down_write();                                                 percpu_down_read_trylock() -> fail
      synchronize_rcu(); -> in some periods very slow on big SMP       ...
                                                                       shrink_slab()
                                                                         percpu_down_read_trylock() -> fail

  Also, register_shrinker() and unregister_shrinker() will become slower for the same reason.
  Unlike unregister_shrinker(); register_shrinker() can't be made asynchronous/delayed, so 
  simple mount() performance will be worse.

  It's possible, these both can be solved by using both percpu_rw_semaphore and rw_semaphore.
  shrink_slab() may fall back to rw_semaphore in case of percpu_rw_semaphore can't be blocked:

  shrink_slab()
  {
        bool percpu = true;

        if (!percpu_down_read_try_lock()) {
               if(!down_read_trylock())
                    return 0;
               percpu = false;
  	}

        shrinker = idr_find();
        ...

        if (percpu)
             percpu_up_read();
        else
             up_read();
   }

   register_shrinker()
   {
         down_write();
         idr_alloc();
         up_write();
   }

   unregister_shrinker()
   {
         percpu_down_write();
         down_write();
         idr_remove();
         up_write();
         percpu_up_write();
   }

   But a)On big machine this may turn in always down_read_trylock() like we have now;
       b)I'm not sure, unlocked idr_find() is safe in parallel with idr_alloc(), maybe,
         there is needed something else around it (I just haven't investigated this).

   All the above are cons. Pros are not enabling SRCU.

2)SRCU. Pros are there are no the above problems; we will have completely unlocked and
  scalable shrink_slab(). We will also have a possibility to avoid unregistering delays,
  like I did for superblock shrinker. There will be full scalability.
  Cons is enabling SRCU.

Kirill

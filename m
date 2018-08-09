Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4196B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 06:58:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i9-v6so4251501qtj.3
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 03:58:28 -0700 (PDT)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60123.outbound.protection.outlook.com. [40.107.6.123])
        by mx.google.com with ESMTPS id l3-v6si1375023qvl.84.2018.08.09.03.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Aug 2018 03:58:27 -0700 (PDT)
Subject: Re: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
 <20180809071418.GA24884@dhcp22.suse.cz>
 <cf7ba095-8be9-ead8-5422-59fa1f3bb07d@virtuozzo.com>
 <7b746367-e4bc-0e64-4e27-14fd7f06ba8f@i-love.sakura.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <2e1cdec3-5133-67ec-e929-8bc174574b3a@virtuozzo.com>
Date: Thu, 9 Aug 2018 13:58:16 +0300
MIME-Version: 1.0
In-Reply-To: <7b746367-e4bc-0e64-4e27-14fd7f06ba8f@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 09.08.2018 13:37, Tetsuo Handa wrote:
> On 2018/08/09 18:21, Kirill Tkhai wrote:
>> 2)SRCU. Pros are there are no the above problems; we will have completely unlocked and
>>   scalable shrink_slab(). We will also have a possibility to avoid unregistering delays,
>>   like I did for superblock shrinker. There will be full scalability.
>>   Cons is enabling SRCU.
>>
> 
> How unregistering delays can be avoided? Since you traverse all shrinkers
> using one shrinker_srcu, synchronize_srcu(&shrinker_srcu) will block
> unregistering threads until longest inflight srcu_read_lock() user calls
> srcu_read_unlock().

Yes, but we can do synchronize_srcu() from async work like I did for the further patches.
The only thing we need is to teach shrinker::count_objects() and shrinker::scan_objects()
be safe to be called on unregistering shrinker user. The next patches do this for superblock
shrinker.

> Unless you use per shrinker counter like below, I wonder whether
> unregistering delays can be avoided...
> 
>   https://marc.info/?l=linux-mm&m=151060909613004
>   https://marc.info/?l=linux-mm&m=151060909713005

I'm afraid these atomic_{inc,dec}(&shrinker->nr_active) may regulary drop CPU caches
on another CPUs on some workloads. Also, synchronize_rcu() is also a heavy delay.

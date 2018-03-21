Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A09D6B002B
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:12:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o1so2551683pga.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:12:27 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0106.outbound.protection.outlook.com. [104.47.0.106])
        by mx.google.com with ESMTPS id w5si2915846pgt.823.2018.03.21.08.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 08:12:26 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
 <20180321145625.GA4780@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <eda62454-5788-4f65-c2b5-719d4a98cb2a@virtuozzo.com>
Date: Wed, 21 Mar 2018 18:12:17 +0300
MIME-Version: 1.0
In-Reply-To: <20180321145625.GA4780@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 21.03.2018 17:56, Matthew Wilcox wrote:
> On Wed, Mar 21, 2018 at 04:21:40PM +0300, Kirill Tkhai wrote:
>> +++ b/include/linux/memcontrol.h
>> @@ -151,6 +151,11 @@ struct mem_cgroup_thresholds {
>>  	struct mem_cgroup_threshold_ary *spare;
>>  };
>>  
>> +struct shrinkers_map {
>> +	struct rcu_head rcu;
>> +	unsigned long *map[0];
>> +};
>> +
>>  enum memcg_kmem_state {
>>  	KMEM_NONE,
>>  	KMEM_ALLOCATED,
>> @@ -182,6 +187,9 @@ struct mem_cgroup {
>>  	unsigned long low;
>>  	unsigned long high;
>>  
>> +	/* Bitmap of shrinker ids suitable to call for this memcg */
>> +	struct shrinkers_map __rcu *shrinkers_map;
>> +
>>  	/* Range enforcement for interrupt charges */
>>  	struct work_struct high_work;
>>  
> 
> Why use your own bitmap here?  Why not use an IDA which can grow and
> shrink automatically without you needing to play fun games with RCU?

Bitmap allows to use unlocked set_bit()/clear_bit() to maintain the map
of not empty shrinkers.

So, the reason to use IDR here is to save bitmap memory? Does this mean
IDA works fast with sparse identifiers? It seems they require per-memcg
lock to call IDR primitives. I just don't have information about this.

If so, which IDA primitive can be used to set particular id in bitmap?
There is idr_alloc_cyclic(idr, NULL, id, id+1, GFP_KERNEL) only I see
to do that.

Kirill

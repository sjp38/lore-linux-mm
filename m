Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 303A56B026C
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:19:51 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id a28-v6so6363774ljd.6
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:19:51 -0700 (PDT)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 9-v6si13690686lja.3.2018.10.16.06.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 06:19:49 -0700 (PDT)
Subject: Re: [PATCH] mm: Convert mem_cgroup_id::ref to refcount_t type
References: <153910718919.7006.13400779039257185427.stgit@localhost.localdomain>
 <20181016124939.GA13278@andrea>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a990eed4-611b-8464-c2aa-56684fee0ee5@virtuozzo.com>
Date: Tue, 16 Oct 2018 16:19:40 +0300
MIME-Version: 1.0
In-Reply-To: <20181016124939.GA13278@andrea>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Andrea,

On 16.10.2018 15:49, Andrea Parri wrote:
> Hi Kirill,
> 
> On Tue, Oct 09, 2018 at 08:46:56PM +0300, Kirill Tkhai wrote:
>> This will allow to use generic refcount_t interfaces
>> to check counters overflow instead of currently existing
>> VM_BUG_ON(). The only difference after the patch is
>> VM_BUG_ON() may cause BUG(), while refcount_t fires
>> with WARN().
> 
> refcount_{sub_and_test,inc_not_zero}() are documented to provide
> "slightly" more relaxed ordering than their atomic_* counterpart,
> c.f.,
> 
>   Documentation/core-api/refcount-vs-atomic.rst
>   lib/refcount.c (inline comments)
> 
> IIUC, this semantic change won't cause problems here (but please
> double-check? ;D ).

I just don't see a place, where we may think about using a modification
of struct mem_cgroup::id::ref as a memory barrier to order something,
and all this looks safe for me.

Kirill
 
>> But this seems not to be significant here,
>> since such the problems are usually caught by syzbot
>> with panic-on-warn enabled.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/memcontrol.h |    2 +-
>>  mm/memcontrol.c            |   10 ++++------
>>  2 files changed, 5 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 4399cc3f00e4..7ab2120155a4 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -78,7 +78,7 @@ struct mem_cgroup_reclaim_cookie {
>>  
>>  struct mem_cgroup_id {
>>  	int id;
>> -	atomic_t ref;
>> +	refcount_t ref;
>>  };
>>  
>>  /*
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 7bebe2ddec05..aa728d5b3d72 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4299,14 +4299,12 @@ static void mem_cgroup_id_remove(struct mem_cgroup *memcg)
>>  
>>  static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
>>  {
>> -	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
>> -	atomic_add(n, &memcg->id.ref);
>> +	refcount_add(n, &memcg->id.ref);
>>  }
>>  
>>  static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>>  {
>> -	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
>> -	if (atomic_sub_and_test(n, &memcg->id.ref)) {
>> +	if (refcount_sub_and_test(n, &memcg->id.ref)) {
>>  		mem_cgroup_id_remove(memcg);
>>  
>>  		/* Memcg ID pins CSS */
>> @@ -4523,7 +4521,7 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>>  	}
>>  
>>  	/* Online state pins memcg ID, memcg ID pins CSS */
>> -	atomic_set(&memcg->id.ref, 1);
>> +	refcount_set(&memcg->id.ref, 1);
>>  	css_get(css);
>>  	return 0;
>>  }
>> @@ -6357,7 +6355,7 @@ subsys_initcall(mem_cgroup_init);
>>  #ifdef CONFIG_MEMCG_SWAP
>>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
>>  {
>> -	while (!atomic_inc_not_zero(&memcg->id.ref)) {
>> +	while (!refcount_inc_not_zero(&memcg->id.ref)) {
>>  		/*
>>  		 * The root cgroup cannot be destroyed, so it's refcount must
>>  		 * always be >= 1.
>>

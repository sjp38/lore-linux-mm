Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 798BC6B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 19:33:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so61143083pgd.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:33:16 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id d124si66442032pga.215.2016.11.30.16.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 16:33:15 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 3so2770366pgd.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:33:15 -0800 (PST)
Subject: Re: [Bug 189181] New: BUG: unable to handle kernel NULL pointer
 dereference in mem_cgroup_node_nr_lru_pages
References: <bug-189181-27@https.bugzilla.kernel.org/>
 <20161129145654.c48bebbd684edcd6f64a03fe@linux-foundation.org>
 <20161130170040.GJ18432@dhcp22.suse.cz> <20161130181653.GA30558@cmpxchg.org>
 <20161130183016.GO18432@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <8eaf5cd7-3846-0c34-47d8-e0d09a17ece3@gmail.com>
Date: Thu, 1 Dec 2016 11:33:08 +1100
MIME-Version: 1.0
In-Reply-To: <20161130183016.GO18432@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, marmarek@mimuw.edu.pl, Vladimir Davydov <vdavydov.dev@gmail.com>



On 01/12/16 05:30, Michal Hocko wrote:
> On Wed 30-11-16 13:16:53, Johannes Weiner wrote:
>> Hi Michael,
>>
>> On Wed, Nov 30, 2016 at 06:00:40PM +0100, Michal Hocko wrote:
> [...]
>>> diff --git a/mm/workingset.c b/mm/workingset.c
>>> index 617475f529f4..0f07522c5c0e 100644
>>> --- a/mm/workingset.c
>>> +++ b/mm/workingset.c
>>> @@ -348,7 +348,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>>>  	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
>>>  	local_irq_enable();
>>>  
>>> -	if (memcg_kmem_enabled()) {
>>> +	if (memcg_kmem_enabled() && sc->memcg) {
>>>  		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
>>>  						     LRU_ALL_FILE);
>>>  	} else {
>>
>> If we do that, I'd remove the racy memcg_kmem_enabled() check
>> altogether and just check for whether we have a memcg or not.
> 
> But that would make this a memcg aware shrinker even when kmem is not
> enabled...
> 
> But now that I am looking into the code
> shrink_slab:
> 		if (memcg_kmem_enabled() &&
> 		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> 			continue;
> 
> this should be taken care of already. So sc->memcg should be indeed
> sufficient. So unless I am missing something I will respin my local
> patch and post it later after the reporter has some time to test the
> current one.
>  

I did a quick dis-assembly of the code

R9 and RDI are NULL and the instruction seems to be

mov rsi, [rdi+r9*8+0x400]

RDI is NULL, sc->memcg is NULL, which indicates global reclaim

The check referred to earlier

                /*
                 * If kernel memory accounting is disabled, we ignore
                 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
                 * passing NULL for memcg.
                 */
                if (memcg_kmem_enabled() &&
                    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
                        continue;

So we do pass NULL for memcg

A check for sc->memcg should be enough in count_shadow_nodes and a VM_BUG_ON
for memcg == NULL in mem_cgroup_node_nr_lru_pages would be nice

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

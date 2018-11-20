Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A09496B2137
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:59:10 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w7-v6so2244283plp.9
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:59:10 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o3si42021120pgi.388.2018.11.20.09.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 09:59:09 -0800 (PST)
Subject: Re: [PATCH] mm: use this_cpu_cmpxchg_double in put_cpu_partial
References: <20181117013335.32220-1-wen.gang.wang@oracle.com>
 <20181118010229.esa32zk5hpob67y7@master>
From: Wengang Wang <wen.gang.wang@oracle.com>
Message-ID: <d3e91590-adaa-11a5-67f9-0ef15df6b07d@oracle.com>
Date: Tue, 20 Nov 2018 09:58:58 -0800
MIME-Version: 1.0
In-Reply-To: <20181118010229.esa32zk5hpob67y7@master>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Wei,


On 2018/11/17 17:02, Wei Yang wrote:
> On Fri, Nov 16, 2018 at 05:33:35PM -0800, Wengang Wang wrote:
>> The this_cpu_cmpxchg makes the do-while loop pass as long as the
>> s->cpu_slab->partial as the same value. It doesn't care what happened to
>> that slab. Interrupt is not disabled, and new alloc/free can happen in the
> Well, I seems to understand your description.
>
> There are two slabs
>
>     * one which put_cpu_partial() trying to free an object
>     * one which is the first slab in cpu_partial list
>
> There is some tricky case, the first slab in cpu_partial list we
> reference to will change since interrupt is not disabled.
Yes, two slabs involved here just as you said above.
And yes, the case is really tricky, but it's there.

>> interrupt handlers. Theoretically, after we have a reference to the it,
>                                                                   ^^^
> 							 one more word?
sorry, "the" should not be there.

>> stored in _oldpage_, the first slab on the partial list on this CPU can be
>                                              ^^^
> One little suggestion here, mayby use cpu_partial would be more easy to
> understand. I confused this with the partial list in kmem_cache_node at
> the first time.  :-)
Right, making others understanding easily is very important. I just 
meant cpu_partial.

>> moved to kmem_cache_node and then moved to different kmem_cache_cpu and
>> then somehow can be added back as head to partial list of current
>> kmem_cache_cpu, though that is a very rare case. If that rare case really
> Actually, no matter what happens after the removal of the first slab in
> cpu_partial, it would leads to problem.
Maybe you are right, what I see is the problem on the page->pobjects.

>
>> happened, the reading of oldpage->pobjects may get a 0xdead0000
>> unexpectedly, stored in _pobjects_, if the reading happens just after
>> another CPU removed the slab from kmem_cache_node, setting lru.prev to
>> LIST_POISON2 (0xdead000000000200). The wrong _pobjects_(negative) then
>> prevents slabs from being moved to kmem_cache_node and being finally freed.
>>
>> We see in a vmcore, there are 375210 slabs kept in the partial list of one
>> kmem_cache_cpu, but only 305 in-use objects in the same list for
>> kmalloc-2048 cache. We see negative values for page.pobjects, the last page
>> with negative _pobjects_ has the value of 0xdead0004, the next page looks
>> good (_pobjects is 1).
>>
>> For the fix, I wanted to call this_cpu_cmpxchg_double with
>> oldpage->pobjects, but failed due to size difference between
>> oldpage->pobjects and cpu_slab->partial. So I changed to call
>> this_cpu_cmpxchg_double with _tid_. I don't really want no alloc/free
>> happen in between, but just want to make sure the first slab did expereince
>> a remove and re-add. This patch is more to call for ideas.
> Maybe not an exact solution.
>
> I took a look into the code and change log.
>
> _tid_ is introduced by commit 8a5ec0ba42c4 ('Lockless (and preemptless)
> fastpaths for slub'), which is used to guard cpu_freelist. While we don't
> modify _tid_ when cpu_partial changes.
>
> May need another _tid_ for cpu_partial?
Right, _tid_ changes later than cpu_partial changes.

As pointed out by Zhong Jiang, the pobjects issue is fixed by commit 
e5d9998f3e09 (not sure if by side effect, see my replay there),
I'd skip this patch.A  If we found other problems regarding the change of 
cpu_partial, let's fix them. What do you think?

thanks,
wengang

>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>> mm/slub.c | 20 +++++++++++++++++---
>> 1 file changed, 17 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index e3629cd..26539e6 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -2248,6 +2248,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>> {
>> #ifdef CONFIG_SLUB_CPU_PARTIAL
>> 	struct page *oldpage;
>> +	unsigned long tid;
>> 	int pages;
>> 	int pobjects;
>>
>> @@ -2255,8 +2256,12 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>> 	do {
>> 		pages = 0;
>> 		pobjects = 0;
>> -		oldpage = this_cpu_read(s->cpu_slab->partial);
>>
>> +		tid = this_cpu_read(s->cpu_slab->tid);
>> +		/* read tid before reading oldpage */
>> +		barrier();
>> +
>> +		oldpage = this_cpu_read(s->cpu_slab->partial);
>> 		if (oldpage) {
>> 			pobjects = oldpage->pobjects;
>> 			pages = oldpage->pages;
>> @@ -2283,8 +2288,17 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>> 		page->pobjects = pobjects;
>> 		page->next = oldpage;
>>
>> -	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>> -								!= oldpage);
>> +		/* we dont' change tid, but want to make sure it didn't change
>> +		 * in between. We don't really hope alloc/free not happen on
>> +		 * this CPU, but don't want the first slab be removed from and
>> +		 * then re-added as head to this partial list. If that case
>> +		 * happened, pobjects may read 0xdead0000 when this slab is just
>> +		 * removed from kmem_cache_node by other CPU setting lru.prev
>> +		 * to LIST_POISON2.
>> +		 */
>> +	} while (this_cpu_cmpxchg_double(s->cpu_slab->partial, s->cpu_slab->tid,
>> +					 oldpage, tid, page, tid) == 0);
>> +
>> 	if (unlikely(!s->cpu_partial)) {
>> 		unsigned long flags;
>>
>> -- 
>> 2.9.5

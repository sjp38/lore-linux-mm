Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D66206B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:06:22 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so138382043wmp.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 06:06:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si34151071wjs.103.2016.03.29.06.06.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 06:06:21 -0700 (PDT)
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com>
 <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA7DC8.4000902@suse.cz>
Date: Tue, 29 Mar 2016 15:06:16 +0200
MIME-Version: 1.0
In-Reply-To: <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2016 08:22 PM, Andrew Morton wrote:
> On Fri, 25 Mar 2016 14:56:04 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
>
>> It is incorrect to use next_node to find a target node, it will
>> return MAX_NUMNODES or invalid node. This will lead to crash in
>> buddy system allocation.
>>
>> ...
>>
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>>   	 * now as a simple work-around, we use the next node for destination.
>>   	 */
>>   	if (PageHuge(page)) {
>> -		nodemask_t src = nodemask_of_node(page_to_nid(page));
>> -		nodemask_t dst;
>> -		nodes_complement(dst, src);
>> +		int node = next_online_node(page_to_nid(page));
>> +		if (node == MAX_NUMNODES)
>> +			node = first_online_node;
>>   		return alloc_huge_page_node(page_hstate(compound_head(page)),
>> -					    next_node(page_to_nid(page), dst));
>> +					    node);
>>   	}
>>
>>   	if (PageHighMem(page))
>
> Indeed.  Can you tell us more about this circumstances under which the
> kernel will crash?  I need to decide which kernel version(s) need the
> patch, but the changelog doesn't contain the info needed to make this
> decision (it should).
>
>
>
> next_node() isn't a very useful interface, really.  Just about every
> caller does this:
>
>
> 	node = next_node(node, XXX);
> 	if (node == MAX_NUMNODES)
> 		node = first_node(XXX);
>
> so how about we write a function which does that, and stop open-coding
> the same thing everywhere?

Good idea.

> And I think your fix could then use such a function:
>
> 	int node = that_new_function(page_to_nid(page), node_online_map);
>
>
>
> Also, mm/mempolicy.c:offset_il_node() worries me:
>
> 	do {
> 		nid = next_node(nid, pol->v.nodes);
> 		c++;
> 	} while (c <= target);
>
> Can't `nid' hit MAX_NUMNODES?

AFAICS it can. interleave_nid() uses this and the nid is then used e.g. 
in node_zonelist() where it's used for NODE_DATA(nid). That's quite 
scary. It also predates git. Why don't we see crashes or KASAN finding this?

>
> And can someone please explain mem_cgroup_select_victim_node() to me?
> How can we hit the "node = numa_node_id()" path?  Only if
> memcg->scan_nodes is empty?  is that even valid?  The comment seems to
> have not much to do with the code?

I understand the comment that it's valid to be empty and the comment 
lists reasons why that can happen (with somewhat broken language). Note 
that I didn't verify these reasons:
- we call this when hitting memcg limit, not when adding pages to LRU, 
as adding to LRU means it would contain the given LRU's node
- adding to unevictable LRU means it's not added to scan_nodes (probably 
because scanning unevictable lru would be useless)
- for other reasons (which?) it might have pages not on LRU and it's so 
small there are no other pages that would be on LRU

> mpol_rebind_nodemask() is similar.
>
>
>
> Something like this?
>
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: include/linux/nodemask.h: create next_node_in() helper
>
> Lots of code does
>
> 	node = next_node(node, XXX);
> 	if (node == MAX_NUMNODES)
> 		node = first_node(XXX);
>
> so create next_node_in() to do this and use it in various places.
>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Patch doesn't address offset_il_node() which is good, because if it's 
indeed buggy, it's serious and needs a non-cleanup patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

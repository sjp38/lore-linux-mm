Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD8CC6B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 05:50:45 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jb2so25764094wjb.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 02:50:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si48653108wjz.60.2016.11.29.02.50.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 02:50:44 -0800 (PST)
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
 <f6fc93b4-5c1c-bbab-7c74-a0d60d4afc84@suse.cz>
 <20161129090322.GB16569@sha-win-210.asiapac.arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <777f7e0c-c04b-77c3-b866-0787bad32aa8@suse.cz>
Date: Tue, 29 Nov 2016 11:50:37 +0100
MIME-Version: 1.0
In-Reply-To: <20161129090322.GB16569@sha-win-210.asiapac.arm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/29/2016 10:03 AM, Huang Shijie wrote:
> On Mon, Nov 28, 2016 at 03:17:28PM +0100, Vlastimil Babka wrote:
>> On 11/16/2016 07:55 AM, Huang Shijie wrote:
>> > +static struct page *__hugetlb_alloc_gigantic_page(struct hstate *h,
>> > +		struct vm_area_struct *vma, unsigned long addr, int nid)
>> > +{
>> > +	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>>
>> What if the allocation fails and nodes_allowed is NULL?
>> It might work fine now, but it's rather fragile, so I'd rather see an
> Yes.
>
>> explicit check.
> See the comment below.
>
>>
>> BTW same thing applies to __nr_hugepages_store_common().
>>
>> > +	struct page *page = NULL;
>> > +
>> > +	/* Not NUMA */
>> > +	if (!IS_ENABLED(CONFIG_NUMA)) {
>> > +		if (nid == NUMA_NO_NODE)
>> > +			nid = numa_mem_id();
>> > +
>> > +		page = alloc_gigantic_page(nid, huge_page_order(h));
>> > +		if (page)
>> > +			prep_compound_gigantic_page(page, huge_page_order(h));
>> > +
>> > +		NODEMASK_FREE(nodes_allowed);
>> > +		return page;
>> > +	}
>> > +
>> > +	/* NUMA && !vma */
>> > +	if (!vma) {
>> > +		if (nid == NUMA_NO_NODE) {
>> > +			if (!init_nodemask_of_mempolicy(nodes_allowed)) {
>> > +				NODEMASK_FREE(nodes_allowed);
>> > +				nodes_allowed = &node_states[N_MEMORY];
>> > +			}
>> > +		} else if (nodes_allowed) {
> The check is here.

It's below a possible usage of nodes_allowed as an argument of 
init_nodemask_of_mempolicy(mask). Which does

         if (!(mask && current->mempolicy))
                 return false;

which itself looks like an error at first sight :)

> Do we really need to re-arrange the code here for the explicit check? :)

We don't need it *now* to be correct, but I still find it fragile. Also it
mixes up the semantic of NULL as a conscious "default" value, and NULL as
a side-effect of memory allocation failure. Nothing good can come from that in 
the long term :)

> Thanks
> Huang Shijie
>> > +			init_nodemask_of_node(nodes_allowed, nid);
>> > +		} else {
>> > +			nodes_allowed = &node_states[N_MEMORY];
>> > +		}
>> > +
>> > +		page = alloc_fresh_gigantic_page(h, nodes_allowed, true);
>> > +
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

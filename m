Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE7616B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 04:03:36 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id q197so298993184oic.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:03:36 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0085.outbound.protection.outlook.com. [104.47.1.85])
        by mx.google.com with ESMTPS id z186si28514281oiz.143.2016.11.29.01.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 01:03:36 -0800 (PST)
Date: Tue, 29 Nov 2016 17:03:23 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
Message-ID: <20161129090322.GB16569@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
 <f6fc93b4-5c1c-bbab-7c74-a0d60d4afc84@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <f6fc93b4-5c1c-bbab-7c74-a0d60d4afc84@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon, Nov 28, 2016 at 03:17:28PM +0100, Vlastimil Babka wrote:
> On 11/16/2016 07:55 AM, Huang Shijie wrote:
> > +static struct page *__hugetlb_alloc_gigantic_page(struct hstate *h,
> > +		struct vm_area_struct *vma, unsigned long addr, int nid)
> > +{
> > +	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
> 
> What if the allocation fails and nodes_allowed is NULL?
> It might work fine now, but it's rather fragile, so I'd rather see an
Yes.

> explicit check.
See the comment below.

> 
> BTW same thing applies to __nr_hugepages_store_common().
> 
> > +	struct page *page = NULL;
> > +
> > +	/* Not NUMA */
> > +	if (!IS_ENABLED(CONFIG_NUMA)) {
> > +		if (nid == NUMA_NO_NODE)
> > +			nid = numa_mem_id();
> > +
> > +		page = alloc_gigantic_page(nid, huge_page_order(h));
> > +		if (page)
> > +			prep_compound_gigantic_page(page, huge_page_order(h));
> > +
> > +		NODEMASK_FREE(nodes_allowed);
> > +		return page;
> > +	}
> > +
> > +	/* NUMA && !vma */
> > +	if (!vma) {
> > +		if (nid == NUMA_NO_NODE) {
> > +			if (!init_nodemask_of_mempolicy(nodes_allowed)) {
> > +				NODEMASK_FREE(nodes_allowed);
> > +				nodes_allowed = &node_states[N_MEMORY];
> > +			}
> > +		} else if (nodes_allowed) {
The check is here.

Do we really need to re-arrange the code here for the explicit check? :)


Thanks
Huang Shijie
> > +			init_nodemask_of_node(nodes_allowed, nid);
> > +		} else {
> > +			nodes_allowed = &node_states[N_MEMORY];
> > +		}
> > +
> > +		page = alloc_fresh_gigantic_page(h, nodes_allowed, true);
> > +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

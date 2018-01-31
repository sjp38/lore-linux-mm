Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7B306B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:55:18 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n28so12657352qtk.7
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:55:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h37si618290qth.275.2018.01.30.18.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 18:55:17 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0V2nXhi084977
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:55:17 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fu0tc8yqp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:55:17 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 31 Jan 2018 02:55:15 -0000
Subject: Re: [RFC] mm/migrate: Consolidate page allocation helper functions
References: <20180130050642.19834-1-khandual@linux.vnet.ibm.com>
 <20180130143635.GF21609@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 31 Jan 2018 08:25:09 +0530
MIME-Version: 1.0
In-Reply-To: <20180130143635.GF21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <53cf5454-405b-a812-1389-af4fd7527122@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 01/30/2018 08:06 PM, Michal Hocko wrote:
> On Tue 30-01-18 10:36:42, Anshuman Khandual wrote:
>> Allocation helper functions for migrate_pages() remmain scattered with
>> similar names making them really confusing. Rename these functions based
>> on the context for the migration and move them all into common migration
>> header. Functionality remains unchanged.
> 
> OK, I do not rememeber why I was getting header dependecy issues here.
> Maybe I've just screwed something. So good if we can make most of the
> callbacks at the single place. It will hopefully prevent from reinventig
> the weel again. I do not like your renames though. You are making them
> specific to the caller rather than their semantic.

Got it. Actually at first the semantics looked not too trivial to put in
a single word at the end in a new_page_[alloc]_* kind of naming.

> 
>> +#ifdef CONFIG_MIGRATION
>> +/*
>> + * Allocate a new page for page migration based on vma policy.
>> + * Start by assuming the page is mapped by the same vma as contains @start.
>> + * Search forward from there, if not.  N.B., this assumes that the
>> + * list of pages handed to migrate_pages()--which is how we get here--
>> + * is in virtual address order.
>> + */
>> +static inline struct page *new_page_alloc_mbind(struct page *page, unsigned long start)
> 
> new_page_alloc_mempolicy or new_page_alloc_vma

Will rename as new_page_alloc_mempolicy.

>
>> +{
>> +	struct vm_area_struct *vma;
>> +	unsigned long uninitialized_var(address);
>> +
>> +	vma = find_vma(current->mm, start);
>> +	while (vma) {
>> +		address = page_address_in_vma(page, vma);
>> +		if (address != -EFAULT)
>> +			break;
>> +		vma = vma->vm_next;
>> +	}
>> +
>> +	if (PageHuge(page)) {
>> +		return alloc_huge_page_vma(page_hstate(compound_head(page)),
>> +				vma, address);
>> +	} else if (PageTransHuge(page)) {
>> +		struct page *thp;
>> +
>> +		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
>> +					 HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>> +	}
>> +	/*
>> +	 * if !vma, alloc_page_vma() will use task or system default policy
>> +	 */
>> +	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
>> +			vma, address);
>> +}
>> +
>> +/* page allocation callback for NUMA node migration */
>> +static inline struct page *new_page_alloc_syscall(struct page *page, unsigned long node)
> 
> new_page_alloc_node. The important thing about this one is that it
> doesn't fall back to any other node. And the comment should be explicit
> about that fact.

Sure, will do.

> 
>> +{
>> +	if (PageHuge(page))
>> +		return alloc_huge_page_node(page_hstate(compound_head(page)),
>> +					node);
>> +	else if (PageTransHuge(page)) {
>> +		struct page *thp;
>> +
>> +		thp = alloc_pages_node(node,
>> +			(GFP_TRANSHUGE | __GFP_THISNODE),
>> +			HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>> +	} else
>> +		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
>> +						    __GFP_THISNODE, 0);
>> +}
>> +
>> +
>> +static inline struct page *new_page_alloc_misplaced(struct page *page,
>> +					   unsigned long data)
> 
> This is so special cased that I even wouldn't expose it. Who is going to
> reuse it?

Yeah this is special cased but the idea to just keep the helper functions
in the same place, hence just move this as well.

> 
>> +{
>> +	int nid = (int) data;
>> +	struct page *newpage;
>> +
>> +	newpage = __alloc_pages_node(nid,
>> +					 (GFP_HIGHUSER_MOVABLE |
>> +					  __GFP_THISNODE | __GFP_NOMEMALLOC |
>> +					  __GFP_NORETRY | __GFP_NOWARN) &
>> +					 ~__GFP_RECLAIM, 0);
> 
> this also deserves one hell of a comment.

Sure, will do.

> 
>> +
>> +	return newpage;
>> +}
>> +
>>  static inline struct page *new_page_nodemask(struct page *page,
>>  				int preferred_nid, nodemask_t *nodemask)
>>  {
>> @@ -59,7 +138,34 @@ static inline struct page *new_page_nodemask(struct page *page,
>>  	return new_page;
>>  }
>>  
>> -#ifdef CONFIG_MIGRATION
>> +static inline struct page *new_page_alloc_failure(struct page *p, unsigned long private)
> 
> This function in fact allocates arbitrary page with preference of the
> original page's node. It is by no means specific to HWPoison and
> _failure in the name is just confusing.
> 
> new_page_alloc_keepnode

Sure, will do.

> 
>> +{
>> +	int nid = page_to_nid(p);
>> +
>> +	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
>> +}
>> +
>> +/*
>> + * Try to allocate from a different node but reuse this node if there
>> + * are no other online nodes to be used (e.g. we are offlining a part
>> + * of the only existing node).
>> + */
>> +static inline struct page *new_page_alloc_hotplug(struct page *page, unsigned long private)
> 
> Does anybody ever want to use the same function? We try hard to allocate
> from any other than original node.

Will replace this with new_page_alloc_othernode.

>> +{
>> +	int nid = page_to_nid(page);
>> +	nodemask_t nmask = node_states[N_MEMORY];
>> +
>> +	node_clear(nid, nmask);
>> +	if (nodes_empty(nmask))
>> +		node_set(nid, nmask);
>> +
>> +	return new_page_nodemask(page, nid, &nmask);
>> +}
>> +
>> +static inline struct page *new_page_alloc_contig(struct page *page, unsigned long private)
> 
> What does this name acutally means? Why not simply new_page_alloc? It
> simply allocates from any node with the local node preference. So
> basically alloc_pages like.

I just followed caller based semantics as you have pointed out earlier.
Sure, will replace with new_page_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

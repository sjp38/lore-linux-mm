Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E90366B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 01:43:26 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4318354pdb.0
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 22:43:26 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id r17si10068647pdi.172.2014.11.26.22.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Nov 2014 22:43:25 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Nov 2014 16:33:08 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 7FBA53578083
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 17:33:06 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAR6Wvmp23658734
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 17:33:06 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAR6WWNP030696
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 17:32:32 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm/thp: Always allocate transparent hugepages on local node
In-Reply-To: <alpine.DEB.2.10.1411241317430.21237@chino.kir.corp.google.com>
References: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141124150342.GA3889@node.dhcp.inet.fi> <alpine.DEB.2.10.1411241317430.21237@chino.kir.corp.google.com>
Date: Thu, 27 Nov 2014 12:02:01 +0530
Message-ID: <87r3wp887y.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes <rientjes@google.com> writes:

> On Mon, 24 Nov 2014, Kirill A. Shutemov wrote:
>
>> > This make sure that we try to allocate hugepages from local node. If
>> > we can't we fallback to small page allocation based on
>> > mempolicy. This is based on the observation that allocating pages
>> > on local node is more beneficial that allocating hugepages on remote node.
>> 
>> Local node on allocation is not necessary local node for use.
>> If policy says to use a specific node[s], we should follow.
>> 
>
> True, and the interaction between thp and mempolicies is fragile: if a 
> process has a MPOL_BIND mempolicy over a set of nodes, that does not 
> necessarily mean that we want to allocate thp remotely if it will always 
> be accessed remotely.  It's simple to benchmark and show that remote 
> access latency of a hugepage can exceed that of local pages.  MPOL_BIND 
> itself is a policy of exclusion, not inclusion, and it's difficult to 
> define when local pages and its cost of allocation is better than remote 
> thp.
>
> For MPOL_BIND, if the local node is allowed then thp should be forced from 
> that node, if the local node is disallowed then allocate from any node in 
> the nodemask.  For MPOL_INTERLEAVE, I think we should only allocate thp 
> from the next node in order, otherwise fail the allocation and fallback to 
> small pages.  Is this what you meant as well?
>

Something like below

struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
				unsigned long addr, int order)
{
	struct page *page;
	nodemask_t *nmask;
	struct mempolicy *pol;
	int node = numa_node_id();
	unsigned int cpuset_mems_cookie;

retry_cpuset:
	pol = get_vma_policy(vma, addr);
	cpuset_mems_cookie = read_mems_allowed_begin();

	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
		unsigned nid;
		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
		mpol_cond_put(pol);
		page = alloc_page_interleave(gfp, order, nid);
		if (unlikely(!page &&
			     read_mems_allowed_retry(cpuset_mems_cookie)))
			goto retry_cpuset;
		return page;
	}
	nmask = policy_nodemask(gfp, pol);
	if (!nmask || node_isset(node, *nmask)) {
		mpol_cond_put(pol);
		page = alloc_hugepage_exact_node(node, gfp, order);
		if (unlikely(!page &&
			     read_mems_allowed_retry(cpuset_mems_cookie)))
			goto retry_cpuset;
		return page;

	}
	/*
	 * if current node is not part of node mask, try
	 * the allocation from any node, and we can do retry
	 * in that case.
	 */
	page = __alloc_pages_nodemask(gfp, order,
				      policy_zonelist(gfp, pol, node),
				      nmask);
	mpol_cond_put(pol);
	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
		goto retry_cpuset;

	return page;
}

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

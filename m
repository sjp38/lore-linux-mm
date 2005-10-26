Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9QLkWPs018941
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 17:46:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9QLkVw5108452
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 17:46:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9QLkVI3015818
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 17:46:31 -0400
Subject: Re: RFC: Cleanup / small fixes to hugetlb fault handling
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20051026024831.GB17191@localhost.localdomain>
References: <20051026020055.GA17191@localhost.localdomain>
	 <20051026024831.GB17191@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 26 Oct 2005 16:46:16 -0500
Message-Id: <1130363177.2689.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-26 at 12:48 +1000, David Gibson wrote:
> On Wed, Oct 26, 2005 at 12:00:55PM +1000, David Gibson wrote:
> > Hi, Adam, Bill, Hugh,
> > 
> > Does this look like a reasonable patch to send to akpm for -mm.
> 
> Ahem.  Or rather this version, which actually compiles.
> 
> This patch makes some slight tweaks / cleanups to the fault handling
> path for huge pages in -mm.  My main motivation is to make it simpler
> to fit COW in, but along the way it addresses a few minor problems
> with the existing code:
> 
> - The check against i_size was duplicated: once in
>   find_lock_huge_page() and again in hugetlb_fault() after taking the
>   page_table_lock.  We only really need the locked one, so remove the
>   other.

Fair enough.

> - find_lock_huge_page() didn't, in fact, lock the page if it newly
>   allocated one, rather than finding it in the page cache already.  As
>   far as I can tell this is a bug, so the patch corrects it.

Thanks.  I was about to post a fix for this too.  It is reproducible in
the case where two threads race in the fault handler and both do
alloc_huge_page().  In that case, the loser will fail to insert his page
into the page cache and will call put_page() which has a
BUG_ON(page_count(page) == 0).

> - find_lock_huge_page() isn't a great name, since it does extra things
>   not analagous to find_lock_page().  Rename it
>   find_or_alloc_huge_page() which is closer to the mark.

I'll agree with the above.  I am not all that committed to the current
layout and what you have here is a little closer to the thinking in my
original patch ;)

<snip>

> +int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> +		  unsigned long address, int write_access)
> +{
> +	pte_t *ptep;
> +	pte_t entry;
> +
> +	ptep = huge_pte_alloc(mm, address);
> +	if (! ptep)
> +		/* OOM */
> +		return VM_FAULT_SIGBUS;
> +
> +	entry = *ptep;
> +
> +	if (pte_none(entry))
> +		return hugetlb_no_page(mm, vma, address, ptep);
> +
> +	/* we could get here if another thread instantiated the pte
> +	 * before the test above */
> +
> +	return VM_FAULT_SIGBUS;
>  }

I'll agree with Ken that the last return should probably still be
VM_FAULT_MINOR.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

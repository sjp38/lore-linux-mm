Date: Fri, 11 Jul 2008 09:17:34 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 2/2] [PATCH] Align faulting address to a hugepage boundary before unmapping
Message-ID: <20080711081734.GO7410@shadowen.org>
References: <20080710173001.16433.87538.sendpatchset@skynet.skynet.ie> <20080710173041.16433.21192.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080710173041.16433.21192.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 10, 2008 at 06:30:41PM +0100, Mel Gorman wrote:
> 
> When taking a fault for COW on a private mapping it is possible that the
> parent will have to steal the original page from its children due to an
> insufficient hugepage pool.  In this case, unmap_ref_private() is called
> for the faulting address to unmap via unmap_hugepage_range(). This patch
> ensures that the address used for unmapping is hugepage-aligned.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Andy Whitcroft <apw@shadowen.org>

Clearly far too many of our tests use page aligned accesss to trigger
behaviour.

>  mm/hugetlb.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-mm1-clean/mm/hugetlb.c linux-2.6.26-rc8-mm1-fix-needsreserve-check/mm/hugetlb.c
> --- linux-2.6.26-rc8-mm1-clean/mm/hugetlb.c	2008-07-08 11:54:34.000000000 -0700
> +++ linux-2.6.26-rc8-mm1-fix-needsreserve-check/mm/hugetlb.c	2008-07-08 15:50:00.000000000 -0700
> @@ -1767,6 +1767,7 @@ int unmap_ref_private(struct mm_struct *
>  	 * vm_pgoff is in PAGE_SIZE units, hence the different calculation
>  	 * from page cache lookup which is in HPAGE_SIZE units.
>  	 */
> +	address = address & huge_page_mask(hstate_vma(vma));
>  	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT)
>  		+ (vma->vm_pgoff >> PAGE_SHIFT);
>  	mapping = (struct address_space *)page_private(page);

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

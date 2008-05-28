Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SKrPfU000618
	for <linux-mm@kvack.org>; Wed, 28 May 2008 16:53:25 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SKrDSq114346
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:53:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SKrAUf005755
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:53:12 -0600
Subject: Re: [PATCH 3/3]
	hugetlb-allow-huge-page-mappings-to-be-created-without-reservations
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1211929806.0@pinky>
References: <exportbomb.1211929624@pinky>  <1211929806.0@pinky>
Content-Type: text/plain
Date: Wed, 28 May 2008 15:53:10 -0500
Message-Id: <1212007990.12036.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-28 at 00:10 +0100, Andy Whitcroft wrote:
> By default all shared mappings and most private mappings now
> have reservations associated with them.  This improves semantics by
> providing allocation guarentees to the mapper.  However a small number of
> applications may attempt to make very large sparse mappings, with these
> strict reservations the system will never be able to honour the mapping.
> 
> This patch set brings MAP_NORESERVE support to hugetlb files.
> This allows new mappings to be made to hugetlbfs files without an
> associated reservation, for both shared and private mappings.  This allows
> applications which want to create very sparse mappings to opt-out of the
> reservation system.  Obviously as there is no reservation they are liable
> to fault at runtime if the huge page pool becomes exhausted; buyer beware.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> ---
>  mm/hugetlb.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 55 insertions(+), 5 deletions(-)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 90a7f5f..118dc54 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -88,6 +88,9 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
>  /* Decrement the reserved pages in the hugepage pool by one */
>  static void decrement_hugepage_resv_vma(struct vm_area_struct *vma)
>  {
> +	if (vma->vm_flags & VM_NORESERVE)
> +		return;
> +
>  	if (vma->vm_flags & VM_SHARED) {
>  		/* Shared mappings always use reserves */
>  		resv_huge_pages--;
> @@ -682,25 +685,67 @@ static long region_truncate(struct list_head *head, long end)
>  	return chg;
>  }
> 
> +/*
> + * Determine if the huge page at addr within the vma has an associated
> + * reservation.  Where it does not we will need to logically increase
> + * reservation and actually increase quota before an allocation can occur.
> + * Where any new reservation would be required the reservation change is
> + * prepared, but not committed.  Once the page has been quota'd allocated
> + * an instantiated the change should be committed via vma_commit_reservation.
> + * No action is required on failure.
> + */
> +static int vma_needs_reservation(struct vm_area_struct *vma, unsigned long addr)

To me, this function has an odd name and led to some confusion when I
read the patch.  This naming suggests that the function determines
_whether_or_not_ a particular page requires a reservation when in fact
it is determining a number of pages required and then (to use your
wording in the comments) prepares said reservation.  Could we rename it
to vma_prepare_reservation() or something?  I feel that would also align
it with vma_commit_reservation() a bit more.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

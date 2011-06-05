Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 771236B0117
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 18:13:47 -0400 (EDT)
Date: Sun, 5 Jun 2011 23:13:44 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: ENOSPC returned by handle_mm_fault()
Message-ID: <20110605221344.GJ11521@ZenIV.linux.org.uk>
References: <20110605134317.GF11521@ZenIV.linux.org.uk>
 <alpine.LSU.2.00.1106051141570.5792@sister.anvils>
 <20110605195025.GH11521@ZenIV.linux.org.uk>
 <alpine.LSU.2.00.1106051339001.8317@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106051339001.8317@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org

On Sun, Jun 05, 2011 at 01:48:55PM -0700, Hugh Dickins wrote:
> On Sun, 5 Jun 2011, Al Viro wrote:
> > On Sun, Jun 05, 2011 at 12:16:08PM -0700, Hugh Dickins wrote:
> > 
> > > Good find, news to me.  Interesting uses of -PTR_ERR()!
> > 
> > You mean, something like the diff below?
> 
> Second hunk yes, but first hunk no: there's at least one other place
> (hugetlb_reserve_pages) which calls region_chg(), and expects a
> conventional -errno return from it; and even if there weren't,
> I'd rather not spread these unconventional return values any deeper.

Umm...  FWIW, callers of hugetlb_reserve_pages() only check if it's 0;
exact value is lost.  But yes, I agree that your variant makes more
sense - they might start caring at some point.

> Signed-off-by: Hugh Dickins <hughd@google.com
Acked-by: Al Viro <viro@zeniv.linux.org.uk>

>  mm/hugetlb.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- 3.0-rc1/mm/hugetlb.c	2011-05-29 18:42:37.425882575 -0700
> +++ linux/mm/hugetlb.c	2011-06-05 13:33:22.795341004 -0700
> @@ -1033,10 +1033,10 @@ static struct page *alloc_huge_page(stru
>  	 */
>  	chg = vma_needs_reservation(h, vma, addr);
>  	if (chg < 0)
> -		return ERR_PTR(chg);
> +		return ERR_PTR(-VM_FAULT_OOM);
>  	if (chg)
>  		if (hugetlb_get_quota(inode->i_mapping, chg))
> -			return ERR_PTR(-ENOSPC);
> +			return ERR_PTR(-VM_FAULT_SIGBUS);
>  
>  	spin_lock(&hugetlb_lock);
>  	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

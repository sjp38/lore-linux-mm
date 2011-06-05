Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBF66B0115
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 16:49:07 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p55Kn3xg032365
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 13:49:04 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe14.cbf.corp.google.com with ESMTP id p55Kn1xN000922
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 13:49:01 -0700
Received: by pzk30 with SMTP id 30so1689808pzk.4
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 13:49:01 -0700 (PDT)
Date: Sun, 5 Jun 2011 13:48:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: ENOSPC returned by handle_mm_fault()
In-Reply-To: <20110605195025.GH11521@ZenIV.linux.org.uk>
Message-ID: <alpine.LSU.2.00.1106051339001.8317@sister.anvils>
References: <20110605134317.GF11521@ZenIV.linux.org.uk> <alpine.LSU.2.00.1106051141570.5792@sister.anvils> <20110605195025.GH11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org

On Sun, 5 Jun 2011, Al Viro wrote:
> On Sun, Jun 05, 2011 at 12:16:08PM -0700, Hugh Dickins wrote:
> 
> > Good find, news to me.  Interesting uses of -PTR_ERR()!
> 
> You mean, something like the diff below?

Second hunk yes, but first hunk no: there's at least one other place
(hugetlb_reserve_pages) which calls region_chg(), and expects a
conventional -errno return from it; and even if there weren't,
I'd rather not spread these unconventional return values any deeper.

Something more like the one at the bottom I think: okay, it's slightly
tacky to assume the nature of the failure from vma_needs_reservation(),
but we already have two places which do make that assumption.

> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f33bb31..3de23f0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -125,7 +125,7 @@ static long region_chg(struct list_head *head, long f, long t)
>  	if (&rg->link == head || t < rg->from) {
>  		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
>  		if (!nrg)
> -			return -ENOMEM;
> +			return -VM_FAULT_OOM;
>  		nrg->from = f;
>  		nrg->to   = f;
>  		INIT_LIST_HEAD(&nrg->link);
> @@ -1036,7 +1036,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		return ERR_PTR(chg);
>  	if (chg)
>  		if (hugetlb_get_quota(inode->i_mapping, chg))
> -			return ERR_PTR(-ENOSPC);
> +			return ERR_PTR(-VM_FAULT_SIGBUS);
>  
>  	spin_lock(&hugetlb_lock);
>  	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);

Signed-off-by: Hugh Dickins <hughd@google.com
---

 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 3.0-rc1/mm/hugetlb.c	2011-05-29 18:42:37.425882575 -0700
+++ linux/mm/hugetlb.c	2011-06-05 13:33:22.795341004 -0700
@@ -1033,10 +1033,10 @@ static struct page *alloc_huge_page(stru
 	 */
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
-		return ERR_PTR(chg);
+		return ERR_PTR(-VM_FAULT_OOM);
 	if (chg)
 		if (hugetlb_get_quota(inode->i_mapping, chg))
-			return ERR_PTR(-ENOSPC);
+			return ERR_PTR(-VM_FAULT_SIGBUS);
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

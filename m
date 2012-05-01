Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A50D46B0081
	for <linux-mm@kvack.org>; Tue,  1 May 2012 11:43:25 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3043205pbb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 08:43:25 -0700 (PDT)
Date: Tue, 1 May 2012 08:43:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() ->
 hugetlb_cow()
In-Reply-To: <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
Message-ID: <alpine.LSU.2.00.1205010834310.27480@eggly.anvils>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com> <alpine.LSU.2.00.1204301308090.2829@eggly.anvils> <20120501131413.GA11435@suse.de> <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 29 Apr 2012, Chris Metcalf wrote:

No, Chris wrote this version on Mon, 30 Apr 2012, but gmail,
or its intereaction with imap, is too confused to grasp that.

> Commit 66aebce747eaf added code to avoid a race condition by
> elevating the page refcount in hugetlb_fault() while calling
> hugetlb_cow().  However, one code path in hugetlb_cow() includes
> an assertion that the page count is 1, whereas it may now also
> have the value 2 in this path.  Consensus is that this BUG_ON
> has served its purpose, so rather than extending it to cover both
> cases, we just remove it.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org

It is rather important that we Cc stable on this, since the
earlier fix triggering this BUG went out in 3.0.29, 3.2.16 and 3.3.3
stable.  Sadly, 3.2.16 was the end of the 3.2 line...

> ---
>  mm/hugetlb.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index cd65cb1..baaad5d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2498,7 +2498,6 @@ retry_avoidcopy:
>  		if (outside_reserve) {
>  			BUG_ON(huge_pte_none(pte));
>  			if (unmap_ref_private(mm, vma, old_page, address)) {
> -				BUG_ON(page_count(old_page) != 1);
>  				BUG_ON(huge_pte_none(pte));
>  				spin_lock(&mm->page_table_lock);
>  				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> -- 
> 1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

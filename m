Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B9C4990013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:40:39 -0400 (EDT)
Date: Tue, 21 Jun 2011 15:38:00 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2 V2] ksm: take dirty bit as reference to avoid
 volatile pages scanning
Message-ID: <20110621223800.GO25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212136.17445.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106212136.17445.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

* Nai Xia (nai.xia@gmail.com) wrote:
> Introduced ksm_page_changed() to reference the dirty bit of a pte. We clear 
> the dirty bit for each pte scanned but don't flush the tlb. For a huge page, 
> if one of the subpage has changed, we try to skip the whole huge page 
> assuming(this is true by now) that ksmd linearly scans the address space.

This doesn't build w/ kvm as a module.

> A NEW_FLAG is also introduced as a status of rmap_item to make ksmd scan
> more aggressively for new VMAs - only skip the pages considered to be volatile
> by the dirty bits. This can be enabled/disabled through KSM's sysfs interface.

This seems like it should be separated out.  And while it might be useful
to enable/disable for testing, I don't think it's worth supporting for
the long term.  Would also be useful to see the value of this flag.

> @@ -454,7 +468,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  		else
>  			ksm_pages_shared--;
>  		put_anon_vma(rmap_item->anon_vma);
> -		rmap_item->address &= PAGE_MASK;
> +		rmap_item->address &= ~STABLE_FLAG;
>  		cond_resched();
>  	}
>  
> @@ -542,7 +556,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  			ksm_pages_shared--;
>  
>  		put_anon_vma(rmap_item->anon_vma);
> -		rmap_item->address &= PAGE_MASK;
> +		rmap_item->address &= ~STABLE_FLAG;
>  
>  	} else if (rmap_item->address & UNSTABLE_FLAG) {
>  		unsigned char age;
> @@ -554,12 +568,14 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  		 * than left over from before.
>  		 */
>  		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
> -		BUG_ON(age > 1);
> +		BUG_ON (age > 1);

No need to add space after BUG_ON() there

> +
>  		if (!age)
>  			rb_erase(&rmap_item->node, &root_unstable_tree);
>  
>  		ksm_pages_unshared--;
> -		rmap_item->address &= PAGE_MASK;
> +		rmap_item->address &= ~UNSTABLE_FLAG;
> +		rmap_item->address &= ~SEQNR_MASK;

None of these changes are needed AFAICT.  &= PAGE_MASK clears all
relevant bits.  How could it be in a tree, have NEW_FLAG set, and
while removing from tree want to preserve NEW_FLAG?

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

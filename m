Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E8B056B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 10:29:30 -0400 (EDT)
Date: Sun, 12 Jul 2009 15:44:33 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: KSM: current madvise rollup
In-Reply-To: <20090712002219.502540d2@woof.woof>
Message-ID: <Pine.LNX.4.64.0907121459150.7417@sister.anvils>
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
 <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils>
 <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
 <4A4B317F.4050100@redhat.com> <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
 <4A57C3D1.7000407@redhat.com> <Pine.LNX.4.64.0907111916001.30651@sister.anvils>
 <20090712002219.502540d2@woof.woof>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Jul 2009, Izik Eidus wrote:
> On Sat, 11 Jul 2009 20:22:11 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > We may want to do that anyway.  It concerned me a lot when I was
> > first testing (and often saw kernel_pages_allocated greater than
> > pages_shared - probably because of the original KSM's eagerness to
> > merge forked pages, though I think there may have been more to it
> > than that).  But seems much less of an issue now (that ratio is much
> > healthier), and even less of an issue once KSM pages can be swapped.
> > So I'm not bothering about it at the moment, but it may make sense.

I realized since writing that with the current statistics you really
cannot tell how big an issue the orphaned (count 1) KSM pages are -
good sharing of a few will completely hide non-sharing of many.

But I've hacked in more stats (not something I'd care to share yet!),
and those confirm that for my loads at least, the orphaned KSM pages
are few compared with the shared ones.

> 
> We could add patch like the below, but I think we should leave it as it
> is now,

I agree we should leave it as is for now.  My guess is that we'll
prefer to leave them around, until approaching max_kernel_pages_alloc,
pruning them only at that stage (rather as we free swap more aggressively
when it's 50% full).  There may be benefit in not removing them too soon,
there may be benefit in holding on to stable pages for longer (holding a
reference in the stable tree for a while).  Or maybe not, just an idea.

> and solve it all (like you have said) with the ksm pages
> swapping support in next kernel release.
> (Right now ksm can limit itself with max_kernel_pages_alloc)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index a0fbdb2..ee80861 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1261,8 +1261,13 @@ static void ksm_do_scan(unsigned int scan_npages)
>  		rmap_item = scan_get_next_rmap_item(&page);
>  		if (!rmap_item)
>  			return;
> -		if (!PageKsm(page) || !in_stable_tree(rmap_item))
> +		if (!PageKsm(page) || !in_stable_tree(rmap_item)) {
>  			cmp_and_merge_page(page, rmap_item);
> +		} else if (page_mapcount(page) == 0) {

If we did that (but we agree not for now), shouldn't it be
			   page_mapcount(page) == 1
?  The mapcount 0 ones already got freed by the zap/unmap code.

> +			break_cow(rmap_item->mm,
> +				  rmap_item->address & PAGE_MASK);

Just a note on that " & PAGE_MASK": it's unnecessary there and
almost everywhere else.  One of the pleasures of putting flags into
the bottom bits of the address, in code concerned with faulting, is
that the faulting address can be anywhere within the page, so we
don't have to bother to mask off the flags.

> +			remove_rmap_item_from_tree(rmap_item);
> +		}
>  		put_page(page);
>  	}
>  }
> 
> > Oh, something that might be making it higher, that I didn't highlight
> > (and can revert if you like, it was just more straightforward this
> > way): with scan_get_next_rmap skipping the non-present ptes,
> > pages_to_scan is currently a limit on the _present_ pages scanned in
> > one batch.
> 
> You mean that now when you say: pages_to_scan = 512, it wont count the
> none present ptes as part of the counter, so if we have 500 not present
> ptes in the begining and then 512 ptes later, before it used to call
> cmp_and_merge_page() only for 12 pages while now it will get called on
> 512 pages?

If I understand you right, yes, before it would do those 500 absent then
512 present in two batches, first 512 (of which only 12 present) then 500;
whereas now it'll skip the 500 absent without counting them, and handle
the 512 present in that same one batch.

> 
> If yes, then I liked this change, it is more logical from cpu
> consumption point of view,

Yes, although it does spend a little time on the absent ones, it should
be much less time than it spends comparing or checksumming on present ones.

> and in addition we have that cond_reched()
> so I dont see a problem with this.

Right, that cond_resched() is vital in this case.

By the way, something else I didn't highlight, a significant benefit
from avoiding get_user_pages(): that was doing a mark_page_accessed()
on every present pte that it found, interfering with pageout decisions.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

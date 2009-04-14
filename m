Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D8C55F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 08:24:56 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Date: Tue, 14 Apr 2009 22:25:09 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <200904141925.46012.nickpiggin@yahoo.com.au> <2f11576a0904140502h295faf33qcea9a39ff7f230a5@mail.gmail.com>
In-Reply-To: <2f11576a0904140502h295faf33qcea9a39ff7f230a5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904142225.10788.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 14 April 2009 22:02:47 KOSAKI Motohiro wrote:
> > On Tuesday 14 April 2009 16:16:52 KOSAKI Motohiro wrote:
> >> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> >> @@ -547,7 +549,13 @@ int reuse_swap_page(struct page *page)
> >>                       SetPageDirty(page);
> >>               }
> >>       }
> >> -     return count == 1;
> >> +
> >> +     /*
> >> +      * If we can re-use the swap page _and_ the end
> >> +      * result has only one user (the mapping), then
> >> +      * we reuse the whole page
> >> +      */
> >> +     return count + page_count(page) == 2;
> >>  }
> >
> > I guess this patch does work to close the read-side race, but I slightly don't
> > like using page_count for things like this. page_count can be temporarily
> > raised for reasons other than access through their user mapping. Swapcache,
> > page reclaim, LRU pagevecs, concurrent do_wp_page, etc.
> 
> Yes, that's trade-off.
> your early decow also can misjudge and make unnecessary copy.

Yes indeed it can. Although it would only ever do so in case of pages
that have had get_user_pages run against them previously, and not from
random interactions from any other parts of the kernel.

I would be interested, using an anon vma field as you say for keeping
a gup count... it could potentially be used to avoid the extra copy.
But hmm, I don't have much time to go down that path so long as the
basic concept of my proposal is in question.


> >>       /*
> >> +      * Don't pull an anonymous page out from under get_user_pages.
> >> +      * GUP carefully breaks COW and raises page count (while holding
> >> +      * pte_lock, as we have here) to make sure that the page
> >> +      * cannot be freed.  If we unmap that page here, a user write
> >> +      * access to the virtual address will bring back the page, but
> >> +      * its raised count will (ironically) be taken to mean it's not
> >> +      * an exclusive swap page, do_wp_page will replace it by a copy
> >> +      * page, and the user never get to see the data GUP was holding
> >> +      * the original page for.
> >> +      *
> >> +      * This test is also useful for when swapoff (unuse_process) has
> >> +      * to drop page lock: its reference to the page stops existing
> >> +      * ptes from being unmapped, so swapoff can make progress.
> >> +      */
> >> +     if (PageSwapCache(page) &&
> >> +         page_count(page) != page_mapcount(page) + 2) {
> >> +             ret = SWAP_FAIL;
> >> +             goto out_unmap;
> >> +     }
> >
> > I guess it does add another constraint to the VM, ie. not allowed to
> > unmap an anonymous page with elevated refcount. Maybe not a big deal
> > now, but I think it is enough that it should be noted. If you squint,
> > this could actually be more complex/intrusive to the wider VM than my
> > copy on fork (which is basically exactly like a manual do_wp_page at
> > fork time).
> 
> I agree this code effect widely kernel activity.
> but actually, in past days, the kernel did the same behavior. then
> almost core code is
> page_count checking safe.
> 
> but Yes, we need to afraid newer code don't works with this code...
> 
> 
> > And.... I don't think this is safe against a concurrent gup_fast()
> > (which helps my point).
> 
> Could you please explain more detail ?
> 

+     if (PageSwapCache(page) &&
+         page_count(page) != page_mapcount(page) + 2) {
+             ret = SWAP_FAIL;
+             goto out_unmap;
+     }

Now if another thread does a get_user_pages_fast after it passes this
check, it can take a gup reference to the page which is now about to
be unmapped. Then after it is unmapped, if a wp fault is caused on the
page, then it will not be reused and thus you lose data as explained
in your big comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

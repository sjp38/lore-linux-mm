Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 45C1B6B004F
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 17:09:34 -0400 (EDT)
Date: Sun, 12 Jul 2009 00:22:19 +0300
From: Izik Eidus <ieidus@redhat.com>
Subject: Re: KSM: current madvise rollup
Message-ID: <20090712002219.502540d2@woof.woof>
In-Reply-To: <Pine.LNX.4.64.0907111916001.30651@sister.anvils>
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
	<4A49E051.1080400@redhat.com>
	<Pine.LNX.4.64.0906301518370.967@sister.anvils>
	<4A4A5C56.5000109@redhat.com>
	<Pine.LNX.4.64.0907010057320.4255@sister.anvils>
	<4A4B317F.4050100@redhat.com>
	<Pine.LNX.4.64.0907082035400.10356@sister.anvils>
	<4A57C3D1.7000407@redhat.com>
	<Pine.LNX.4.64.0907111916001.30651@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Jul 2009 20:22:11 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:


> I think it becomes quite a big subject, and you may be able to
> excite other people with it.

Yea, I agree, I dropped this patch, I think i have idea how to mange
it from userspace in a much better way for the kvm case.

> 
> > 
> > To make the second method thing work as much as reaible as we can
> > we would want to break KsmPages that have just one mapping into
> > them...
> 
> We may want to do that anyway.  It concerned me a lot when I was
> first testing (and often saw kernel_pages_allocated greater than
> pages_shared - probably because of the original KSM's eagerness to
> merge forked pages, though I think there may have been more to it
> than that).  But seems much less of an issue now (that ratio is much
> healthier), and even less of an issue once KSM pages can be swapped.
> So I'm not bothering about it at the moment, but it may make sense.
> 

We could add patch like the below, but I think we should leave it as it
is now, and solve it all (like you have said) with the ksm pages
swapping support in next kernel release.
(Right now ksm can limit itself with max_kernel_pages_alloc)

diff --git a/mm/ksm.c b/mm/ksm.c
index a0fbdb2..ee80861 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1261,8 +1261,13 @@ static void ksm_do_scan(unsigned int scan_npages)
 		rmap_item = scan_get_next_rmap_item(&page);
 		if (!rmap_item)
 			return;
-		if (!PageKsm(page) || !in_stable_tree(rmap_item))
+		if (!PageKsm(page) || !in_stable_tree(rmap_item)) {
 			cmp_and_merge_page(page, rmap_item);
+		} else if (page_mapcount(page) == 0) {
+			break_cow(rmap_item->mm,
+				  rmap_item->address & PAGE_MASK);
+			remove_rmap_item_from_tree(rmap_item);
+		}
 		put_page(page);
 	}
 }


> 
> I think you've resolved that as a non-issue, but is cpu still looking
> too high to you?  It looks high to me, but then I realize that I've
> tuned it to be high anyway.  Do you have any comparison against the
> /dev/ksm KSM, or your first madvise version?

I think I made myself to think it is to high, i ran it for 250 pages
scan each 10 millisecond, cpu usage was most of the time 1-4%, (beside
when it merged pages) - then the walking on the tree is longer, and if
it is the first page, we have addition memcpy of the page (into new
allocated page) - we can solve this issue, together with a big list of
optimizations that can come into ksm stable/unstable
algorithm/implemantion, in later releases of the kernel.

> 
> Oh, something that might be making it higher, that I didn't highlight
> (and can revert if you like, it was just more straightforward this
> way): with scan_get_next_rmap skipping the non-present ptes,
> pages_to_scan is currently a limit on the _present_ pages scanned in
> one batch.

You mean that now when you say: pages_to_scan = 512, it wont count the
none present ptes as part of the counter, so if we have 500 not present
ptes in the begining and then 512 ptes later, before it used to call
cmp_and_merge_page() only for 12 pages while now it will get called on
512 pages?

If yes, then I liked this change, it is more logical from cpu
consumption point of view, and in addition we have that cond_reched()
so I dont see a problem with this.

Thanks.

> 
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

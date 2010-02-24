Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9B4BA6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:52:15 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: s2disk hang update
Date: Wed, 24 Feb 2010 21:52:55 +0100
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com> <201002232213.56455.rjw@sisk.pl> <9b2b86521002240823t126d5ad8nbd292da0f4090e6c@mail.gmail.com>
In-Reply-To: <9b2b86521002240823t126d5ad8nbd292da0f4090e6c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Message-Id: <201002242152.55408.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 24 February 2010, Alan Jenkins wrote:
> On 2/23/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
...
> > My guess is that the preallocated memory pages freed by
> > free_unnecessary_pages() go into a place from where they cannot be taken for
> > subsequent NOIO allocations.  I have no idea why that happens though.
> >
> > To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
> > calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
> > kernel/power/suspend.c for completness).
> 
> Effectively forcing GFP_NOWAIT, so the allocation should fail instead
> of hanging?
> 
> It seems to stop the hang, but I don't see any other difference - the
> hibernation process isn't stopped earlier, and I don't get any new
> kernel messages about allocation failures.  I wonder if it's because
> GFP_NOWAIT triggers ALLOC_HARDER.
> 
> I have other evidence which argues for your theory:
> 
> [ successful s2disk, with forced NOIO (but not NOWAIT), and test code
> as attached ]
> 
>  Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
>  1280 GFP_NOWAIT allocations of order 0 are possible
>  640 GFP_NOWAIT allocations of order 1 are possible
>  320 GFP_NOWAIT allocations of order 2 are possible
> 
> [ note - 1280 pages is the maximum test allocation used here.  The
> test code is only accurate when talking about smaller numbers of free
> pages ]
> 
>  1280 GFP_KERNEL allocations of order 0 are possible
>  640 GFP_KERNEL allocations of order 1 are possible
>  320 GFP_KERNEL allocations of order 2 are possible
> 
>  PM: Preallocating image memory...
>  212 GFP_NOWAIT allocations of order 0 are possible
>  102 GFP_NOWAIT allocations of order 1 are possible
>  50 GFP_NOWAIT allocations of order 2 are possible
> 
>  Freeing all 90083 preallocated pages
>  (and 0 highmem pages, out of 0)
>  190 GFP_NOWAIT allocations of order 0 are possible
>  102 GFP_NOWAIT allocations of order 1 are possible
>  50 GFP_NOWAIT allocations of order 2 are possible
>  1280 GFP_KERNEL allocations of order 0 are possible
>  640 GFP_KERNEL allocations of order 1 are possible
>  320 GFP_KERNEL allocations of order 2 are possible
>  done (allocated 90083 pages)
> 
> It looks like you're right and the freed pages are not accessible with
> GFP_NOWAIT for some reason.

I'd expect this, really.  There only is a limited number of pages you can
allocate with GFP_NOWAIT.

> I also tried a number of test runs with too many applications, and saw this:
> 
> Freeing all 104006 preallocated pages ...
> 65 GFP_NOWAIT allocations of order 0 ...
> 18 GFP_NOWAIT allocations of order 1 ...
> 9 GFP_NOWAIT allocations of order 2 ...
> 0 GFP_KERNEL allocations of order 0 are possible
> ...

Now that's interesting.  We've just freed 104006 pages and we can't allocate
any, so where did all of these freed pages go, actually?

OK, I think I see what the problem is.  Quite embarassing, actually ...

Can you check if the patch below helps?

Rafael

---
 kernel/power/snapshot.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -1181,7 +1181,7 @@ static void free_unnecessary_pages(void)
 
 	memory_bm_position_reset(&copy_bm);
 
-	while (to_free_normal > 0 && to_free_highmem > 0) {
+	while (to_free_normal > 0 || to_free_highmem > 0) {
 		unsigned long pfn = memory_bm_next_pfn(&copy_bm);
 		struct page *page = pfn_to_page(pfn);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

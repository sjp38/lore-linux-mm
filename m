Received: from atlas.infra.CARNet.hr (zcalusic@atlas.infra.CARNet.hr [161.53.160.131])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA04461
	for <linux-mm@kvack.org>; Wed, 10 Dec 1997 08:20:47 -0500
Subject: Re: Ideas for memory management hackers.
References: <199712091611.RAA05335@boole.fs100.suse.de>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 10 Dec 1997 14:13:34 +0100
In-Reply-To: "Dr. Werner Fink"'s message of Tue, 9 Dec 1997 17:11:20 +0100
Message-ID: <87g1o1nxxd.fsf@atlas.infra.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Dr. Werner Fink" <werner@suse.de> writes:

> > 
> > I have integrated mmap aging in kswapd, without the need for
> > vhand, in 2.1.71 (experimental). As ppp isn't working in 2.1.71
> > I'm back to 2.1.66 now, but I have seen kswapd use over 10% of
> > CPU for short times now :(
> 
> Q: if ageing is now a separate part the CPU usage of freeing a page
>    in kswapd and __get_free_pages should drop, shouldn't it?
> 
> > I think I'll send it to Linus (together with Zlatko's
> > big-order hack) as a bug-fix (we're on feature-freeze after all:)
> > for inclusion in 2.1.72...
> > 
> > opinions please,
> 
> Q2: Is the patch available (ftp/http) for testing/reading?
> 

Due to a heavy demand... :)

Here it comes (comments below):



diff -urN linux-2.1.61/include/linux/swap.h linux/include/linux/swap.h
--- linux-2.1.61/include/linux/swap.h	Sat Oct 18 00:49:15 1997
+++ linux/include/linux/swap.h	Fri Oct 31 19:42:09 1997
@@ -34,6 +34,7 @@
 
 extern int nr_swap_pages;
 extern int nr_free_pages;
+extern int nr_free_pages_bigorder;
 extern atomic_t nr_async_pages;
 extern int min_free_pages;
 extern int free_pages_low;
diff -urN linux-2.1.61/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.1.61/mm/page_alloc.c	Tue Jun 17 01:36:01 1997
+++ linux/mm/page_alloc.c	Fri Oct 31 19:42:10 1997
@@ -30,6 +30,9 @@
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
 
+/* Number of the free pages in chunks of order 2 and bigger */
+int nr_free_pages_bigorder = 0;
+
 /*
  * Free area management
  *
@@ -118,12 +121,17 @@
 		if (!test_and_change_bit(index, area->map))
 			break;
 		remove_mem_queue(list(map_nr ^ -mask));
+		if (order >= 2)
+			nr_free_pages_bigorder -= 1 << order;
 		mask <<= 1;
+		order++;
 		area++;
 		index >>= 1;
 		map_nr &= mask;
 	}
 	add_mem_queue(area, list(map_nr));
+	if (order >= 2)
+		nr_free_pages_bigorder += 1 << order;
 
 #undef list
 
@@ -171,6 +179,8 @@
 				(prev->next = ret->next)->prev = prev; \
 				MARK_USED(map_nr, new_order, area); \
 				nr_free_pages -= 1 << order; \
+			        if (new_order >= 2) \
+				        nr_free_pages_bigorder -= 1 << new_order; \
 				EXPAND(ret, map_nr, order, new_order, area); \
 				spin_unlock_irqrestore(&page_alloc_lock, flags); \
 				return ADDRESS(map_nr); \
@@ -187,6 +197,8 @@
 		area--; high--; size >>= 1; \
 		add_mem_queue(area, map); \
 		MARK_USED(index, high, area); \
+		if (high >= 2) \
+		        nr_free_pages_bigorder += 1 << high; \
 		index += size; \
 		map += size; \
 	} \
diff -urN linux-2.1.61/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.1.61/mm/vmscan.c	Thu Oct 23 22:30:25 1997
+++ linux/mm/vmscan.c	Fri Oct 31 19:42:10 1997
@@ -465,7 +465,8 @@
 			pages = nr_free_pages;
 			if (nr_free_pages >= min_free_pages)
 				pages += atomic_read(&nr_async_pages);
-			if (pages >= free_pages_high)
+			if (pages >= free_pages_high &&
+				nr_free_pages_bigorder >= min_free_pages / 2)
 				break;
 			wait = (pages < free_pages_low);
 			if (try_to_free_page(GFP_KERNEL, 0, wait))
@@ -489,7 +490,7 @@
 	int want_wakeup = 0, memory_low = 0;
 	int pages = nr_free_pages + atomic_read(&nr_async_pages);
 
-	if (pages < free_pages_low)
+	if (pages < free_pages_low || nr_free_pages_bigorder < min_free_pages / 2)
 		memory_low = want_wakeup = 1;
 	else if (pages < free_pages_high && jiffies >= next_swap_jiffies)
 		want_wakeup = 1;



It was originally developed for 2.1.61, but it works perfectly on
2.1.71 (I just checked). It was posted on linux-kernel list during
recent problems (massive unsubscribe), so many people missed it.

Now some comments on the patch:

I had nasty lockups with all 2.1 kernels. I traced problem down to the
network stuff which was trying to allocate pages of order 2 what was
constantly failing. Problem was (and still is!) that Linux doesn't
swap pages out to get more free memory if it already has
free_pages_high or more free pages. Of course, it is correct
behaviour, but... sometimes memory is completely fragmented, and all
free chunks are of one or two pages, so there's no way you could get
16KB of contiguous memory (even if you have 512KB free!). Networking
can't proceed without that and if you're logged remotely you're in
fact completely disconnected.

The patch was my initial attempt to solve that problems, but in the
end I found that it had some other problems which I didn't like.
Many people that tried it, reported that their machines swapped much
more with patch applied. And I noticed it for myself, too. It is true
that exactly in that cases when Linux swaps out heavily to get bigger
chunks of memory, it would lockup without the patch, but in the end I
didn't liked the idea and abandoned work on that.

My opinion is that the problem is much bigger, and we will need much
more hard work to resolve it in the future.

That shouldn't stop anybody from experimenting with the patch, since
it is simple enough and thoroughly tested, so you won't have any
problems with it. If you don't count heavier swapping, that is. :)

My current workaround against network blockups is in mm/slab.c where I 
explicitely ask from slab allocator that it stop using such a big
memory chunks for small network buffers (mostly of ~1700 bytes in
size or less).

It works perfectly and nobody knows how (and if) it affects
the performance, but (so?) I'm happy. :)

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	   What has four legs and an arm? A happy pitbull.

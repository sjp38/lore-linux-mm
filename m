Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA25984
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 12:49:31 -0500
Received: from dragon.bogus (andrea@isdn33-imo.e-mind.com [195.223.140.43])
	by penguin.e-mind.com (8.9.1a/8.9.1/Debian/GNU) with ESMTP id SAA31629
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 18:49:17 +0100
Received: from localhost (andrea@localhost)
	by dragon.bogus (8.9.1a/8.9.1/Debian/GNU) with SMTP id SAA00257
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 18:40:11 +0100
Date: Tue, 1 Dec 1998 18:40:11 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.1.130 mem usage. (fwd)
Message-ID: <Pine.LNX.3.96.981201183922.243B-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I forget to post here too (now that I subscribed ;).

Andrea Arcangeli

---------- Forwarded message ----------
Date: Tue, 1 Dec 1998 18:12:05 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.1.130 mem usage.

I read now the latest mm changes from you, Stephen. So now we have only 1
bit to do page aging and we have an unused field in the mem_map_t.
Logically 32 bit can give us more info than one bit. Instead of waste 32
bit and use 1 bit, why we don' t drop the bit and use the 32 bit instead?
I can agree that having both PG_referenced in ->flags and ->age it' s not
a simple and clean approch. I can agree to use only 1 bit but sure I don'
t want the wasting the `unused' field in the mem_map_t ;). 

On Mon, 30 Nov 1998, Stephen C. Tweedie wrote:

>@@ -214,7 +214,15 @@
> 		if (shrink_one_page(page, gfp_mask))
> 			return 1;
> 		count_max--;
>-		if (page->inode || page->buffers)
>+		/* 
>+		 * If the page we looked at was recyclable but we didn't
>+		 * reclaim it (presumably due to PG_referenced), don't
>+		 * count it as scanned.  This way, the more referenced
>+		 * page cache pages we encounter, the more rapidly we
>+		 * will age them. 
>+		 */
>+		if (atomic_read(&page->count) != 1 ||
>+		    (!page->inode && !page->buffers))
> 			count_min--;

I don' t think count_min should count the number of tries on pages we have
no chance to free. It should be the opposite according to me.

I think that we should decrease count_min if:

	((page->inode || page->buffers) && atomic_read(->count) == 1)

is true instead. I am going to do this in my kernel now.

2.1.129 does also this (that will cause shrink_mmap() to be more light):

@@ -212,8 +207,8 @@
 	struct page * page;
 	int count_max, count_min;
 
-	count_max = (limit<<2) >> (priority>>1);
-	count_min = (limit<<2) >> (priority);
+	count_max = (limit<<1) >> (priority>>1);
+	count_min = (limit<<1) >> (priority);
 
 	page = mem_map + clock;
 	do {

2.1.130 does also this:

@@ -188,7 +180,7 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
-		free_page_and_swap_cache(page);
+		free_page(page);
 		return 1;	/* we slept: the process may not exist any
more */
 	}
 
Doing this we are not swapping out really I think, because the page now is
also on the hd, but it' s still in memory and so shrink_mmap() will have
the double of the work to do.

@@ -218,7 +210,7 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = page_unuse(page_map);
+	entry = (atomic_read(&page_map->count) == 1);
 	__free_page(page_map);
 	return entry;
 }

This will cause the double of work to shrink_mmap() too I think.

I' ll try to reverse these patches right now in my own tree.

Andrea Arcangeli


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

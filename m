Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA22804
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 08:06:48 -0500
Date: Mon, 21 Dec 1998 10:53:35 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812191709.RAA01245@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981221104034.591A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Dec 1998, Stephen C. Tweedie wrote:

>I've tried to port the best bits of that VM to 132-pre2, preserving your
>do_try_to_free_page state change, but so far I have not been able find a
>combination which gives anywhere near the overall performance of ac11
>for all of my test cases (although it works reasonably well on low
			   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>memory at first, until we start to fragment swap).

The good point of 132-pre2 is that you' ll never see a thread on linux
kernel that will say "132-pre2 VM performance jerky". It could be not
the best but sure will work well for everybody out there on every
hardware. 132-pre2 policy is "if you need great performance buy more
memory" swap will work fine but it' s not the default action. I agree to
help improving it though. 

>The patch below is the best I have so far against 132-pre2.  You will
>find that it has absolutely no references to the borrow percentages, and
>although it does honour the buffer/pgcache min percentages, those
>default to 1%.

I agree also to drop every borrow/max check in the kernel since we don' t
want a limit on the cache/buffer used until there is free memory. If a
special software need a lot of memory at once can grab it slowly and then
mlock it I think.

Index: linux/fs/buffer.c
diff -u linux/fs/buffer.c:1.1.1.1 linux/fs/buffer.c:1.1.1.1.2.1
--- linux/fs/buffer.c:1.1.1.1	Fri Nov 20 00:01:06 1998
+++ linux/fs/buffer.c	Thu Dec 17 22:35:20 1998
@@ -725,8 +725,7 @@
 	/* We are going to try to locate this much memory. */
 	needed = bdf_prm.b_un.nrefill * size;  
 
-	while ((nr_free_pages > freepages.min*2) &&
-	        !buffer_over_max() &&
+	while (free_memory_available() == 2 &&
 		grow_buffers(GFP_BUFFER, size)) {
 		obtained += PAGE_SIZE;
 		if (obtained >= needed)


Alternatively we could set the default of max to 90% or something
similar... probably it would be more tunable but I like more the
total autotuning approch...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

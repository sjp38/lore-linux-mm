Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA29188
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 04:33:24 -0500
Subject: Buffer handling (setting PG_referenced on access)
References: <Pine.LNX.3.95.990108223729.3436D-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 11 Jan 1999 10:21:28 +0100
In-Reply-To: Linus Torvalds's message of "Fri, 8 Jan 1999 22:44:25 -0800 (PST)"
Message-ID: <87k8yuupuv.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Dax Kelson <dkelson@inconnect.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> Btw, if there are people there who actually like timing different things
> (something I _hate_ doing - I lose interest if things become just a matter
> of numbers rather than trying to get some algorithm right), then there's
> one thing I'd love to hear about: the effect of trying to do some
> access bit setting on buffer cache pages.

OK, implementation was easy and simple, much simpler than it was made
before (with BH_Touched copying...), but I must admit that even after
lots of testing I couldn't find any difference. Not in performance,
not in CPU usage, not in overall behaviour. Whatever results I have
accomplished, they were too much in the statistical noise, so I don't
have any useful data. Maybe, others can try and see.

But, nevertheless, four lines added to the kernel look very correct to
me. My vote for including, if for nothing, then to make balance with
page cache. It won't harm anything, that's for sure. Patch applies
cleanly on pre-7, as found in testing directory on ftp.kernel.org.


Index: 2206.7/include/linux/fs.h
--- 2206.7/include/linux/fs.h Mon, 04 Jan 1999 17:24:06 +0100 zcalusic (linux-2.1/z/b/10_fs.h 1.1.5.1.1.3 644)
+++ 2206.8(w)/include/linux/fs.h Mon, 11 Jan 1999 08:31:48 +0100 zcalusic (linux-2.1/z/b/10_fs.h 1.1.5.1.1.3.1.1 644)
@@ -178,6 +178,9 @@
 #define BH_Req		3	/* 0 if the buffer has been invalidated */
 #define BH_Protected	6	/* 1 if the buffer is protected */
 
+#define buffer_page(bh)		(mem_map + MAP_NR((bh)->b_data))
+#define touch_buffer(bh)	set_bit(PG_referenced, &buffer_page(bh)->flags)
+
 /*
  * Try to keep the most commonly used fields in single cache lines (16
  * bytes) to improve performance.  This ordering should be
@@ -250,19 +253,6 @@
 {
 	return test_bit(BH_Protected, &bh->b_state);
 }
-
-/*
- * Deprecated - we don't keep per-buffer reference flags
- * any more.
- *
- * We _could_ try to update the page reference, but that
- * doesn't seem to really be worth it either. If we did,
- * it would look something like this:
- *
- *	#define buffer_page(bh)		(mem_map + MAP_NR((bh)->b_data))
- *	#define touch_buffer(bh)	set_bit(PG_referenced, &buffer_page(bh)->flags)
- */
-#define touch_buffer(bh)	do { } while (0)
 
 #include <linux/pipe_fs_i.h>
 #include <linux/minix_fs_i.h>
Index: 2206.7/fs/buffer.c
--- 2206.7/fs/buffer.c Sat, 09 Jan 1999 03:44:23 +0100 zcalusic (linux-2.1/G/b/41_buffer.c 1.1.1.1.1.3.2.1.2.1 644)
+++ 2206.8(w)/fs/buffer.c Mon, 11 Jan 1999 08:31:48 +0100 zcalusic (linux-2.1/G/b/41_buffer.c 1.1.1.1.1.3.2.1.2.1.1.1 644)
@@ -737,6 +737,7 @@
 				 put_last_lru(bh);
 			bh->b_flushtime = 0;
 		}
+		touch_buffer(bh);
 		return bh;
 	}
 
@@ -754,6 +755,7 @@
 	bh->b_lru_time	= jiffies;
 	bh->b_state=0;
 	insert_into_queues(bh);
+	touch_buffer(bh);
 	return bh;
 
 	/*

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

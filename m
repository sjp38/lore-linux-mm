Date: Tue, 7 Aug 2001 16:36:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33L.0108071621180.1439-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0108071627360.32481-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just a quick follow-up: Leonard reports that the problem seems fixed in
-pre6, which matches my hypothesis that it was refill_freelist() that just
didn't end up causing enough memory movement.

So pre6 (together with the balance_dirty() fix that Ben tested out) might
be getting closer to where we want to be again...

Also, my own testing indicates that we should _not_ wake up bdflush too
early, as that just seems to cause more context switches and more queue
flushing. Delaying it until we really need it seems to be better, and also
makes more sense anyway (this makes bdflush work as an anti-hysteresis
thing, instead of working just at the border of "maybe enough memory").

Patch appended (this does not do the highmem fix that Ben has).

(And Leonard also pointed out that I forgot to bump the version number).

		Linus

-----
diff -u --recursive --new-file pre6/linux/Makefile linux/Makefile
--- pre6/linux/Makefile	Tue Aug  7 16:16:00 2001
+++ linux/Makefile	Tue Aug  7 16:12:28 2001
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 4
 SUBLEVEL = 8
-EXTRAVERSION =-pre5
+EXTRAVERSION =-pre6

 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

diff -u --recursive --new-file pre6/linux/fs/buffer.c linux/fs/buffer.c
--- pre6/linux/fs/buffer.c	Tue Aug  7 16:16:02 2001
+++ linux/fs/buffer.c	Tue Aug  7 14:36:27 2001
@@ -1116,15 +1116,17 @@
 	/* If we're getting into imbalance, start write-out */
 	spin_lock(&lru_list_lock);
 	write_some_buffers(dev);
-	wakeup_bdflush();

 	/*
 	 * And if we're _really_ out of balance, wait for
-	 * some of the dirty/locked buffers ourselves.
+	 * some of the dirty/locked buffers ourselves and
+	 * start bdflush.
 	 * This will throttle heavy writers.
 	 */
-	if (state > 0)
+	if (state > 0) {
 		wait_for_some_buffers(dev);
+		wakeup_bdflush();
+	}
 }

 static __inline__ void __mark_dirty(struct buffer_head *bh)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Tue, 16 May 2000 16:32:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [dirtypatch] quickhack to make pre8/9 behave (fwd)
Message-ID: <Pine.LNX.4.21.0005161631320.32026-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

[ARGHHH, this time -with- patch, thanks RogerL]

Hi,

with the quick&dirty patch below the system:
- gracefully (more or less) survives mmap002
- has good performance on mmap002

To me this patch shows that we really want to wait
for dirty page IO to finish before randomly evicting
the (wrong) clean pages and dying horribly.

This is a dirty hack which should be replaced by whichever
solution people thing should be implemented to have the
allocator waiting for dirty pages to be flushed out.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- fs/buffer.c.orig	Mon May 15 09:49:46 2000
+++ fs/buffer.c	Tue May 16 14:53:08 2000
@@ -2124,11 +2124,16 @@
 static void sync_page_buffers(struct buffer_head *bh)
 {
 	struct buffer_head * tmp;
+	static int rand = 0;
+	if (++rand > 64)
+		rand = 0;
 
 	tmp = bh;
 	do {
 		struct buffer_head *p = tmp;
 		tmp = tmp->b_this_page;
+		if (buffer_locked(p) && !rand)
+			__wait_on_buffer(p);
 		if (buffer_dirty(p) && !buffer_locked(p))
 			ll_rw_block(WRITE, 1, &p);
 	} while (tmp != bh);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Tue, 15 May 2001 01:41:23 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] remove page_launder() from bdflush
Message-ID: <Pine.LNX.4.21.0105150134190.32493-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus, 

There is no reason why bdflush should call page_launder().

Its pretty obvious that bdflush's job is to only write out _buffers_. 

Under my tests this patch makes things faster.

Guess why? Because bdflush is writing out buffers when it should instead
blocking inside try_to_free_pages().

Please apply. 

--- fs/buffer.c.orig    Tue May 15 03:13:05 2001
+++ fs/buffer.c Tue May 15 03:13:22 2001
@@ -2703,8 +2703,6 @@
                CHECK_EMERGENCY_SYNC
 
                flushed = flush_dirty_buffers(0);
-               if (free_shortage())
-                       flushed += page_launder(GFP_KERNEL, 0);
 
                /*
                 * If there are still a lot of dirty buffers around,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

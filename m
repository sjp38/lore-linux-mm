Date: Thu, 1 Mar 2001 19:31:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] oom-killer trigger
Message-ID: <Pine.LNX.4.33.0103011904140.1304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, =?ISO-8859-1?Q?Xos=C9_V=E1zquez?= <xose@smi-ps.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

the OOM killer in Linux 2.4 has a rather embarrasing bug.

1. the OOM killer never triggers if we have > freepages.min
   of free memory
2. __alloc_pages() never allocates pages to < freepages.min
   for user allocations

==> the OOM killer never gets triggered under some workloads;
    the system just sits around with nr_free_pages == freepages.min

The patch below trivially fixes this by upping the OOM kill limit
by a really small number of pages ...

Now lets hope it won't trigger too early (but since it'll only
trigger when we're completely out of swap, etc...).

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--- mm/oom_kill.c.orig	Thu Mar  1 18:57:11 2001
+++ mm/oom_kill.c	Thu Mar  1 18:58:23 2001
@@ -188,13 +188,17 @@
  *
  * Returns 0 if there is still enough memory left,
  * 1 when we are out of memory (otherwise).
+ *
+ * Note that since __alloc_pages() never lets user
+ * allocations go below freepages.min, we have to
+ * use a slightly higher threshold here...
  */
 int out_of_memory(void)
 {
 	struct sysinfo swp_info;

 	/* Enough free memory?  Not OOM. */
-	if (nr_free_pages() > freepages.min)
+	if (nr_free_pages() > freepages.min + 4)
 		return 0;

 	if (nr_free_pages() + nr_inactive_clean_pages() > freepages.low)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

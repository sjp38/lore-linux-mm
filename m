Received: from toomuch.toronto.redhat.com (IDENT:bcrl@toomuch.toronto.redhat.com [172.16.14.22])
	by devserv.devel.redhat.com (8.11.0/8.11.0) with ESMTP id f85JcwO09100
	for <linux-mm@kvack.org>; Wed, 5 Sep 2001 15:38:58 -0400
Date: Wed, 5 Sep 2001 15:38:57 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] /proc/meminfo (fwd)
Message-ID: <Pine.LNX.4.33.0109051538400.16684-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Oops, forgot to cc linux-mm.

		-ben

-- 
"The world would be a better place if Larry Wall had been born in
Iceland, or any other country where the native language actually
has syntax" -- Peter da Silva

---------- Forwarded message ----------
Date: Wed, 5 Sep 2001 15:26:36 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>
Subject: [PATCH] /proc/meminfo

Heyo,

Below is a patch to fix overflows in /proc/meminfo on machines with lots
of highmem.  I wish I had 64GB.  Dell was right -- I was reading the
MemTotal: line automatically instead of Mem:.

		-ben

diff -urN v2.4.9-ac8/fs/proc/proc_misc.c work-v2.4.9-ac8/fs/proc/proc_misc.c
--- v2.4.9-ac8/fs/proc/proc_misc.c	Wed Sep  5 15:13:56 2001
+++ work-v2.4.9-ac8/fs/proc/proc_misc.c	Wed Sep  5 15:16:47 2001
@@ -147,13 +147,13 @@
 /*
  * display in kilobytes.
  */
-#define K(x) ((x) << (PAGE_SHIFT - 10))
-#define B(x) ((x) << PAGE_SHIFT)
+#define K(x) ((unsigned long)(x) << (PAGE_SHIFT - 10))
+#define B(x) ((unsigned long long)(x) << PAGE_SHIFT)
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	len = sprintf(page, "        total:    used:    free:  shared: buffers:  cached:\n"
-		"Mem:  %8lu %8lu %8lu %8lu %8lu %8u\n"
-		"Swap: %8lu %8lu %8lu\n",
+		"Mem:  %8Lu %8Lu %8Lu %8Lu %8Lu %8Lu\n"
+		"Swap: %8Lu %8Lu %8Lu\n",
 		B(i.totalram), B(i.totalram-i.freeram), B(i.freeram),
 		B(i.sharedram), B(i.bufferram),
 		B(cached), B(i.totalswap),
@@ -170,10 +170,10 @@
 		"Buffers:      %8lu kB\n"
 		"Cached:       %8lu kB\n"
 		"SwapCached:   %8lu kB\n"
-		"Active:       %8u kB\n"
-		"Inact_dirty:  %8u kB\n"
-		"Inact_clean:  %8u kB\n"
-		"Inact_target: %8u kB\n"
+		"Active:       %8lu kB\n"
+		"Inact_dirty:  %8lu kB\n"
+		"Inact_clean:  %8lu kB\n"
+		"Inact_target: %8lu kB\n"
 		"HighTotal:    %8lu kB\n"
 		"HighFree:     %8lu kB\n"
 		"LowTotal:     %8lu kB\n"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

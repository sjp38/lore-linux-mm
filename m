Date: Tue, 17 Aug 1999 00:47:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This incremental (against bigmem-2.3.13-L) patch will fix the ptrace and
/proc/*/mem read/writes to other process VM inside the kernel.

diff -urN 2.3.13-bigmem-L/fs/proc/mem.c tmp/fs/proc/mem.c
--- 2.3.13-bigmem-L/fs/proc/mem.c	Tue Jul 13 02:02:09 1999
+++ tmp/fs/proc/mem.c	Tue Aug 17 00:02:48 1999
@@ -15,6 +15,9 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/pgtable.h>
+#ifdef CONFIG_BIGMEM
+#include <asm/bigmem.h>
+#endif
 
 /*
  * mem_write isn't really a good idea right now. It needs
@@ -120,7 +123,13 @@
 		i = PAGE_SIZE-(addr & ~PAGE_MASK);
 		if (i > scount)
 			i = scount;
+#ifdef CONFIG_BIGMEM
+		page = (char *) kmap((unsigned long) page, KM_READ);
+#endif
 		copy_to_user(tmp, page, i);
+#ifdef CONFIG_BIGMEM
+		kunmap((unsigned long) page, KM_READ);
+#endif
 		addr += i;
 		tmp += i;
 		scount -= i;
@@ -177,7 +186,13 @@
 		i = PAGE_SIZE-(addr & ~PAGE_MASK);
 		if (i > count)
 			i = count;
+#ifdef CONFIG_BIGMEM
+		page = (unsigned long) kmap((unsigned long) page, KM_WRITE);
+#endif
 		copy_from_user(page, tmp, i);
+#ifdef CONFIG_BIGMEM
+		kunmap((unsigned long) page, KM_WRITE);
+#endif
 		addr += i;
 		tmp += i;
 		count -= i;
diff -urN 2.3.13-bigmem-L/kernel/ptrace.c tmp/kernel/ptrace.c
--- 2.3.13-bigmem-L/kernel/ptrace.c	Thu Jul 22 01:07:28 1999
+++ tmp/kernel/ptrace.c	Tue Aug 17 00:02:40 1999
@@ -13,6 +13,9 @@
 
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
+#ifdef CONFIG_BIGMEM
+#include <asm/bigmem.h>
+#endif
 
 /*
  * Access another process' address space, one page at a time.
@@ -52,7 +55,15 @@
 			dst = src;
 			src = buf;
 		}
+#ifdef CONFIG_BIGMEM
+		src = (void *) kmap((unsigned long) src, KM_READ);
+		dst = (void *) kmap((unsigned long) dst, KM_WRITE);
+#endif
 		memcpy(dst, src, len);
+#ifdef CONFIG_BIGMEM
+		kunmap((unsigned long) src, KM_READ);
+		kunmap((unsigned long) dst, KM_WRITE);
+#endif
 	}
 	flush_page_to_ram(page);
 	return len;

The /proc/*/mem read/write seems to not work though (maybe I am doing
something wrong...).

black:/home/andrea# cat /proc/1/mem 
cat: /proc/1/mem: No such process

The same happens also on 2.2.11.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

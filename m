From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911090324.TAA27308@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm26-2.3.26 Fix nonPAE kernel panics
Date: Mon, 8 Nov 1999 19:24:45 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

Please put this patch into 2.3.27. It prevents a nonPAE kernel from
attempting to use >4Gb physical memory, if the ia32 box has that
much. My non PAE kernel is now able to multiuser boot my ia32 box
which has slightly more than 4Gb RAM.

Also, add in helpful messages for sysadmins, so that they can create
the best possible kernel for their ia32 boxes.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a006bj/setup.c	Mon Nov  8 19:22:00 1999
+++ arch/i386/kernel/setup.c	Mon Nov  8 18:17:08 1999
@@ -583,6 +583,7 @@
 #define VMALLOC_RESERVE	(unsigned long)(128 << 20)
 #define MAXMEM		(unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE)
 #define MAXMEM_PFN	PFN_DOWN(MAXMEM)
+#define MAX_NONPAE_PFN	(1 << 20)
 
 	/*
 	 * partially used pages are not usable - thus
@@ -608,8 +609,26 @@
 	 * Determine low and high memory ranges:
 	 */
 	max_low_pfn = max_pfn;
-	if (max_low_pfn > MAXMEM_PFN)
+	if (max_low_pfn > MAXMEM_PFN) {
 		max_low_pfn = MAXMEM_PFN;
+#ifndef CONFIG_HIGHMEM
+		/* Maximum memory usable is what is directly addressable */
+		printk(KERN_WARNING "Warning only %ldMB will be used.\n",
+					MAXMEM>>20);
+		if (max_pfn > MAX_NONPAE_PFN)
+			printk(KERN_WARNING "Use a PAE enabled kernel.\n");
+		else
+			printk(KERN_WARNING "Use a HIGHMEM enabled kernel.\n");
+#else /* !CONFIG_HIGHMEM */
+#ifndef CONFIG_X86_PAE
+		if (max_pfn > MAX_NONPAE_PFN) {
+			max_pfn = MAX_NONPAE_PFN;
+			printk(KERN_WARNING "Warning only 4GB will be used.\n");
+			printk(KERN_WARNING "Use a PAE enabled kernel.\n");
+		}
+#endif /* !CONFIG_X86_PAE */
+#endif /* !CONFIG_HIGHMEM */
+	}
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

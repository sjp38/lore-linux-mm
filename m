From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 8/8] pagemap: export PG_hwpoison
Date: Fri, 08 May 2009 18:53:28 +0800
Message-ID: <20090508111032.121067794@intel.com>
References: <20090508105320.316173813@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E3C746B004D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:12:37 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-hwpoison.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

This flag indicates a hardware detected memory corruption on the page.
Any future access of the page data may bring down the machine.

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/page-types.c |    2 ++
 Documentation/vm/pagemap.txt  |    4 ++++
 fs/proc/page.c                |    5 +++++
 3 files changed, 11 insertions(+)

--- linux.orig/fs/proc/page.c
+++ linux/fs/proc/page.c
@@ -92,6 +92,7 @@ static const struct file_operations proc
 #define KPF_COMPOUND_TAIL	16
 #define KPF_HUGE		17
 #define KPF_UNEVICTABLE		18
+#define KPF_HWPOISON		19
 #define KPF_NOPAGE		20
 
 /* kernel hacking assistances
@@ -171,6 +172,10 @@ static u64 get_uflags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_SWAPCACHE,	PG_swapcache);
 	u |= kpf_copy_bit(k, KPF_SWAPBACKED,	PG_swapbacked);
 
+#ifdef CONFIG_MEMORY_FAILURE
+	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
+#endif
+
 #ifdef CONFIG_UNEVICTABLE_LRU
 	u |= kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);
 	u |= kpf_copy_bit(k, KPF_MLOCKED,	PG_mlocked);
--- linux.orig/Documentation/vm/page-types.c
+++ linux/Documentation/vm/page-types.c
@@ -47,6 +47,7 @@
 #define KPF_COMPOUND_TAIL	16
 #define KPF_HUGE		17
 #define KPF_UNEVICTABLE		18
+#define KPF_HWPOISON		19
 #define KPF_NOPAGE		20
 
 /* [32-] kernel hacking assistances */
@@ -94,6 +95,7 @@ static char *page_flag_names[] = {
 	[KPF_COMPOUND_TAIL]	= "T:compound_tail",
 	[KPF_HUGE]		= "G:huge",
 	[KPF_UNEVICTABLE]	= "u:unevictable",
+	[KPF_HWPOISON]		= "X:hwpoison",
 	[KPF_NOPAGE]		= "n:nopage",
 
 	[KPF_RESERVED]		= "r:reserved",
--- linux.orig/Documentation/vm/pagemap.txt
+++ linux/Documentation/vm/pagemap.txt
@@ -57,6 +57,7 @@ There are three components to pagemap:
     16. COMPOUND_TAIL
     16. HUGE
     18. UNEVICTABLE
+    19. HWPOISON
     20. NOPAGE
 
 Short descriptions to the page flags:
@@ -86,6 +87,9 @@ Short descriptions to the page flags:
 17. HUGE
     this is an integral part of a HugeTLB page
 
+19. HWPOISON
+    hardware detected memory corruption on this page: don't touch the data!
+
 20. NOPAGE
     no page frame exists at the requested address
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

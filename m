Received: from m7.gw.fujitsu.co.jp ([10.0.50.77]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i966bjUI030662 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:37:45 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i966bjDE029369 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:37:45 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 07015EFB0A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:37:45 +0900 (JST)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id BF781EFB0C
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:37:44 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I550047YH2VQN@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  6 Oct 2004 15:37:44 +0900 (JST)
Date: Wed, 06 Oct 2004 15:43:19 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH] pfn_valid more generic : ia64 part [2/2]
Message-id: <41639407.9050504@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is ia64 + generic_arch/CONFIG_DISCONTIG part.
This patch doesn't cover all ia64 configration.

BTW, my previous e-mail was named "arch independent part [0/2]"....
it should be [1/2] , sorry.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

---

 test-pfn-valid-kamezawa/arch/ia64/mm/discontig.c |    2 ++
 test-pfn-valid-kamezawa/arch/ia64/mm/init.c      |   12 ------------
 test-pfn-valid-kamezawa/include/asm-ia64/page.h  |    4 +++-
 3 files changed, 5 insertions(+), 13 deletions(-)

diff -puN include/asm-ia64/page.h~ia64_careful_pfn_valid include/asm-ia64/page.h
--- test-pfn-valid/include/asm-ia64/page.h~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/include/asm-ia64/page.h	2004-10-05 15:22:23.000000000 +0900
@@ -78,7 +78,9 @@ do {						\
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)

 #ifdef CONFIG_VIRTUAL_MEM_MAP
-extern int ia64_pfn_valid (unsigned long pfn);
+#define CAREFUL_PFN_VALID 1
+#define  ia64_pfn_valid(x)	careful_pfn_valid(x)
 #else
 # define ia64_pfn_valid(pfn) 1
 #endif
diff -puN arch/ia64/mm/discontig.c~ia64_careful_pfn_valid arch/ia64/mm/discontig.c
--- test-pfn-valid/arch/ia64/mm/discontig.c~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/arch/ia64/mm/discontig.c	2004-10-05 15:22:23.000000000 +0900
@@ -475,6 +475,7 @@ void __init find_memory(void)
 	max_pfn = max_low_pfn;

 	find_initrd();
+	pfn_valid_init();
 }

 /**
@@ -692,4 +693,5 @@ void paging_init(void)
 	}

 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
+	pfn_valid_setup();
 }
diff -puN arch/ia64/mm/init.c~ia64_careful_pfn_valid arch/ia64/mm/init.c
--- test-pfn-valid/arch/ia64/mm/init.c~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/arch/ia64/mm/init.c	2004-10-05 15:22:23.000000000 +0900
@@ -455,18 +455,6 @@ memmap_init (unsigned long size, int nid
 }

 int
-ia64_pfn_valid (unsigned long pfn)
-{
-	char byte;
-	struct page *pg = pfn_to_page(pfn);
-
-	return     (__get_user(byte, (char *) pg) == 0)
-		&& ((((u64)pg & PAGE_MASK) == (((u64)(pg + 1) - 1) & PAGE_MASK))
-			|| (__get_user(byte, (char *) (pg + 1) - 1) == 0));
-}
-EXPORT_SYMBOL(ia64_pfn_valid);
-
-int
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;

_



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

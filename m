Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i97CaYR6031821 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 21:36:34 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i97CaYkt007983 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 21:36:34 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 464AC1F723E
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 21:36:34 +0900 (JST)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1389A1F7238
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 21:36:33 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5700K6KSCVAJ@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  7 Oct 2004 21:36:32 +0900 (JST)
Date: Thu, 07 Oct 2004 21:42:05 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] no buddy bitmap patch : for ia64 [2/2]
Message-id: <4165399D.7010600@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch is for ia64.
Add HOLES_IN_ZONE macro definition and align vmemmap with ia64's granule size.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

=== for arch/ia64 ===============
This patch is for ia64 kernel.
This defines HOLES_IN_ZONE in asm-ia64/page.h
And makes vmemmap aligned with IA64_GRANULE_SIZE in arch/ia64/mm/init.c.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 test-kernel-kamezawa/arch/ia64/mm/init.c     |    3 ++-
 test-kernel-kamezawa/include/asm-ia64/page.h |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff -puN include/asm-ia64/page.h~ia64_fix include/asm-ia64/page.h
--- test-kernel/include/asm-ia64/page.h~ia64_fix	2004-10-07 19:40:30.953218680 +0900
+++ test-kernel-kamezawa/include/asm-ia64/page.h	2004-10-07 19:40:30.958217920 +0900
@@ -79,6 +79,7 @@ do {						\

 #ifdef CONFIG_VIRTUAL_MEM_MAP
 extern int ia64_pfn_valid (unsigned long pfn);
+#define HOLES_IN_ZONE 1
 #else
 # define ia64_pfn_valid(pfn) 1
 #endif
diff -puN arch/ia64/mm/init.c~ia64_fix arch/ia64/mm/init.c
--- test-kernel/arch/ia64/mm/init.c~ia64_fix	2004-10-07 19:40:30.955218376 +0900
+++ test-kernel-kamezawa/arch/ia64/mm/init.c	2004-10-07 19:40:30.959217768 +0900
@@ -410,7 +410,8 @@ virtual_memmap_init (u64 start, u64 end,
 	struct page *map_start, *map_end;

 	args = (struct memmap_init_callback_data *) arg;
-
+	start = GRANULEROUNDDOWN(start);
+	end = GRANULEROUNDUP(end);
 	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
 	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);


_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

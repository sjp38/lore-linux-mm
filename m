Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i98C66R6028970 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 21:06:06 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i98C65fQ031746 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 21:06:05 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id A52D5EFB0B
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 21:06:05 +0900 (JST)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 7080AEFB0A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 21:06:05 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5900GJULM2KV@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  8 Oct 2004 21:06:03 +0900 (JST)
Date: Fri, 08 Oct 2004 21:11:38 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] no buddy bitmap patch revist : for ia64 [2/2]
Message-id: <416683FA.5060406@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, Tony Luck <tony.luck@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This is for ia64.
CONFIG_HOLES_IN_ZONE is added to Kconfig.
It is set automaically if CONFIG_VIRTUAL_MEMMAP=y.

Thanks.
Kame <kamezawa.hiroyu@jp.fujitsu.com>
=========== for ia64 stuff==========


This patch is for ia64 kernel.
This defines CONFIG_HOLES_IN_ZONE in arch/ia64/Kconfig.
IA64 has memory holes smaller than its MAX_ORDER and its virtual memmap
allows holes in a zone's memmap.

This patch makes vmemmap aligned with IA64_GRANULE_SIZE in
arch/ia64/mm/init.c.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

 test-kernel-kamezawa/arch/ia64/Kconfig   |    4 ++++
 test-kernel-kamezawa/arch/ia64/mm/init.c |    3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff -puN arch/ia64/mm/init.c~ia64_fix arch/ia64/mm/init.c
--- test-kernel/arch/ia64/mm/init.c~ia64_fix	2004-10-08 18:29:20.510992392 +0900
+++ test-kernel-kamezawa/arch/ia64/mm/init.c	2004-10-08 18:29:20.515991632 +0900
@@ -410,7 +410,8 @@ virtual_memmap_init (u64 start, u64 end,
 	struct page *map_start, *map_end;

 	args = (struct memmap_init_callback_data *) arg;
-
+	start = GRANULEROUNDDOWN(start);
+	end = GRANULEROUNDUP(end);
 	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
 	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);

diff -puN arch/ia64/Kconfig~ia64_fix arch/ia64/Kconfig
--- test-kernel/arch/ia64/Kconfig~ia64_fix	2004-10-08 18:29:20.513991936 +0900
+++ test-kernel-kamezawa/arch/ia64/Kconfig	2004-10-08 18:29:20.516991480 +0900
@@ -178,6 +178,10 @@ config VIRTUAL_MEM_MAP
 	  require the DISCONTIGMEM option for your machine. If you are
 	  unsure, say Y.

+config HOLES_IN_ZONE
+	bool
+	default y if VIRTUAL_MEM_MAP
+
 config DISCONTIGMEM
 	bool "Discontiguous memory support"
 	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1) && NUMA && VIRTUAL_MEM_MAP

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

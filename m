Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6BF6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 00:29:35 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so10948289pab.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 21:29:35 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id ql9si18614568pbb.60.2015.10.14.21.29.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 21:29:34 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id DF174AC0220
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 13:29:30 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH] mm: Introduce kernelcore=reliable option
Date: Thu, 15 Oct 2015 22:32:22 +0900
Message-Id: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, akpm@linux-foundation.org, dave.hansen@intel.com, matt@codeblueprint.co.uk, Taku Izumi <izumi.taku@jp.fujitsu.com>

Xeon E7 v3 based systems supports Address Range Mirroring
and UEFI BIOS complied with UEFI spec 2.5 can notify which
ranges are reliable (mirrored) via EFI memory map.
Now Linux kernel utilize its information and allocates
boot time memory from reliable region.

My requirement is:
  - allocate kernel memory from reliable region
  - allocate user memory from non-reliable region

In order to meet my requirement, ZONE_MOVABLE is useful.
By arranging non-reliable range into ZONE_MOVABLE,
reliable memory is only used for kernel allocations.

This patch extends existing "kernelcore" option and
introduces kernelcore=reliable option. By specifying
"reliable" instead of specifying the amount of memory,
non-reliable region will be arranged into ZONE_MOVABLE.

Earlier discussion is at:
 https://lkml.org/lkml/2015/10/9/24

For example, suppose 2-nodes system with the following
 memory range:
  node 0 [mem 0x0000000000001000-0x000000109fffffff]
  node 1 [mem 0x00000010a0000000-0x000000209fffffff]

and the following ranges are marked as reliable (*):
  [0x0000000000000000-0x0000000100000000]
  [0x0000000100000000-0x0000000180000000]
  [0x00000010a0000000-0x0000001120000000]

If you specify kernelcore=reliable, Movable zones are
arranged like the following:
  Movable zone start for each node
    Node 0: 0x0000000180000000
    Node 1: 0x0000001120000000

(*) I specified the following instead of using UEFI BIOS
    complied with UEFI spec 2.5,
    efi_fake_mem=4G@0:0x10000,2G@0x10a0000000:0x10000,2G@4G:0x10000
    efi_fake_mem is found at:
     git://git.kernel.org/pub/scm/linux/kernel/git/mfleming/efi.git
     tags/efi-next

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 Documentation/kernel-parameters.txt |  9 ++++++++-
 mm/page_alloc.c                     | 26 ++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cd5312f..b2c8c13 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1663,7 +1663,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	keepinitrd	[HW,ARM]
 
-	kernelcore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
+	kernelcore=	Format: nn[KMG] | "reliable"
+			[KNL,X86,IA-64,PPC] This parameter
 			specifies the amount of memory usable by the kernel
 			for non-movable allocations.  The requested amount is
 			spread evenly throughout all nodes in the system. The
@@ -1679,6 +1680,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			use the HighMem zone if it exists, and the Normal
 			zone if it does not.
 
+			Instead of specifying the amount of memory (nn[KMS]),
+			you can specify "reliable" option. In case "reliable"
+			option is specified, reliable memory is used for
+			non-movable allocations and remaining memory is used
+			for Movable pages.
+
 	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
 			Format: <Controller#>[,poll interval]
 			The controller # is the number of the ehci usb debug
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beda417..d0b3ac9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -221,6 +221,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
 static unsigned long __initdata required_movablecore;
 static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
+static bool reliable_kernelcore __initdata;
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
 int movable_zone;
@@ -5618,6 +5619,25 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	}
 
 	/*
+	 * If kernelcore=reliable is specified, ignore movablecore option
+	 */
+	if (reliable_kernelcore) {
+		for_each_memblock(memory, r) {
+			if (memblock_is_mirror(r))
+				continue;
+
+			nid = r->nid;
+
+			usable_startpfn = PFN_DOWN(r->base);
+			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
+				min(usable_startpfn, zone_movable_pfn[nid]) :
+				usable_startpfn;
+		}
+
+		goto out2;
+	}
+
+	/*
 	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
@@ -5873,6 +5893,12 @@ static int __init cmdline_parse_core(char *p, unsigned long *core)
  */
 static int __init cmdline_parse_kernelcore(char *p)
 {
+	/* parse kernelcore=reliable */
+	if (parse_option_str(p, "reliable")) {
+		reliable_kernelcore = true;
+		return 0;
+	}
+
 	return cmdline_parse_core(p, &required_kernelcore);
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

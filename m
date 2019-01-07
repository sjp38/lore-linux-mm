Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 808F38E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 03:05:22 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id x26so33478637pgc.5
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 00:05:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor39813920pfk.38.2019.01.07.00.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 00:05:20 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X consistent with kaslr
Date: Mon,  7 Jan 2019 16:04:59 +0800
Message-Id: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kexec@lists.infradead.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

Customer reported a bug on a high end server with many pcie devices, where
kernel bootup with crashkernel=384M, and kaslr is enabled. Even
though we still see much memory under 896 MB, the finding still failed
intermittently. Because currently we can only find region under 896 MB,
if w/0 ',high' specified. Then KASLR breaks 896 MB into several parts
randomly, and crashkernel reservation need be aligned to 128 MB, that's
why failure is found. It raises confusion to the end user that sometimes
crashkernel=X works while sometimes fails.
If want to make it succeed, customer can change kernel option to
"crashkernel=384M, high". Just this give "crashkernel=xx@yy" a very
limited space to behave even though its grammer looks more generic.
And we can't answer questions raised from customer that confidently:
1) why it doesn't succeed to reserve 896 MB;
2) what's wrong with memory region under 4G;
3) why I have to add ',high', I only require 384 MB, not 3840 MB.

This patch simplifies the method suggested in the mail [1]. It just goes
bottom-up to find a candidate region for crashkernel. The bottom-up may be
better compatible with the old reservation style, i.e. still want to get
memory region from 896 MB firstly, then [896 MB, 4G], finally above 4G.

There is one trivial thing about the compatibility with old kexec-tools:
if the reserved region is above 896M, then old tool will fail to load
bzImage. But without this patch, the old tool also fail since there is no
memory below 896M can be reserved for crashkernel.

[1]: http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Daniel Vacek <neelx@redhat.com>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: yinghai@kernel.org,
Cc: vgoyal@redhat.com
Cc: linux-kernel@vger.kernel.org
---
v4 -> v5:
  add a wrapper of bottom up allocation func
v3 -> v4:
  instead of exporting the stage of parsing mem hotplug info, just using the bottom-up allocation func directly
 arch/x86/kernel/setup.c  |  8 ++++----
 include/linux/memblock.h |  3 +++
 mm/memblock.c            | 29 +++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d494b9b..80e7923 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -546,10 +546,10 @@ static void __init reserve_crashkernel(void)
 		 * as old kexec-tools loads bzImage below that, unless
 		 * "crashkernel=size[KMG],high" is specified.
 		 */
-		crash_base = memblock_find_in_range(CRASH_ALIGN,
-						    high ? CRASH_ADDR_HIGH_MAX
-							 : CRASH_ADDR_LOW_MAX,
-						    crash_size, CRASH_ALIGN);
+		crash_base = memblock_find_range_bottom_up(CRASH_ALIGN,
+			(max_pfn * PAGE_SIZE), crash_size, CRASH_ALIGN,
+			NUMA_NO_NODE);
+
 		if (!crash_base) {
 			pr_info("crashkernel reservation failed - No suitable area found.\n");
 			return;
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index aee299a..a35ae17 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -116,6 +116,9 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t size, phys_addr_t align,
 					int nid, enum memblock_flags flags);
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
+phys_addr_t __init_memblock
+memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
+	phys_addr_t size, phys_addr_t align, int nid);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 81ae63c..f68287e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -192,6 +192,35 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
 	return 0;
 }
 
+phys_addr_t __init_memblock
+memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
+	phys_addr_t size, phys_addr_t align, int nid)
+{
+	phys_addr_t ret;
+	enum memblock_flags flags = choose_memblock_flags();
+
+	/* pump up @end */
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
+
+	/* avoid allocating the first page */
+	start = max_t(phys_addr_t, start, PAGE_SIZE);
+	end = max(start, end);
+
+again:
+	ret = __memblock_find_range_bottom_up(start, end, size, align,
+					    nid, flags);
+
+	if (!ret && (flags & MEMBLOCK_MIRROR)) {
+		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
+			&size);
+		flags &= ~MEMBLOCK_MIRROR;
+		goto again;
+	}
+
+	return ret;
+}
+
 /**
  * __memblock_find_range_top_down - find free area utility, in top-down
  * @start: start of candidate range
-- 
2.7.4

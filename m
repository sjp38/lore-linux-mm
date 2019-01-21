Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 857A18E0018
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:19 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w28so18283131qkj.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:05:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u24si1176942qtj.98.2019.01.21.00.05.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:05:18 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L84GkD084052
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:18 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q57yk5juj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:17 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:05:14 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 08/21] memblock: drop __memblock_alloc_base()
Date: Mon, 21 Jan 2019 10:03:55 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-9-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

The __memblock_alloc_base() function tries to allocate a memory up to the
limit specified by its max_addr parameter. Depending on the value of this
parameter, the __memblock_alloc_base() can is replaced with the appropriate
memblock_phys_alloc*() variant.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 arch/sh/kernel/machine_kexec.c |  3 ++-
 arch/x86/kernel/e820.c         |  2 +-
 arch/x86/mm/numa.c             | 12 ++++--------
 drivers/of/of_reserved_mem.c   |  7 ++-----
 include/linux/memblock.h       |  2 --
 mm/memblock.c                  |  9 ++-------
 6 files changed, 11 insertions(+), 24 deletions(-)

diff --git a/arch/sh/kernel/machine_kexec.c b/arch/sh/kernel/machine_kexec.c
index b9f9f1a..63d63a3 100644
--- a/arch/sh/kernel/machine_kexec.c
+++ b/arch/sh/kernel/machine_kexec.c
@@ -168,7 +168,8 @@ void __init reserve_crashkernel(void)
 	crash_size = PAGE_ALIGN(resource_size(&crashk_res));
 	if (!crashk_res.start) {
 		unsigned long max = memblock_end_of_DRAM() - memory_limit;
-		crashk_res.start = __memblock_alloc_base(crash_size, PAGE_SIZE, max);
+		crashk_res.start = memblock_phys_alloc_range(crash_size,
+							     PAGE_SIZE, 0, max);
 		if (!crashk_res.start) {
 			pr_err("crashkernel allocation failed\n");
 			goto disable;
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 50895c2..9c0eb54 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -778,7 +778,7 @@ u64 __init e820__memblock_alloc_reserved(u64 size, u64 align)
 {
 	u64 addr;
 
-	addr = __memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
+	addr = memblock_phys_alloc(size, align);
 	if (addr) {
 		e820__range_update_kexec(addr, size, E820_TYPE_RAM, E820_TYPE_RESERVED);
 		pr_info("update e820_table_kexec for e820__memblock_alloc_reserved()\n");
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f54..f85ae42 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -195,15 +195,11 @@ static void __init alloc_node_data(int nid)
 	 * Allocate node data.  Try node-local memory and then any node.
 	 * Never allocate in DMA zone.
 	 */
-	nd_pa = memblock_phys_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
 	if (!nd_pa) {
-		nd_pa = __memblock_alloc_base(nd_size, SMP_CACHE_BYTES,
-					      MEMBLOCK_ALLOC_ACCESSIBLE);
-		if (!nd_pa) {
-			pr_err("Cannot find %zu bytes in any node (initial node: %d)\n",
-			       nd_size, nid);
-			return;
-		}
+		pr_err("Cannot find %zu bytes in any node (initial node: %d)\n",
+		       nd_size, nid);
+		return;
 	}
 	nd = __va(nd_pa);
 
diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index 1977ee0..499f16d 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -31,13 +31,10 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	phys_addr_t *res_base)
 {
 	phys_addr_t base;
-	/*
-	 * We use __memblock_alloc_base() because memblock_alloc_base()
-	 * panic()s on allocation failure.
-	 */
+
 	end = !end ? MEMBLOCK_ALLOC_ANYWHERE : end;
 	align = !align ? SMP_CACHE_BYTES : align;
-	base = __memblock_alloc_base(size, align, end);
+	base = memblock_phys_alloc_range(size, align, 0, end);
 	if (!base)
 		return -ENOMEM;
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7883c74..768e2b4 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -496,8 +496,6 @@ static inline bool memblock_bottom_up(void)
 
 phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
 				phys_addr_t max_addr);
-phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
-				  phys_addr_t max_addr);
 phys_addr_t memblock_phys_mem_size(void);
 phys_addr_t memblock_reserved_size(void);
 phys_addr_t memblock_mem_size(unsigned long limit_pfn);
diff --git a/mm/memblock.c b/mm/memblock.c
index 461e40a3..e5ffdcd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1363,17 +1363,12 @@ phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align,
 	return ret;
 }
 
-phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	return memblock_alloc_range_nid(size, align, 0, max_addr, NUMA_NO_NODE,
-					MEMBLOCK_NONE);
-}
-
 phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	phys_addr_t alloc;
 
-	alloc = __memblock_alloc_base(size, align, max_addr);
+	alloc = memblock_alloc_range_nid(size, align, 0, max_addr, NUMA_NO_NODE,
+					MEMBLOCK_NONE);
 
 	if (alloc == 0)
 		panic("ERROR: Failed to allocate %pa bytes below %pa.\n",
-- 
2.7.4

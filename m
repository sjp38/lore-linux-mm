Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEC3B8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:45:08 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so4658828pfi.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:45:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e66si6610278plb.107.2019.01.16.05.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:45:07 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GDeYOi079251
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:45:06 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q2303fvh0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:45:06 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 13:45:03 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 05/21] memblock: emphasize that memblock_alloc_range() returns a physical address
Date: Wed, 16 Jan 2019 15:44:05 +0200
In-Reply-To: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1547646261-32535-6-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

Rename memblock_alloc_range() to memblock_phys_alloc_range() to emphasize
that it returns a physical address.
While on it, remove the 'enum memblock_flags' parameter from this function
as its only user anyway sets it to MEMBLOCK_NONE, which is the default for
the most of memblock allocations.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |  5 ++---
 mm/cma.c                 | 10 ++++------
 mm/memblock.c            |  9 +++++----
 3 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f7ef313..66dfdb3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -369,6 +369,8 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 #define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
 #endif
 
+phys_addr_t memblock_phys_alloc_range(phys_addr_t size, phys_addr_t align,
+				      phys_addr_t start, phys_addr_t end);
 phys_addr_t memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
@@ -487,9 +489,6 @@ static inline bool memblock_bottom_up(void)
 	return memblock.bottom_up;
 }
 
-phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
-					phys_addr_t start, phys_addr_t end,
-					enum memblock_flags flags);
 phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
 				phys_addr_t max_addr);
 phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
diff --git a/mm/cma.c b/mm/cma.c
index c7b39dd..e4530ae 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -327,16 +327,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 		 * memory in case of failure.
 		 */
 		if (base < highmem_start && limit > highmem_start) {
-			addr = memblock_alloc_range(size, alignment,
-						    highmem_start, limit,
-						    MEMBLOCK_NONE);
+			addr = memblock_phys_alloc_range(size, alignment,
+							 highmem_start, limit);
 			limit = highmem_start;
 		}
 
 		if (!addr) {
-			addr = memblock_alloc_range(size, alignment, base,
-						    limit,
-						    MEMBLOCK_NONE);
+			addr = memblock_phys_alloc_range(size, alignment, base,
+							 limit);
 			if (!addr) {
 				ret = -ENOMEM;
 				goto err;
diff --git a/mm/memblock.c b/mm/memblock.c
index c80029e..f019aee 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1338,12 +1338,13 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 	return 0;
 }
 
-phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
-					phys_addr_t start, phys_addr_t end,
-					enum memblock_flags flags)
+phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
+					     phys_addr_t align,
+					     phys_addr_t start,
+					     phys_addr_t end)
 {
 	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE,
-					flags);
+					MEMBLOCK_NONE);
 }
 
 phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
-- 
2.7.4

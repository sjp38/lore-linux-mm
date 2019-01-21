Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD598E0018
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:56 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x67so15388009pfk.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:04:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 24si6163365pgm.167.2019.01.21.00.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:04:55 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L83moS132163
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:55 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q59werwyg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:04:54 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:04:51 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 04/21] memblock: drop memblock_alloc_base_nid()
Date: Mon, 21 Jan 2019 10:03:51 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-5-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

The memblock_alloc_base_nid() is a oneliner wrapper for
memblock_alloc_range_nid() without any side effect.
Replace it's usage by the direct calls to memblock_alloc_range_nid().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |  3 ---
 mm/memblock.c            | 15 ++++-----------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 60e100f..f7ef313 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -490,9 +490,6 @@ static inline bool memblock_bottom_up(void)
 phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 					phys_addr_t start, phys_addr_t end,
 					enum memblock_flags flags);
-phys_addr_t memblock_alloc_base_nid(phys_addr_t size,
-					phys_addr_t align, phys_addr_t max_addr,
-					int nid, enum memblock_flags flags);
 phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
 				phys_addr_t max_addr);
 phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
diff --git a/mm/memblock.c b/mm/memblock.c
index a32db30..c80029e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1346,21 +1346,14 @@ phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 					flags);
 }
 
-phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
-					phys_addr_t align, phys_addr_t max_addr,
-					int nid, enum memblock_flags flags)
-{
-	return memblock_alloc_range_nid(size, align, 0, max_addr, nid, flags);
-}
-
 phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	enum memblock_flags flags = choose_memblock_flags();
 	phys_addr_t ret;
 
 again:
-	ret = memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE,
-				      nid, flags);
+	ret = memblock_alloc_range_nid(size, align, 0,
+				       MEMBLOCK_ALLOC_ACCESSIBLE, nid, flags);
 
 	if (!ret && (flags & MEMBLOCK_MIRROR)) {
 		flags &= ~MEMBLOCK_MIRROR;
@@ -1371,8 +1364,8 @@ phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align,
 
 phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
-	return memblock_alloc_base_nid(size, align, max_addr, NUMA_NO_NODE,
-				       MEMBLOCK_NONE);
+	return memblock_alloc_range_nid(size, align, 0, max_addr, NUMA_NO_NODE,
+					MEMBLOCK_NONE);
 }
 
 phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-- 
2.7.4

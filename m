Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id D1F248E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:29 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p23-v6so3503845otl.23
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:12:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h126-v6si3830463oia.375.2018.09.14.05.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:12:28 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4YGD125049
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:28 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgc6csqy6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:27 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:12:24 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 13/30] memblock: replace __alloc_bootmem_nopanic with memblock_alloc_from_nopanic
Date: Fri, 14 Sep 2018 15:10:28 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-14-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

When __alloc_bootmem_nopanic() is used with explicit lower limit for the
allocation it attempts to allocate memory at or above that limit and falls
back to allocation with no limit set.

The memblock_alloc_from_nopanic() does exactly the same thing and can be
used as a replacement for __alloc_bootmem_nopanic() is such cases.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/arc/kernel/unwind.c       | 4 ++--
 arch/x86/kernel/setup_percpu.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
index 183391d..2a01dd1 100644
--- a/arch/arc/kernel/unwind.c
+++ b/arch/arc/kernel/unwind.c
@@ -181,8 +181,8 @@ static void init_unwind_hdr(struct unwind_table *table,
  */
 static void *__init unw_hdr_alloc_early(unsigned long sz)
 {
-	return __alloc_bootmem_nopanic(sz, sizeof(unsigned int),
-				       MAX_DMA_ADDRESS);
+	return memblock_alloc_from_nopanic(sz, sizeof(unsigned int),
+					   MAX_DMA_ADDRESS);
 }
 
 static void *unw_hdr_alloc(unsigned long sz)
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index 67d48e26..041663a 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -106,7 +106,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
 	void *ptr;
 
 	if (!node_online(node) || !NODE_DATA(node)) {
-		ptr = __alloc_bootmem_nopanic(size, align, goal);
+		ptr = memblock_alloc_from_nopanic(size, align, goal);
 		pr_info("cpu %d has no node %d or node-local memory\n",
 			cpu, node);
 		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
@@ -121,7 +121,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
 	}
 	return ptr;
 #else
-	return __alloc_bootmem_nopanic(size, align, goal);
+	return memblock_alloc_from_nopanic(size, align, goal);
 #endif
 }
 
-- 
2.7.4

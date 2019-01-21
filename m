Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 153238E0018
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:50 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b16so19921527qtc.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:05:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k15si1670981qvc.27.2019.01.21.00.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:05:49 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L850Zm131766
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:48 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q590xu378-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:48 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:05:45 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 13/21] arch: don't memset(0) memory returned by memblock_alloc()
Date: Mon, 21 Jan 2019 10:04:00 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-14-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

memblock_alloc() already clears the allocated memory, no point in doing it
twice.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> # m68k
---
 arch/c6x/mm/init.c          | 1 -
 arch/h8300/mm/init.c        | 1 -
 arch/ia64/kernel/mca.c      | 2 --
 arch/m68k/mm/mcfmmu.c       | 1 -
 arch/microblaze/mm/init.c   | 6 ++----
 arch/sparc/kernel/prom_32.c | 2 --
 6 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index af5ada0..e83c046 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -40,7 +40,6 @@ void __init paging_init(void)
 
 	empty_zero_page      = (unsigned long) memblock_alloc(PAGE_SIZE,
 							      PAGE_SIZE);
-	memset((void *)empty_zero_page, 0, PAGE_SIZE);
 
 	/*
 	 * Set up user data space
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 6519252..a157890 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -68,7 +68,6 @@ void __init paging_init(void)
 	 * to a couple of allocated pages.
 	 */
 	empty_zero_page = (unsigned long)memblock_alloc(PAGE_SIZE, PAGE_SIZE);
-	memset((void *)empty_zero_page, 0, PAGE_SIZE);
 
 	/*
 	 * Set up SFC/DFC registers (user data space).
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 74d148b..370bc34 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -400,8 +400,6 @@ ia64_log_init(int sal_info_type)
 
 	// set up OS data structures to hold error info
 	IA64_LOG_ALLOCATE(sal_info_type, max_size);
-	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);
-	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);
 }
 
 /*
diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
index 0de4999..492f953 100644
--- a/arch/m68k/mm/mcfmmu.c
+++ b/arch/m68k/mm/mcfmmu.c
@@ -44,7 +44,6 @@ void __init paging_init(void)
 	int i;
 
 	empty_zero_page = (void *) memblock_alloc(PAGE_SIZE, PAGE_SIZE);
-	memset((void *) empty_zero_page, 0, PAGE_SIZE);
 
 	pg_dir = swapper_pg_dir;
 	memset(swapper_pg_dir, 0, sizeof(swapper_pg_dir));
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 44f4b89..bd1cd4b 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -376,10 +376,8 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 
 	if (mem_init_done)
 		p = kzalloc(size, mask);
-	else {
+	else
 		p = memblock_alloc(size, SMP_CACHE_BYTES);
-		if (p)
-			memset(p, 0, size);
-	}
+
 	return p;
 }
diff --git a/arch/sparc/kernel/prom_32.c b/arch/sparc/kernel/prom_32.c
index 38940af..e7126ca 100644
--- a/arch/sparc/kernel/prom_32.c
+++ b/arch/sparc/kernel/prom_32.c
@@ -33,8 +33,6 @@ void * __init prom_early_alloc(unsigned long size)
 	void *ret;
 
 	ret = memblock_alloc(size, SMP_CACHE_BYTES);
-	if (ret != NULL)
-		memset(ret, 0, size);
 
 	prom_early_allocated += size;
 
-- 
2.7.4

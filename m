Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00898C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 12:56:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C50120578
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 12:56:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C50120578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF0076B0005; Tue,  7 May 2019 08:56:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7A596B0006; Tue,  7 May 2019 08:56:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A43606B0007; Tue,  7 May 2019 08:56:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 812516B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 08:56:36 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id c4so31448137ywd.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 05:56:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=VDdhOKSczAGYAtVFPq55uQzVtItdbo6EaCYwPAMtV/E=;
        b=JxEOETK9uerHv/O0+QblFQnNzXwzRr9y6flO9r/Y1Kh5YT9IIpd87+0ZsVeYKjsfK/
         jFIRMYi4THMYnsMD/pm6sc96jlwN8RC2YfcFHn9miT+xTrRLKBFi5UpeKI37yQz9A4Ys
         vHwpJGeGBRnW7DLeFhMiwGk1B4JIhae4pUdAF/vxR9NFPTO6shyQ3OOBcZ6IP5GS7NZd
         /qkgIQNCwEbdcmGHOkcuoWNnYRMcHlLXAviU2Ocn7ph09tFa82oBzbdknj53GlUgfGwK
         MA8yEf1lxSoDV7VS4oy4uUqWS3xAi87hqib3VxgH5Yf8fTEJ1ysDNOS7bovOHVAWVLYl
         UKIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVZkRkGSNk1nTHsORIQJt4grWw4QpD0YIu1JuGlSInNRyxp+eqv
	CjlYp9TythgNZ8jcpMaXJ7fboYw85prbTJ0MIjn6OmzCSokQtA9tyOzSzrXx/trwUmYNdspquPH
	sFo8/z3DmleTwZnbNJ44S53UJyva1uFsphtuTGeIWZ2Sn670+decBFiZuTEcDSWjMfQ==
X-Received: by 2002:a25:41c5:: with SMTP id o188mr20629516yba.249.1557233796225;
        Tue, 07 May 2019 05:56:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxizzvD1qYMdhVsCR3kvYtJVpuiD0C0rjmxplxD8KLge8OB+aSv4iRVxsu6qGMNPet5ZcQK
X-Received: by 2002:a25:41c5:: with SMTP id o188mr20629480yba.249.1557233795208;
        Tue, 07 May 2019 05:56:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557233795; cv=none;
        d=google.com; s=arc-20160816;
        b=DnCD6XhPVoJMTWGAvYezT2bXY/RgpNZzu9wn+QPBO+Wbrbd65TnspgKkz92nLjHWXe
         lSz5IhMWaZ085/vAZGnjIu+uk2Ix8WOjCnkTHnHH+HXJ3tEBWs7+VGjcaoA/WjZzZRzU
         RYjs1Jsv3ylpVf136Ti/2+cj0ozrQjuRaW13Rhz+MIPM9LbwRz2s+4ynS52AG6FITdrL
         ppBVEYS1e0pDQhyli/8Yg0JPl0to1nU0zibyx+2eCRIdsugw2sDdzEDUoRmze7Paqgal
         9jrXJFLjptCPqgbk5KUjoWvIo3LJmsJz0seBeOmlpB3Iz3FC9qKLqBjwLlkb9uHauM26
         ol4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=VDdhOKSczAGYAtVFPq55uQzVtItdbo6EaCYwPAMtV/E=;
        b=Rv7KTg1gnb2sXsrnT/BQ+IrzoraPssVex49DyV0UfqG8ovnib6GO+3qr+fDQEKcdhs
         1Y4tzM9vBa8WbzkRrrwzuVQbh+USgAWz9RGO+KDTvBCjooBErTy9hh3RpIfQKGbNI5X4
         NL32gtnaGeKfBklYkGENySFTSTdUwVz9CR58Mhog2HZ9U64nhD6FEGoXIxFsLoCtlVuV
         FQEItMtB0uDifVns0CU5rjMyV82AdS21ClMJo0fS2/CaQET7WsMRAy57JZPNmD6dPn0q
         tuc1+8VUff8rS4Qmb74x4XPpsNOFPQNrGUA9X2WLmMwwcdpS99qIAjBWQ7JWiBr4REpl
         jbsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e124si5313823ybe.443.2019.05.07.05.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 05:56:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x47CrZUO000906
	for <linux-mm@kvack.org>; Tue, 7 May 2019 08:56:34 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbabm8bvk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 May 2019 08:56:34 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 7 May 2019 13:56:32 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 7 May 2019 13:56:28 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x47CuRex32702710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 7 May 2019 12:56:27 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A01EFA405B;
	Tue,  7 May 2019 12:56:27 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18537A4054;
	Tue,  7 May 2019 12:56:26 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  7 May 2019 12:56:25 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 07 May 2019 15:56:25 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-alpha@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>,
        Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
        Meelis Roos <mroos@linux.ee>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [RFC/RFT PATCH] alpha: switch from DISCONTIGMEM to SPARSEMEM
Date: Tue,  7 May 2019 15:56:24 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19050712-0020-0000-0000-0000033A2C69
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050712-0021-0000-0000-0000218CC828
Message-Id: <1557233784-3301-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-07_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905070084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enable SPARSEMEM support on alpha and deprecate DISCONTIGMEM.

The required changes are mostly around moving duplicated definitions of
page access and address conversion macros to a common place and making sure
they are available for all memory models.

The DISCONTINGMEM support is marked as BROKEN an will be removed in a
couple of releases.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/alpha/Kconfig                 |  8 ++++++++
 arch/alpha/include/asm/mmzone.h    | 17 ++---------------
 arch/alpha/include/asm/page.h      |  7 ++++---
 arch/alpha/include/asm/pgtable.h   | 12 +++++-------
 arch/alpha/include/asm/sparsemem.h | 22 ++++++++++++++++++++++
 arch/alpha/kernel/setup.c          |  2 ++
 6 files changed, 43 insertions(+), 25 deletions(-)
 create mode 100644 arch/alpha/include/asm/sparsemem.h

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 584a6e1..6be7bec 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -36,6 +36,7 @@ config ALPHA
 	select ODD_RT_SIGACTION
 	select OLD_SIGSUSPEND
 	select CPU_NO_EFFICIENT_FFS if !ALPHA_EV67
+	select SPARSEMEM_STATIC if SPARSEMEM
 	help
 	  The Alpha is a 64-bit general-purpose processor designed and
 	  marketed by the Digital Equipment Corporation of blessed memory,
@@ -554,12 +555,19 @@ config NR_CPUS
 
 config ARCH_DISCONTIGMEM_ENABLE
 	bool "Discontiguous Memory Support"
+	depends on BROKEN
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa.rst> for more.
 
+config ARCH_SPARSEMEM_ENABLE
+	bool "Sparse Memory Support"
+	help
+	  Say Y to support efficient handling of discontiguous physical memory,
+	  for systems that have huge holes in the physical address space.
+
 config NUMA
 	bool "NUMA Support (EXPERIMENTAL)"
 	depends on DISCONTIGMEM && BROKEN
diff --git a/arch/alpha/include/asm/mmzone.h b/arch/alpha/include/asm/mmzone.h
index 889b5d3..8664460 100644
--- a/arch/alpha/include/asm/mmzone.h
+++ b/arch/alpha/include/asm/mmzone.h
@@ -6,9 +6,9 @@
 #ifndef _ASM_MMZONE_H_
 #define _ASM_MMZONE_H_
 
-#include <asm/smp.h>
+#ifdef CONFIG_DISCONTIGMEM
 
-struct bootmem_data_t; /* stupid forward decl. */
+#include <asm/smp.h>
 
 /*
  * Following are macros that are specific to this numa platform.
@@ -47,8 +47,6 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p, int n)
 }
 #endif
 
-#ifdef CONFIG_DISCONTIGMEM
-
 /*
  * Following are macros that each numa implementation must define.
  */
@@ -70,12 +68,6 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p, int n)
 /* XXX: FIXME -- nyc */
 #define kern_addr_valid(kaddr)	(0)
 
-#define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
-
-#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> 32))
-#define pgd_page(pgd)		(pfn_to_page(pgd_val(pgd) >> 32))
-#define pte_pfn(pte)		(pte_val(pte) >> 32)
-
 #define mk_pte(page, pgprot)						     \
 ({								 	     \
 	pte_t pte;                                                           \
@@ -98,16 +90,11 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p, int n)
 	__xx;                                                           \
 })
 
-#define page_to_pa(page)						\
-	(page_to_pfn(page) << PAGE_SHIFT)
-
 #define pfn_to_nid(pfn)		pa_to_nid(((u64)(pfn) << PAGE_SHIFT))
 #define pfn_valid(pfn)							\
 	(((pfn) - node_start_pfn(pfn_to_nid(pfn))) <			\
 	 node_spanned_pages(pfn_to_nid(pfn)))					\
 
-#define virt_addr_valid(kaddr)	pfn_valid((__pa(kaddr) >> PAGE_SHIFT))
-
 #endif /* CONFIG_DISCONTIGMEM */
 
 #endif /* _ASM_MMZONE_H_ */
diff --git a/arch/alpha/include/asm/page.h b/arch/alpha/include/asm/page.h
index f3fb284..f89eef3 100644
--- a/arch/alpha/include/asm/page.h
+++ b/arch/alpha/include/asm/page.h
@@ -83,12 +83,13 @@ typedef struct page *pgtable_t;
 
 #define __pa(x)			((unsigned long) (x) - PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long) (x) + PAGE_OFFSET))
-#ifndef CONFIG_DISCONTIGMEM
+
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
+#define virt_addr_valid(kaddr)	pfn_valid((__pa(kaddr) >> PAGE_SHIFT))
 
+#ifdef CONFIG_FLATMEM
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
-#define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
-#endif /* CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 #define VM_DATA_DEFAULT_FLAGS		(VM_READ | VM_WRITE | VM_EXEC | \
 					 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pgtable.h
index 89c2032..83a0487 100644
--- a/arch/alpha/include/asm/pgtable.h
+++ b/arch/alpha/include/asm/pgtable.h
@@ -203,10 +203,10 @@ extern unsigned long __zero_page(void);
  * Conversion functions:  convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  */
-#ifndef CONFIG_DISCONTIGMEM
-#define page_to_pa(page)	(((page) - mem_map) << PAGE_SHIFT)
-
+#define page_to_pa(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define pte_pfn(pte)	(pte_val(pte) >> 32)
+
+#ifndef CONFIG_DISCONTIGMEM
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 #define mk_pte(page, pgprot)						\
 ({									\
@@ -236,10 +236,8 @@ pmd_page_vaddr(pmd_t pmd)
 	return ((pmd_val(pmd) & _PFN_MASK) >> (32-PAGE_SHIFT)) + PAGE_OFFSET;
 }
 
-#ifndef CONFIG_DISCONTIGMEM
-#define pmd_page(pmd)	(mem_map + ((pmd_val(pmd) & _PFN_MASK) >> 32))
-#define pgd_page(pgd)	(mem_map + ((pgd_val(pgd) & _PFN_MASK) >> 32))
-#endif
+#define pmd_page(pmd)	(pfn_to_page(pmd_val(pmd) >> 32))
+#define pgd_page(pgd)	(pfn_to_page(pgd_val(pgd) >> 32))
 
 extern inline unsigned long pgd_page_vaddr(pgd_t pgd)
 { return PAGE_OFFSET + ((pgd_val(pgd) & _PFN_MASK) >> (32-PAGE_SHIFT)); }
diff --git a/arch/alpha/include/asm/sparsemem.h b/arch/alpha/include/asm/sparsemem.h
new file mode 100644
index 0000000..3e3fdd3
--- /dev/null
+++ b/arch/alpha/include/asm/sparsemem.h
@@ -0,0 +1,22 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_ALPHA_SPARSEMEM_H
+#define _ASM_ALPHA_SPARSEMEM_H
+
+#ifdef CONFIG_SPARSEMEM
+
+/*
+ * The section size matches the minimal possible size of a NUMA node,
+ * which is 16G on Marvel
+ */
+#define SECTION_SIZE_BITS	34
+
+/*
+ * According to "Alpha Architecture Reference Manual" physical
+ * addresses are at most 48 bits.
+ * https://download.majix.org/dec/alpha_arch_ref.pdf
+ */
+#define MAX_PHYSMEM_BITS	48
+
+#endif /* CONFIG_SPARSEMEM */
+
+#endif /* _ASM_ALPHA_SPARSEMEM_H */
diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
index 5d4c76a..7e4dc23 100644
--- a/arch/alpha/kernel/setup.c
+++ b/arch/alpha/kernel/setup.c
@@ -635,6 +635,8 @@ setup_arch(char **cmdline_p)
 	/* Find our memory.  */
 	setup_memory(kernel_end);
 	memblock_set_bottom_up(true);
+	memblocks_present();
+	sparse_init();
 
 	/* First guess at cpu cache sizes.  Do this before init_arch.  */
 	determine_cpu_caches(cpu->type);
-- 
2.7.4


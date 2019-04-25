Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A070BC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8314D206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8314D206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB4C96B0007; Thu, 25 Apr 2019 17:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D65716B0008; Thu, 25 Apr 2019 17:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C570B6B000A; Thu, 25 Apr 2019 17:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0CE6B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so589921pgc.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=DlbkNDgTSlJ8f9jY3c6eZpPtmL2owk7d0TJfhnEqe/g=;
        b=ks0So9msD7fz4JFHzEcbNiCyhAQht68AFyzIHQoXwkXHyHI9sYnqbQDc5Pl0VvOZVX
         jPBb9u4JXVGVOm4hFUd+1VlD1OnMvnRbkS8leBDoyl0dFiv59mKyflEdF2caqEbqSiZg
         V2GuOHxmkACBUig6CtcaWZ5sgIb6kojy4xc4CZX27H3P808XccXI7r/DL5iB8JcWt/B4
         oHNFQEkYAbagVYLioX9FQeykY98bKEhkTsZSW9QWZBP2Lgds1XqGsQ3lK3DEGewm+xwI
         GH1AC6G3HJ9Jf6OLsxYma9mulb4/OgDD+36QrgJ5wJPzP5jNbAaS8+fUZ3TGjr4ui/ah
         5TFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV9sB3H0OApKii6wER6jBnK6OiqIJQTjFEqduSk6zHDZ/4fx3+5
	KIQclXf3apYqO5sv3dW2ajMvftLMNav5N0FHf/UGib/EzN9FvX22gMo4WXWLyAqnKnjlYgC6RRU
	TlQETIK4WI+ALA4eyU12h/YVDm3O3C9PM1IaFxb0YlX9KN10hs8gyaXXpSVEsrjdBdA==
X-Received: by 2002:a63:bf0d:: with SMTP id v13mr16831390pgf.186.1556228781078;
        Thu, 25 Apr 2019 14:46:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2w6RiaHu/6yVLmESGbUlibYpUSmG8ah3f6OH3KU2MOVQskp+mLRdih/PMTNxhztPi4aTa
X-Received: by 2002:a63:bf0d:: with SMTP id v13mr16831263pgf.186.1556228779480;
        Thu, 25 Apr 2019 14:46:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228779; cv=none;
        d=google.com; s=arc-20160816;
        b=Y9Kfl+JqkujmcZb74OUUFXrusWAB/qr9hutlRHT2qTs8opm7QsJBwbyXuT3SzonSOi
         JzJGjEjH7JZwANyxRWe6l/Y7+NNsJC5QRd2l1F33QSVeX6Eif0PsaZgo+Kxv+9yS1bfQ
         h9MeUjY1kV68kyLwrlyXlD761ku1hJ/F8Ea6mhCKpJxBM62gl+dp+4ZYKDvj4EwIHeDt
         tEsZ6Z/4nAnlbfHmWM9Q2+wvLgNfhYEAnqsGRlRi92q2zOgwHTDMRGYOFeLmuK0FDrS9
         bqeLohEumyxLE7n9UDcB6mS8tPy6nxQgRflf4LrTEDAw0KDUrIshXVwEqAhYA/SbPPPK
         /+rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=DlbkNDgTSlJ8f9jY3c6eZpPtmL2owk7d0TJfhnEqe/g=;
        b=cxWWJ1EpVZ4Zjyr8M25cA0+Q5TnU8uP3/pR77j0NTk0gXXk9k57Zgj11OO0Lp1skPC
         qwwLu1Ffc9BjqEc+HJLALE1kZkK/8M47/Egeh+TLccHTPb1NpGoVGC/XlWuETlwB1NpV
         +195ias4ao605W27E2Jav/EdOwDr3VI2tYxZ2WrqBqZYzmHgH/MqGEmqXFf470cI34km
         VmMPgkfuMum0LJPXeSWlvcA9JSS7zfm0H6+1Ba8TH2zweYBe6hOjjuAqTt+tbd/jCW0Z
         ekIdh2WOzJ9nrQypgexPvXZBC0qEG0Mh01EVC+t4xaA5/8lPjjTrCcTmRJ9Pbfya/8o2
         nksg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m186si9995841pfb.96.2019.04.25.14.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLY8pB091382
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:19 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3jg76d6r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:18 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:15 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:11 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLk9wg54984822
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:10 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D3B725205A;
	Thu, 25 Apr 2019 21:46:09 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 4AED55204E;
	Thu, 25 Apr 2019 21:46:07 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:06 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org, x86@kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
Date: Fri, 26 Apr 2019 00:45:49 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0028-0000-0000-000003670D68
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0029-0000-0000-00002426659D
Message-Id: <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When enabled, the system call isolation (SCI) would allow execution of the
system calls with reduced page tables. These page tables are almost
identical to the user page tables in PTI. The only addition is the code
page containing system call entry function that will continue exectution
after the context switch.

Unlike PTI page tables, there is no sharing at higher levels and all the
hierarchy for SCI page tables is cloned.

The SCI page tables are created when a system call that requires isolation
is executed for the first time.

Whenever a system call should be executed in the isolated environment, the
context is switched to the SCI page tables. Any further access to the
kernel memory will generate a page fault. The page fault handler can verify
that the access is safe and grant it or kill the task otherwise.

The initial SCI implementation allows access to any kernel data, but it
limits access to the code in the following way:
* calls and jumps to known code symbols without offset are allowed
* calls and jumps into a known symbol with offset are allowed only if that
symbol was already accessed and the offset is in the next page
* all other code access are blocked

After the isolated system call finishes, the mappings created during its
execution are cleared.

The entire SCI page table is lazily freed at task exit() time.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/include/asm/sci.h |  55 ++++
 arch/x86/mm/Makefile       |   1 +
 arch/x86/mm/init.c         |   2 +
 arch/x86/mm/sci.c          | 608 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h      |   5 +
 include/linux/sci.h        |  12 +
 6 files changed, 683 insertions(+)
 create mode 100644 arch/x86/include/asm/sci.h
 create mode 100644 arch/x86/mm/sci.c
 create mode 100644 include/linux/sci.h

diff --git a/arch/x86/include/asm/sci.h b/arch/x86/include/asm/sci.h
new file mode 100644
index 0000000..0b56200
--- /dev/null
+++ b/arch/x86/include/asm/sci.h
@@ -0,0 +1,55 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _ASM_X86_SCI_H
+#define _ASM_X86_SCI_H
+
+#ifdef CONFIG_SYSCALL_ISOLATION
+
+struct sci_task_data {
+	pgd_t		*pgd;
+	unsigned long	cr3_offset;
+	unsigned long	backtrace_size;
+	unsigned long	*backtrace;
+	unsigned long	ptes_count;
+	pte_t		**ptes;
+};
+
+struct sci_percpu_data {
+	unsigned long		sci_syscall;
+	unsigned long		sci_cr3_offset;
+};
+
+DECLARE_PER_CPU_PAGE_ALIGNED(struct sci_percpu_data, cpu_sci);
+
+void sci_check_boottime_disable(void);
+
+int sci_init(struct task_struct *tsk);
+void sci_exit(struct task_struct *tsk);
+
+bool sci_verify_and_map(struct pt_regs *regs, unsigned long addr,
+			unsigned long hw_error_code);
+void sci_clear_data(void);
+
+static inline void sci_switch_to(struct task_struct *next)
+{
+	this_cpu_write(cpu_sci.sci_syscall, next->in_isolated_syscall);
+	if (next->sci)
+		this_cpu_write(cpu_sci.sci_cr3_offset, next->sci->cr3_offset);
+}
+
+#else /* CONFIG_SYSCALL_ISOLATION */
+
+static inline void sci_check_boottime_disable(void) {}
+
+static inline bool sci_verify_and_map(struct pt_regs *regs,unsigned long addr,
+				      unsigned long hw_error_code)
+{
+	return true;
+}
+
+static inline void sci_clear_data(void) {}
+
+static inline void sci_switch_to(struct task_struct *next) {}
+
+#endif /* CONFIG_SYSCALL_ISOLATION */
+
+#endif /* _ASM_X86_SCI_H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd..9a728b7 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_X86_INTEL_MPX)			+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)	+= pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY)			+= kaslr.o
 obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
+obj-$(CONFIG_SYSCALL_ISOLATION)			+= sci.o
 
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index f905a23..b6e2db4 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -22,6 +22,7 @@
 #include <asm/hypervisor.h>
 #include <asm/cpufeature.h>
 #include <asm/pti.h>
+#include <asm/sci.h>
 
 /*
  * We need to define the tracepoints somewhere, and tlb.c
@@ -648,6 +649,7 @@ void __init init_mem_mapping(void)
 	unsigned long end;
 
 	pti_check_boottime_disable();
+	sci_check_boottime_disable();
 	probe_page_size_mask();
 	setup_pcid();
 
diff --git a/arch/x86/mm/sci.c b/arch/x86/mm/sci.c
new file mode 100644
index 0000000..e7ddec1
--- /dev/null
+++ b/arch/x86/mm/sci.c
@@ -0,0 +1,608 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright(c) 2019 IBM Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * Author: Mike Rapoport <rppt@linux.ibm.com>
+ *
+ * This code is based on pti.c, see it for the original copyrights
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/bug.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/kallsyms.h>
+#include <linux/slab.h>
+#include <linux/debugfs.h>
+#include <linux/sizes.h>
+#include <linux/sci.h>
+#include <linux/random.h>
+
+#include <asm/cpufeature.h>
+#include <asm/hypervisor.h>
+#include <asm/cmdline.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+#include <asm/desc.h>
+#include <asm/sections.h>
+#include <asm/traps.h>
+
+#undef pr_fmt
+#define pr_fmt(fmt)     "SCI: " fmt
+
+#define SCI_MAX_PTES 256
+#define SCI_MAX_BACKTRACE 64
+
+__visible DEFINE_PER_CPU_PAGE_ALIGNED(struct sci_percpu_data, cpu_sci);
+
+/*
+ * Walk the shadow copy of the page tables to PMD level (optionally)
+ * trying to allocate page table pages on the way down.
+ *
+ * Allocation failures are not handled here because the entire page
+ * table will be freed in sci_free_pagetable.
+ *
+ * Returns a pointer to a PMD on success, or NULL on failure.
+ */
+static pmd_t *sci_pagetable_walk_pmd(struct mm_struct *mm,
+				     pgd_t *pgd, unsigned long address)
+{
+	p4d_t *p4d;
+	pud_t *pud;
+
+	p4d = p4d_alloc(mm, pgd, address);
+	if (!p4d)
+		return NULL;
+
+	pud = pud_alloc(mm, p4d, address);
+	if (!pud)
+		return NULL;
+
+	return pmd_alloc(mm, pud, address);
+}
+
+/*
+ * Walk the shadow copy of the page tables to PTE level (optionally)
+ * trying to allocate page table pages on the way down.
+ *
+ * Returns a pointer to a PTE on success, or NULL on failure.
+ */
+static pte_t *sci_pagetable_walk_pte(struct mm_struct *mm,
+				     pgd_t *pgd, unsigned long address)
+{
+	pmd_t *pmd = sci_pagetable_walk_pmd(mm, pgd, address);
+
+	if (!pmd)
+		return NULL;
+
+	if (__pte_alloc(mm, pmd))
+		return NULL;
+
+	return pte_offset_kernel(pmd, address);
+}
+
+/*
+ * Clone a single page mapping
+ *
+ * The new mapping in the @target_pgdp is always created for base
+ * page. If the orinal page table has the page at @addr mapped at PMD
+ * level, we anyway create at PTE in the target page table and map
+ * only PAGE_SIZE.
+ */
+static pte_t *sci_clone_page(struct mm_struct *mm,
+			     pgd_t *pgdp, pgd_t *target_pgdp,
+			     unsigned long addr)
+{
+	pte_t *pte, *target_pte, ptev;
+	pgd_t *pgd, *target_pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_pgd(pgdp, addr);
+	if (pgd_none(*pgd))
+		return NULL;
+
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return NULL;
+
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return NULL;
+
+	target_pgd = pgd_offset_pgd(target_pgdp, addr);
+
+	if (pmd_large(*pmd)) {
+		pgprot_t flags;
+		unsigned long pfn;
+
+		/*
+		 * We map only PAGE_SIZE rather than the entire huge page.
+		 * The PTE will have the same pgprot bits as the origial PMD
+		 */
+		flags = pte_pgprot(pte_clrhuge(*(pte_t *)pmd));
+		pfn = pmd_pfn(*pmd) + pte_index(addr);
+		ptev = pfn_pte(pfn, flags);
+	} else {
+		pte = pte_offset_kernel(pmd, addr);
+		if (pte_none(*pte) || !(pte_flags(*pte) & _PAGE_PRESENT))
+			return NULL;
+
+		ptev = *pte;
+	}
+
+	target_pte = sci_pagetable_walk_pte(mm, target_pgd, addr);
+	if (!target_pte)
+		return NULL;
+
+	*target_pte = ptev;
+
+	return target_pte;
+}
+
+/*
+ * Clone a range keeping the same leaf mappings
+ *
+ * If the range has holes they are simply skipped
+ */
+static int sci_clone_range(struct mm_struct *mm,
+			   pgd_t *pgdp, pgd_t *target_pgdp,
+			   unsigned long start, unsigned long end)
+{
+	unsigned long addr;
+
+	/*
+	 * Clone the populated PMDs which cover start to end. These PMD areas
+	 * can have holes.
+	 */
+	for (addr = start; addr < end;) {
+		pte_t *pte, *target_pte;
+		pgd_t *pgd, *target_pgd;
+		pmd_t *pmd, *target_pmd;
+		p4d_t *p4d;
+		pud_t *pud;
+
+		/* Overflow check */
+		if (addr < start)
+			break;
+
+		pgd = pgd_offset_pgd(pgdp, addr);
+		if (pgd_none(*pgd))
+			return 0;
+
+		p4d = p4d_offset(pgd, addr);
+		if (p4d_none(*p4d))
+			return 0;
+
+		pud = pud_offset(p4d, addr);
+		if (pud_none(*pud)) {
+			addr += PUD_SIZE;
+			continue;
+		}
+
+		pmd = pmd_offset(pud, addr);
+		if (pmd_none(*pmd)) {
+			addr += PMD_SIZE;
+			continue;
+		}
+
+		target_pgd = pgd_offset_pgd(target_pgdp, addr);
+
+		if (pmd_large(*pmd)) {
+			target_pmd = sci_pagetable_walk_pmd(mm, target_pgd,
+							    addr);
+			if (!target_pmd)
+				return -ENOMEM;
+
+			*target_pmd = *pmd;
+
+			addr += PMD_SIZE;
+			continue;
+		} else {
+			pte = pte_offset_kernel(pmd, addr);
+			if (pte_none(*pte)) {
+				addr += PAGE_SIZE;
+				continue;
+			}
+
+			target_pte = sci_pagetable_walk_pte(mm, target_pgd,
+							    addr);
+			if (!target_pte)
+				return -ENOMEM;
+
+			*target_pte = *pte;
+
+			addr += PAGE_SIZE;
+		}
+	}
+
+	return 0;
+}
+
+/*
+ * we have to map the syscall entry because we'll fault there after
+ * CR3 switch and before the verifier is able to detect this as proper
+ * access
+ */
+extern void do_syscall_64(unsigned long nr, struct pt_regs *regs);
+unsigned long syscall_entry_addr = (unsigned long)do_syscall_64;
+
+static void sci_reset_backtrace(struct sci_task_data *sci)
+{
+	memset(sci->backtrace, 0, sci->backtrace_size);
+	sci->backtrace[0] = syscall_entry_addr;
+	sci->backtrace_size = 1;
+}
+
+static inline void sci_sync_user_pagetable(struct task_struct *tsk)
+{
+	pgd_t *u_pgd = kernel_to_user_pgdp(tsk->mm->pgd);
+	pgd_t *sci_pgd = tsk->sci->pgd;
+
+	down_write(&tsk->mm->mmap_sem);
+	memcpy(sci_pgd, u_pgd, PGD_KERNEL_START * sizeof(pgd_t));
+	up_write(&tsk->mm->mmap_sem);
+}
+
+static int sci_free_pte_range(struct mm_struct *mm, pmd_t *pmd)
+{
+	pte_t *ptep = pte_offset_kernel(pmd, 0);
+
+	pmd_clear(pmd);
+	pte_free(mm, virt_to_page(ptep));
+	mm_dec_nr_ptes(mm);
+
+	return 0;
+}
+
+static int sci_free_pmd_range(struct mm_struct *mm, pud_t *pud)
+{
+	pmd_t *pmd, *pmdp;
+	int i;
+
+	pmdp = pmd_offset(pud, 0);
+
+	for (i = 0, pmd = pmdp; i < PTRS_PER_PMD; i++, pmd++)
+		if (!pmd_none(*pmd) && !pmd_large(*pmd))
+			sci_free_pte_range(mm, pmd);
+
+	pud_clear(pud);
+	pmd_free(mm, pmdp);
+	mm_dec_nr_pmds(mm);
+
+	return 0;
+}
+
+static int sci_free_pud_range(struct mm_struct *mm, p4d_t *p4d)
+{
+	pud_t *pud, *pudp;
+	int i;
+
+	pudp = pud_offset(p4d, 0);
+
+	for (i = 0, pud = pudp; i < PTRS_PER_PUD; i++, pud++)
+		if (!pud_none(*pud))
+			sci_free_pmd_range(mm, pud);
+
+	p4d_clear(p4d);
+	pud_free(mm, pudp);
+	mm_dec_nr_puds(mm);
+
+	return 0;
+}
+
+static int sci_free_p4d_range(struct mm_struct *mm, pgd_t *pgd)
+{
+	p4d_t *p4d, *p4dp;
+	int i;
+
+	p4dp = p4d_offset(pgd, 0);
+
+	for (i = 0, p4d = p4dp; i < PTRS_PER_P4D; i++, p4d++)
+		if (!p4d_none(*p4d))
+			sci_free_pud_range(mm, p4d);
+
+	pgd_clear(pgd);
+	p4d_free(mm, p4dp);
+
+	return 0;
+}
+
+static int sci_free_pagetable(struct task_struct *tsk, pgd_t *sci_pgd)
+{
+	struct mm_struct *mm = tsk->mm;
+	pgd_t *pgd, *pgdp = sci_pgd;
+
+#ifdef SCI_SHARED_PAGE_TABLES
+	int i;
+
+	for (i = KERNEL_PGD_BOUNDARY; i < PTRS_PER_PGD; i++) {
+		if (i >= pgd_index(VMALLOC_START) &&
+		    i < pgd_index(__START_KERNEL_map))
+			continue;
+		pgd = pgdp + i;
+		sci_free_p4d_range(mm, pgd);
+	}
+#else
+	for (pgd = pgdp + KERNEL_PGD_BOUNDARY; pgd < pgdp + PTRS_PER_PGD; pgd++)
+		if (!pgd_none(*pgd))
+			sci_free_p4d_range(mm, pgd);
+#endif
+
+
+	return 0;
+}
+
+static int sci_pagetable_init(struct task_struct *tsk, pgd_t *sci_pgd)
+{
+	struct mm_struct *mm = tsk->mm;
+	pgd_t *k_pgd = mm->pgd;
+	pgd_t *u_pgd = kernel_to_user_pgdp(k_pgd);
+	unsigned long stack = (unsigned long)tsk->stack;
+	unsigned long addr;
+	unsigned int cpu;
+	pte_t *pte;
+	int ret;
+
+	/* copy the kernel part of user visible page table */
+	ret = sci_clone_range(mm, u_pgd, sci_pgd, CPU_ENTRY_AREA_BASE,
+			      CPU_ENTRY_AREA_BASE + CPU_ENTRY_AREA_MAP_SIZE);
+	if (ret)
+		goto err_free_pagetable;
+
+	ret = sci_clone_range(mm, u_pgd, sci_pgd,
+			      (unsigned long) __entry_text_start,
+			      (unsigned long) __irqentry_text_end);
+	if (ret)
+		goto err_free_pagetable;
+
+	ret = sci_clone_range(mm, mm->pgd, sci_pgd,
+			      stack, stack + THREAD_SIZE);
+	if (ret)
+		goto err_free_pagetable;
+
+	ret = -ENOMEM;
+	for_each_possible_cpu(cpu) {
+		addr = (unsigned long)&per_cpu(cpu_sci, cpu);
+		pte = sci_clone_page(mm, k_pgd, sci_pgd, addr);
+		if (!pte)
+			goto err_free_pagetable;
+	}
+
+	/* plus do_syscall_64 */
+	pte = sci_clone_page(mm, k_pgd, sci_pgd, syscall_entry_addr);
+	if (!pte)
+		goto err_free_pagetable;
+
+	return 0;
+
+err_free_pagetable:
+	sci_free_pagetable(tsk, sci_pgd);
+	return ret;
+}
+
+static int sci_alloc(struct task_struct *tsk)
+{
+	struct sci_task_data *sci;
+	int err = -ENOMEM;
+
+	if (!static_cpu_has(X86_FEATURE_SCI))
+		return 0;
+
+	if (tsk->sci)
+		return 0;
+
+	sci = kzalloc(sizeof(*sci), GFP_KERNEL);
+	if (!sci)
+		return err;
+
+	sci->ptes = kcalloc(SCI_MAX_PTES, sizeof(*sci->ptes), GFP_KERNEL);
+	if (!sci->ptes)
+		goto free_sci;
+
+	sci->backtrace = kcalloc(SCI_MAX_BACKTRACE, sizeof(*sci->backtrace),
+				  GFP_KERNEL);
+	if (!sci->backtrace)
+		goto free_ptes;
+
+	sci->pgd = (pgd_t *)get_zeroed_page(GFP_KERNEL);
+	if (!sci->pgd)
+		goto free_backtrace;
+
+	err = sci_pagetable_init(tsk, sci->pgd);
+	if (err)
+		goto free_pgd;
+
+	sci_reset_backtrace(sci);
+
+	tsk->sci = sci;
+
+	return 0;
+
+free_pgd:
+	free_page((unsigned long)sci->pgd);
+free_backtrace:
+	kfree(sci->backtrace);
+free_ptes:
+	kfree(sci->ptes);
+free_sci:
+	kfree(sci);
+	return err;
+}
+
+int sci_init(struct task_struct *tsk)
+{
+	if (!tsk->sci) {
+		int err = sci_alloc(tsk);
+
+		if (err)
+			return err;
+	}
+
+	sci_sync_user_pagetable(tsk);
+
+	return 0;
+}
+
+void sci_exit(struct task_struct *tsk)
+{
+	struct sci_task_data *sci = tsk->sci;
+
+	if (!static_cpu_has(X86_FEATURE_SCI))
+		return;
+
+	if (!sci)
+		return;
+
+	sci_free_pagetable(tsk, tsk->sci->pgd);
+	free_page((unsigned long)sci->pgd);
+	kfree(sci->backtrace);
+	kfree(sci->ptes);
+	kfree(sci);
+}
+
+void sci_clear_data(void)
+{
+	struct sci_task_data *sci = current->sci;
+	int i;
+
+	if (WARN_ON(!sci))
+		return;
+
+	for (i = 0; i < sci->ptes_count; i++)
+		pte_clear(NULL, 0, sci->ptes[i]);
+
+	memset(sci->ptes, 0, sci->ptes_count);
+	sci->ptes_count = 0;
+
+	sci_reset_backtrace(sci);
+}
+
+static void sci_add_pte(struct sci_task_data *sci, pte_t *pte)
+{
+	int i;
+
+	for (i = sci->ptes_count - 1; i >= 0; i--)
+		if (pte == sci->ptes[i])
+			return;
+	sci->ptes[sci->ptes_count++] = pte;
+}
+
+static void sci_add_rip(struct sci_task_data *sci, unsigned long rip)
+{
+	int i;
+
+	for (i = sci->backtrace_size - 1; i >= 0; i--)
+		if (rip == sci->backtrace[i])
+			return;
+
+	sci->backtrace[sci->backtrace_size++] = rip;
+}
+
+static bool sci_verify_code_access(struct sci_task_data *sci,
+				   struct pt_regs *regs, unsigned long addr)
+{
+	char namebuf[KSYM_NAME_LEN];
+	unsigned long offset, size;
+	const char *symbol;
+	char *modname;
+
+
+	/* instruction fetch outside kernel or module text */
+	if (!(is_kernel_text(addr) || is_module_text_address(addr)))
+		return false;
+
+	/* no symbol matches the address */
+	symbol = kallsyms_lookup(addr, &size, &offset, &modname, namebuf);
+	if (!symbol)
+		return false;
+
+	/* BPF or ftrace? */
+	if (symbol != namebuf)
+		return false;
+
+	/* access in the middle of a function */
+	if (offset) {
+		int i = 0;
+
+		for (i = sci->backtrace_size - 1; i >= 0; i--) {
+			unsigned long rip = sci->backtrace[i];
+
+			/* allow jumps to the next page of already mapped one */
+			if ((addr >> PAGE_SHIFT) == ((rip >> PAGE_SHIFT) + 1))
+				return true;
+		}
+
+		return false;
+	}
+
+	sci_add_rip(sci, regs->ip);
+
+	return true;
+}
+
+bool sci_verify_and_map(struct pt_regs *regs, unsigned long addr,
+			unsigned long hw_error_code)
+{
+	struct task_struct *tsk = current;
+	struct mm_struct *mm = tsk->mm;
+	struct sci_task_data *sci = tsk->sci;
+	pte_t *pte;
+
+	/* run out of room for metadata, can't grant access */
+	if (sci->ptes_count >= SCI_MAX_PTES ||
+	    sci->backtrace_size >= SCI_MAX_BACKTRACE)
+		return false;
+
+	/* only code access is checked */
+	if (hw_error_code & X86_PF_INSTR &&
+	    !sci_verify_code_access(sci, regs, addr))
+		return false;
+
+	pte = sci_clone_page(mm, mm->pgd, sci->pgd, addr);
+	if (!pte)
+		return false;
+
+	sci_add_pte(sci, pte);
+
+	return true;
+}
+
+void __init sci_check_boottime_disable(void)
+{
+	char arg[5];
+	int ret;
+
+	if (!cpu_feature_enabled(X86_FEATURE_PCID)) {
+		pr_info("System call isolation requires PCID\n");
+		return;
+	}
+
+	/* Assume SCI is disabled unless explicitly overridden. */
+	ret = cmdline_find_option(boot_command_line, "sci", arg, sizeof(arg));
+	if (ret == 2 && !strncmp(arg, "on", 2)) {
+		setup_force_cpu_cap(X86_FEATURE_SCI);
+		pr_info("System call isolation is enabled\n");
+		return;
+	}
+
+	pr_info("System call isolation is disabled\n");
+}
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f9b43c9..cdcdb07 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1202,6 +1202,11 @@ struct task_struct {
 	unsigned long			prev_lowest_stack;
 #endif
 
+#ifdef CONFIG_SYSCALL_ISOLATION
+	unsigned long			in_isolated_syscall;
+	struct sci_task_data		*sci;
+#endif
+
 	/*
 	 * New fields for task_struct should be added above here, so that
 	 * they are included in the randomized portion of task_struct.
diff --git a/include/linux/sci.h b/include/linux/sci.h
new file mode 100644
index 0000000..7a6beac
--- /dev/null
+++ b/include/linux/sci.h
@@ -0,0 +1,12 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _LINUX_SCI_H
+#define _LINUX_SCI_H
+
+#ifdef CONFIG_SYSCALL_ISOLATION
+#include <asm/sci.h>
+#else
+static inline int sci_init(struct task_struct *tsk) { return 0; }
+static inline void sci_exit(struct task_struct *tsk) {}
+#endif
+
+#endif /* _LINUX_SCI_H */
-- 
2.7.4


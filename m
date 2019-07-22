Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62D1EC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16D7E21BE6
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16D7E21BE6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9FC8E0015; Mon, 22 Jul 2019 11:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF30C8E000E; Mon, 22 Jul 2019 11:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F98D8E0015; Mon, 22 Jul 2019 11:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0E88E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so26515927edd.22
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oY2sFz5yZBlH6BUqTF+AgQqmbr3LE7oatd7KC5QobtM=;
        b=DiYKm/EU30xJEyrfVKsPJloOs/NWLg6D5XXDJwstjVzmUz5UmFyGLPdvb2vnRf7vuC
         Zclo8AsjAvkzeZ7s+MKlPQC2NeEWhHe3tMa0TdgIMnlBzNtoBxxBmVaxh59ccoJ4c2mp
         rHOf3cG0mAI6iIp72E0SaHfcAHbmn5z5nwZd7vzOVHo12yyD6owV3eVOvHFh1Tm56r4q
         wdlTK8UE8s9Dc+fnWr09C3SjlB+Js0TcVsQUt2rvn66DFYupd5MIbC5raCnZ8NN4BNHp
         /PVZQK+pqjwWDI+Ge9gqXw71pdvr1kckE6vffY2/aiEhRAJB/2aYEQz3CfMqC5Z14YGT
         2pyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUnpS+g5H/V2KLYjr24FNuyPvyDsDz8DM5t4sQvYiw0ZpN7Y5RM
	IqLdGFBru+AlAWyYg6FXv2bX5WMzSDs31XXzwi2dlsI/VfrHFy+8/mGHVf2w37UVm3/PNux+Ko4
	CB42Ro+Ex5mj1xRUIwcuUBTlnQyK4igeLTrP/HANkbcaMIXcHOJylkjIb+i0J4DCqkQ==
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr53803723ejb.245.1563810200786;
        Mon, 22 Jul 2019 08:43:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7NEbO8RllI2GLKzMvuXA2LDIdRWkc8spuroqOE97nwHT8doK4li5WrKuInP6lRYP0yLNu
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr53803667ejb.245.1563810199771;
        Mon, 22 Jul 2019 08:43:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810199; cv=none;
        d=google.com; s=arc-20160816;
        b=TaeKqWv41V0/EpHoXQGvlof765Fp9m8OWPZGJBesh2Ve51sa571KBwJ+ac+BDhNXWN
         zxUAKAwDl0oTbHS5PiKrDbfx06F4PxyCkzKmJf6MqxFsSVGGdVgSYlG6d8ba0NX7hfIM
         yUAGhU6+q1UFz52vvsBqM1gzLgb91K42ke8CiDhDQCNpyU1w28wXYaN1nqffIjOj4iH5
         xWpqoKWJZWTzkuI02i5FZ+OaOH8PXMCwLVgJS1RNjaLPtqvTxbYUHv7LsgvAMYoddGsV
         aMqGDRKxAP3gR1QT0tvWeeaMmgbZnNouJv5pHssyNOj5ATRY1x6l0qamLA8FLEAbI8bq
         1/JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oY2sFz5yZBlH6BUqTF+AgQqmbr3LE7oatd7KC5QobtM=;
        b=m53gdyaoxjXo3vMUhs1y/FSGWvIzdXOKH0StO1bTAKfYgUjDtUyeh6/aMIvtuswzKM
         gJ7vlrEOjBbUO6YIJscBzg89W5eyzvsrJwyZG9HyFQMVK0n3cnFXjNrQm+7tsciA6Yzl
         yQsn9w5uSJ3AISaOHjcAKgR4Lsn8crznBkWpUaT82Mk+xoO1fEFhO5zHf5gKlTHpOxyq
         BTxCD/b04Gy7QdPGsQ3BuyI3hs66dSXRKY1uWNnIgEKbBj6ex3SHxa6xEZYQt2BNCd8o
         UrefJt1rg0wJXNIENArtqw418cGTQlNaDMgZDIW8YCUvrG8EUQoT4hMBjEBAJE9Q+QnX
         mPjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h4si704888ejj.127.2019.07.22.08.43.19
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D653C1509;
	Mon, 22 Jul 2019 08:43:18 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4D1383F694;
	Mon, 22 Jul 2019 08:43:16 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 19/21] mm: Add generic ptdump
Date: Mon, 22 Jul 2019 16:42:08 +0100
Message-Id: <20190722154210.42799-20-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a generic version of page table dumping that architectures can
opt-in to

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/ptdump.h |  19 +++++
 mm/Kconfig.debug       |  21 ++++++
 mm/Makefile            |   1 +
 mm/ptdump.c            | 161 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 202 insertions(+)
 create mode 100644 include/linux/ptdump.h
 create mode 100644 mm/ptdump.c

diff --git a/include/linux/ptdump.h b/include/linux/ptdump.h
new file mode 100644
index 000000000000..eb8e78154be3
--- /dev/null
+++ b/include/linux/ptdump.h
@@ -0,0 +1,19 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#ifndef _LINUX_PTDUMP_H
+#define _LINUX_PTDUMP_H
+
+struct ptdump_range {
+	unsigned long start;
+	unsigned long end;
+};
+
+struct ptdump_state {
+	void (*note_page)(struct ptdump_state *st, unsigned long addr,
+			  int level, unsigned long val);
+	const struct ptdump_range *range;
+};
+
+void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm);
+
+#endif /* _LINUX_PTDUMP_H */
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 82b6a20898bd..7ad939b7140f 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -115,3 +115,24 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config GENERIC_PTDUMP
+	bool
+
+config PTDUMP_CORE
+	bool
+
+config PTDUMP_DEBUGFS
+	bool "Export kernel pagetable layout to userspace via debugfs"
+	depends on DEBUG_KERNEL
+	depends on DEBUG_FS
+	depends on GENERIC_PTDUMP
+	select PTDUMP_CORE
+	help
+	  Say Y here if you want to show the kernel pagetable layout in a
+	  debugfs file. This information is only useful for kernel developers
+	  who are working in architecture specific areas of the kernel.
+	  It is probably not a good idea to enable this feature in a production
+	  kernel.
+
+	  If in doubt, say N.
diff --git a/mm/Makefile b/mm/Makefile
index 338e528ad436..750a4c12d5da 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -104,3 +104,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM_MIRROR) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_PTDUMP_CORE) += ptdump.o
diff --git a/mm/ptdump.c b/mm/ptdump.c
new file mode 100644
index 000000000000..39befc9088b8
--- /dev/null
+++ b/mm/ptdump.c
@@ -0,0 +1,161 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <linux/mm.h>
+#include <linux/ptdump.h>
+#include <linux/kasan.h>
+
+static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pgd_t val = READ_ONCE(*pgd);
+
+	if (pgd_leaf(val))
+		st->note_page(st, addr, 1, pgd_val(val));
+
+	return 0;
+}
+
+static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	p4d_t val = READ_ONCE(*p4d);
+
+	if (p4d_leaf(val))
+		st->note_page(st, addr, 2, p4d_val(val));
+
+	return 0;
+}
+
+static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pud_t val = READ_ONCE(*pud);
+
+	if (pud_leaf(val))
+		st->note_page(st, addr, 3, pud_val(val));
+
+	return 0;
+}
+
+static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pmd_t val = READ_ONCE(*pmd);
+
+	if (pmd_leaf(val))
+		st->note_page(st, addr, 4, pmd_val(val));
+
+	return 0;
+}
+
+static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, 5, pte_val(READ_ONCE(*pte)));
+
+	return 0;
+}
+
+#ifdef CONFIG_KASAN
+/*
+ * This is an optimization for KASAN=y case. Since all kasan page tables
+ * eventually point to the kasan_early_shadow_page we could call note_page()
+ * right away without walking through lower level page tables. This saves
+ * us dozens of seconds (minutes for 5-level config) while checking for
+ * W+X mapping or reading kernel_page_tables debugfs file.
+ */
+static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
+				    unsigned long addr)
+{
+	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
+#ifdef CONFIG_X86
+	    (pgtable_l5_enabled() &&
+			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
+#endif
+	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
+		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
+		return true;
+	}
+	return false;
+}
+#else
+static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
+				    unsigned long addr)
+{
+	return false;
+}
+#endif
+
+static int ptdump_test_p4d(unsigned long addr, unsigned long next,
+			   p4d_t *p4d, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, p4d, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_test_pud(unsigned long addr, unsigned long next,
+			   pud_t *pud, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, pud, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_test_pmd(unsigned long addr, unsigned long next,
+			   pmd_t *pmd, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, pmd, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_hole(unsigned long addr, unsigned long next,
+		       struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, -1, 0);
+
+	return 0;
+}
+
+void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm)
+{
+	struct mm_walk walk = {
+		.mm		= mm,
+		.pgd_entry	= ptdump_pgd_entry,
+		.p4d_entry	= ptdump_p4d_entry,
+		.pud_entry	= ptdump_pud_entry,
+		.pmd_entry	= ptdump_pmd_entry,
+		.pte_entry	= ptdump_pte_entry,
+		.test_p4d	= ptdump_test_p4d,
+		.test_pud	= ptdump_test_pud,
+		.test_pmd	= ptdump_test_pmd,
+		.pte_hole	= ptdump_hole,
+		.private	= st
+	};
+	const struct ptdump_range *range = st->range;
+
+	down_read(&mm->mmap_sem);
+	while (range->start != range->end) {
+		walk_page_range(range->start, range->end, &walk);
+		range++;
+	}
+	up_read(&mm->mmap_sem);
+
+	/* Flush out the last page */
+	st->note_page(st, 0, 0, 0);
+}
-- 
2.20.1


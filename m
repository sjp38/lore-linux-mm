Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ACB0C32754
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3955F217D4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3955F217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C56258E0027; Wed, 31 Jul 2019 11:47:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB96F8E0003; Wed, 31 Jul 2019 11:47:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A81648E0027; Wed, 31 Jul 2019 11:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53FAB8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so42689443edt.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r83NP4DGUKh+mGCDCmNnM30wzJ7ALCL9e17lMTyJP30=;
        b=TZZhdMc008FxAGVW/uuesVfgthBk5ADXy+5LWtGWfEXj5EI+yjf7gaZ2B7L0VRm6CN
         OA+6zA80Zwtwh4DurQKNOa/0JIqudHgeqdajVnOSiIYmqtmX1jczQox21mZcWpl1aoRC
         28J3hV5rqhZT1TU7p0pvqoisA3ziMiGD0lM4IqMKuOLqW357DAsejdsyOHEFpLwC8Hbr
         +q4oXA+0dwinATUA4WHa8G6iwEpbmiX5NrlPqUE0pImb6g+UKKQ7OiktARvHPulhgeG2
         M5/7/kjnGsAXGpsVG++F6MWx+sBHhdWYX7lXkKfBlyjU/2Ea2fibRoc4j4Eo3JxqxjhX
         mUXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAX/ACQ6mTqgR+zNPFxcbufg7idxg5kgKZAfc6EKzBsWHlW9wgEu
	YKV5u3egsKq7dSY0xf6C9B8sDn5eTb3VdpBkq49sk9xIQKS4jyl7SBHtVy0OUISKwvCTxVYPO7b
	pmdqBqes+cKrZqXyl3xpBqrJBLZYB2YOF8SgcJhVtx8FCunoNBoOnHrFJaG1n6JeUzA==
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr106237907edg.110.1564588028884;
        Wed, 31 Jul 2019 08:47:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJBaFpn1CmIGEwaqZ/5rtJ3cJihquCUtwdz1dvEKl985V0ZMMHMw/91CBeCfw4kEbuSUJ/
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr106237841edg.110.1564588027964;
        Wed, 31 Jul 2019 08:47:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588027; cv=none;
        d=google.com; s=arc-20160816;
        b=G47NDS6loEkHZFkACWK2+peNUrkY7mI4cAv7JM5shO2Q0u9N5inYcpwGtj9aYOjXxE
         7j+kE76w8RaUUZFpdXj/KUKIj/fniQPXQb5LCNDTDaUKw8fzJiSMzq2XpqSUi/NfDkyX
         OiNaLqUkdO88wZfnIrsCP93BZxeNkrsNUOvmjqjj5O5IxqHrlZ0OPG8+Lo7syVa3yajK
         Do1AAw6IR7HuGZF2SyD/3yMRgD5XOJINpirSXtoAMhArP/EsfavSh+aTpbfs+kMvOON9
         xq9ULyXfvHL73ms9whne/DtbZ8MZEaLbVYvJNVAfndPQkNaoGUMNkjmLhxRVgBD/7MrE
         wLtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r83NP4DGUKh+mGCDCmNnM30wzJ7ALCL9e17lMTyJP30=;
        b=ZEtzDRw/JSKZ4EYqn5XqPOETinzLPKpX9J3ez02c2uDhN2Px6wlB298lFhk0mTMLmo
         xGTYGNuScDRSRHirJ0k5RvDJBolmokiunpU1REN8GiIiGmXIfvKB0OGETzzzHekwTshb
         AmZueiIBEbkZFwmFqv7ae55/f0w+JxVmOiurJmnivyYcmR8c0Tfnrf7kte6Af6jYNdmK
         5CPrlMjS2Rx/VJmoQhJcbKMN3Cxc2vGeVRCNDO2GE6FKCbOwavZfhNEtXK0Pu8saNvaX
         5Uv6qH+E6EH3WpXBYIxhhXfyZWRdviEVqE/UWPoYpGCA2ZGR0hk2A/u3yncIrZavLTEd
         jQ7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c2si18661120ejm.100.2019.07.31.08.47.07
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:47:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 20E0D1596;
	Wed, 31 Jul 2019 08:47:07 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8C3573F694;
	Wed, 31 Jul 2019 08:47:04 -0700 (PDT)
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
Subject: [PATCH v10 19/22] mm: Add generic ptdump
Date: Wed, 31 Jul 2019 16:46:00 +0100
Message-Id: <20190731154603.41797-20-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
 include/linux/ptdump.h |  19 ++++++
 mm/Kconfig.debug       |  21 ++++++
 mm/Makefile            |   1 +
 mm/ptdump.c            | 151 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 192 insertions(+)
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
index 000000000000..186af468d1a1
--- /dev/null
+++ b/mm/ptdump.c
@@ -0,0 +1,151 @@
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
+static inline int note_kasan_page_table(struct mm_walk *walk,
+					unsigned long addr)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
+	return 1;
+}
+
+static int ptdump_test_p4d(unsigned long addr, unsigned long next,
+			   p4d_t *p4d, struct mm_walk *walk)
+{
+#if CONFIG_PGTABLE_LEVELS > 4
+	if (p4d == lm_alias(kasan_early_shadow_p4d))
+		return note_kasan_page_table(walk, addr);
+#endif
+	return 0;
+}
+
+static int ptdump_test_pud(unsigned long addr, unsigned long next,
+			   pud_t *pud, struct mm_walk *walk)
+{
+#if CONFIG_PGTABLE_LEVELS > 3
+	if (pud == lm_alias(kasan_early_shadow_pud))
+		return note_kasan_page_table(walk, addr);
+#endif
+	return 0;
+}
+
+static int ptdump_test_pmd(unsigned long addr, unsigned long next,
+			   pmd_t *pmd, struct mm_walk *walk)
+{
+#if CONFIG_PGTABLE_LEVELS > 2
+	if (pmd == lm_alias(kasan_early_shadow_pmd))
+		return note_kasan_page_table(walk, addr);
+#endif
+	return 0;
+}
+#endif /* CONFIG_KASAN */
+
+static int ptdump_hole(unsigned long addr, unsigned long next,
+		       int depth, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, depth + 1, 0);
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
+#ifdef CONFIG_KASAN
+		.test_p4d	= ptdump_test_p4d,
+		.test_pud	= ptdump_test_pud,
+		.test_pmd	= ptdump_test_pmd,
+#endif
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


Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E1D0C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA51320673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="gqg0wWjp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA51320673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 508CE6B0007; Tue, 11 Jun 2019 08:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2258A6B0010; Tue, 11 Jun 2019 08:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E766B0007; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6986B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id r84so2053317ljr.22
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=T4ll45PU4kfSDSFIA8ewpcqgrnU8HAKiDusR1hfTMIQ=;
        b=pof+yGzFeMsJh+KCtmtcLRGsmxndQsPuMeE7rWclejJH6HsToUuzNwuIEkgxV++DXq
         nNkN3idrjW+xHti0wdNJceT2rhep9/7HKsGxhCN1dB2QLLV/T2Cp6nNZZnVnJGr4QnXY
         fgiaN6e8gscSXsz58ABuC8xBnzbJlsDDuMFPoK5ALgJtYFxYJNeY9vSy3hdnVf3NrVJr
         bKFPcoA1ZLaaQXORBlndNEjSxQsbPS23gFwitl0rc7R9+zDRK748RTBtFy/yQ+zgVV85
         5teCTcJeNd1YRCJsXB403LVxYhqklGR4pMgHVOJ2BJG9/jtJNV5xjdoHKpzkUDzRs+qR
         FK+g==
X-Gm-Message-State: APjAAAVTBJhgi3GmFCGVYmP0K5yDKCLszbPpvUJzoRY+R6XYgzrS9wT1
	rDw+b9aPCXbiLDHvCDtDRalrNcOpg5n0TpU9UYx1S0wN4A4vmiFXzIzPOaWUd/f6ydA0O3BtWbz
	5dyzANmS1QYgzJpjiLNf9x5RoZTqZAoBo1p8zowyv41lt2ymSX+c1T9Efksm/T8bYDQ==
X-Received: by 2002:a19:3f16:: with SMTP id m22mr36407329lfa.104.1560255930464;
        Tue, 11 Jun 2019 05:25:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylVnOR5gHv1w3ZmbxGjTtxY12sbjgY/ic7RbMb9CsZ/pQ3Tx+7CBjGBg9Vz/Uv/goICkr6
X-Received: by 2002:a19:3f16:: with SMTP id m22mr36407274lfa.104.1560255929188;
        Tue, 11 Jun 2019 05:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255929; cv=none;
        d=google.com; s=arc-20160816;
        b=qVo+sh8uCVaFWvkxQHGKU94vxesUCUVOLA2rtbyRNhVqThPl0UzcgUbnKLDaZDNGtU
         J3f3HxLJkU9j+7EENnrEAm/DeoED8/3n9FKLVIa9C3RYCxnwpsq0xg16h8XYv4HHoC3x
         PFR83Zzj7ogf895CCVXxYYtXNujzGPRKP/Fk1fsTnyyV45Ha7ZZ5XOQW2hsYhN7r3Xq0
         5clEQCV3Jz3WDE7EPloRR+X9TAByBw1HJjSOeSKD8AJ9gcIXJzMCwBPLG83t6XyRRgVS
         37APzwfUSdNyknl2PbZiQ3AjqumIEnMAfOyTwYI1saU7Hp23W/d83DcZRngOIVdP90yP
         zLxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=T4ll45PU4kfSDSFIA8ewpcqgrnU8HAKiDusR1hfTMIQ=;
        b=AMN2LzWWtivFlXcyLsWvgqabWwPsBdY8FJI9XqTQ24N3LwhNbzwpw4xY4AiY32mXbL
         a4xnYMvtz0YXFsWrd/HY4JfMXRmUJ+8QSMhZkESSvAG66bF61wc/loWBTuRmmBbMTiin
         L4h6UbjeWLHf1ksykCeSDYchKV/wtFGd1JHkQTO/3sfC5cvxJpGxxiSSKXPMPgSYapcU
         5J+ZbYsZrAtdnH4YA8ilKyldMsXEiJy9pQDaw0V0yhI0CDWpkMmG3RDEBIJ125yL0F95
         HZrindUKvUVxaa0qvZgQcwhM8ePGz/FfbhbWLi5uyiIi2K+1LFdjuO58SX1ZciyZ62eB
         7szw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gqg0wWjp;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se. [213.80.101.70])
        by mx.google.com with ESMTPS id f15si12711339ljj.159.2019.06.11.05.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) client-ip=213.80.101.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=gqg0wWjp;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id B47663F530;
	Tue, 11 Jun 2019 14:25:23 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=gqg0wWjp;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XNlbMip8T2HR; Tue, 11 Jun 2019 14:25:09 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id C47FD3F7AB;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 73AC9361A96;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560255908;
	bh=vE1EQxmA2FhOs8EwFEFftTUOyx8/23joN2AFJRtsCIs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=gqg0wWjpfCCf7/QvHhCh4Q6P2fAHFcg8ffwp79ROUZanPco+GFTU38ijelVOtxPfw
	 hbxEO6XVlrnZl3d2b35Y9mBAGsIKrr5weDeN4uH9wwqb/AkfIx/3TtNf3ovlcrMktG
	 iQwxk/n72BwX4d1hb9QhJYa6fKTXxEgvQMIhPmDA=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v4 3/9] mm: Add write-protect and clean utilities for address space ranges
Date: Tue, 11 Jun 2019 14:24:48 +0200
Message-Id: <20190611122454.3075-4-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611122454.3075-1-thellstrom@vmwopensource.org>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

Add two utilities to a) write-protect and b) clean all ptes pointing into
a range of an address space.
The utilities are intended to aid in tracking dirty pages (either
driver-allocated system memory or pci device memory).
The write-protect utility should be used in conjunction with
page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
accesses. Typically one would want to use this on sparse accesses into
large memory regions. The clean utility should be used to utilize
hardware dirtying functionality and avoid the overhead of page-faults,
typically on large accesses into small memory regions.

The added file "as_dirty_helpers.c" is initially listed as maintained by
VMware under our DRM driver. If somebody would like it elsewhere,
that's of course no problem.

Notable changes since RFC:
- Added comments to help avoid the usage of these function for VMAs
  it's not intended for. We also do advisory checks on the vm_flags and
  warn on illegal usage.
- Perform the pte modifications the same way softdirty does.
- Add mmu_notifier range invalidation calls.
- Add a config option so that this code is not unconditionally included.
- Tell the mmu_gather code about pending tlb flushes.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
---
 MAINTAINERS           |   1 +
 include/linux/mm.h    |   9 +-
 mm/Kconfig            |   3 +
 mm/Makefile           |   1 +
 mm/as_dirty_helpers.c | 298 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 311 insertions(+), 1 deletion(-)
 create mode 100644 mm/as_dirty_helpers.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 7a2f487ea49a..a55d4ef91b0b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5179,6 +5179,7 @@ T:	git git://people.freedesktop.org/~thomash/linux
 S:	Supported
 F:	drivers/gpu/drm/vmwgfx/
 F:	include/uapi/drm/vmwgfx_drm.h
+F:	mm/as_dirty_helpers.c
 
 DRM DRIVERS
 M:	David Airlie <airlied@linux.ie>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3d06ce2a64af..a0bc2a82917e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2685,7 +2685,14 @@ struct pfn_range_apply {
 };
 extern int apply_to_pfn_range(struct pfn_range_apply *closure,
 			      unsigned long address, unsigned long size);
-
+unsigned long apply_as_wrprotect(struct address_space *mapping,
+				 pgoff_t first_index, pgoff_t nr);
+unsigned long apply_as_clean(struct address_space *mapping,
+			     pgoff_t first_index, pgoff_t nr,
+			     pgoff_t bitmap_pgoff,
+			     unsigned long *bitmap,
+			     pgoff_t *start,
+			     pgoff_t *end);
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
 extern void kernel_poison_pages(struct page *page, int numpages, int enable);
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..5006d0e6a5c7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -765,4 +765,7 @@ config GUP_BENCHMARK
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+config AS_DIRTY_HELPERS
+        bool
+
 endmenu
diff --git a/mm/Makefile b/mm/Makefile
index ac5e5ba78874..f5d412bbc2f7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -104,3 +104,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_AS_DIRTY_HELPERS) += as_dirty_helpers.o
diff --git a/mm/as_dirty_helpers.c b/mm/as_dirty_helpers.c
new file mode 100644
index 000000000000..ccaad41b70bc
--- /dev/null
+++ b/mm/as_dirty_helpers.c
@@ -0,0 +1,298 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/mm.h>
+#include <linux/mm_types.h>
+#include <linux/hugetlb.h>
+#include <linux/bitops.h>
+#include <linux/mmu_notifier.h>
+#include <asm/cacheflush.h>
+#include <asm/tlbflush.h>
+
+/**
+ * struct apply_as - Closure structure for apply_as_range
+ * @base: struct pfn_range_apply we derive from
+ * @start: Address of first modified pte
+ * @end: Address of last modified pte + 1
+ * @total: Total number of modified ptes
+ * @vma: Pointer to the struct vm_area_struct we're currently operating on
+ */
+struct apply_as {
+	struct pfn_range_apply base;
+	unsigned long start;
+	unsigned long end;
+	unsigned long total;
+	struct vm_area_struct *vma;
+};
+
+/**
+ * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
+ * @pte: Pointer to the pte
+ * @token: Page table token, see apply_to_pfn_range()
+ * @addr: The virtual page address
+ * @closure: Pointer to a struct pfn_range_apply embedded in a
+ * struct apply_as
+ *
+ * The function write-protects a pte and records the range in
+ * virtual address space of touched ptes for efficient range TLB flushes.
+ *
+ * Return: Always zero.
+ */
+static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
+			      unsigned long addr,
+			      struct pfn_range_apply *closure)
+{
+	struct apply_as *aas = container_of(closure, typeof(*aas), base);
+	pte_t ptent = *pte;
+
+	if (pte_write(ptent)) {
+		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
+
+		ptent = pte_wrprotect(old_pte);
+		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
+		aas->total++;
+		aas->start = min(aas->start, addr);
+		aas->end = max(aas->end, addr + PAGE_SIZE);
+	}
+
+	return 0;
+}
+
+/**
+ * struct apply_as_clean - Closure structure for apply_as_clean
+ * @base: struct apply_as we derive from
+ * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
+ * @bitmap: Bitmap with one bit for each page offset in the address_space range
+ * covered.
+ * @start: Address_space page offset of first modified pte relative
+ * to @bitmap_pgoff
+ * @end: Address_space page offset of last modified pte relative
+ * to @bitmap_pgoff
+ */
+struct apply_as_clean {
+	struct apply_as base;
+	pgoff_t bitmap_pgoff;
+	unsigned long *bitmap;
+	pgoff_t start;
+	pgoff_t end;
+};
+
+/**
+ * apply_pt_clean - Leaf pte callback to clean a pte
+ * @pte: Pointer to the pte
+ * @token: Page table token, see apply_to_pfn_range()
+ * @addr: The virtual page address
+ * @closure: Pointer to a struct pfn_range_apply embedded in a
+ * struct apply_as_clean
+ *
+ * The function cleans a pte and records the range in
+ * virtual address space of touched ptes for efficient TLB flushes.
+ * It also records dirty ptes in a bitmap representing page offsets
+ * in the address_space, as well as the first and last of the bits
+ * touched.
+ *
+ * Return: Always zero.
+ */
+static int apply_pt_clean(pte_t *pte, pgtable_t token,
+			  unsigned long addr,
+			  struct pfn_range_apply *closure)
+{
+	struct apply_as *aas = container_of(closure, typeof(*aas), base);
+	struct apply_as_clean *clean = container_of(aas, typeof(*clean), base);
+	pte_t ptent = *pte;
+
+	if (pte_dirty(ptent)) {
+		pgoff_t pgoff = ((addr - aas->vma->vm_start) >> PAGE_SHIFT) +
+			aas->vma->vm_pgoff - clean->bitmap_pgoff;
+		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
+
+		ptent = pte_mkclean(old_pte);
+		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
+
+		aas->total++;
+		aas->start = min(aas->start, addr);
+		aas->end = max(aas->end, addr + PAGE_SIZE);
+
+		__set_bit(pgoff, clean->bitmap);
+		clean->start = min(clean->start, pgoff);
+		clean->end = max(clean->end, pgoff + 1);
+	}
+
+	return 0;
+}
+
+/**
+ * apply_as_range - Apply a pte callback to all PTEs pointing into a range
+ * of an address_space.
+ * @mapping: Pointer to the struct address_space
+ * @aas: Closure structure
+ * @first_index: First page offset in the address_space
+ * @nr: Number of incremental page offsets to cover
+ *
+ * Return: Number of ptes touched. Note that this number might be larger
+ * than @nr if there are overlapping vmas
+ */
+static unsigned long apply_as_range(struct address_space *mapping,
+				    struct apply_as *aas,
+				    pgoff_t first_index, pgoff_t nr)
+{
+	struct vm_area_struct *vma;
+	pgoff_t vba, vea, cba, cea;
+	unsigned long start_addr, end_addr;
+	struct mmu_notifier_range range;
+
+	i_mmap_lock_read(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, first_index,
+				  first_index + nr - 1) {
+		unsigned long vm_flags = READ_ONCE(vma->vm_flags);
+
+		/*
+		 * We can only do advisory flag tests below, since we can't
+		 * require the vm's mmap_sem to be held to protect the flags.
+		 * Therefore, callers that strictly depend on specific mmap
+		 * flags to remain constant throughout the operation must
+		 * either ensure those flags are immutable for all relevant
+		 * vmas or can't use this function. Fixing this properly would
+		 * require the vma::vm_flags to be protected by a separate
+		 * lock taken after the i_mmap_lock
+		 */
+
+		/* Skip non-applicable VMAs */
+		if ((vm_flags & (VM_SHARED | VM_WRITE)) !=
+		    (VM_SHARED | VM_WRITE))
+			continue;
+
+		/* Warn on and skip VMAs whose flags indicate illegal usage */
+		if (WARN_ON((vm_flags & (VM_HUGETLB | VM_IO)) != VM_IO))
+			continue;
+
+		/* Clip to the vma */
+		vba = vma->vm_pgoff;
+		vea = vba + vma_pages(vma);
+		cba = first_index;
+		cba = max(cba, vba);
+		cea = first_index + nr;
+		cea = min(cea, vea);
+
+		/* Translate to virtual address */
+		start_addr = ((cba - vba) << PAGE_SHIFT) + vma->vm_start;
+		end_addr = ((cea - vba) << PAGE_SHIFT) + vma->vm_start;
+		if (start_addr >= end_addr)
+			continue;
+
+		aas->base.mm = vma->vm_mm;
+		aas->vma = vma;
+		aas->start = end_addr;
+		aas->end = start_addr;
+
+		mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE, 0,
+					vma, vma->vm_mm, start_addr, end_addr);
+		mmu_notifier_invalidate_range_start(&range);
+
+		/* Needed when we only change protection? */
+		flush_cache_range(vma, start_addr, end_addr);
+
+		/*
+		 * We're not using tlb_gather_mmu() since typically
+		 * only a small subrange of PTEs are affected.
+		 */
+		inc_tlb_flush_pending(vma->vm_mm);
+
+		/* Should not error since aas->base.alloc == 0 */
+		WARN_ON(apply_to_pfn_range(&aas->base, start_addr,
+					   end_addr - start_addr));
+		if (aas->end > aas->start)
+			flush_tlb_range(vma, aas->start, aas->end);
+
+		mmu_notifier_invalidate_range_end(&range);
+		dec_tlb_flush_pending(vma->vm_mm);
+	}
+	i_mmap_unlock_read(mapping);
+
+	return aas->total;
+}
+
+/**
+ * apply_as_wrprotect - Write-protect all ptes in an address_space range
+ * @mapping: The address_space we want to write protect
+ * @first_index: The first page offset in the range
+ * @nr: Number of incremental page offsets to cover
+ *
+ * WARNING: This function should only be used for address spaces that
+ * completely own the pages / memory the page table points to. Typically a
+ * device file.
+ *
+ * Return: The number of ptes actually write-protected. Note that
+ * already write-protected ptes are not counted.
+ */
+unsigned long apply_as_wrprotect(struct address_space *mapping,
+				 pgoff_t first_index, pgoff_t nr)
+{
+	struct apply_as aas = {
+		.base = {
+			.alloc = 0,
+			.ptefn = apply_pt_wrprotect,
+		},
+		.total = 0,
+	};
+
+	return apply_as_range(mapping, &aas, first_index, nr);
+}
+EXPORT_SYMBOL(apply_as_wrprotect);
+
+/**
+ * apply_as_clean - Clean all ptes in an address_space range
+ * @mapping: The address_space we want to clean
+ * @first_index: The first page offset in the range
+ * @nr: Number of incremental page offsets to cover
+ * @bitmap_pgoff: The page offset of the first bit in @bitmap
+ * @bitmap: Pointer to a bitmap of at least @nr bits. The bitmap needs to
+ * cover the whole range @first_index..@first_index + @nr.
+ * @start: Pointer to number of the first set bit in @bitmap.
+ * is modified as new bits are set by the function.
+ * @end: Pointer to the number of the last set bit in @bitmap.
+ * none set. The value is modified as new bits are set by the function.
+ *
+ * Note: When this function returns there is no guarantee that a CPU has
+ * not already dirtied new ptes. However it will not clean any ptes not
+ * reported in the bitmap.
+ *
+ * If a caller needs to make sure all dirty ptes are picked up and none
+ * additional are added, it first needs to write-protect the address-space
+ * range and make sure new writers are blocked in page_mkwrite() or
+ * pfn_mkwrite(). And then after a TLB flush following the write-protection
+ * pick up all dirty bits.
+ *
+ * WARNING: This function should only be used for address spaces that
+ * completely own the pages / memory the page table points to. Typically a
+ * device file.
+ *
+ * Return: The number of dirty ptes actually cleaned.
+ */
+unsigned long apply_as_clean(struct address_space *mapping,
+			     pgoff_t first_index, pgoff_t nr,
+			     pgoff_t bitmap_pgoff,
+			     unsigned long *bitmap,
+			     pgoff_t *start,
+			     pgoff_t *end)
+{
+	bool none_set = (*start >= *end);
+	struct apply_as_clean clean = {
+		.base = {
+			.base = {
+				.alloc = 0,
+				.ptefn = apply_pt_clean,
+			},
+			.total = 0,
+		},
+		.bitmap_pgoff = bitmap_pgoff,
+		.bitmap = bitmap,
+		.start = none_set ? nr : *start,
+		.end = none_set ? 0 : *end,
+	};
+	unsigned long ret = apply_as_range(mapping, &clean.base, first_index,
+					   nr);
+
+	*start = clean.start;
+	*end = clean.end;
+	return ret;
+}
+EXPORT_SYMBOL(apply_as_clean);
-- 
2.20.1


Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58C09C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B59D4222D9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="LYDUDFfd";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kiWUA94o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B59D4222D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 031FC8E0009; Fri, 15 Feb 2019 17:09:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F238B8E0014; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D74C28E0009; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9824C8E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:28 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id o34so10051373qtf.19
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=xRBm+vHil3BZm0ttcnYbNzuq2O2Fb/0nzUxUc/QQj80=;
        b=O7kE5sOueRfK6MkFbBdvNstbDHhsvESU37CiRdnJpR0tsnCAV78waYBsUHJDgrDG1l
         lzOn7el2B6AkhwO4aF8YhIaPCUPti+PrIfx8v5P//rUrswutEEyotpc3MitU9UAUtwt2
         jPX4ax8acptEo6NVtM+/XVhvzG56mYWaX1marU+/x/adJh8a2iP7eGByZ1BDc9OwVkbz
         bLGZQMevx1M/ru+UctZWR12DG1XxRyZmvngtD1nqQnBoV7sG61BwIK8j80KJGT0f0Per
         gTnF8sj6dMEDUKRq3491SEolWyvt667a5yKlytN+89pRRph3ccsRG7duNLhbRker514C
         pODQ==
X-Gm-Message-State: AHQUAubNUm3bQQDSfY7/ZJCFVGTsuHFOCK4l74pjjhAyvhO0vGP5TiXu
	4ebuzekdLjebscneRX0jtoKeEnvzJjDwxjZw/jlF4RpxX/WP5RIJoHG8zuFo3qna8EI8UBgipYX
	zJKWe+BxSJKwSS4/q6csBnopgcf13nwAQSUg7nDZfwhgQKblzLkHOc8Ww6PT+V9Y5pw==
X-Received: by 2002:aed:384a:: with SMTP id j68mr9346179qte.171.1550268568191;
        Fri, 15 Feb 2019 14:09:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUozO/RdeKLu6vcDVD4N8XYBVwOQYQOUO2aTx48kqpO+zRCh2bkcmguo7mbPsMCLtFkmUp
X-Received: by 2002:aed:384a:: with SMTP id j68mr9346012qte.171.1550268565205;
        Fri, 15 Feb 2019 14:09:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268565; cv=none;
        d=google.com; s=arc-20160816;
        b=n4pHeOfe7+HTdXzY+OJC+BoZRWhD/i7RsopHnPsYO2ss/69GKljjPdJZpwQ9swr0f3
         ZljS6t1vD5WJXTYEVo8Nn499aX0sT3QSzIRzVMjeySAv82ueutdSOJxKvy6wmGpsXDub
         l+JSr5rJ5syILGwjn9sGyW54Gb+adhKguHkwv3RkUEujOYqcOiWbtwHcSIXyDLtH14N+
         YPX3h39OTPncWDcd9dFGgpIoGmIPyS0RcHbzDdDfIdlPyywfBiVnWnKMCptVvL5FPJX6
         Wu+tKdrLyo35i756on3HwItYCn6TIQLHs0QJKZlStF/rxE4k30+7AfBsJEj1YNDMotey
         GNKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=xRBm+vHil3BZm0ttcnYbNzuq2O2Fb/0nzUxUc/QQj80=;
        b=vXPPr9amJlPCz/OXf27MPiugxmE6myi0sJX90ht9HNXhy5zxmc1qeYyIpo41h2sqjf
         G2x24FAhSYxyKES4mkHh9rQoMyGV/YK3J0AlC1Lb27wifU7B3IEEEDXFhQ1XC43xDnm1
         hUUxSh1Vxmk2nvkpxiMfCITBGnHimWi0VqDVnJPsW2T9wcQCbLvehU+rT1xH+Q7xoA0i
         vliAZ/GjYfAa28B/340/sAZKdLbwzvBeD0ptHqnnnOTWuR8OCIi0rdcYyHeL+AnuTTKr
         canyshME2SDp+JYP+3F8MUMhAkKHLp+PcZiIOj6jSvnuTp983w0vLJU84nKKIFPb/4N3
         mUrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=LYDUDFfd;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kiWUA94o;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id g7si713992qkd.146.2019.02.15.14.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:25 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=LYDUDFfd;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kiWUA94o;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 4FE10310A;
	Fri, 15 Feb 2019 17:09:23 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:24 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=xRBm+vHil3BZm
	0ttcnYbNzuq2O2Fb/0nzUxUc/QQj80=; b=LYDUDFfdSWvZnNMqEiO/4rFrwFPIa
	yeAbmeC9aZGMozkMgwqkGOkCbZvlU7wFN28QWVJh2QuQIeMSEjOJTBD76BU3GS9/
	4D0ZoHt4pLwFmlQSQBf0ohEbIbSr7EoIBn2tBceNct6sIzzF1p5j35l1K5UQGbik
	fcLadp3HaVSb29XY0GAGl4RZIYuG6em51TQIQdQ7rPbHZ/GtnmbRW+9KIGiQ/ZMK
	hKFhLrBrAfjCJ9JF46BYN0C3OAutbE7ziVRoQjMNrEXN5u5HxGZAF4u1igbHzxkb
	2OXMM5Nh4BVsMtJOhjD9FGaZl2BZLrOlgg/NY9hyCbkTKfFbDWwtp0SOQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=xRBm+vHil3BZm0ttcnYbNzuq2O2Fb/0nzUxUc/QQj80=; b=kiWUA94o
	3TP+LJ4eH5EPIgk8Qe6OedG4IJdtPdahn4jaNC+xnwyP7PkPHCjjaIZolF3BHL2U
	MWzWXLgRjLm5IScSfaSbAml3DINLrpx+kBwuRSCPU7L/mbgar9F/Am7jtWxpvn04
	dcdLiKAA+9QxH9egbFrqLh271GEUQijmYURQgahGZAPHDFfAHWMu0lerDNOXSXeF
	ZByWB7IfrE47ZMKuWIIaSSEdHjjANaOvwSQVLKzUuF2Y1vde7O6/8p5TingPI2ny
	k08q9SPbPoxxmpeWGhUhru4U0ybOBPU5SIxPOC+KNLvMmNILJpOxxiFYMtd7Vzqy
	Oujbgtx9CL+8lw==
X-ME-Sender: <xms:kjhnXLZzVA78ckGN59ur95WRXYBv4kt9mCJMVv0i5nSDh3PADQdMyQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedufe
X-ME-Proxy: <xmx:kjhnXDdlOtOavpKB1YrWyCNnqG1NbuCboy6h6WgA2Q19eDPgtS6HtA>
    <xmx:kjhnXHLeZzw0UIYquzdI2wT3U8I3U745vRjZborTolcnhLncxGifmQ>
    <xmx:kjhnXDRgVNEOADeR-ji9fjobfkTqxD_Gtd8zZsHY5BNsaZpOncjCUQ>
    <xmx:kjhnXCQ0GJptcXjglqwVWSEw9aWdk3-L795S09sVASiJokKrXaOrLA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 13C37E4511;
	Fri, 15 Feb 2019 17:09:21 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 15/31] mm: thp: add 1GB THP split_huge_pud_page() function.
Date: Fri, 15 Feb 2019 14:08:40 -0800
Message-Id: <20190215220856.29749-16-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

It mimics PMD-level THP split. In addition, to support PMD-mapped PUD
THP, PMDPageInPUD() is used. For the mapcount of PMD-mapped PUD THP,
sub_compound_mapcount() is used, which uses
(head_page+3).compound_mapcount, since each base page's mapcount is used
for PTE mapping. PagePUDDoubleMap() is used for both PUD-mapped and
PMD-mapped PUD THPs.

page_xxx_rmap() functions now have an extra page order parameter to
distinguish different THP sizes.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/include/asm/pgtable.h |  15 +
 include/asm-generic/pgtable.h  |  83 ++++
 include/linux/huge_mm.h        |  31 +-
 include/linux/memcontrol.h     |   5 +
 include/linux/mm.h             |  18 +
 include/linux/page-flags.h     |  79 +++-
 include/linux/rmap.h           |   9 +-
 include/linux/swap.h           |   2 +
 include/linux/vm_event_item.h  |   4 +
 kernel/events/uprobes.c        |   4 +-
 mm/huge_memory.c               | 695 ++++++++++++++++++++++++++++++---
 mm/hugetlb.c                   |   4 +-
 mm/khugepaged.c                |   4 +-
 mm/ksm.c                       |   4 +-
 mm/memcontrol.c                |  13 +
 mm/memory.c                    |  16 +-
 mm/migrate.c                   |   8 +-
 mm/page_alloc.c                |  18 +-
 mm/pgtable-generic.c           |  11 +
 mm/rmap.c                      | 108 +++--
 mm/swap.c                      |  38 ++
 mm/swapfile.c                  |   4 +-
 mm/userfaultfd.c               |   2 +-
 mm/util.c                      |   7 +
 mm/vmstat.c                    |   4 +
 25 files changed, 1079 insertions(+), 107 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index f99ce657d282..4a6805f8f128 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1269,6 +1269,21 @@ static inline p4d_t *user_to_kernel_p4dp(p4d_t *p4dp)
 }
 #endif /* CONFIG_PAGE_TABLE_ISOLATION */
 
+#ifndef pudp_establish
+#define pudp_establish pudp_establish
+static inline pud_t pudp_establish(struct vm_area_struct *vma,
+		unsigned long address, pud_t *pudp, pud_t pud)
+{
+	if (IS_ENABLED(CONFIG_SMP)) {
+		return xchg(pudp, pud);
+	} else {
+		pud_t old = *pudp;
+		*pudp = pud;
+		return old;
+	}
+}
+#endif
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 682531e0d55c..1ae33b6590b8 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -346,6 +346,11 @@ extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 #endif
 
+#ifndef __HAVE_ARCH_PUDP_INVALIDATE
+extern pud_t pudp_invalidate(struct vm_area_struct *vma, unsigned long address,
+			    pud_t *pudp);
+#endif
+
 #ifndef __HAVE_ARCH_PTE_SAME
 static inline int pte_same(pte_t pte_a, pte_t pte_b)
 {
@@ -941,6 +946,18 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 }
 #endif
 
+#ifndef pud_read_atomic
+static inline pud_t pud_read_atomic(pud_t *pudp)
+{
+	/*
+	 * Depend on compiler for an atomic pmd read. NOTE: this is
+	 * only going to work, if the pmdval_t isn't larger than
+	 * an unsigned long.
+	 */
+	return *pudp;
+}
+#endif
+
 #ifndef arch_needs_pgtable_deposit
 #define arch_needs_pgtable_deposit() (false)
 #endif
@@ -1032,6 +1049,72 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+static inline int pud_none_or_trans_huge_or_clear_bad(pud_t *pud)
+{
+	pud_t pudval = pud_read_atomic(pud);
+	/*
+	 * The barrier will stabilize the pmdval in a register or on
+	 * the stack so that it will stop changing under the code.
+	 *
+	 * When CONFIG_TRANSPARENT_HUGEPAGE=y on x86 32bit PAE,
+	 * pmd_read_atomic is allowed to return a not atomic pmdval
+	 * (for example pointing to an hugepage that has never been
+	 * mapped in the pmd). The below checks will only care about
+	 * the low part of the pmd with 32bit PAE x86 anyway, with the
+	 * exception of pmd_none(). So the important thing is that if
+	 * the low part of the pmd is found null, the high part will
+	 * be also null or the pmd_none() check below would be
+	 * confused.
+	 */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	barrier();
+#endif
+	/*
+	 * !pmd_present() checks for pmd migration entries
+	 *
+	 * The complete check uses is_pmd_migration_entry() in linux/swapops.h
+	 * But using that requires moving current function and pmd_trans_unstable()
+	 * to linux/swapops.h to resovle dependency, which is too much code move.
+	 *
+	 * !pmd_present() is equivalent to is_pmd_migration_entry() currently,
+	 * because !pmd_present() pages can only be under migration not swapped
+	 * out.
+	 *
+	 * pmd_none() is preseved for future condition checks on pmd migration
+	 * entries and not confusing with this function name, although it is
+	 * redundant with !pmd_present().
+	 */
+	if (pud_none(pudval) || pud_trans_huge(pudval))
+		return 1;
+	if (unlikely(pud_bad(pudval))) {
+		pud_clear_bad(pud);
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * This is a noop if Transparent Hugepage Support is not built into
+ * the kernel. Otherwise it is equivalent to
+ * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in
+ * places that already verified the pmd is not none and they want to
+ * walk ptes while holding the mmap sem in read mode (write mode don't
+ * need this). If THP is not enabled, the pmd can't go away under the
+ * code even if MADV_DONTNEED runs, but if THP is enabled we need to
+ * run a pmd_trans_unstable before walking the ptes after
+ * split_huge_page_pmd returns (because it may have run when the pmd
+ * become null, but then a page fault can map in a THP and not a
+ * regular page).
+ */
+static inline int pud_trans_unstable(pud_t *pud)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return pud_none_or_trans_huge_or_clear_bad(pud);
+#else
+	return 0;
+#endif
+}
+
 #ifndef CONFIG_NUMA_BALANCING
 /*
  * Technically a PTE can be PROTNONE even when not doing NUMA balancing but
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 02419fa91e12..bd5cc5e65de8 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -178,17 +178,27 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		bool freeze, struct page *page);
 
+bool can_split_huge_pud_page(struct page *page, int *pextra_pins);
+int split_huge_pud_page_to_list(struct page *page, struct list_head *list);
+static inline int split_huge_pud_page(struct page *page)
+{
+	return split_huge_pud_page_to_list(page, NULL);
+}
 void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long address);
+		unsigned long address, bool freeze, struct page *page);
 
 #define split_huge_pud(__vma, __pud, __address)				\
 	do {								\
 		pud_t *____pud = (__pud);				\
 		if (pud_trans_huge(*____pud)				\
 					|| pud_devmap(*____pud))	\
-			__split_huge_pud(__vma, __pud, __address);	\
+			__split_huge_pud(__vma, __pud, __address,	\
+						false, NULL);		\
 	}  while (0)
 
+void split_huge_pud_address(struct vm_area_struct *vma, unsigned long address,
+		bool freeze, struct page *page);
+
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
 extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
@@ -319,8 +329,25 @@ static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
 		unsigned long address, bool freeze, struct page *page) {}
 
+static inline bool
+can_split_huge_pud_page(struct page *page, int *pextra_pins)
+{
+	BUILD_BUG();
+	return false;
+}
+static inline int
+split_huge_pud_page_to_list(struct page *page, struct list_head *list)
+{
+	return 0;
+}
+static inline int split_huge_pud_page(struct page *page)
+{
+	return 0;
+}
 #define split_huge_pud(__vma, __pmd, __address)	\
 	do { } while (0)
+static inline void split_huge_pud_address(struct vm_area_struct *vma,
+		unsigned long address, bool freeze, struct page *page) {}
 
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11cbd12c..fd362559d4b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -790,6 +790,7 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
+void mem_cgroup_split_huge_pud_fixup(struct page *head);
 #endif
 
 #else /* CONFIG_MEMCG */
@@ -1098,6 +1099,10 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head)
 {
 }
 
+static inline void mem_cgroup_split_huge_pud_fixup(struct page *head)
+{
+}
+
 static inline void count_memcg_events(struct mem_cgroup *memcg,
 				      enum vm_event_item idx,
 				      unsigned long count)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d10dc9db2311..af6257d05189 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -652,6 +652,24 @@ static inline int compound_mapcount(struct page *page)
 	return atomic_read(compound_mapcount_ptr(page)) + 1;
 }
 
+static inline unsigned int compound_order(struct page *page);
+static inline atomic_t *sub_compound_mapcount_ptr(struct page *page, int sub_level)
+{
+	struct page *head = compound_head(page);
+
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON_PAGE(compound_order(head) != HPAGE_PUD_ORDER, page);
+	VM_BUG_ON_PAGE((page - head) % HPAGE_PMD_NR, page);
+	VM_BUG_ON_PAGE(sub_level != 1, page);
+	return &page[2 + sub_level].compound_mapcount;
+}
+
+/* Only works for PUD pages */
+static inline int sub_compound_mapcount(struct page *page)
+{
+	return atomic_read(sub_compound_mapcount_ptr(page, 1)) + 1;
+}
+
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 39b4494e29f1..480e091f52ac 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -607,6 +607,23 @@ static inline int PageTransTail(struct page *page)
 	return PageTail(page);
 }
 
+#define HPAGE_PMD_SHIFT PMD_SHIFT
+#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
+#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
+
+#define HPAGE_PUD_SHIFT PUD_SHIFT
+#define HPAGE_PUD_ORDER (HPAGE_PUD_SHIFT-PAGE_SHIFT)
+#define HPAGE_PUD_NR (1<<HPAGE_PUD_ORDER)
+
+static inline unsigned int compound_order(struct page *page);
+
+static inline int PMDPageInPUD(struct page *page)
+{
+	struct page *head = compound_head(page);
+	return (PageCompound(page) && compound_order(head) == HPAGE_PUD_ORDER &&
+		((page - head) % HPAGE_PMD_NR == 0));
+}
+
 /*
  * PageDoubleMap indicates that the compound page is mapped with PTEs as well
  * as PMDs.
@@ -622,30 +639,72 @@ static inline int PageTransTail(struct page *page)
  */
 static inline int PageDoubleMap(struct page *page)
 {
-	return PageHead(page) && test_bit(PG_double_map, &page[1].flags);
+	return (PageHead(page) || PMDPageInPUD(page)) &&
+		test_bit(PG_double_map, &compound_head(page)[1].flags);
 }
 
 static inline void SetPageDoubleMap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	set_bit(PG_double_map, &page[1].flags);
+	VM_BUG_ON_PAGE(!PageHead(page) && !PMDPageInPUD(page), page);
+	set_bit(PG_double_map, &compound_head(page)[1].flags);
 }
 
 static inline void ClearPageDoubleMap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	clear_bit(PG_double_map, &page[1].flags);
+	VM_BUG_ON_PAGE(!PageHead(page) && !PMDPageInPUD(page), page);
+	clear_bit(PG_double_map, &compound_head(page)[1].flags);
 }
 static inline int TestSetPageDoubleMap(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	return test_and_set_bit(PG_double_map, &page[1].flags);
+	VM_BUG_ON_PAGE(!PageHead(page) && !PMDPageInPUD(page), page);
+	return test_and_set_bit(PG_double_map, &compound_head(page)[1].flags);
 }
 
 static inline int TestClearPageDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page) && !PMDPageInPUD(page), page);
+	return test_and_clear_bit(PG_double_map, &compound_head(page)[1].flags);
+}
+
+/*
+ * PagePUDDoubleMap indicates that the compound page is mapped with PMDs as well
+ * as PUDs.
+ *
+ * This is required for optimization of rmap operations for THP: we can postpone
+ * per small page mapcount accounting (and its overhead from atomic operations)
+ * until the first PMD split.
+ *
+ * For the page PageDoubleMap means ->_mapcount in all sub-pages is offset up
+ * by one. This reference will go away with last compound_mapcount.
+ *
+ * See also __split_huge_pmd_locked() and page_remove_anon_compound_rmap().
+ */
+static inline int PagePUDDoubleMap(struct page *page)
+{
+	return PageHead(page) && test_bit(PG_double_map, &page[2].flags);
+}
+
+static inline void SetPagePUDDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	set_bit(PG_double_map, &page[2].flags);
+}
+
+static inline void ClearPagePUDDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	clear_bit(PG_double_map, &page[2].flags);
+}
+static inline int TestSetPagePUDDoubleMap(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	return test_and_set_bit(PG_double_map, &page[2].flags);
+}
+
+static inline int TestClearPagePUDDoubleMap(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
-	return test_and_clear_bit(PG_double_map, &page[1].flags);
+	return test_and_clear_bit(PG_double_map, &page[2].flags);
 }
 
 #else
@@ -653,9 +712,13 @@ TESTPAGEFLAG_FALSE(TransHuge)
 TESTPAGEFLAG_FALSE(TransCompound)
 TESTPAGEFLAG_FALSE(TransCompoundMap)
 TESTPAGEFLAG_FALSE(TransTail)
+TESTPAGEFLAG_FALSE(PMDPageInPUD)
 PAGEFLAG_FALSE(DoubleMap)
 	TESTSETFLAG_FALSE(DoubleMap)
 	TESTCLEARFLAG_FALSE(DoubleMap)
+PAGEFLAG_FALSE(PUDDoubleMap)
+	TESTSETFLAG_FALSE(PUDDoubleMap)
+	TESTCLEARFLAG_FALSE(PUDDoubleMap)
 #endif
 
 /*
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 2b566736e3c2..6adb6e835b30 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -99,6 +99,7 @@ enum ttu_flags {
 	TTU_RMAP_LOCKED		= 0x80,	/* do not grab rmap lock:
 					 * caller holds it */
 	TTU_SPLIT_FREEZE	= 0x100,		/* freeze pte under splitting thp */
+	TTU_SPLIT_HUGE_PUD	= 0x200,		/* split huge PUD if any */
 };
 
 #ifdef CONFIG_MMU
@@ -171,13 +172,13 @@ struct anon_vma *page_get_anon_vma(struct page *page);
  */
 void page_move_anon_rmap(struct page *, struct vm_area_struct *);
 void page_add_anon_rmap(struct page *, struct vm_area_struct *,
-		unsigned long, bool);
+		unsigned long, bool, int);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
-			   unsigned long, int);
+			   unsigned long, int, int);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
-		unsigned long, bool);
+		unsigned long, bool, int);
 void page_add_file_rmap(struct page *, bool);
-void page_remove_rmap(struct page *, bool);
+void page_remove_rmap(struct page *, bool, int);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 			    unsigned long);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 622025ac1461..1a6bac77c854 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -333,6 +333,8 @@ extern void lru_cache_add_anon(struct page *page);
 extern void lru_cache_add_file(struct page *page);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
+extern void lru_add_pud_page_tail(struct page *page, struct page *page_tail,
+			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 4550667b2274..df619262b1b4 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -85,6 +85,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_FAULT_ALLOC_PUD,
 		THP_FAULT_FALLBACK_PUD,
 		THP_SPLIT_PUD,
+		THP_SPLIT_PUD_PAGE,
+		THP_SPLIT_PUD_PAGE_FAILED,
+		THP_ZERO_PUD_PAGE_ALLOC,
+		THP_ZERO_PUD_PAGE_ALLOC_FAILED,
 #endif
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 8aef47ee7bfa..e4819fef634f 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -195,7 +195,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
 
 	get_page(new_page);
-	page_add_new_anon_rmap(new_page, vma, addr, false);
+	page_add_new_anon_rmap(new_page, vma, addr, false, 0);
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 
@@ -209,7 +209,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	set_pte_at_notify(mm, addr, pvmw.pte,
 			mk_pte(new_page, vma->vm_page_prot));
 
-	page_remove_rmap(old_page, false);
+	page_remove_rmap(old_page, false, 0);
 	if (!page_mapped(old_page))
 		try_to_free_swap(old_page);
 	page_vma_mapped_walk_done(&pvmw);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0a006592f3fe..5f83f4c5eac7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -121,10 +121,10 @@ static struct page *get_huge_pud_zero_page(void)
 	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
 			HPAGE_PUD_ORDER);
 	if (!zero_page) {
-		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
+		count_vm_event(THP_ZERO_PUD_PAGE_ALLOC_FAILED);
 		return NULL;
 	}
-	count_vm_event(THP_ZERO_PAGE_ALLOC);
+	count_vm_event(THP_ZERO_PUD_PAGE_ALLOC);
 	preempt_disable();
 	if (cmpxchg(&huge_pud_zero_page, NULL, zero_page)) {
 		preempt_enable();
@@ -660,7 +660,7 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		page_add_new_anon_rmap(page, vma, haddr, true);
+		page_add_new_anon_rmap(page, vma, haddr, true, HPAGE_PMD_ORDER);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
@@ -969,7 +969,7 @@ static int __do_huge_pud_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 		entry = mk_huge_pud(page, vma->vm_page_prot);
 		entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
-		page_add_new_anon_rmap(page, vma, haddr, true);
+		page_add_new_anon_rmap(page, vma, haddr, true, HPAGE_PUD_ORDER);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_pud_deposit(vma->vm_mm, vmf->pud,
@@ -1463,7 +1463,7 @@ static int do_huge_pud_wp_page_fallback(struct vm_fault *vmf, pud_t orig_pud,
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, true);
+		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, true, HPAGE_PMD_ORDER);
 		mem_cgroup_commit_charge(pages[i], memcg, false, true);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		vmf->pmd = pmd_offset(&_pud, haddr);
@@ -1475,7 +1475,7 @@ static int do_huge_pud_wp_page_fallback(struct vm_fault *vmf, pud_t orig_pud,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pud_populate_with_pgtable(vma->vm_mm, vmf->pud, pgtable);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, true, HPAGE_PUD_ORDER);
 	spin_unlock(vmf->ptl);
 
 	/*
@@ -1566,13 +1566,13 @@ int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
 		prep_transhuge_page(new_page);
 	} else {
 		if (!page) {
-			WARN(1, "%s: split_huge_page\n", __func__);
+			/*WARN(1, "%s: split_huge_page\n", __func__);*/
 			split_huge_pud(vma, vmf->pud, vmf->address);
 			ret |= VM_FAULT_FALLBACK;
 		} else {
 			ret = do_huge_pud_wp_page_fallback(vmf, orig_pud, page);
 			if (ret & VM_FAULT_OOM) {
-				WARN(1, "%s: split_huge_page after wp fallback\n", __func__);
+				/*WARN(1, "%s: split_huge_page after wp fallback\n", __func__);*/
 				split_huge_pud(vma, vmf->pud, vmf->address);
 				ret |= VM_FAULT_FALLBACK;
 			}
@@ -1585,7 +1585,7 @@ int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
 	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
 					huge_gfp, &memcg, true))) {
 		put_page(new_page);
-		WARN(1, "%s: split_huge_page after mem cgroup failed\n", __func__);
+		/*WARN(1, "%s: split_huge_page after mem cgroup failed\n", __func__);*/
 		split_huge_pud(vma, vmf->pud, vmf->address);
 		if (page)
 			put_page(page);
@@ -1620,7 +1620,7 @@ int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
 		entry = mk_huge_pud(new_page, vma->vm_page_prot);
 		entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
 		pudp_huge_clear_flush_notify(vma, haddr, vmf->pud);
-		page_add_new_anon_rmap(new_page, vma, haddr, true);
+		page_add_new_anon_rmap(new_page, vma, haddr, true, HPAGE_PUD_ORDER);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pud_at(vma->vm_mm, haddr, vmf->pud, entry);
@@ -1629,7 +1629,7 @@ int do_huge_pud_wp_page(struct vm_fault *vmf, pud_t orig_pud)
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PUD_NR);
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, true, HPAGE_PUD_ORDER);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -1748,7 +1748,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
+		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false, 0);
 		mem_cgroup_commit_charge(pages[i], memcg, false, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		vmf->pte = pte_offset_map(&_pmd, haddr);
@@ -1760,7 +1760,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(vma->vm_mm, vmf->pmd, pgtable);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 	spin_unlock(vmf->ptl);
 
 	/*
@@ -1900,7 +1900,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
-		page_add_new_anon_rmap(new_page, vma, haddr, true);
+		page_add_new_anon_rmap(new_page, vma, haddr, true, HPAGE_PMD_ORDER);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
@@ -1909,7 +1909,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -2282,9 +2282,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		if (pmd_present(orig_pmd)) {
 			page = pmd_page(orig_pmd);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-			VM_BUG_ON_PAGE(!PageHead(page), page);
+			VM_BUG_ON_PAGE(!PageHead(page) && !PMDPageInPUD(page), page);
 		} else if (thp_migration_supported()) {
 			swp_entry_t entry;
 
@@ -2560,7 +2560,7 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		if (pud_present(orig_pud)) {
 			page = pud_page(orig_pud);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, true, HPAGE_PUD_ORDER);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
 		} else
@@ -2582,9 +2582,60 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return 1;
 }
 
+static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
+		unsigned long haddr, pmd_t *pmd);
+
+static void __split_huge_zero_page_pud(struct vm_area_struct *vma,
+		unsigned long haddr, pud_t *pud)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	pud_t _pud;
+	int i;
+
+	/*
+	 * Leave pmd empty until pte is filled note that it is fine to delay
+	 * notification until mmu_notifier_invalidate_range_end() as we are
+	 * replacing a zero pmd write protected page with a zero pte write
+	 * protected page.
+	 *
+	 * See Documentation/vm/mmu_notifier.txt
+	 */
+	pudp_huge_clear_flush(vma, haddr, pud);
+
+	pgtable = pgtable_trans_huge_pud_withdraw(mm, pud);
+	pud_populate_with_pgtable(mm, &_pud, pgtable);
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER));
+		 i++, haddr += PMD_SIZE) {
+		pmd_t *pmd = pmd_offset(&_pud, haddr), entry;
+		struct page *zero_page = mm_get_huge_zero_page(mm);
+
+		if (unlikely(!zero_page)) {
+			VM_BUG_ON(1);
+			__split_huge_zero_page_pmd(vma, haddr, pmd);
+			continue;
+		}
+
+		VM_BUG_ON(!pmd_none(*pmd));
+		entry = mk_huge_pmd(zero_page, vma->vm_page_prot);
+		set_pmd_at(mm, haddr, pmd, entry);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pud_populate_with_pgtable(mm, pud, pgtable);
+}
+
 static void __split_huge_pud_locked(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long haddr)
+		unsigned long haddr, bool freeze)
 {
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *page;
+	pgtable_t pgtable;
+	pud_t _pud, old_pud;
+	bool young, write, dirty, soft_dirty;
+	unsigned long addr;
+	int i;
+
 	VM_BUG_ON(haddr & ~HPAGE_PUD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PUD_SIZE, vma);
@@ -2592,22 +2643,149 @@ static void __split_huge_pud_locked(struct vm_area_struct *vma, pud_t *pud,
 
 	count_vm_event(THP_SPLIT_PUD);
 
-	pudp_huge_clear_flush_notify(vma, haddr, pud);
+	if (!vma_is_anonymous(vma)) {
+		_pud = pudp_huge_clear_flush_notify(vma, haddr, pud);
+		/*
+		 * We are going to unmap this huge page. So
+		 * just go ahead and zap it
+		 */
+		if (arch_needs_pgtable_deposit())
+			zap_pud_deposited_table(mm, pud);
+		if (vma_is_dax(vma))
+			return;
+		page = pud_page(_pud);
+		if (!PageReferenced(page) && pud_young(_pud))
+			SetPageReferenced(page);
+		page_remove_rmap(page, true, HPAGE_PUD_ORDER);
+		put_page(page);
+		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PUD_NR);
+		return;
+	} else if (is_huge_zero_pud(*pud)) {
+		/*
+		 * FIXME: Do we want to invalidate secondary mmu by calling
+		 * mmu_notifier_invalidate_range() see comments below inside
+		 * __split_huge_pmd() ?
+		 *
+		 * We are going from a zero huge page write protected to zero
+		 * small page also write protected so it does not seems useful
+		 * to invalidate secondary mmu at this time.
+		 */
+		return __split_huge_zero_page_pud(vma, haddr, pud);
+	}
+
+	/* See the comment above pmdp_invalidate() in __split_huge_pmd_locked() */
+	old_pud = pudp_invalidate(vma, haddr, pud);
+
+	page = pud_page(old_pud);
+	VM_BUG_ON_PAGE(!page_count(page), page);
+	page_ref_add(page, (1<<(HPAGE_PUD_ORDER-HPAGE_PMD_ORDER)) - 1);
+	if (pud_dirty(old_pud))
+		SetPageDirty(page);
+	write = pud_write(old_pud);
+	young = pud_young(old_pud);
+	dirty = pud_dirty(old_pud);
+	soft_dirty = pud_soft_dirty(old_pud);
+
+	pgtable = pgtable_trans_huge_pud_withdraw(mm, pud);
+	pud_populate_with_pgtable(mm, &_pud, pgtable);
+
+	for (i = 0, addr = haddr; i < HPAGE_PUD_NR;
+		 i += HPAGE_PMD_NR, addr += PMD_SIZE) {
+		pmd_t entry, *pmd;
+		/*
+		 * Note that NUMA hinting access restrictions are not
+		 * transferred to avoid any possibility of altering
+		 * permissions across VMAs.
+		 */
+		if (freeze) {
+			swp_entry_t swp_entry;
+
+			swp_entry = make_migration_entry(page + i, write);
+			entry = swp_entry_to_pmd(swp_entry);
+			if (soft_dirty)
+				entry = pmd_swp_mksoft_dirty(entry);
+		} else {
+			entry = mk_huge_pmd(page + i, READ_ONCE(vma->vm_page_prot));
+			entry = maybe_pmd_mkwrite(entry, vma);
+			if (!write)
+				entry = pmd_wrprotect(entry);
+			if (!young)
+				entry = pmd_mkold(entry);
+			if (soft_dirty)
+				entry = pmd_mksoft_dirty(entry);
+		}
+		pmd = pmd_offset(&_pud, addr);
+		VM_BUG_ON(!pmd_none(*pmd));
+		set_pmd_at(mm, addr, pmd, entry);
+		/* distinguish between pud compound_mapcount and pmd compound_mapcount */
+		if (atomic_inc_and_test(sub_compound_mapcount_ptr(&page[i], 1)))
+			/* first pmd-mapped pud page */
+			__inc_node_page_state(page, NR_ANON_THPS);
+	}
+
+	/*
+	 * Set PG_double_map before dropping compound_mapcount to avoid
+	 * false-negative page_mapped().
+	 */
+	if (compound_mapcount(page) > 1 && !TestSetPagePUDDoubleMap(page)) {
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+		/* distinguish between pud compound_mapcount and pmd compound_mapcount */
+			atomic_inc(sub_compound_mapcount_ptr(&page[i], 1));
+	}
+
+	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
+		/* Last compound_mapcount is gone. */
+		__dec_node_page_state(page, NR_ANON_THPS_PUD);
+		if (TestClearPagePUDDoubleMap(page)) {
+			/* No need in mapcount reference anymore */
+			for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+		/* distinguish between pud compound_mapcount and pmd compound_mapcount */
+				atomic_dec(sub_compound_mapcount_ptr(&page[i], 1));
+		}
+	}
+
+	smp_wmb(); /* make pte visible before pmd */
+	pud_populate_with_pgtable(mm, pud, pgtable);
+
+	if (freeze) {
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+			/*page_remove_rmap(page + i, true, HPAGE_PMD_ORDER);*/
+			atomic_dec(sub_compound_mapcount_ptr(&page[i], 1));
+			__dec_node_page_state(page, NR_ANON_THPS);
+			__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -HPAGE_PMD_NR);
+			put_page(page + i);
+		}
+	}
 }
 
 void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
-		unsigned long address)
+		unsigned long address, bool freeze, struct page *page)
 {
 	spinlock_t *ptl;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PUD_MASK;
 	struct mmu_notifier_range range;
 
 	mmu_notifier_range_init(&range, vma->vm_mm, address & HPAGE_PUD_MASK,
 				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
-	ptl = pud_lock(vma->vm_mm, pud);
-	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
+	ptl = pud_lock(mm, pud);
+
+	/*
+	 * If caller asks to setup a migration entries, we need a page to check
+	 * pmd against. Otherwise we can end up replacing wrong page.
+	 */
+	VM_BUG_ON(freeze && !page);
+	if (page && page != pud_page(*pud))
 		goto out;
-	__split_huge_pud_locked(vma, pud, range.start);
+
+	if (pud_trans_huge(*pud)) {
+		page = pud_page(*pud);
+		if (PageMlocked(page))
+			clear_page_mlock(page);
+	} else if (unlikely(!pud_devmap(*pud)))
+		goto out;
+	__split_huge_pud_locked(vma, pud, haddr, freeze);
 
 out:
 	spin_unlock(ptl);
@@ -2617,6 +2795,369 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 	 */
 	mmu_notifier_invalidate_range_only_end(&range);
 }
+
+void split_huge_pud_address(struct vm_area_struct *vma, unsigned long address,
+		bool freeze, struct page *page)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+
+	pgd = pgd_offset(vma->vm_mm, address);
+	if (!pgd_present(*pgd))
+		return;
+
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return;
+
+	pud = pud_offset(p4d, address);
+
+	__split_huge_pud(vma, pud, address, freeze, page);
+}
+
+static void freeze_pud_page(struct page *page)
+{
+	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
+		TTU_RMAP_LOCKED | TTU_SPLIT_HUGE_PUD;
+	bool unmap_success;
+
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+
+	if (PageAnon(page))
+		ttu_flags |= TTU_SPLIT_FREEZE;
+
+	unmap_success = try_to_unmap(page, ttu_flags);
+	VM_BUG_ON_PAGE(!unmap_success, page);
+}
+
+static void unfreeze_pud_page(struct page *page)
+{
+	int i;
+
+	VM_BUG_ON(!PageTransHuge(page));
+	if (compound_order(page) == HPAGE_PUD_ORDER) {
+		remove_migration_ptes(page, page, true);
+	} else if (compound_order(page) == HPAGE_PMD_ORDER) {
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+			remove_migration_ptes(page + i, page + i, true);
+	} else
+		VM_BUG_ON_PAGE(1, page);
+}
+
+static void __split_huge_pud_page_tail(struct page *head, int tail,
+		struct lruvec *lruvec, struct list_head *list)
+{
+	struct page *page_tail = head + tail;
+	/*int page_tail_mapcount = sub_compound_mapcount(page_tail);*/
+
+	VM_BUG_ON_PAGE(page_ref_count(page_tail) != 0, page_tail);
+
+	/*atomic_set(sub_compound_mapcount_ptr(page_tail, 1), -1);*/
+
+	clear_compound_head(page_tail);
+	prep_compound_page(page_tail, HPAGE_PMD_ORDER);
+	prep_transhuge_page(page_tail);
+
+	/* move sub PMD page mapcount */
+	/*atomic_set(compound_mapcount_ptr(page_tail), page_tail_mapcount);*/
+	/*
+	 * tail_page->_refcount is zero and not changing from under us. But
+	 * get_page_unless_zero() may be running from under us on the
+	 * tail_page. If we used atomic_set() below instead of atomic_inc() or
+	 * atomic_add(), we would then run atomic_set() concurrently with
+	 * get_page_unless_zero(), and atomic_set() is implemented in C not
+	 * using locked ops. spin_unlock on x86 sometime uses locked ops
+	 * because of PPro errata 66, 92, so unless somebody can guarantee
+	 * atomic_set() here would be safe on all archs (and not only on x86),
+	 * it's safer to use atomic_inc()/atomic_add().
+	 */
+	if (PageAnon(head) && !PageSwapCache(head)) {
+		page_ref_inc(page_tail);
+	} else {
+		VM_BUG_ON(1);
+		/* Additional pin to radix tree */
+		page_ref_add(page_tail, 2);
+	}
+
+	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	page_tail->flags |= (head->flags &
+			((1L << PG_referenced) |
+			 (1L << PG_swapbacked) |
+			 (1L << PG_swapcache) |
+			 (1L << PG_mlocked) |
+			 (1L << PG_uptodate) |
+			 (1L << PG_active) |
+			 (1L << PG_locked) |
+			 (1L << PG_unevictable) |
+			 (1L << PG_dirty) |
+			 /* preserve THP */
+			 (1L << PG_head)));
+
+	/*
+	 * After clearing PageTail the gup refcount can be released.
+	 * Page flags also must be visible before we make the page non-compound.
+	 */
+	smp_wmb();
+
+	if (page_is_young(head))
+		set_page_young(page_tail);
+	if (page_is_idle(head))
+		set_page_idle(page_tail);
+
+	/* ->mapping in first tail page is compound_mapcount */
+	VM_BUG_ON_PAGE(tail > 2 && page_tail->mapping != TAIL_MAPPING,
+			page_tail);
+	page_tail->mapping = head->mapping;
+
+	page_tail->index = head->index + tail;
+	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
+	lru_add_pud_page_tail(head, page_tail, lruvec, list);
+}
+
+static void __split_huge_pud_page(struct page *page, struct list_head *list,
+		unsigned long flags)
+{
+	struct page *head = compound_head(page);
+	struct zone *zone = page_zone(head);
+	struct lruvec *lruvec;
+	pgoff_t end = -1;
+	int i;
+
+	lruvec = mem_cgroup_page_lruvec(head, zone->zone_pgdat);
+
+	/* complete memcg works before add pages to LRU */
+	mem_cgroup_split_huge_pud_fixup(head);
+
+	if (!PageAnon(page)) {
+		VM_BUG_ON(1);
+		end = DIV_ROUND_UP(i_size_read(head->mapping->host), PAGE_SIZE);
+	}
+
+	for (i = HPAGE_PUD_NR - HPAGE_PMD_NR; i >= 1; i -= HPAGE_PMD_NR) {
+		__split_huge_pud_page_tail(head, i, lruvec, list);
+		/* Some pages can be beyond i_size: drop them from page cache */
+		if (head[i].index >= end) {
+			VM_BUG_ON(1);
+			__ClearPageDirty(head + i);
+			__delete_from_page_cache(head + i, NULL);
+			if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
+				shmem_uncharge(head->mapping->host, 1);
+			put_page(head + i);
+		}
+	}
+	/* reset head page order  */
+	prep_compound_page(head, HPAGE_PMD_ORDER);
+	prep_transhuge_page(head);
+
+	/* See comment in __split_huge_page_tail() */
+	if (PageAnon(head)) {
+		/* Additional pin to radix tree of swap cache */
+		if (PageSwapCache(head)) {
+			VM_BUG_ON(1);
+			page_ref_add(head, 2);
+		} else
+			page_ref_inc(head);
+	} else {
+		VM_BUG_ON(1);
+		/* Additional pin to radix tree */
+		page_ref_add(head, 2);
+		xa_unlock(&head->mapping->i_pages);
+	}
+
+	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+
+	unfreeze_pud_page(head);
+
+	for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+		struct page *subpage = head + i;
+
+		if (subpage == page)
+			continue;
+		unlock_page(subpage);
+
+		/*
+		 * Subpages may be freed if there wasn't any mapping
+		 * like if add_to_swap() is running on a lru page that
+		 * had its mapping zapped. And freeing these pages
+		 * requires taking the lru_lock so we do the put_page
+		 * of the tail pages after the split is complete.
+		 */
+		put_page(subpage);
+	}
+}
+/* Racy check whether the huge page can be split */
+bool can_split_huge_pud_page(struct page *page, int *pextra_pins)
+{
+	int extra_pins;
+
+	/* Additional pins from radix tree */
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? HPAGE_PUD_NR : 0;
+	else
+		extra_pins = HPAGE_PUD_NR;
+	if (pextra_pins)
+		*pextra_pins = extra_pins;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
+/*
+ * This function splits huge page into normal pages. @page can point to any
+ * subpage of huge page to split. Split doesn't change the position of @page.
+ *
+ * Only caller must hold pin on the @page, otherwise split fails with -EBUSY.
+ * The huge page must be locked.
+ *
+ * If @list is null, tail pages will be added to LRU list, otherwise, to @list.
+ *
+ * Both head page and tail pages will inherit mapping, flags, and so on from
+ * the hugepage.
+ *
+ * GUP pin and PG_locked transferred to @page. Rest subpages can be freed if
+ * they are not mapped.
+ *
+ * Returns 0 if the hugepage is split successfully.
+ * Returns -EBUSY if the page is pinned or if anon_vma disappeared from under
+ * us.
+ */
+int split_huge_pud_page_to_list(struct page *page, struct list_head *list)
+{
+	struct page *head = compound_head(page);
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
+	struct anon_vma *anon_vma = NULL;
+	struct address_space *mapping = NULL;
+	int count, mapcount, extra_pins, ret;
+	bool mlocked;
+	unsigned long flags;
+
+	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
+
+	if (PageWriteback(page))
+		return -EBUSY;
+
+	if (PageAnon(head)) {
+		/*
+		 * The caller does not necessarily hold an mmap_sem that would
+		 * prevent the anon_vma disappearing so we first we take a
+		 * reference to it and then lock the anon_vma for write. This
+		 * is similar to page_lock_anon_vma_read except the write lock
+		 * is taken to serialise against parallel split or collapse
+		 * operations.
+		 */
+		anon_vma = page_get_anon_vma(head);
+		if (!anon_vma) {
+			ret = -EBUSY;
+			goto out;
+		}
+		mapping = NULL;
+		anon_vma_lock_write(anon_vma);
+	} else {
+		VM_BUG_ON(1);
+		mapping = head->mapping;
+
+		/* Truncated ? */
+		if (!mapping) {
+			ret = -EBUSY;
+			goto out;
+		}
+
+		anon_vma = NULL;
+		i_mmap_lock_read(mapping);
+	}
+
+	/*
+	 * Racy check if we can split the page, before freeze_pud_page() will
+	 * split PUDs
+	 */
+	if (!can_split_huge_pud_page(head, &extra_pins)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	mlocked = PageMlocked(page);
+	freeze_pud_page(head);
+	VM_BUG_ON_PAGE(compound_mapcount(head), head);
+
+	/* Make sure the page is not on per-CPU pagevec as it takes pin */
+	if (mlocked)
+		lru_add_drain();
+
+	/* prevent PageLRU to go away from under us, and freeze lru stats */
+	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
+
+	if (mapping) {
+		void **pslot;
+
+		VM_BUG_ON(1);
+
+		xa_lock(&mapping->i_pages);
+		pslot = radix_tree_lookup_slot(&mapping->i_pages,
+				page_index(head));
+		/*
+		 * Check if the head page is present in radix tree.
+		 * We assume all tail are present too, if head is there.
+		 */
+		if (radix_tree_deref_slot_protected(pslot,
+					&mapping->i_pages.xa_lock) != head)
+			goto fail;
+	}
+
+	/* Prevent deferred_split_scan() touching ->_refcount */
+	spin_lock(&pgdata->split_queue_lock);
+	count = page_count(head);
+	mapcount = total_mapcount(head);
+	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
+		if (!list_empty(page_deferred_list(head))) {
+			pgdata->split_queue_len--;
+			list_del(page_deferred_list(head));
+		}
+		if (mapping) {
+			VM_BUG_ON(1);
+			__dec_node_page_state(page, NR_SHMEM_THPS);
+		}
+		spin_unlock(&pgdata->split_queue_lock);
+		__split_huge_pud_page(page, list, flags);
+		if (PageSwapCache(head)) {
+			swp_entry_t entry = { .val = page_private(head) };
+
+			VM_BUG_ON(1);
+
+			ret = split_swap_cluster(entry);
+		} else
+			ret = 0;
+	} else {
+		if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
+			pr_alert("total_mapcount: %u, page_count(): %u\n",
+					mapcount, count);
+			if (PageTail(page))
+				dump_page(head, NULL);
+			dump_page(page, "total_mapcount(head) > 0");
+			VM_BUG_ON(1);
+		}
+		spin_unlock(&pgdata->split_queue_lock);
+fail:
+		if (mapping) {
+			VM_BUG_ON(1);
+			xa_unlock(&mapping->i_pages);
+		}
+		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+		unfreeze_pud_page(head);
+		ret = -EBUSY;
+	}
+
+out_unlock:
+	if (anon_vma) {
+		anon_vma_unlock_write(anon_vma);
+		put_anon_vma(anon_vma);
+	}
+	if (mapping)
+		i_mmap_unlock_read(mapping);
+out:
+	count_vm_event(!ret ? THP_SPLIT_PUD_PAGE : THP_SPLIT_PUD_PAGE_FAILED);
+	return ret;
+}
 #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
 static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
@@ -2687,7 +3228,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			set_page_dirty(page);
 		if (!PageReferenced(page) && pmd_young(_pmd))
 			SetPageReferenced(page);
-		page_remove_rmap(page, true);
+		page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 		put_page(page);
 		add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
 		return;
@@ -2787,12 +3328,19 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 * Set PG_double_map before dropping compound_mapcount to avoid
 	 * false-negative page_mapped().
 	 */
-	if (compound_mapcount(page) > 1 && !TestSetPageDoubleMap(page)) {
+	if (((PMDPageInPUD(page) &&
+		sub_compound_mapcount(page) >
+			(1 + PagePUDDoubleMap(compound_head(page)))) ||
+		compound_mapcount(page) > 1)
+		&& !TestSetPageDoubleMap(page)) {
 		for (i = 0; i < HPAGE_PMD_NR; i++)
 			atomic_inc(&page[i]._mapcount);
 	}
 
-	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
+	if ((PMDPageInPUD(page) &&
+		atomic_add_negative(-(1 + PagePUDDoubleMap(compound_head(page))),
+			sub_compound_mapcount_ptr(page, 1))) ||
+		atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
 		__dec_node_page_state(page, NR_ANON_THPS);
 		if (TestClearPageDoubleMap(page)) {
@@ -2807,7 +3355,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (freeze) {
 		for (i = 0; i < HPAGE_PMD_NR; i++) {
-			page_remove_rmap(page + i, false);
+			page_remove_rmap(page + i, false, 0);
 			put_page(page + i);
 		}
 	}
@@ -2892,6 +3440,11 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	 * previously contain an hugepage: check if we need to split
 	 * an huge pmd.
 	 */
+	if (start & ~HPAGE_PUD_MASK &&
+	    (start & HPAGE_PUD_MASK) >= vma->vm_start &&
+	    (start & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE <= vma->vm_end)
+		split_huge_pud_address(vma, start, false, NULL);
+
 	if (start & ~HPAGE_PMD_MASK &&
 	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
@@ -2902,6 +3455,11 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	 * previously contain an hugepage: check if we need to split
 	 * an huge pmd.
 	 */
+	if (end & ~HPAGE_PUD_MASK &&
+	    (end & HPAGE_PUD_MASK) >= vma->vm_start &&
+	    (end & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE <= vma->vm_end)
+		split_huge_pud_address(vma, end, false, NULL);
+
 	if (end & ~HPAGE_PMD_MASK &&
 	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
@@ -2916,6 +3474,11 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long nstart = next->vm_start;
 		nstart += adjust_next << PAGE_SHIFT;
+		if (nstart & ~HPAGE_PUD_MASK &&
+		    (nstart & HPAGE_PUD_MASK) >= next->vm_start &&
+		    (nstart & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE <= next->vm_end)
+			split_huge_pud_address(next, nstart, false, NULL);
+
 		if (nstart & ~HPAGE_PMD_MASK &&
 		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
 		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
@@ -3084,12 +3647,23 @@ int total_mapcount(struct page *page)
 	if (PageHuge(page))
 		return compound;
 	ret = compound;
-	for (i = 0; i < HPAGE_PMD_NR; i++)
-		ret += atomic_read(&page[i]._mapcount) + 1;
+	/* if PMD, read all base page, if PUD, read the sub_compound_mapcount()*/
+	if (compound_order(page) == HPAGE_PMD_ORDER) {
+		for (i = 0; i < hpage_nr_pages(page); i++)
+			ret += atomic_read(&page[i]._mapcount) + 1;
+	} else if (compound_order(page) == HPAGE_PUD_ORDER) {
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+			ret += sub_compound_mapcount(&page[i]);
+		for (i = 0; i < hpage_nr_pages(page); i++)
+			ret += atomic_read(&page[i]._mapcount) + 1;
+	} else
+		VM_BUG_ON_PAGE(1, page);
 	/* File pages has compound_mapcount included in _mapcount */
+	/* both PUD and PMD has HPAGE_PMD_NR sub pages */
 	if (!PageAnon(page))
 		return ret - compound * HPAGE_PMD_NR;
-	if (PageDoubleMap(page))
+	/* both PUD and PMD has HPAGE_PMD_NR sub pages */
+	if (PagePUDDoubleMap(page) || PageDoubleMap(page))
 		ret -= HPAGE_PMD_NR;
 	return ret;
 }
@@ -3135,13 +3709,38 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
 	page = compound_head(page);
 
 	_total_mapcount = ret = 0;
-	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		mapcount = atomic_read(&page[i]._mapcount) + 1;
-		ret = max(ret, mapcount);
-		_total_mapcount += mapcount;
-	}
-	if (PageDoubleMap(page)) {
+	/* if PMD, read all base page, if PUD, read the sub_compound_mapcount()*/
+	if (compound_order(page) == HPAGE_PMD_ORDER) {
+		for (i = 0; i < hpage_nr_pages(page); i++) {
+			mapcount = atomic_read(&page[i]._mapcount) + 1;
+			ret = max(ret, mapcount);
+			_total_mapcount += mapcount;
+		}
+	} else if (compound_order(page) == HPAGE_PUD_ORDER) {
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+			int j;
+
+			mapcount = sub_compound_mapcount(&page[i]);
+			ret = max(ret, mapcount);
+			_total_mapcount += mapcount;
+
+			/* Triple mapped at base page size */
+			for (j = 0; j < HPAGE_PMD_NR; j++) {
+				mapcount = atomic_read(&page[i + j]._mapcount) + 1;
+				ret = max(ret, mapcount);
+				_total_mapcount += mapcount;
+			}
+
+			if (PageDoubleMap(&page[i])) {
+				ret -= 1;
+				_total_mapcount -= HPAGE_PMD_NR;
+			}
+		}
+	} else
+		VM_BUG_ON_PAGE(1, page);
+	if (PageDoubleMap(page) || PagePUDDoubleMap(page)) {
 		ret -= 1;
+		/* both PUD and PMD has HPAGE_PMD_NR sub pages */
 		_total_mapcount -= HPAGE_PMD_NR;
 	}
 	mapcount = compound_mapcount(page);
@@ -3360,6 +3959,9 @@ static unsigned long deferred_split_count(struct shrinker *shrink,
 	return READ_ONCE(pgdata->split_queue_len);
 }
 
+#define deferred_list_entry(x) (compound_head(list_entry((void *)x, \
+					struct page, mapping)))
+
 static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
@@ -3372,8 +3974,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
 	list_for_each_safe(pos, next, &pgdata->split_queue) {
-		page = list_entry((void *)pos, struct page, mapping);
-		page = compound_head(page);
+		page = deferred_list_entry(pos);
 		if (get_page_unless_zero(page)) {
 			list_move(page_deferred_list(page), &list);
 		} else {
@@ -3387,12 +3988,18 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
 	list_for_each_safe(pos, next, &list) {
-		page = list_entry((void *)pos, struct page, mapping);
+		page = deferred_list_entry(pos);
 		if (!trylock_page(page))
 			goto next;
 		/* split_huge_page() removes page from list on success */
-		if (!split_huge_page(page))
-			split++;
+		if (compound_order(page) == HPAGE_PUD_ORDER) {
+			if (!split_huge_pud_page(page))
+				split++;
+		} else if (compound_order(page) == HPAGE_PMD_ORDER) {
+			if (!split_huge_page(page))
+				split++;
+		} else
+			VM_BUG_ON_PAGE(1, page);
 		unlock_page(page);
 next:
 		put_page(page);
@@ -3499,7 +4106,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	if (pmd_soft_dirty(pmdval))
 		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
 	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 	put_page(page);
 }
 
@@ -3525,7 +4132,7 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 
 	flush_cache_range(vma, mmun_start, mmun_start + HPAGE_PMD_SIZE);
 	if (PageAnon(new))
-		page_add_anon_rmap(new, vma, mmun_start, true);
+		page_add_anon_rmap(new, vma, mmun_start, true, HPAGE_PMD_ORDER);
 	else
 		page_add_file_rmap(new, true);
 	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef61656c1e..0db6c31440e8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3418,7 +3418,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			set_page_dirty(page);
 
 		hugetlb_count_sub(pages_per_huge_page(h), mm);
-		page_remove_rmap(page, true);
+		page_remove_rmap(page, true, huge_page_order(h));
 
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, page, huge_page_size(h));
@@ -3643,7 +3643,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		mmu_notifier_invalidate_range(mm, range.start, range.end);
 		set_huge_pte_at(mm, haddr, ptep,
 				make_huge_pte(vma, new_page, 1));
-		page_remove_rmap(old_page, true);
+		page_remove_rmap(old_page, true, huge_page_order(h));
 		hugepage_add_new_anon_rmap(new_page, vma, haddr);
 		/* Make the old page be freed below */
 		new_page = old_page;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index aedaa9f75806..3acfddcba714 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -674,7 +674,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			 * superfluous.
 			 */
 			pte_clear(vma->vm_mm, address, _pte);
-			page_remove_rmap(src_page, false);
+			page_remove_rmap(src_page, false, 0);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
@@ -1073,7 +1073,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
-	page_add_new_anon_rmap(new_page, vma, address, true);
+	page_add_new_anon_rmap(new_page, vma, address, true, HPAGE_PMD_ORDER);
 	mem_cgroup_commit_charge(new_page, memcg, false, true);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
diff --git a/mm/ksm.c b/mm/ksm.c
index dc1ec06b71a0..68f1d0f8be22 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1154,7 +1154,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	 */
 	if (!is_zero_pfn(page_to_pfn(kpage))) {
 		get_page(kpage);
-		page_add_anon_rmap(kpage, vma, addr, false);
+		page_add_anon_rmap(kpage, vma, addr, false, 0);
 		newpte = mk_pte(kpage, vma->vm_page_prot);
 	} else {
 		newpte = pte_mkspecial(pfn_pte(page_to_pfn(kpage),
@@ -1178,7 +1178,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, newpte);
 
-	page_remove_rmap(page, false);
+	page_remove_rmap(page, false, 0);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	put_page(page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..ae3ff6a4da8c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2678,6 +2678,19 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 
 	__mod_memcg_state(head->mem_cgroup, MEMCG_RSS_HUGE, -HPAGE_PMD_NR);
 }
+
+void mem_cgroup_split_huge_pud_fixup(struct page *head)
+{
+	int i;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	for (i = HPAGE_PMD_NR; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+		head[i].mem_cgroup = head->mem_cgroup;
+
+	/*__mod_memcg_state(head->mem_cgroup, MEMCG_RSS_HUGE, -HPAGE_PUD_NR);*/
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_MEMCG_SWAP
diff --git a/mm/memory.c b/mm/memory.c
index 3608b5436519..c875cc1a2600 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1088,7 +1088,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					mark_page_accessed(page);
 			}
 			rss[mm_counter(page)]--;
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, false, 0);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
@@ -1116,7 +1116,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 			rss[mm_counter(page)]--;
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, false, 0);
 			put_page(page);
 			continue;
 		}
@@ -2300,7 +2300,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, vmf->address, vmf->pte);
-		page_add_new_anon_rmap(new_page, vma, vmf->address, false);
+		page_add_new_anon_rmap(new_page, vma, vmf->address, false, 0);
 		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2333,7 +2333,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 			 * mapcount is visible. So transitively, TLBs to
 			 * old page will be flushed before it can be reused.
 			 */
-			page_remove_rmap(old_page, false);
+			page_remove_rmap(old_page, false, 0);
 		}
 
 		/* Free the old page.. */
@@ -2816,11 +2816,11 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 	/* ksm created a completely new copy */
 	if (unlikely(page != swapcache && swapcache)) {
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		page_add_new_anon_rmap(page, vma, vmf->address, false, 0);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
-		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
+		do_page_add_anon_rmap(page, vma, vmf->address, exclusive, 0);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
 	}
@@ -2967,7 +2967,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	}
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, vmf->address, false);
+	page_add_new_anon_rmap(page, vma, vmf->address, false, 0);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
@@ -3241,7 +3241,7 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	/* copy-on-write page */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, vmf->address, false);
+		page_add_new_anon_rmap(page, vma, vmf->address, false, 0);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index b8c79aa62134..f7e5d88210ee 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -268,7 +268,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
 			if (PageAnon(new))
-				page_add_anon_rmap(new, vma, pvmw.address, false);
+				page_add_anon_rmap(new, vma, pvmw.address, false, 0);
 			else
 				page_add_file_rmap(new, false);
 		}
@@ -2067,7 +2067,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	page_ref_unfreeze(page, 2);
 	mlock_migrate_page(new_page, page);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, true, HPAGE_PMD_ORDER);
 	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
 
 	spin_unlock(ptl);
@@ -2297,7 +2297,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			 * drop page refcount. Page won't be freed, as we took
 			 * a reference just above.
 			 */
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, false, 0);
 			put_page(page);
 
 			if (pte_present(pte))
@@ -2688,7 +2688,7 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 	}
 
 	inc_mm_counter(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, addr, false);
+	page_add_new_anon_rmap(page, vma, addr, false, 0);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	if (!is_zone_device_page(page))
 		lru_cache_add_active_or_unevictable(page, vma);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a3b295ea7348..dbcccc022b30 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -626,6 +626,9 @@ void prep_compound_page(struct page *page, unsigned int order)
 		set_compound_head(p, page);
 	}
 	atomic_set(compound_mapcount_ptr(page), -1);
+	if (order == HPAGE_PUD_ORDER)
+		for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+			atomic_set(sub_compound_mapcount_ptr(&page[i], 1), -1);
 }
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -1001,6 +1004,13 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 		 */
 		break;
 	default:
+		/* sub_compound_map_ptr store here */
+		if (compound_order(head_page) == HPAGE_PUD_ORDER &&
+			(page - head_page) % HPAGE_PMD_NR == 3) {
+			if (unlikely(atomic_read(&page->compound_mapcount) != -1))
+				bad_page(page, "nonzero sub_compound_mapcount", 0);
+			break;
+		}
 		if (page->mapping != TAIL_MAPPING) {
 			bad_page(page, "corrupted mapping in tail page", 0);
 			goto out;
@@ -1041,8 +1051,14 @@ static __always_inline bool free_pages_prepare(struct page *page,
 
 		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
 
-		if (compound)
+		if (compound) {
 			ClearPageDoubleMap(page);
+			if (order == HPAGE_PUD_ORDER) {
+				ClearPagePUDDoubleMap(page);
+				for (i = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR)
+					ClearPageDoubleMap(&page[i]);
+			}
+		}
 		for (i = 1; i < (1 << order); i++) {
 			if (compound)
 				bad += free_tail_pages_check(page, page + i);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 0b79568fba1c..95af1d67f209 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -236,6 +236,17 @@ pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 }
 #endif
 
+#ifndef __HAVE_ARCH_PUDP_INVALIDATE
+pud_t pudp_invalidate(struct vm_area_struct *vma, unsigned long address,
+		     pud_t *pudp)
+{
+	pud_t old = pudp_establish(vma, address, pudp, pud_mknotpresent(*pudp));
+
+	flush_pud_tlb_range(vma, address, address + HPAGE_PUD_SIZE);
+	return old;
+}
+#endif
+
 #ifndef pmdp_collapse_flush
 pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
diff --git a/mm/rmap.c b/mm/rmap.c
index f69d81d4a956..79908cfc518a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1097,9 +1097,9 @@ static void __page_check_anon_rmap(struct page *page,
  * (but PageKsm is never downgraded to PageAnon).
  */
 void page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, bool compound)
+	struct vm_area_struct *vma, unsigned long address, bool compound, int order)
 {
-	do_page_add_anon_rmap(page, vma, address, compound ? RMAP_COMPOUND : 0);
+	do_page_add_anon_rmap(page, vma, address, compound ? RMAP_COMPOUND : 0, order);
 }
 
 /*
@@ -1108,7 +1108,7 @@ void page_add_anon_rmap(struct page *page,
  * Everybody else should continue to use page_add_anon_rmap above.
  */
 void do_page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, int flags)
+	struct vm_area_struct *vma, unsigned long address, int flags, int order)
 {
 	bool compound = flags & RMAP_COMPOUND;
 	bool first;
@@ -1117,7 +1117,18 @@ void do_page_add_anon_rmap(struct page *page,
 		atomic_t *mapcount;
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		mapcount = compound_mapcount_ptr(page);
+		if (compound_order(page) == HPAGE_PUD_ORDER) {
+			if (order == HPAGE_PUD_ORDER) {
+				mapcount = compound_mapcount_ptr(page);
+			} else if (order == HPAGE_PMD_ORDER) {
+				VM_BUG_ON(!PMDPageInPUD(page));
+				mapcount = sub_compound_mapcount_ptr(page, 1);
+			} else
+				VM_BUG_ON(1);
+		} else if (compound_order(page) == HPAGE_PMD_ORDER) {
+			mapcount = compound_mapcount_ptr(page);
+		} else
+			VM_BUG_ON(1);
 		first = atomic_inc_and_test(mapcount);
 	} else {
 		first = atomic_inc_and_test(&page->_mapcount);
@@ -1132,7 +1143,7 @@ void do_page_add_anon_rmap(struct page *page,
 		 * disabled.
 		 */
 		if (compound) {
-			if (nr == HPAGE_PMD_NR)
+			if (order == HPAGE_PMD_ORDER)
 				__inc_node_page_state(page, NR_ANON_THPS);
 			else
 				__inc_node_page_state(page, NR_ANON_THPS_PUD);
@@ -1164,7 +1175,7 @@ void do_page_add_anon_rmap(struct page *page,
  * Page does not have to be locked.
  */
 void page_add_new_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, bool compound)
+	struct vm_area_struct *vma, unsigned long address, bool compound, int order)
 {
 	int nr = compound ? hpage_nr_pages(page) : 1;
 
@@ -1174,10 +1185,15 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		if (nr == HPAGE_PMD_NR)
-			__inc_node_page_state(page, NR_ANON_THPS);
-		else
+		if (order == HPAGE_PUD_ORDER) {
+			VM_BUG_ON(compound_order(page) != HPAGE_PUD_ORDER);
+			/* Anon THP always mapped first with PMD */
 			__inc_node_page_state(page, NR_ANON_THPS_PUD);
+		} else if (order == HPAGE_PMD_ORDER) {
+			VM_BUG_ON(compound_order(page) != HPAGE_PMD_ORDER);
+			__inc_node_page_state(page, NR_ANON_THPS);
+		} else
+			VM_BUG_ON(1);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1268,12 +1284,40 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	unlock_page_memcg(page);
 }
 
-static void page_remove_anon_compound_rmap(struct page *page)
+static void page_remove_anon_compound_rmap(struct page *page, int order)
 {
-	int i, nr;
-
-	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
-		return;
+	int i, nr = 0;
+	struct page *head = compound_head(page);
+
+	if (compound_order(head) == HPAGE_PUD_ORDER) {
+		if (order == HPAGE_PMD_ORDER) {
+			VM_BUG_ON(!PMDPageInPUD(page));
+			if (atomic_add_negative(-1, sub_compound_mapcount_ptr(page, 1))) {
+				if (TestClearPageDoubleMap(page)) {
+					/*
+					 * Subpages can be mapped with PTEs too. Check how many of
+					 * themi are still mapped.
+					 */
+					for (i = 0; i < hpage_nr_pages(head); i++) {
+						if (atomic_add_negative(-1, &head[i]._mapcount))
+							nr++;
+					}
+				}
+				__dec_node_page_state(page, NR_ANON_THPS);
+			}
+			nr += HPAGE_PMD_NR;
+			__mod_node_page_state(page_pgdat(head), NR_ANON_MAPPED, -nr);
+			return;
+		} else {
+			VM_BUG_ON(order != HPAGE_PUD_ORDER);
+			if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+				return;
+		}
+	} else if (compound_order(head) == HPAGE_PMD_ORDER) {
+		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+			return;
+	} else
+		VM_BUG_ON_PAGE(1, page);
 
 	/* Hugepages are not counted in NR_ANON_PAGES for now. */
 	if (unlikely(PageHuge(page)))
@@ -1282,30 +1326,44 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	if (hpage_nr_pages(page) == HPAGE_PMD_NR)
+	if (order == HPAGE_PMD_ORDER)
 		__dec_node_page_state(page, NR_ANON_THPS);
-	else
+	else if (order == HPAGE_PUD_ORDER)
 		__dec_node_page_state(page, NR_ANON_THPS_PUD);
+	else
+		VM_BUG_ON(1);
 
-	if (TestClearPageDoubleMap(page)) {
+	/* PMD-mapped PUD THP is handled above */
+	if (TestClearPagePUDDoubleMap(head)) {
+		VM_BUG_ON(!(compound_order(head) == HPAGE_PUD_ORDER || head == page));
+		/*
+		 * Subpages can be mapped with PMDs too. Check how many of
+		 * themi are still mapped.
+		 */
+		for (i = 0, nr = 0; i < HPAGE_PUD_NR; i += HPAGE_PMD_NR) {
+			if (atomic_add_negative(-1, sub_compound_mapcount_ptr(&head[i], 1)))
+				nr += HPAGE_PMD_NR;
+		}
+	} else if (TestClearPageDoubleMap(head)) {
+		VM_BUG_ON(compound_order(head) != HPAGE_PMD_ORDER);
 		/*
 		 * Subpages can be mapped with PTEs too. Check how many of
 		 * themi are still mapped.
 		 */
-		for (i = 0, nr = 0; i < hpage_nr_pages(page); i++) {
-			if (atomic_add_negative(-1, &page[i]._mapcount))
+		for (i = 0, nr = 0; i < hpage_nr_pages(head); i++) {
+			if (atomic_add_negative(-1, &head[i]._mapcount))
 				nr++;
 		}
 	} else {
-		nr = hpage_nr_pages(page);
+		nr = hpage_nr_pages(head);
 	}
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
 	if (nr) {
-		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
-		deferred_split_huge_page(page);
+		__mod_node_page_state(page_pgdat(head), NR_ANON_MAPPED, -nr);
+		deferred_split_huge_page(head);
 	}
 }
 
@@ -1316,13 +1374,13 @@ static void page_remove_anon_compound_rmap(struct page *page)
  *
  * The caller needs to hold the pte lock.
  */
-void page_remove_rmap(struct page *page, bool compound)
+void page_remove_rmap(struct page *page, bool compound, int order)
 {
 	if (!PageAnon(page))
 		return page_remove_file_rmap(page, compound);
 
 	if (compound)
-		return page_remove_anon_compound_rmap(page);
+		return page_remove_anon_compound_rmap(page, order);
 
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
@@ -1672,7 +1730,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 *
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
-		page_remove_rmap(subpage, PageHuge(page));
+		page_remove_rmap(subpage, PageHuge(page), 0);
 		put_page(page);
 	}
 
diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1be60e..79de59875280 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -851,6 +851,44 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	if (!PageUnevictable(page))
 		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
 }
+
+/* used by __split_pud_huge_page_tail() */
+void lru_add_pud_page_tail(struct page *page, struct page *page_tail,
+		       struct lruvec *lruvec, struct list_head *list)
+{
+	const int file = 0;
+
+	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
+	VM_BUG_ON(NR_CPUS != 1 &&
+		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
+
+	if (!list)
+		SetPageLRU(page_tail);
+
+	if (likely(PageLRU(page)))
+		list_add_tail(&page_tail->lru, &page->lru);
+	else if (list) {
+		/* page reclaim is reclaiming a huge page */
+		get_page(page_tail);
+		list_add_tail(&page_tail->lru, list);
+	} else {
+		struct list_head *list_head;
+		/*
+		 * Head page has not yet been counted, as an hpage,
+		 * so we must account for each subpage individually.
+		 *
+		 * Use the standard add function to put page_tail on the list,
+		 * but then correct its position so they all end up in order.
+		 */
+		add_page_to_lru_list(page_tail, lruvec, page_lru(page_tail));
+		list_head = page_tail->lru.prev;
+		list_move_tail(&page_tail->lru, list_head);
+	}
+
+	if (!PageUnevictable(page))
+		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
diff --git a/mm/swapfile.c b/mm/swapfile.c
index dbac1d49469d..742caaea2aa5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1775,10 +1775,10 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
-		page_add_anon_rmap(page, vma, addr, false);
+		page_add_anon_rmap(page, vma, addr, false, 0);
 		mem_cgroup_commit_charge(page, memcg, true, false);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, addr, false);
+		page_add_new_anon_rmap(page, vma, addr, false, 0);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d59b5a73dfb3..e49537f6000e 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -90,7 +90,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 		goto out_release_uncharge_unlock;
 
 	inc_mm_counter(dst_mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, dst_vma, dst_addr, false);
+	page_add_new_anon_rmap(page, dst_vma, dst_addr, false, 0);
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, dst_vma);
 
diff --git a/mm/util.c b/mm/util.c
index 1ea055138043..1b1b6dd386d1 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -536,8 +536,15 @@ struct address_space *page_mapping_file(struct page *page)
 int __page_mapcount(struct page *page)
 {
 	int ret;
+	struct page *head = compound_head(page);
 
 	ret = atomic_read(&page->_mapcount) + 1;
+	if (compound_order(head) == HPAGE_PUD_ORDER) {
+		struct page *sub_compound_page = head +
+			(((page - head) / HPAGE_PMD_NR) * HPAGE_PMD_NR);
+
+		ret += sub_compound_mapcount(sub_compound_page);
+	}
 	/*
 	 * For file THP page->_mapcount contains total number of mapping
 	 * of the page: no need to look into compound_mapcount.
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 25a88693e417..1d185cf748a6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1263,6 +1263,10 @@ const char * const vmstat_text[] = {
 	"thp_fault_alloc_pud",
 	"thp_fault_fallback_pud",
 	"thp_split_pud",
+	"thp_split_pud_page",
+	"thp_split_pud_page_failed",
+	"thp_zero_pud_page_alloc",
+	"thp_zero_pud_page_alloc_failed",
 #endif
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
2.20.1


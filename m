Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17AD0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93986222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="luujar5O";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UrF6Li26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93986222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90EA78E000C; Fri, 15 Feb 2019 17:09:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8203B8E0009; Fri, 15 Feb 2019 17:09:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BFC58E000C; Fri, 15 Feb 2019 17:09:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3074E8E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:18 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id c9so2510219qte.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=oa/dF8R2QGjPtC6Q8g6KGYStpyoteQyjNj2+6vec29I=;
        b=E9yZDJNyeS3tF39wvteB1BgsMfNZfPYsi1ho6palcSA9tILmcLdOTd/nPu57xT384Z
         QslbmXAeiAWrrSZXe31v3ChtOIAuZUDYlckAtLvqKNETCn4VfpBIDpw/FRtgU/Bp+jv2
         /niJryoSVVuljoYp4CZSS9jrrnTPDAso63aA4PolAmgbsYGg+maVLc9FYnEYHXLZl51M
         umeEEiulInxn5fWmHdhoXFLQg8RpiB5hRGN5BIOWTMVepVFwyRVkywODArIqkItAnhET
         IuBFy1RS55W38JSWwtmpUNDfQwJ40KtX4XThNZ5Sm47VVE77Nm9ASNqcO702AjUuY5pj
         moNA==
X-Gm-Message-State: AHQUAuZPeVXwqoNTZwlYeO27/QlZDLrZcHSGkc9BdUm9nXrfwpra609y
	arWk18UqWta0wA4JZg2bXP7BekB6J+i1TL2YZCuTB8ozyGgtFVKrmd/dsfNwrxagmlen95Eq9H+
	sp+lLZlyCBpKSbLo5CWoMiULBPzrq3tyCTsfhzqfzKMwgJOg3pmwLUkfaYBVyz8RP7Q==
X-Received: by 2002:aed:3964:: with SMTP id l91mr9441195qte.33.1550268557877;
        Fri, 15 Feb 2019 14:09:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibku1PecIF/Ee8vwYTwuKgtKFGkdqa8nbyQAv/iGeN94hNHs/hgHfNwL4XHUemHw+v6A4K5
X-Received: by 2002:aed:3964:: with SMTP id l91mr9441106qte.33.1550268556383;
        Fri, 15 Feb 2019 14:09:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268556; cv=none;
        d=google.com; s=arc-20160816;
        b=IA757XAGmuCowLc/pe697d88lhfw6TfR5fmj0TZ7kPOo2mdA+fUzl2DIpCx6w9mku+
         /VFGCz2hkvwj5lWW4WRAiki3OIOLtij885j+pMZBwHJQvEv6W42/8tFZb2Z5JMjh6Fhd
         oIQUJbteO51crgYwkKkfnkceT+hLYRItlqcsaarfjGM8cAvjuOVIl5wJdsJl9lUfrJms
         J+zq+OZnqlkQjrOSPUrzKuZH+JDvuaJvxhKz/PSLeqjyzgvd/S33qZceUlT4lSVuUUqD
         GWfOmT6+Vprk73usVzs7N0CM9Gh26qQztwel1/VRKDbV0aH4aqSlEQk4fw2vA585OLW7
         G9LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=oa/dF8R2QGjPtC6Q8g6KGYStpyoteQyjNj2+6vec29I=;
        b=ZHGIjJkduRbjWa55lTERvM7L8hnrULwxEESP2t8te7SV//1zavQdQHuTHtIi6lGqfH
         xQsycKfVmYnmLi501TS1INVFZY+TqUU9azrWeriVAnDSd55susZ7TZYGNEmxex7H3dy0
         PuHwcqSbXTHZfkHtSqW21Sfd8D1Mo9/iPt+zlFTEi5OnLAHIUvKszOhn2gGY9QPdatv6
         OoR+MwIHDHlIAl0yRtX40+zNfECJ67Rxcw1zUrCqZMTcysXImt0zTjKwgyY1DE26JccX
         k5b89TUmF2BIPVG5naU1w3FtrGDX+qyeWmUC03I6/R3HVPSJQqOLgJox//AMQWgnjZ4d
         7dUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=luujar5O;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=UrF6Li26;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id b20si4244865qvd.185.2019.02.15.14.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:16 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=luujar5O;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=UrF6Li26;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 94721310A;
	Fri, 15 Feb 2019 17:09:14 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:15 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=oa/dF8R2QGjPt
	C6Q8g6KGYStpyoteQyjNj2+6vec29I=; b=luujar5ODCU+O2/+uwbwjjus4qceG
	Enib9BNOHyjFEJUjK2KN20YEtoljGKq7qkcC2EjEkAivOOMLCYQ830FXxrh7A9cI
	qsGF1zG/JADVvqKRvJ5kZmBCZbtvj3Yyxvgg4u2LQbwvdvTXjuMZiOiaX4ZyR4HB
	SQg8qufkM95BlnJvYpgnSTNLvwYJgGhx992+Neg/32WKM3Y8KgJJ/0kFbqgdtcBE
	5KJKOhOlcf3aYj9RUGHno9Dw1IhrgS5ZjolcwPXKm+dLjdZuL+WJNVa9r+TYsy8K
	n2SRVkyaaLfa59qr/f1IMap2nTTA8l/9BuQeP7a4sm/XhC5C3LKcxucDg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=oa/dF8R2QGjPtC6Q8g6KGYStpyoteQyjNj2+6vec29I=; b=UrF6Li26
	GW652u9rOpjSnz/n3zGVXtGN2IdPrSfjoSaT3axO0XzynXfQ8p5ZTuqMtSK8wvvU
	qx/Gm9wyTreHfxNzHZNd3u0A2yJWMD2ufBFUk61tnGvQwQcT4EGKhD/H9fZzdI1f
	SU8tW7cQ6RL5pwNL5crFa1LcFUge3cpvWbo80zNgVh2oEyba8oIZk5EuxZmg+Dfw
	Cz5B8FBqTuqO2IUgBomgdzLvlzsySBZ4OXv5+Z48+vQ7bF+/xi1qo8zEM2AJgH2V
	VALNg1lVVmzm824skU4HzhkbP19gPYGqf0NxSpP9EqVaNrCZCtvyCzPs10ORu54X
	vNTcY7vyowaCGA==
X-ME-Sender: <xms:iThnXKrIfVUZoq4J1pRMTilcH96_6gQRjwdDSX0GUtNPBAcAB-VsQw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeeh
X-ME-Proxy: <xmx:ijhnXEX8Md57XK8gAmfHQS0j3xyyg3YuTD-aEaHZhoqEPxu5CTHNnA>
    <xmx:ijhnXJ7A0oXF3LSRieREfFvQolyE9tqGMhwDFBCGuLlFFdXfDkgCqw>
    <xmx:ijhnXK0-nLeBN0jYmPqe91fb0YqLd-UBpGMstx5KMIvALIPep6j7LA>
    <xmx:ijhnXNM9k5L9jTemBKIL9ayjiAyrMc_tKs9Rq-mL8t3Obrxi7wJlpQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7DF09E4649;
	Fri, 15 Feb 2019 17:09:12 -0500 (EST)
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
Subject: [RFC PATCH 09/31] mm: thp: 1GB anonymous page implementation.
Date: Fri, 15 Feb 2019 14:08:34 -0800
Message-Id: <20190215220856.29749-10-zi.yan@sent.com>
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

This adds 1GB THP support for anonymous pages. Applications can get 1GB
pages during page faults when their VMAs are larger than 1GB. For
read-only 1GB zero THP, a shared 1GB zero THP is created for all
readers.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/include/asm/pgalloc.h |  58 +++++++
 arch/x86/include/asm/pgtable.h |   2 +
 arch/x86/mm/pgtable.c          |  25 +++
 drivers/base/node.c            |   4 +-
 fs/proc/meminfo.c              |   3 +-
 include/asm-generic/pgtable.h  |   3 +
 include/linux/huge_mm.h        |  17 ++-
 include/linux/mm.h             |   4 +
 include/linux/mm_types.h       |   1 +
 include/linux/mmzone.h         |   1 +
 include/linux/sched/coredump.h |   1 +
 include/linux/vm_event_item.h  |   2 +
 kernel/fork.c                  |   5 +
 mm/huge_memory.c               | 267 ++++++++++++++++++++++++++++++++-
 mm/memory.c                    |  28 +++-
 mm/page_alloc.c                |   3 +-
 mm/pgtable-generic.c           |  47 +++++-
 mm/rmap.c                      |  28 +++-
 mm/vmstat.c                    |   3 +
 19 files changed, 484 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index a281e61ec60c..6e29ad9b9d7f 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -49,6 +49,7 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *);
 extern pgtable_t pte_alloc_one(struct mm_struct *);
+extern pgtable_t pte_alloc_order(struct mm_struct *, unsigned long, int);
 
 /* Should really implement gc for free page table pages. This could be
    done with a reference count in struct page. */
@@ -65,6 +66,17 @@ static inline void pte_free(struct mm_struct *mm, struct page *pte)
 	__free_page(pte);
 }
 
+static inline void pte_free_order(struct mm_struct *mm, struct page *pte,
+		int order)
+{
+	int i;
+
+	for (i = 0; i < (1<<order); i++) {
+		pgtable_page_dtor(&pte[i]);
+		__free_page(&pte[i]);
+	}
+}
+
 extern void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte);
 
 static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *pte,
@@ -123,6 +135,52 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	free_page((unsigned long)pmd);
 }
 
+static inline pmd_t *pmd_alloc_one_page_with_ptes(struct mm_struct *mm, unsigned long addr)
+{
+	pgtable_t pte_pgtables;
+	pmd_t *pmd;
+	spinlock_t *pmd_ptl;
+	int i;
+
+	pte_pgtables = pte_alloc_order(mm, addr,
+		HPAGE_PUD_ORDER - HPAGE_PMD_ORDER);
+	if (!pte_pgtables)
+		return NULL;
+
+	pmd = pmd_alloc_one(mm, addr);
+	if (unlikely(!pmd)) {
+		pte_free_order(mm, pte_pgtables,
+			HPAGE_PUD_ORDER - HPAGE_PMD_ORDER);
+		return NULL;
+	}
+	pmd_ptl = pmd_lock(mm, pmd);
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++)
+		pgtable_trans_huge_deposit(mm, pmd, pte_pgtables + i);
+
+	spin_unlock(pmd_ptl);
+
+	return pmd;
+}
+
+static inline void pmd_free_page_with_ptes(struct mm_struct *mm, pmd_t *pmd)
+{
+	spinlock_t *pmd_ptl;
+	int i;
+
+	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
+	pmd_ptl = pmd_lock(mm, pmd);
+
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++) {
+		pgtable_t pte_pgtable;
+
+		pte_pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+		pte_free(mm, pte_pgtable);
+	}
+
+	spin_unlock(pmd_ptl);
+	pmd_free(mm, pmd);
+}
 extern void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd);
 
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..ae3ac49c32ad 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1165,6 +1165,8 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long
 	return native_pmdp_get_and_clear(pmdp);
 }
 
+#define mk_pud(page, pgprot)   pfn_pud(page_to_pfn(page), (pgprot))
+
 #define __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR
 static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
 					unsigned long addr, pud_t *pudp)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7bd01709a091..0a5008690d7c 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -42,6 +42,31 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
 	return pte;
 }
 
+pgtable_t pte_alloc_order(struct mm_struct *mm, unsigned long address, int order)
+{
+	struct page *pte;
+	int i;
+
+	pte = alloc_pages(__userpte_alloc_gfp, order);
+	if (!pte)
+		return NULL;
+	split_page(pte, order);
+	for (i = 1; i < (1 << order); i++)
+		set_page_private(pte + i, 0);
+
+	for (i = 0; i < (1<<order); i++) {
+		if (!pgtable_page_ctor(&pte[i])) {
+			__free_page(&pte[i]);
+			while (--i >= 0) {
+				pgtable_page_dtor(&pte[i]);
+				__free_page(&pte[i]);
+			}
+			return NULL;
+		}
+	}
+	return pte;
+}
+
 static int __init setup_userpte(char *arg)
 {
 	if (!arg)
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..f21d2235bf97 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -150,7 +150,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       ,
 		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
-				       HPAGE_PMD_NR),
+				       HPAGE_PMD_NR) +
+				    K(node_page_state(pgdat, NR_ANON_THPS_PUD) *
+				       HPAGE_PUD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..9d127e440e4c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -131,7 +131,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	show_val_kb(m, "AnonHugePages:  ",
-		    global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR);
+		    global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR +
+			global_node_page_state(NR_ANON_THPS_PUD) * HPAGE_PUD_NR);
 	show_val_kb(m, "ShmemHugePages: ",
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
 	show_val_kb(m, "ShmemPmdMapped: ",
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6c843f..0f626d6177c3 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -303,10 +303,13 @@ static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
+extern void pgtable_trans_huge_pud_deposit(struct mm_struct *mm, pud_t *pudp,
+				       pgtable_t pgtable);
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+extern pgtable_t pgtable_trans_huge_pud_withdraw(struct mm_struct *mm, pud_t *pudp);
 #endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 381e872bfde0..c6272e6ffc35 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -18,10 +18,15 @@ extern int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 extern void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud);
+extern int do_huge_pud_anonymous_page(struct vm_fault *vmf);
 #else
 static inline void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
 {
 }
+extern int do_huge_pud_anonymous_page(struct vm_fault *vmf)
+{
+	return VM_FAULT_FALLBACK;
+}
 #endif
 
 extern vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
@@ -80,6 +85,9 @@ extern struct kobj_attribute shmem_enabled_attr;
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
+#define HPAGE_PUD_ORDER (HPAGE_PUD_SHIFT-PAGE_SHIFT)
+#define HPAGE_PUD_NR (1<<HPAGE_PUD_ORDER)
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
@@ -214,7 +222,7 @@ static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
-		return HPAGE_PMD_NR;
+		return (1<<page[1].compound_order);
 	return 1;
 }
 
@@ -226,10 +234,12 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
+extern struct page *huge_pud_zero_page;
 
 static inline bool is_huge_zero_page(struct page *page)
 {
-	return READ_ONCE(huge_zero_page) == page;
+	return (READ_ONCE(huge_zero_page) == page) ||
+			(READ_ONCE(huge_pud_zero_page) == page);
 }
 
 static inline bool is_huge_zero_pmd(pmd_t pmd)
@@ -239,13 +249,14 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 
 static inline bool is_huge_zero_pud(pud_t pud)
 {
-	return false;
+	return is_huge_zero_page(pud_page(pud));
 }
 
 struct page *mm_get_huge_zero_page(struct mm_struct *mm);
 void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
+#define mk_huge_pud(page, prot) pud_mkhuge(mk_pud(page, prot))
 
 static inline bool thp_migration_supported(void)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5bcc1b03372a..d10dc9db2311 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -26,6 +26,7 @@
 #include <linux/page_ref.h>
 #include <linux/memremap.h>
 #include <linux/overflow.h>
+#include <linux/pagechain.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1985,6 +1986,7 @@ static inline void pgtable_init(void)
 {
 	ptlock_cache_init();
 	pgtable_cache_init();
+	pagechain_cache_init();
 }
 
 static inline bool pgtable_page_ctor(struct page *page)
@@ -2101,6 +2103,8 @@ static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
 	return ptl;
 }
 
+#define pud_huge_pte(mm, pud) ((mm)->pud_huge_pte)
+
 extern void __init pagecache_init(void);
 extern void free_area_init(unsigned long * zones_size);
 extern void __init free_area_init_node(int nid, unsigned long * zones_size,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 32549b255d25..a5ac5946a375 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -466,6 +466,7 @@ struct mm_struct {
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 		pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
+		struct list_head pud_huge_pte; /* protected by page_table_lock */
 #ifdef CONFIG_NUMA_BALANCING
 		/*
 		 * numa_next_scan is the next time that the PTEs will be marked
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..ea84d6a1802d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -177,6 +177,7 @@ enum node_stat_item {
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
 	NR_ANON_THPS,
+	NR_ANON_THPS_PUD,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index 52ad71db6687..4893849d11eb 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -73,6 +73,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_OOM_VICTIM		25	/* mm is the oom victim */
 #define MMF_OOM_REAP_QUEUED	26	/* mm was queued for oom_reaper */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
+#define MMF_HUGE_PUD_ZERO_PAGE	26	/* mm has ever used the global huge pud zero page */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
 				 MMF_DISABLE_THP_MASK)
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 6b32c8243616..4550667b2274 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -82,6 +82,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_DEFERRED_SPLIT_PAGE,
 		THP_SPLIT_PMD,
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+		THP_FAULT_ALLOC_PUD,
+		THP_FAULT_FALLBACK_PUD,
 		THP_SPLIT_PUD,
 #endif
 		THP_ZERO_PAGE_ALLOC,
diff --git a/kernel/fork.c b/kernel/fork.c
index dcefa978c232..fc5a925e0496 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -662,6 +662,10 @@ static void check_mm(struct mm_struct *mm)
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
 #endif
+	VM_BUG_ON_MM(!list_empty(&mm->pud_huge_pte) &&
+				 !pagechain_empty(list_first_entry(&mm->pud_huge_pte,
+					struct pagechain, list)),
+				mm);
 }
 
 #define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
@@ -1003,6 +1007,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
+	INIT_LIST_HEAD(&mm->pud_huge_pte);
 	mm_init_uprobes_state(mm);
 
 	if (current->mm) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ffcae07a87d3..cad4ef01f607 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -62,6 +62,8 @@ static struct shrinker deferred_split_shrinker;
 
 static atomic_t huge_zero_refcount;
 struct page *huge_zero_page __read_mostly;
+static atomic_t huge_pud_zero_refcount;
+struct page *huge_pud_zero_page __read_mostly;
 
 bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
@@ -109,6 +111,42 @@ static void put_huge_zero_page(void)
 	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
 }
 
+static struct page *get_huge_pud_zero_page(void)
+{
+	struct page *zero_page;
+retry:
+	if (likely(atomic_inc_not_zero(&huge_pud_zero_refcount)))
+		return READ_ONCE(huge_pud_zero_page);
+
+	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
+			HPAGE_PUD_ORDER);
+	if (!zero_page) {
+		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
+		return NULL;
+	}
+	count_vm_event(THP_ZERO_PAGE_ALLOC);
+	preempt_disable();
+	if (cmpxchg(&huge_pud_zero_page, NULL, zero_page)) {
+		preempt_enable();
+		__free_pages(zero_page, compound_order(zero_page));
+		goto retry;
+	}
+
+	/* We take additional reference here. It will be put back by shrinker */
+	atomic_set(&huge_pud_zero_refcount, 2);
+	preempt_enable();
+	return READ_ONCE(huge_pud_zero_page);
+}
+
+static void put_huge_pud_zero_page(void)
+{
+	/*
+	 * Counter should never go to zero here. Only shrinker can put
+	 * last reference.
+	 */
+	BUG_ON(atomic_dec_and_test(&huge_pud_zero_refcount));
+}
+
 struct page *mm_get_huge_zero_page(struct mm_struct *mm)
 {
 	if (test_bit(MMF_HUGE_ZERO_PAGE, &mm->flags))
@@ -123,9 +161,23 @@ struct page *mm_get_huge_zero_page(struct mm_struct *mm)
 	return READ_ONCE(huge_zero_page);
 }
 
+struct page *mm_get_huge_pud_zero_page(struct mm_struct *mm)
+{
+	if (test_bit(MMF_HUGE_PUD_ZERO_PAGE, &mm->flags))
+		return READ_ONCE(huge_pud_zero_page);
+
+	if (!get_huge_pud_zero_page())
+		return NULL;
+
+	if (test_and_set_bit(MMF_HUGE_PUD_ZERO_PAGE, &mm->flags))
+		put_huge_pud_zero_page();
+
+	return READ_ONCE(huge_pud_zero_page);
+}
+
 void mm_put_huge_zero_page(struct mm_struct *mm)
 {
-	if (test_bit(MMF_HUGE_ZERO_PAGE, &mm->flags))
+	if (test_bit(MMF_HUGE_PUD_ZERO_PAGE, &mm->flags))
 		put_huge_zero_page();
 }
 
@@ -859,6 +911,175 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(vmf_insert_pfn_pud);
+
+static int __do_huge_pud_anonymous_page(struct vm_fault *vmf, struct page *page,
+		gfp_t gfp)
+{
+	struct vm_area_struct *vma = vmf->vma;
+	struct mem_cgroup *memcg;
+	pmd_t *pmd_pgtable;
+	unsigned long haddr = vmf->address & HPAGE_PUD_MASK;
+	int ret = 0;
+
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
+
+	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp, &memcg, true)) {
+		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK_PUD);
+		return VM_FAULT_FALLBACK;
+	}
+
+	pmd_pgtable = pmd_alloc_one_page_with_ptes(vma->vm_mm, haddr);
+	if (unlikely(!pmd_pgtable)) {
+		ret = VM_FAULT_OOM;
+		goto release;
+	}
+
+	clear_huge_page(page, vmf->address, HPAGE_PUD_NR);
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * clear_huge_page writes become visible before the set_pmd_at()
+	 * write.
+	 */
+	__SetPageUptodate(page);
+
+	vmf->ptl = pud_lock(vma->vm_mm, vmf->pud);
+	if (unlikely(!pud_none(*vmf->pud))) {
+		goto unlock_release;
+	} else {
+		pud_t entry;
+		int i;
+
+		ret = check_stable_address_space(vma->vm_mm);
+		if (ret)
+			goto unlock_release;
+
+		/* Deliver the page fault to userland */
+		if (userfaultfd_missing(vma)) {
+			int ret;
+
+			spin_unlock(vmf->ptl);
+			mem_cgroup_cancel_charge(page, memcg, true);
+			put_page(page);
+			pmd_free_page_with_ptes(vma->vm_mm, pmd_pgtable);
+			ret = handle_userfault(vmf, VM_UFFD_MISSING);
+			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			return ret;
+		}
+
+		entry = mk_huge_pud(page, vma->vm_page_prot);
+		entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
+		page_add_new_anon_rmap(page, vma, haddr, true);
+		mem_cgroup_commit_charge(page, memcg, false, true);
+		lru_cache_add_active_or_unevictable(page, vma);
+		pgtable_trans_huge_pud_deposit(vma->vm_mm, vmf->pud,
+				virt_to_page(pmd_pgtable));
+		set_pud_at(vma->vm_mm, haddr, vmf->pud, entry);
+		add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PUD_NR);
+		mm_inc_nr_pmds(vma->vm_mm);
+		for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++)
+			mm_inc_nr_ptes(vma->vm_mm);
+		spin_unlock(vmf->ptl);
+		count_vm_event(THP_FAULT_ALLOC_PUD);
+	}
+
+	return 0;
+unlock_release:
+	spin_unlock(vmf->ptl);
+release:
+	if (pmd_pgtable)
+		pmd_free_page_with_ptes(vma->vm_mm, pmd_pgtable);
+	mem_cgroup_cancel_charge(page, memcg, true);
+	put_page(page);
+	return ret;
+
+}
+
+/* Caller must hold page table lock. */
+static bool set_huge_pud_zero_page(pgtable_t pmd_pgtable,
+		struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long haddr, pud_t *pud,
+		struct page *zero_page)
+{
+	pud_t entry;
+	int i;
+
+	if (!pud_none(*pud))
+		return false;
+	entry = mk_pud(zero_page, vma->vm_page_prot);
+	entry = pud_mkhuge(entry);
+	if (pmd_pgtable)
+		pgtable_trans_huge_pud_deposit(mm, pud, pmd_pgtable);
+	set_pud_at(mm, haddr, pud, entry);
+	mm_inc_nr_pmds(mm);
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++)
+		mm_inc_nr_ptes(mm);
+	return true;
+}
+
+int do_huge_pud_anonymous_page(struct vm_fault *vmf)
+{
+	struct vm_area_struct *vma = vmf->vma;
+	gfp_t gfp;
+	struct page *page;
+	unsigned long haddr = vmf->address & HPAGE_PUD_MASK;
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PUD_SIZE > vma->vm_end)
+		return VM_FAULT_FALLBACK;
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
+		return VM_FAULT_OOM;
+	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
+			!mm_forbids_zeropage(vma->vm_mm) &&
+			transparent_hugepage_use_zero_page()) {
+		pmd_t *pmd_pgtable;
+		struct page *zero_page;
+		bool set;
+		int ret;
+
+		pmd_pgtable = pmd_alloc_one_page_with_ptes(vma->vm_mm, haddr);
+		if (unlikely(!pmd_pgtable))
+			return VM_FAULT_OOM;
+		zero_page = mm_get_huge_pud_zero_page(vma->vm_mm);
+		if (unlikely(!zero_page)) {
+			pmd_free_page_with_ptes(vma->vm_mm, pmd_pgtable);
+			count_vm_event(THP_FAULT_FALLBACK_PUD);
+			return VM_FAULT_FALLBACK;
+		}
+		vmf->ptl = pud_lock(vma->vm_mm, vmf->pud);
+		ret = 0;
+		set = false;
+		if (pud_none(*vmf->pud)) {
+			ret = check_stable_address_space(vma->vm_mm);
+			if (ret) {
+				spin_unlock(vmf->ptl);
+			} else if (userfaultfd_missing(vma)) {
+				spin_unlock(vmf->ptl);
+				ret = handle_userfault(vmf, VM_UFFD_MISSING);
+				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			} else {
+				set_huge_pud_zero_page(virt_to_page(pmd_pgtable),
+					vma->vm_mm, vma, haddr, vmf->pud, zero_page);
+				spin_unlock(vmf->ptl);
+				set = true;
+			}
+		} else
+			spin_unlock(vmf->ptl);
+		if (!set)
+			pmd_free_page_with_ptes(vma->vm_mm, pmd_pgtable);
+		return ret;
+	}
+	gfp = alloc_hugepage_direct_gfpmask(vma);
+	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PUD_ORDER);
+	if (unlikely(!page)) {
+		count_vm_event(THP_FAULT_FALLBACK_PUD);
+		return VM_FAULT_FALLBACK;
+	}
+	prep_transhuge_page(page);
+	return __do_huge_pud_anonymous_page(vmf, page, gfp);
+}
+
 #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
 static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -1980,12 +2201,27 @@ spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
 }
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline void zap_pud_deposited_table(struct mm_struct *mm, pud_t *pud)
+{
+	pgtable_t pgtable;
+	int i;
+
+	pgtable = pgtable_trans_huge_pud_withdraw(mm, pud);
+	pmd_free_page_with_ptes(mm, (pmd_t *)page_address(pgtable));
+
+	mm_dec_nr_pmds(mm);
+	for (i = 0; i < (1<<(HPAGE_PUD_ORDER - HPAGE_PMD_ORDER)); i++)
+		mm_dec_nr_ptes(mm);
+}
+
 int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pud_t *pud, unsigned long addr)
 {
 	pud_t orig_pud;
 	spinlock_t *ptl;
 
+	tlb_remove_check_page_size_change(tlb, HPAGE_PUD_SIZE);
+
 	ptl = __pud_trans_huge_lock(pud, vma);
 	if (!ptl)
 		return 0;
@@ -2001,9 +2237,34 @@ int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
 		/* No zero page support yet */
+	} else if (is_huge_zero_pud(orig_pud)) {
+		zap_pud_deposited_table(tlb->mm, pud);
+		spin_unlock(ptl);
+		tlb_remove_page_size(tlb, pud_page(orig_pud), HPAGE_PUD_SIZE);
 	} else {
-		/* No support for anonymous PUD pages yet */
-		BUG();
+		struct page *page = NULL;
+		int flush_needed = 1;
+
+		if (pud_present(orig_pud)) {
+			page = pud_page(orig_pud);
+			page_remove_rmap(page, true);
+			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+			VM_BUG_ON_PAGE(!PageHead(page), page);
+		} else
+			WARN_ONCE(1, "Non present huge pmd without pmd migration enabled!");
+
+		if (PageAnon(page)) {
+			zap_pud_deposited_table(tlb->mm, pud);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PUD_NR);
+		} else {
+			if (arch_needs_pgtable_deposit())
+				zap_pud_deposited_table(tlb->mm, pud);
+			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PUD_NR);
+		}
+
+		spin_unlock(ptl);
+		if (flush_needed)
+			tlb_remove_page_size(tlb, page, HPAGE_PUD_SIZE);
 	}
 	return 1;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 019036e87088..177478d5ee47 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3710,7 +3710,7 @@ static vm_fault_t create_huge_pud(struct vm_fault *vmf)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
 	if (vma_is_anonymous(vmf->vma))
-		return VM_FAULT_FALLBACK;
+		return do_huge_pud_anonymous_page(vmf);
 	if (vmf->vma->vm_ops->huge_fault)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PUD);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -4593,3 +4593,29 @@ void ptlock_free(struct page *page)
 	kmem_cache_free(page_ptl_cachep, page->ptl);
 }
 #endif
+
+static struct kmem_cache *pagechain_cachep;
+
+void __init pagechain_cache_init(void)
+{
+	pagechain_cachep = kmem_cache_create("pagechain",
+		sizeof(struct pagechain), 0, SLAB_PANIC, NULL);
+}
+
+struct pagechain *pagechain_alloc(void)
+{
+	struct pagechain *chain;
+
+	chain = kmem_cache_alloc(pagechain_cachep, GFP_ATOMIC);
+
+	if (!chain)
+		return NULL;
+
+	pagechain_init(chain);
+	return chain;
+}
+
+void pagechain_free(struct pagechain *pchain)
+{
+	kmem_cache_free(pagechain_cachep, pchain);
+}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cfa99bb54bd6..a3b295ea7348 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5157,7 +5157,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 					* HPAGE_PMD_NR),
-			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
+			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR +
+			  node_page_state(pgdat, NR_ANON_THPS_PUD) * HPAGE_PUD_NR),
 #endif
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 532c29276fce..0b79568fba1c 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -9,6 +9,7 @@
 
 #include <linux/pagemap.h>
 #include <linux/hugetlb.h>
+#include <linux/pagechain.h>
 #include <asm/tlb.h>
 #include <asm-generic/pgtable.h>
 
@@ -44,7 +45,7 @@ void pmd_clear_bad(pmd_t *pmd)
 
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
- * Only sets the access flags (dirty, accessed), as well as write 
+ * Only sets the access flags (dirty, accessed), as well as write
  * permission. Furthermore, we know it always gets set to a "more
  * permissive" setting, which allows most architectures to optimize
  * this. We return whether the PTE actually changed, which in turn
@@ -161,6 +162,23 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 		list_add(&pgtable->lru, &pmd_huge_pte(mm, pmdp)->lru);
 	pmd_huge_pte(mm, pmdp) = pgtable;
 }
+
+void pgtable_trans_huge_pud_deposit(struct mm_struct *mm, pud_t *pudp,
+				pgtable_t pgtable)
+{
+	struct pagechain *chain = NULL;
+
+	assert_spin_locked(pud_lockptr(mm, pudp));
+	/* FIFO */
+	chain = list_first_entry_or_null(&pud_huge_pte(mm, pudp),
+			struct pagechain, list);
+
+	if (!chain || !pagechain_space(chain)) {
+		chain = pagechain_alloc();
+		list_add(&chain->list, &pud_huge_pte(mm, pudp));
+	}
+	pagechain_deposit(chain, pgtable);
+}
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
@@ -179,6 +197,33 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 		list_del(&pgtable->lru);
 	return pgtable;
 }
+
+pgtable_t pgtable_trans_huge_pud_withdraw(struct mm_struct *mm, pud_t *pudp)
+{
+	pgtable_t pgtable;
+	struct pagechain *chain = NULL;
+
+	assert_spin_locked(pud_lockptr(mm, pudp));
+
+	/* FIFO */
+retry:
+	chain = list_first_entry_or_null(&pud_huge_pte(mm, pudp),
+			struct pagechain, list);
+
+	if (!chain)
+		return NULL;
+
+	if (pagechain_empty(chain)) {
+		if (list_is_singular(&chain->list))
+			return NULL;
+		list_del(&chain->list);
+		pagechain_free(chain);
+		goto retry;
+	}
+
+	pgtable = pagechain_withdraw(chain);
+	return pgtable;
+}
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537..dae66a4329ea 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -712,6 +712,7 @@ pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 	pgd_t *pgd;
 	p4d_t *p4d;
 	pud_t *pud;
+	pud_t pude;
 	pmd_t *pmd = NULL;
 	pmd_t pmde;
 
@@ -724,7 +725,10 @@ pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 		goto out;
 
 	pud = pud_offset(p4d, address);
-	if (!pud_present(*pud))
+
+	pude = *pud;
+	barrier();
+	if (!pud_present(pude) || pud_trans_huge(pude))
 		goto out;
 
 	pmd = pmd_offset(pud, address);
@@ -1121,8 +1125,12 @@ void do_page_add_anon_rmap(struct page *page,
 		 * pte lock(a spinlock) is held, which implies preemption
 		 * disabled.
 		 */
-		if (compound)
-			__inc_node_page_state(page, NR_ANON_THPS);
+		if (compound) {
+			if (nr == HPAGE_PMD_NR)
+				__inc_node_page_state(page, NR_ANON_THPS);
+			else
+				__inc_node_page_state(page, NR_ANON_THPS_PUD);
+		}
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
 	}
 	if (unlikely(PageKsm(page)))
@@ -1160,7 +1168,10 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_node_page_state(page, NR_ANON_THPS);
+		if (nr == HPAGE_PMD_NR)
+			__inc_node_page_state(page, NR_ANON_THPS);
+		else
+			__inc_node_page_state(page, NR_ANON_THPS_PUD);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1265,19 +1276,22 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_node_page_state(page, NR_ANON_THPS);
+	if (hpage_nr_pages(page) == HPAGE_PMD_NR)
+		__dec_node_page_state(page, NR_ANON_THPS);
+	else
+		__dec_node_page_state(page, NR_ANON_THPS_PUD);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
 		 * Subpages can be mapped with PTEs too. Check how many of
 		 * themi are still mapped.
 		 */
-		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
+		for (i = 0, nr = 0; i < hpage_nr_pages(page); i++) {
 			if (atomic_add_negative(-1, &page[i]._mapcount))
 				nr++;
 		}
 	} else {
-		nr = HPAGE_PMD_NR;
+		nr = hpage_nr_pages(page);
 	}
 
 	if (unlikely(PageMlocked(page)))
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c18a42250a5c..25a88693e417 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1158,6 +1158,7 @@ const char * const vmstat_text[] = {
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
 	"nr_anon_transparent_hugepages",
+	"nr_anon_transparent_pud_hugepages",
 	"nr_unstable",
 	"nr_vmscan_write",
 	"nr_vmscan_immediate_reclaim",
@@ -1259,6 +1260,8 @@ const char * const vmstat_text[] = {
 	"thp_deferred_split_page",
 	"thp_split_pmd",
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	"thp_fault_alloc_pud",
+	"thp_fault_fallback_pud",
 	"thp_split_pud",
 #endif
 	"thp_zero_page_alloc",
-- 
2.20.1


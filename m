Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D98C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56D4020B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="o6PPi6iG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56D4020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7E26B000D; Wed, 12 Jun 2019 18:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D77A36B000E; Wed, 12 Jun 2019 18:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C18D66B0010; Wed, 12 Jun 2019 18:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99F186B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:18 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id r142so16760554ybc.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=x9wxrExlRXk0Gxj35W1xu8WnApoUM0ZZw68741IhNJg=;
        b=SAImKBxwA4BsvTwGi+NtyXCjCZR3ffvs1L2wrB9mnC92SvWQEaBAwuKXSvbMQvayon
         P1Ee/zEVPp2c/n5JO+HU7uOKbkiy+EsToLkYd1JZOqhSop+bEw/h2uwEY+P+uIdbjCl6
         j9dhWpdb1El/jbA/h1DJNNdqH/1ee8aLL5E7E5/eTQUhtoOzZLZJr5e5hmqKWVpBJjrt
         kkKTnNDkqxOEbKcYR+51Xte7/3+7Z7BYmsbL184wEcCuRPSlCWyeMpRaq/mOq/rfrApb
         qw774LVZEhEVjCcdisoQjKeWFvIPyuh8L0T93WD5Cy1vSNpvxr1M5ZAuE3XyHvHEQflo
         4YtQ==
X-Gm-Message-State: APjAAAUcCYCmiHOlOOvUamXgsykAHBzfCsrehz+HaUFHlCBTFfxwxEWA
	GQLZHcHeEb8coPdWywPmjWzx++0idpEqyWsDyQ2cgTlhUC26NGbxCApprDtC9X5xWsZENhfsyCd
	1Xtxh4fdc0eO+exLiE5icbuvVvrtJQAi5TG4Rh9cvgjEjutD2xzB1MFvRSqtQHZiPRw==
X-Received: by 2002:a25:cf44:: with SMTP id f65mr41198629ybg.66.1560377178293;
        Wed, 12 Jun 2019 15:06:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIYR0g1tTr4WhfZfbdEGV5H7tn8KNjs9e2OLDrUBRBSTXzhp8M6gd5vmkD/t/4laGsm9zy
X-Received: by 2002:a25:cf44:: with SMTP id f65mr41198603ybg.66.1560377177578;
        Wed, 12 Jun 2019 15:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377177; cv=none;
        d=google.com; s=arc-20160816;
        b=LlvZdE3lyD2dyU0HcLbjMcqQAbjSW8q3MNnIyIZmLyaZ4pc5bDz0HQapTpH+KEGNo5
         XbVfe+zcB+YUhcBlx7ukOcipZlgoDfZFzauiReGD4xXNCPNf9vhOR3whUWbtcJfSt2X8
         ciiWjByHZ9bbn+znaUBad+2g6Z0eoKVSip1q4w8tIkpmAWDL9FYyJgD3idaB3iiplDS1
         esvjcpdxC0jxBMugekIU76GRj/zabobuZVM+/mTixrom8WJuXIpGFpmlT3X5bWl4xNMs
         yq5bVsw15B6fNMli97PAUIcqLyQyolJXtj35pRCyxXpjw2bKqu+LbMEJVULw+Zj/GJv7
         6S2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=x9wxrExlRXk0Gxj35W1xu8WnApoUM0ZZw68741IhNJg=;
        b=XM856bIzkwfkjzQsvnRkvGF7oMY2/0fqtLIXczhu855wsaQF2W/TcnVFgnPnbeqtYf
         ZhEP1YdQziRgVvUP3C4Uz4mkaTZ82UhKC5trjOS4XdTq+IROHmayLtxO4knb1cN9u/W9
         XK2orhSygAjWivZZYtJOZ6dQaTgIvwXjrmrLpwE9olaZ5goVci9gwXYH0+rwKAj5B85+
         DZFRIMkDpytK/H14cPamkLbkxsP446gB2o53RL08LhPs3SEAlVN1NSdT9doXEC90iUQw
         EnjtLaHeXT7oJQHdVZTq/fBo53SpQRIEVzoZpmp02zEst6XtdIxj3ifn3n5/QFed28PA
         5qpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=o6PPi6iG;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i84si354505ybi.110.2019.06.12.15.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=o6PPi6iG;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5CLxCWT008898
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=x9wxrExlRXk0Gxj35W1xu8WnApoUM0ZZw68741IhNJg=;
 b=o6PPi6iGRpKRqjhqgZG3PiGt6y32v1mSFaSxH2y3WY+iflMDtaSJMqE7EoV4Nzdb9ND0
 tYWwi4GF14OooU+Wwf6eHMSoqnqy48FtSSDMalXGJNjVZWnFmQxtVf3RJpR/eI0n4ogc
 drIEllVUq9LJiqWboIGfaBjGkIQErxJFFQU= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3338hk6n-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:16 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 15:06:14 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 32B5462E2D12; Wed, 12 Jun 2019 15:03:44 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 5/5] uprobe: collapse THP pmd after removing all uprobes
Date: Wed, 12 Jun 2019 15:03:19 -0700
Message-ID: <20190612220320.2223898-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190612220320.2223898-1-songliubraving@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=784 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse.

An issue on earlier version was discovered by kbuild test robot.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/huge_mm.h |  7 +++++
 kernel/events/uprobes.c |  5 +++-
 mm/huge_memory.c        | 64 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..30669e9a9340 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,9 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+extern void try_collapse_huge_pmd(struct vm_area_struct *vma,
+				  struct page *page);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -368,6 +371,10 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline void try_collapse_huge_pmd(struct vm_area_struct *vma,
+					 struct page *page) {}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index a20d7b43a056..9bec602bf79e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -474,6 +474,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	struct page *orig_page = NULL;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -512,7 +513,6 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
 	if (!is_register) {
-		struct page *orig_page;
 		pgoff_t index;
 
 		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
@@ -540,6 +540,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	if (!ret && orig_page && PageTransCompound(orig_page))
+		try_collapse_huge_pmd(vma, orig_page);
+
 	return ret;
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9a6b32..48e951550988 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2886,6 +2886,70 @@ static struct shrinker deferred_split_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
+/**
+ * try_collapse_huge_pmd - try collapse pmd for a pte mapped huge page
+ * @vma: vma containing the huge page
+ * @page: any sub page of the huge page
+ */
+void try_collapse_huge_pmd(struct vm_area_struct *vma,
+			   struct page *page)
+{
+	struct page *hpage = compound_head(page);
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
+	unsigned long haddr;
+	unsigned long addr;
+	pmd_t *pmd, _pmd;
+	spinlock_t *ptl;
+	int i;
+
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
+
+	haddr = page_address_in_vma(hpage, vma);
+	pmd = mm_find_pmd(mm, haddr);
+	if (!pmd)
+		return;
+
+	lock_page(hpage);
+	ptl = pmd_lock(mm, pmd);
+
+	/* step 1: check all mapped PTEs */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+
+		if (hpage + i != vm_normal_page(vma, addr, *pte)) {
+			spin_unlock(ptl);
+			unlock_page(hpage);
+			return;
+		}
+	}
+
+	/* step 2: adjust rmap */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *p;
+
+		p = vm_normal_page(vma, addr, *pte);
+		page_remove_rmap(p, false);
+	}
+
+	/* step 3: flip page table */
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_start(&range);
+
+	_pmd = pmdp_collapse_flush(vma, haddr, pmd);
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(&range);
+
+	/* step 4: free pgtable, set refcount, mm_counters, etc. */
+	page_ref_sub(page, HPAGE_PMD_NR);
+	unlock_page(hpage);
+	mm_dec_nr_ptes(mm);
+	pte_free(mm, pmd_pgtable(_pmd));
+	add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
+}
+
 #ifdef CONFIG_DEBUG_FS
 static int split_huge_pages_set(void *data, u64 val)
 {
-- 
2.17.1


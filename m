Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83159C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 362E420821
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="pbhEZGJc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 362E420821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DED0D8E0006; Fri, 21 Jun 2019 20:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9D1E8E0001; Fri, 21 Jun 2019 20:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C64F48E0006; Fri, 21 Jun 2019 20:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7E808E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:31 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p68so8113870ywp.2
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=yfkmPBW/NLQwl/dH7qhTlDffK3PtcU3kE6J70hPIVKM=;
        b=NYB1F7f9mtRYu1OVPimKMqYP9Vwa9MbG0WelFgVUM9v3MhX4Rf291+rDEUN3fq9qw2
         GPuNkQrzT1R6XsXKzobGrkI6nUwGTvIYY3L+KyuI3gkl8RYreKegCQVs8Djoed7Aj5aC
         b8Ucb8NRSo3jzxIhI6KdTz0N81+MNsoqjGJ0kER2ic1f+FGppXP2e3jWu8HEVvT+XQan
         wcctKKM+ZLZx/2q8kEta40LJwNiFXvqxtUwoQJfEn14y2AVblc5gKva3aPzWLGehie4M
         3ZqAjvM8SA8GsGJl6JmY+2Syt26Lw7NRyZMWtxbgG+LwztX/1/AZqgDbYsGGhycQF4qa
         kmNA==
X-Gm-Message-State: APjAAAU+nD1+42n1KU8T7L3NFpHTlpVWTWL4iqP0WJssOwxtN1qEfVKv
	ex9yewekixtIdajkTgrGIzNVgKV8ID0SJ6Tf5n3FCEoemZ79ZTOmXKgLKfiWHNRfLV9qJsHPXqR
	VJ353oxyZAT3xCUjdhjoaywqhw9mlQq36hgF59bYfs5QC3L488MRum2scQnhnz8+EIQ==
X-Received: by 2002:a81:48c:: with SMTP id 134mr42887725ywe.387.1561161691444;
        Fri, 21 Jun 2019 17:01:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQx3HM6EMS/cgWsGXqu89UdD/GTc8sOchdylmAfstbybee4kGKidD+I1UULOuvpfII0LfM
X-Received: by 2002:a81:48c:: with SMTP id 134mr42887680ywe.387.1561161690781;
        Fri, 21 Jun 2019 17:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161690; cv=none;
        d=google.com; s=arc-20160816;
        b=Bsn5oRpaqFm3Dj0iNE0k2i6Ha0cPfccWpjlNMb2iu3QdjoMBFzByRdd3DiY/9ChXX1
         eSH3ucJa7VUgFkxRgXqmGeT0Pcs6NX/avdTeiYxzya7c2ySvCSOi/+AO670MxDgzgXaY
         BPC4Ir4S4c1Szl/4Q1qSXmJvF4AkdLZUhWzi7A+fAX8m5VIiSQzG2ZXEwALt0oD0VFJD
         9+xdf8r9jXePAfDRwSkEZA9XRldbZrT1fRW6zleGCf+ATvJZNxA6GJZ/f0iXBw/z4jCx
         2xGOosBQrDK1DfQFFG2xRzEQZ0ylxjCJXO9+f9AzTOC5v5QsqNmbILkW329zhmBgmzeX
         14wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=yfkmPBW/NLQwl/dH7qhTlDffK3PtcU3kE6J70hPIVKM=;
        b=IIs2UhgRUMHKnibJ5IsuszjhDTNXzJfXKDHm+o9SxUkzZVCvw18yCcJisvzeQQtE35
         PwPGZRVzg94OY3q4A2HFARWyGbKce9sLEKGJAEMR33wXBTNBsJ565W51MNbRJdC+FuD4
         byNOQVENhKRiXuV5AL+sN7j6xLj9S5bQpmh9CS+ek/fb8iRUXdOZYWsBgE0mogRxXqoo
         c+TcXLXXLc+ienf17y0LFJzYhUnhne4H+N67Q0S/7ytu8TtX+TaXSCB0wCJOzg5QymaT
         H6YV9JVeiVrk2ShF1XHru4CFqsPBK3JBaRA+wRnGUF01b9pTG6HYX8OuFRz3eiw57RgI
         pQIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=pbhEZGJc;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x188si1515106ywe.453.2019.06.21.17.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=pbhEZGJc;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNqbfH020377
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=yfkmPBW/NLQwl/dH7qhTlDffK3PtcU3kE6J70hPIVKM=;
 b=pbhEZGJcMv8lBkUoI4bsmZ/nWCPwPp7qiQSGQUHSpGiO0sbZK6HW+bQRcz8PaOwIbuma
 c2V2g9C5Ga2iRcxq0pZD9YUdgxhpEqNbVUU49XIzGAeJyYvp9E3uAOuwXTYe/aT40yqX
 OnHQnie6uRslri3Y1apHpD0kPMrSwD//OFc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8uemtyw9-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:30 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 17:01:29 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 18E7862E2D56; Fri, 21 Jun 2019 17:01:28 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 5/5] uprobe: collapse THP pmd after removing all uprobes
Date: Fri, 21 Jun 2019 17:01:09 -0700
Message-ID: <20190622000109.914695-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000109.914695-1-songliubraving@fb.com>
References: <20190622000109.914695-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=790 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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
 kernel/events/uprobes.c |  5 ++-
 mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 80 insertions(+), 1 deletion(-)

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
index 9f8bce9a6b32..cc8464650b72 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2886,6 +2886,75 @@ static struct shrinker deferred_split_shrinker = {
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
+	int i, count = 0;
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
+		if (pte_none(*pte))
+			continue;
+		if (hpage + i != vm_normal_page(vma, addr, *pte)) {
+			spin_unlock(ptl);
+			unlock_page(hpage);
+			return;
+		}
+		count++;
+	}
+
+	/* step 2: adjust rmap */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *p;
+
+		if (pte_none(*pte))
+			continue;
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
+	page_ref_sub(page, count);
+	unlock_page(hpage);
+	mm_dec_nr_ptes(mm);
+	pte_free(mm, pmd_pgtable(_pmd));
+	add_mm_counter(mm, mm_counter_file(page), -count);
+}
+
 #ifdef CONFIG_DEBUG_FS
 static int split_huge_pages_set(void *data, u64 val)
 {
-- 
2.17.1


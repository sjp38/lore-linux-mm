Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D2D3C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F9B20578
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:50:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qogPIpIK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F9B20578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AF0A6B02D0; Thu, 15 Aug 2019 12:50:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 860266B02D2; Thu, 15 Aug 2019 12:50:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E676B02D3; Thu, 15 Aug 2019 12:50:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 5275B6B02D0
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:50:49 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B92AA181AC9B4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:50:48 +0000 (UTC)
X-FDA: 75825251376.24.cub40_7b6a6b0fd8a4c
X-HE-Tag: cub40_7b6a6b0fd8a4c
X-Filterd-Recvd-Size: 11198
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:50:47 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7FGnaTo008915
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:50:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=aU96+L3TXeVWdnsuJYgTkH43ICGKI0e9/Yynh/pI2bE=;
 b=qogPIpIKE6n8rLpdHK5o/9hZ58ns62g7W64okbmI6JpEoNIo0+OY36OKp+Z9GitjIGh+
 MNONMCJ+btKQrVFxGQVK6/6JyLBslmugufGcSgMnB3gehYxluFU1ORO9e9qh4VgfBtTt
 Me1nBwOL84wGNN2Ajkr5FAJNPTYYHM9jOrU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2udagjr7ew-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:50:46 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 15 Aug 2019 09:48:38 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 2C69062E2010; Thu, 15 Aug 2019 09:45:47 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <hannes@cmpxchg.org>, <matthew.wilcox@oracle.com>,
        <kirill.shutemov@linux.intel.com>, <oleg@redhat.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v13 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Date: Thu, 15 Aug 2019 09:45:24 -0700
Message-ID: <20190815164525.1848545-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190815164525.1848545-1-songliubraving@fb.com>
References: <20190815164525.1848545-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-15_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=297 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908150164
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

khugepaged needs exclusive mmap_sem to access page table. When it fails
to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
is already a THP, khugepaged will not handle this pmd again.

This patch enables the khugepaged to retry collapse the page table.

struct mm_slot (in khugepaged.c) is extended with an array, containing
addresses of pte-mapped THPs. We use array here for simplicity. We can
easily replace it with more advanced data structures when needed.

In khugepaged_scan_mm_slot(), if the mm contains pte-mapped THP, we try
to collapse the page table.

Since collapse may happen at an later time, some pages may already fault
in. collapse_pte_mapped_thp() is added to properly handle these pages.
collapse_pte_mapped_thp() also double checks whether all ptes in this pmd
are mapping to the same THP. This is necessary because some subpage of
the THP may be replaced, for example by uprobe. In such cases, it is not
possible to collapse the pmd.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/khugepaged.h |  12 +++
 mm/khugepaged.c            | 168 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 179 insertions(+), 1 deletion(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 082d1d2a5216..bc45ea1efbf7 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -15,6 +15,14 @@ extern int __khugepaged_enter(struct mm_struct *mm);
 extern void __khugepaged_exit(struct mm_struct *mm);
 extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 				      unsigned long vm_flags);
+#ifdef CONFIG_SHMEM
+extern void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr);
+#else
+static inline void collapse_pte_mapped_thp(struct mm_struct *mm,
+					   unsigned long addr)
+{
+}
+#endif
 
 #define khugepaged_enabled()					       \
 	(transparent_hugepage_flags &				       \
@@ -73,6 +81,10 @@ static inline int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 {
 	return 0;
 }
+static inline void collapse_pte_mapped_thp(struct mm_struct *mm,
+					   unsigned long addr)
+{
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_KHUGEPAGED_H */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 40c25ddf29e4..cea0fbf2d7b9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -77,6 +77,8 @@ static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
 
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
+#define MAX_PTE_MAPPED_THP 8
+
 /**
  * struct mm_slot - hash lookup from mm to mm_slot
  * @hash: hash collision list
@@ -87,6 +89,10 @@ struct mm_slot {
 	struct hlist_node hash;
 	struct list_head mm_node;
 	struct mm_struct *mm;
+
+	/* pte-mapped THP in this mm */
+	int nr_pte_mapped_thp;
+	unsigned long pte_mapped_thp[MAX_PTE_MAPPED_THP];
 };
 
 /**
@@ -1254,6 +1260,159 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 }
 
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
+/*
+ * Notify khugepaged that given addr of the mm is pte-mapped THP. Then
+ * khugepaged should try to collapse the page table.
+ */
+static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	struct mm_slot *mm_slot;
+
+	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
+
+	spin_lock(&khugepaged_mm_lock);
+	mm_slot = get_mm_slot(mm);
+	if (likely(mm_slot && mm_slot->nr_pte_mapped_thp < MAX_PTE_MAPPED_THP))
+		mm_slot->pte_mapped_thp[mm_slot->nr_pte_mapped_thp++] = addr;
+	spin_unlock(&khugepaged_mm_lock);
+	return 0;
+}
+
+/**
+ * Try to collapse a pte-mapped THP for mm at address haddr.
+ *
+ * This function checks whether all the PTEs in the PMD are pointing to the
+ * right THP. If so, retract the page table so the THP can refault in with
+ * as pmd-mapped.
+ */
+void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
+{
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
+	struct vm_area_struct *vma = find_vma(mm, haddr);
+	struct page *hpage = NULL;
+	pte_t *start_pte, *pte;
+	pmd_t *pmd, _pmd;
+	spinlock_t *ptl;
+	int count = 0;
+	int i;
+
+	if (!vma || !vma->vm_file ||
+	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
+		return;
+
+	/*
+	 * This vm_flags may not have VM_HUGEPAGE if the page was not
+	 * collapsed by this mm. But we can still collapse if the page is
+	 * the valid THP. Add extra VM_HUGEPAGE so hugepage_vma_check()
+	 * will not fail the vma for missing VM_HUGEPAGE
+	 */
+	if (!hugepage_vma_check(vma, vma->vm_flags | VM_HUGEPAGE))
+		return;
+
+	pmd = mm_find_pmd(mm, haddr);
+	if (!pmd)
+		return;
+
+	start_pte = pte_offset_map_lock(mm, pmd, haddr, &ptl);
+
+	/* step 1: check all mapped PTEs are to the right huge page */
+	for (i = 0, addr = haddr, pte = start_pte;
+	     i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE, pte++) {
+		struct page *page;
+
+		/* empty pte, skip */
+		if (pte_none(*pte))
+			continue;
+
+		/* page swapped out, abort */
+		if (!pte_present(*pte))
+			goto abort;
+
+		page = vm_normal_page(vma, addr, *pte);
+
+		if (!page || !PageCompound(page))
+			goto abort;
+
+		if (!hpage) {
+			hpage = compound_head(page);
+			/*
+			 * The mapping of the THP should not change.
+			 *
+			 * Note that uprobe, debugger, or MAP_PRIVATE may
+			 * change the page table, but the new page will
+			 * not pass PageCompound() check.
+			 */
+			if (WARN_ON(hpage->mapping != vma->vm_file->f_mapping))
+				goto abort;
+		}
+
+		/*
+		 * Confirm the page maps to the correct subpage.
+		 *
+		 * Note that uprobe, debugger, or MAP_PRIVATE may change
+		 * the page table, but the new page will not pass
+		 * PageCompound() check.
+		 */
+		if (WARN_ON(hpage + i != page))
+			goto abort;
+		count++;
+	}
+
+	/* step 2: adjust rmap */
+	for (i = 0, addr = haddr, pte = start_pte;
+	     i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE, pte++) {
+		struct page *page;
+
+		if (pte_none(*pte))
+			continue;
+		page = vm_normal_page(vma, addr, *pte);
+		page_remove_rmap(page, false);
+	}
+
+	pte_unmap_unlock(start_pte, ptl);
+
+	/* step 3: set proper refcount and mm_counters. */
+	if (hpage) {
+		page_ref_sub(hpage, count);
+		add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
+	}
+
+	/* step 4: collapse pmd */
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	_pmd = pmdp_collapse_flush(vma, addr, pmd);
+	spin_unlock(ptl);
+	mm_dec_nr_ptes(mm);
+	pte_free(mm, pmd_pgtable(_pmd));
+	return;
+
+abort:
+	pte_unmap_unlock(start_pte, ptl);
+}
+
+static int khugepaged_collapse_pte_mapped_thps(struct mm_slot *mm_slot)
+{
+	struct mm_struct *mm = mm_slot->mm;
+	int i;
+
+	if (likely(mm_slot->nr_pte_mapped_thp == 0))
+		return 0;
+
+	if (!down_write_trylock(&mm->mmap_sem))
+		return -EBUSY;
+
+	if (unlikely(khugepaged_test_exit(mm)))
+		goto out;
+
+	for (i = 0; i < mm_slot->nr_pte_mapped_thp; i++)
+		collapse_pte_mapped_thp(mm, mm_slot->pte_mapped_thp[i]);
+
+out:
+	mm_slot->nr_pte_mapped_thp = 0;
+	up_write(&mm->mmap_sem);
+	return 0;
+}
+
 static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma;
@@ -1287,7 +1446,8 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			up_write(&vma->vm_mm->mmap_sem);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-		}
+		} else
+			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
 	}
 	i_mmap_unlock_write(mapping);
 }
@@ -1709,6 +1869,11 @@ static void khugepaged_scan_file(struct mm_struct *mm,
 {
 	BUILD_BUG();
 }
+
+static int khugepaged_collapse_pte_mapped_thps(struct mm_slot *mm_slot)
+{
+	return 0;
+}
 #endif
 
 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
@@ -1733,6 +1898,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		khugepaged_scan.mm_slot = mm_slot;
 	}
 	spin_unlock(&khugepaged_mm_lock);
+	khugepaged_collapse_pte_mapped_thps(mm_slot);
 
 	mm = mm_slot->mm;
 	/*
-- 
2.17.1



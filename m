Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BE4DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3500F20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WJQONFkK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3500F20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFEF16B0005; Thu,  1 Aug 2019 14:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DADA06B0269; Thu,  1 Aug 2019 14:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D166B026A; Thu,  1 Aug 2019 14:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id A63676B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:48:35 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v17so37151248ybq.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=zObU9GlGDcgEYU9jwlQPoLYzrtPGAUMxAXujM++xfYg=;
        b=hsKVrNoCa/v5sL8YV25jHnXVmUd0Ac94nIpH8Pl2ShorS3fObC+fLulmMvt6P3Ow/3
         a9hY5DIWFjuwcwvljnoNh+cKWIOxXeqvr5QP7OyB5mRi2NkZrnE0ypqAp3JoWHl/IX9z
         anLap5vEQngl9+mqIh2qXttxG8n+kHv5C0O09L8fjk2Vm4tCJF1ej688UgrRhcpa7gHv
         BWpqOZmC5W3YYNXOju4KRw6wK5hYANyTiIF5GMs+NLwXdPTKnaYPiafbdgYoSh/RGSug
         jfqacmAotBKortELn7d/poaY2He840vjMZvoKqJtGOs6WjeDIx37O2x7kvmhIjOZVBux
         blmw==
X-Gm-Message-State: APjAAAW0RmvOdUp6iT8Q0lEuBkiLlzrKRV9MQ4JKQ0NZ5z4J8C3LR/OV
	cCQZ9Cj36EQiXh6By+Xqryh+Q9eCp0ijCTfJhvI34XBK3j6q5KE39D2Aflgj0qVkjzRUVNcFnqS
	pUZKHANAntglMlxlnFurInNWzaSHwqKtHncdvez9kUbbvrYZXbrdpyDo8B8jYpSPiZA==
X-Received: by 2002:a81:1d05:: with SMTP id d5mr74995127ywd.299.1564685315423;
        Thu, 01 Aug 2019 11:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRl5b4E0qHu2WAFiu+BrWTD2Rb1SSY2yuNoUeVJ3Zrii0nZhiOMets8NnFfGQJBSfvoFFR
X-Received: by 2002:a81:1d05:: with SMTP id d5mr74995106ywd.299.1564685314749;
        Thu, 01 Aug 2019 11:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564685314; cv=none;
        d=google.com; s=arc-20160816;
        b=Um+KjA0De+SSmTdLFgGcklIz+PnUy8z1uDCDrFh2p4eDWk8zjsRDQp1Yha0Z1ClA7e
         osDnXqyeuGAWOe+8zvMCfwtxN0shQkwJTq7Zzf56QIaDHYIxOCz2c62tve92Lf6kgsHX
         J/ZPvXR4seH//cDHPoSvQNBqJYAhMOdxBjt7xQVtzYj5ZF/H3+Fjo3cgM2PhoXNUp4s0
         YIiIrosCmd070lcN0ayRMDCdRHnCIp/qyVNrqT/izJQP8d+rQt6CYmfAzc7GLaz0euxI
         13uNzmHXS3a5d+qfoQG1iSKQWzvBG+/mFJZAPmCQiWW6StSgd2k+7PFXM4ZJKZyHLxfy
         Uv7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=zObU9GlGDcgEYU9jwlQPoLYzrtPGAUMxAXujM++xfYg=;
        b=X4hZiMQYRmXbPXG+eXusS2sFyZMYdV6ctb4z0tgFNPD8fHpNfl7Zu0kRg42jkTM6b5
         DYBfYeJ09yIFcf0lowatuquEcQKWNk6FawXXR1m/lKr+XmJMDhV1+9UCmmsKk6AOYMeW
         T0Yh8PuyYARFGJd1hKJeBE8IsQ60DxUoEARIN2iwEccn6TNT6rqDElCv4SWHyRVLdMaf
         cv6s+hpaiZ+SE56Z6/cmj3FspYE5Ru6qr+TFlx2/+ns35TOkvEFUqLBS2Fl+rFG7FUCV
         30JKQmf1A8K7Uuq+Isj7aZ2LIIewDM3CzLtkpVBO4MXllQEPXnGguwfbnD0ClhWrDFVB
         OTsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WJQONFkK;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g81si25606198ywe.299.2019.08.01.11.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:48:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WJQONFkK;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IlLku006725
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:48:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=zObU9GlGDcgEYU9jwlQPoLYzrtPGAUMxAXujM++xfYg=;
 b=WJQONFkK0FE6lpoNxg+1XKew9fiaKTTOFAiQ1p5PSDNvjeroNNKcQnUnrBQShy6SolDz
 NfJfzhvuYz9asuaFW9IuzSe7jpNSoDg95gO8sSNSZgFalmHvJSctd9OFlG8pVtNaZajj
 GV/p6l2/yGQOEfkRglFoqnmunwAyVtBIZX0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2u427wrx6v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:34 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 11:48:33 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 483FD62E1FCA; Thu,  1 Aug 2019 11:48:33 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Date: Thu, 1 Aug 2019 11:48:22 -0700
Message-ID: <20190801184823.3184410-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184823.3184410-1-songliubraving@fb.com>
References: <20190801184823.3184410-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=573 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010195
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
easily replace it with more advanced data structures when needed. This
array is protected by khugepaged_mm_lock.

In khugepaged_scan_mm_slot(), if the mm contains pte-mapped THP, we try
to collapse the page table.

Since collapse may happen at an later time, some pages may already fault
in. collapse_pte_mapped_thp() is added to properly handle these pages.
collapse_pte_mapped_thp() also double checks whether all ptes in this pmd
are mapping to the same THP. This is necessary because some subpage of
the THP may be replaced, for example by uprobe. In such cases, it is not
possible to collapse the pmd.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/khugepaged.h |  12 ++++
 mm/khugepaged.c            | 140 +++++++++++++++++++++++++++++++++++++
 2 files changed, 152 insertions(+)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 082d1d2a5216..a75693b95071 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -15,6 +15,14 @@ extern int __khugepaged_enter(struct mm_struct *mm);
 extern void __khugepaged_exit(struct mm_struct *mm);
 extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 				      unsigned long vm_flags);
+#ifdef CONFIG_SHMEM
+extern void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long haddr);
+#else
+static inline void collapse_pte_mapped_thp(struct mm_struct *mm,
+					   unsigned long haddr)
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
+					   unsigned long haddr)
+{
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_KHUGEPAGED_H */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b23215..8e8e53318605 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -76,6 +76,8 @@ static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
 
 static struct kmem_cache *mm_slot_cache __read_mostly;
 
+#define MAX_PTE_MAPPED_THP 8
+
 /**
  * struct mm_slot - hash lookup from mm to mm_slot
  * @hash: hash collision list
@@ -86,6 +88,10 @@ struct mm_slot {
 	struct hlist_node hash;
 	struct list_head mm_node;
 	struct mm_struct *mm;
+
+	/* pte-mapped THP in this mm */
+	int nr_pte_mapped_thp;
+	unsigned long pte_mapped_thp[MAX_PTE_MAPPED_THP];
 };
 
 /**
@@ -1248,6 +1254,135 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
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
+	int ret = 0;
+
+	/* hold mmap_sem for khugepaged_test_exit() */
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
+
+	if (unlikely(khugepaged_test_exit(mm)))
+		return 0;
+
+	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
+	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
+		ret = __khugepaged_enter(mm);
+		if (ret)
+			return ret;
+	}
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
+void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long haddr)
+{
+	struct vm_area_struct *vma = find_vma(mm, haddr);
+	pmd_t *pmd = mm_find_pmd(mm, haddr);
+	struct page *hpage = NULL;
+	unsigned long addr;
+	spinlock_t *ptl;
+	int count = 0;
+	pmd_t _pmd;
+	int i;
+
+	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
+
+	if (!vma || !vma->vm_file || !pmd)
+		return;
+
+	/* step 1: check all mapped PTEs are to the right huge page */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *page;
+
+		if (pte_none(*pte))
+			continue;
+
+		page = vm_normal_page(vma, addr, *pte);
+
+		if (!PageCompound(page))
+			return;
+
+		if (!hpage) {
+			hpage = compound_head(page);
+			if (hpage->mapping != vma->vm_file->f_mapping)
+				return;
+		}
+
+		if (hpage + i != page)
+			return;
+		count++;
+	}
+
+	/* step 2: adjust rmap */
+	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+		pte_t *pte = pte_offset_map(pmd, addr);
+		struct page *page;
+
+		if (pte_none(*pte))
+			continue;
+		page = vm_normal_page(vma, addr, *pte);
+		page_remove_rmap(page, false);
+	}
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
+}
+
+static int khugepaged_collapse_pte_mapped_thps(struct mm_slot *mm_slot)
+{
+	struct mm_struct *mm = mm_slot->mm;
+	int i;
+
+	lockdep_assert_held(&khugepaged_mm_lock);
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
@@ -1281,6 +1416,10 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			up_write(&vma->vm_mm->mmap_sem);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
+		} else if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+			/* need down_read for khugepaged_test_exit() */
+			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
+			up_read(&vma->vm_mm->mmap_sem);
 		}
 	}
 	i_mmap_unlock_write(mapping);
@@ -1667,6 +1806,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		khugepaged_scan.address = 0;
 		khugepaged_scan.mm_slot = mm_slot;
 	}
+	khugepaged_collapse_pte_mapped_thps(mm_slot);
 	spin_unlock(&khugepaged_mm_lock);
 
 	mm = mm_slot->mm;
-- 
2.17.1


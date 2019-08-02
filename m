Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70037C0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12FFB2087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VkdmKG5i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12FFB2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 887266B0005; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 836E66B000A; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502A56B0005; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2324F6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:18:28 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id r67so56438851ywg.7
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=QnDZR2Atc3IvSm/9hGSkzUy/OPiqYnHl0bzsO+otMxg=;
        b=R9XQ9M+m0pvA4ldOxrq/g/Xch25MkPKfBtZTp6DnnKKARm+vpR4SzLOwRz5JCz5Rr1
         vIlaHNolkl+yaW2AbwdDTWjM739I2XvVq84Xm1VHRUHvaa3BMuWw0xYPwKGq2xwApQIM
         izixvw2Yvm88cmtgP2NzJPXtzBBeKVCuzXFH2hecSMFZEVOXae3mO3ImJ0vrPOuIFyhZ
         2uF90p5XqJ5Rd/jHNUpynbsclwfsC7/3gdqwnGQZml1TNxM+TW9nC3C8u6R0xneS2d6v
         pdub1bTXqxiy/BfT39Kb9VoEQJ6qP5/+EYiVWJ6ymOsPlJ9mUibnnRXlLbQ6uNee2/Z2
         H9Kw==
X-Gm-Message-State: APjAAAXzXOr6Lf7yL13N2lNg3g1816/Leppp1i1J4pYYueOjYQda3k1x
	D8oCy37PAMxrrS6PQdgthBzjpEodS6WGzOnKdZIFAx8QCoVzDKgjbfjS75bX9urm/MoJoYQV8xU
	ILVs5FLPcNTuqiIR6b+OfaDX5j8fA43BXJ2kGxla4TBQF1r2nuk0mW7l1IfWL29dDhg==
X-Received: by 2002:a81:5517:: with SMTP id j23mr88421208ywb.164.1564787907835;
        Fri, 02 Aug 2019 16:18:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoqfWOIJQuT8GDl/HFA6S2EO54Pg/7WzO/AHZurNOUajj/fHTE8prf6DYTM1tALSC6fBFw
X-Received: by 2002:a81:5517:: with SMTP id j23mr88421174ywb.164.1564787906960;
        Fri, 02 Aug 2019 16:18:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564787906; cv=none;
        d=google.com; s=arc-20160816;
        b=1Lru7SIMaotHSMAUd9mngCVHDZ0wKr/lEYztTM4FcgdkKD4uQwnpB224X3/obwtM4v
         lY/jGBUGmBj+JVkCGmFBtm/lGvpwUMyKVlPgWhWV/QwY9Cyz8/lHmmBPkJo7eR9Sch/R
         jGOVAEH7JuKuImbBDkR40Hm+/eWZy+SltLKs5qwQf2a7IfrZuJ1aIS9V8WM0tUb3yevd
         A3Ihr94y84ije03C8+I6GsJ8ssuZHam9kNYbNfrBFwEOCcCkF00HolX5xUWs2VeDpaAV
         uOmQrIrzTPh3OuEwnq+R8SwDmkQDKOSeCNjmhbw24MrR7XtNXcDknZbTsD2HSZhlip1c
         IeYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=QnDZR2Atc3IvSm/9hGSkzUy/OPiqYnHl0bzsO+otMxg=;
        b=rO8unuDua6yGUYNdSguXVVUBKOefLYsIgEM6ZUH21BX9zEb0u75LaF62Ff5XgwwucB
         wlYhEUe9JCjDUW/slYAtpRysXg8Yq0C1UuGxvNTwcfFUQHR6C094V/c8e0gEnyD4CJ8Y
         l8dcK4aFHGZgYFwTW/wvTXJdy2/NRZw9fYuiu4jcnPs8/uWIIGGBMgeY7sRQcWm8U9oD
         L5iw5Nv4OeSHrVHzcEpfYxEwWO034oHF8IAF4TmXQ918vpXWZKapKBptycCix5lbpLpo
         B9rQSSkuiv7Gr/YwUXECBM+EHcTux2lAgX/csOg4yffaQBMN2As0hO79j7/B2wLxrBHP
         HZvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VkdmKG5i;
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o131si27164752ywo.230.2019.08.02.16.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 16:18:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VkdmKG5i;
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72NH4gp012409
	for <linux-mm@kvack.org>; Fri, 2 Aug 2019 16:18:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QnDZR2Atc3IvSm/9hGSkzUy/OPiqYnHl0bzsO+otMxg=;
 b=VkdmKG5iVKHe5uUBb8vFGrVhSdnMe3Q1pRvmnwVW/KrS/qpTafzadphPnLxgddiNh1P2
 ZBNF93tRgqsLBhqLybEmN0deOE208q7UTeyrPnZjJiAXH4UXa6/kA5msPCzOz+iCEMdS
 HHQZRgOKULNq9E8rNEoo5ZtL6Pv+4yz8IPI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2u4s4q18aw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:26 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 2 Aug 2019 16:18:25 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id CA45362E2BEF; Fri,  2 Aug 2019 16:18:21 -0700 (PDT)
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
Subject: [PATCH v4 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Date: Fri, 2 Aug 2019 16:18:16 -0700
Message-ID: <20190802231817.548920-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190802231817.548920-1-songliubraving@fb.com>
References: <20190802231817.548920-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=545 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020241
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
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/khugepaged.h |  12 ++++
 mm/khugepaged.c            | 123 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 134 insertions(+), 1 deletion(-)

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
index eaaa21b23215..ba36ff5c1d82 100644
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
@@ -1248,6 +1254,119 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
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
+	pmd_t *pmd = mm_find_pmd(mm, haddr);
+	struct page *hpage = NULL;
+	spinlock_t *ptl;
+	int count = 0;
+	pmd_t _pmd;
+	int i;
+
+	if (!vma || !vma->vm_file || !pmd ||
+	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
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
+		if (!page || !PageCompound(page))
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
@@ -1281,7 +1400,8 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			up_write(&vma->vm_mm->mmap_sem);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-		}
+		} else
+			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
 	}
 	i_mmap_unlock_write(mapping);
 }
@@ -1668,6 +1788,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		khugepaged_scan.mm_slot = mm_slot;
 	}
 	spin_unlock(&khugepaged_mm_lock);
+	khugepaged_collapse_pte_mapped_thps(mm_slot);
 
 	mm = mm_slot->mm;
 	/*
-- 
2.17.1


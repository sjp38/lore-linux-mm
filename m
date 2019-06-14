Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E95F1C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9990E2177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="jSSDplLE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9990E2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D1196B0266; Fri, 14 Jun 2019 14:22:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95A5C6B026A; Fri, 14 Jun 2019 14:22:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 821E26B026B; Fri, 14 Jun 2019 14:22:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6078B6B0266
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:22:21 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id y3so3538643ybp.23
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=8YB/ZdF3uuBF9D+pZOT28W22lnsxSvnwDiOmqFoqnc4=;
        b=GystzSlNbXQjtmXVwBY05M7eP8TZNI/76Gtt6WKAx+tprE7K6/+IGDto6fWbx8/GKR
         OUncp5h6tByNHt+xYVaNj/Si9LNsqU7yCB9OUlPJGm7+XHeIpTbaghEsNzbddUc46Jke
         HpkTfeixOmTMc5kWKHqQzxlBVt3rLtqPmbHGxit4xnVLPGlFgws34RJkoX37agg8mAGa
         SfLRk1o2dqPXB/zd3KwK5AeEjgYS1ZZpBfHpdxgRkhrqm2FMdtHv4ohoDUNdK8Df3zYG
         1prGmjmAhrbbW/CxFvEmuCZbGbQCu5CGjq3U2HNqD16tTc1t+b7OFmYPQlkQqo9gXCDs
         kOmg==
X-Gm-Message-State: APjAAAVgAfVAMbU2EvBAbyxvTyVH4mmCcuXbVPn11jbpwdoxKkFVdfyY
	ISt3O5jcrpWehFY61vcE7ka4zjtR4hymV//1sKAlVo0mfPi+nf0dagb9fHfkOU5Ft9TPUPXikB7
	gddKOBVyWtnTOJKTNxWnYTqE2RxwA7EOnmMoHfDPKvcB68uBpfWxYySYSsG3TC33eTA==
X-Received: by 2002:a5b:590:: with SMTP id l16mr45250236ybp.22.1560536541103;
        Fri, 14 Jun 2019 11:22:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQdvvdFwbhiFT1qDRKRMHRORB9zZPUe22KxE2zMsAm2LN0gsXj4QOvXmrJzszkaC/yRz3g
X-Received: by 2002:a5b:590:: with SMTP id l16mr45250197ybp.22.1560536540068;
        Fri, 14 Jun 2019 11:22:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560536540; cv=none;
        d=google.com; s=arc-20160816;
        b=h4bWqy3YwnSLsZhm6R8MtGT0no8UWHDnNkslTAsVI2uHxtOn7VrQJfb11RbnLceawj
         mC/UttElpMG+BftwEwJ4kpK69JQ86ZxuNBLqNlhwyVmCwSO46Tb8kxyuVyjk8KCLNxo5
         lWgrlEqXkpcrTRBoL2OjjRCVM6498ZheYsj0KciVekA8lviYrSc+kI9i22wfSO3GvX4l
         xUXOWPWJjI+lnaX3pdi27qdCWKVsgMYfpHDt7FlMz1+jzMKCNjqyZiKZjfvjIs+YLHKm
         yM8smCJD1Z0sHuAeueIcEySzwY6KzPFqsCRiMlGoL0rCnLXR62BxZ8AMV+YzLVHHNGjX
         lmLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=8YB/ZdF3uuBF9D+pZOT28W22lnsxSvnwDiOmqFoqnc4=;
        b=D0wyB4By4NIQXUs60FwYeNWuD6afMMlbsTun/PtDBahuBKExJHt9C7WTiHB8NBfkAC
         PAlOuI2YKhWDQmT7Pl9NcThSL3OPWb7Nf2fqxg+TEf2Umkpuh3/gN0ccF0ibPWyZtHTI
         D42NvRavHC6x3Ci6X0rupecQnD5LAi+Tv96uHzyoFphLpLgsFMWJ1nD+ByR6FVKK5j4B
         xiNP/XUZivsSBM93DFMXMOzvz66r6EQDhZGJ8Cqq5LQ6oG0RbKJKQw0hsBOJIy0l4jIr
         DLF899bCqvi1/MTa+8Ftfkbqxo5fX/0B1UD1vRXMddonyCSnbeCiTkRYp7O5WKvAMoku
         L70w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jSSDplLE;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p1si1247468ywg.211.2019.06.14.11.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:22:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jSSDplLE;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EIJKXo027346
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=8YB/ZdF3uuBF9D+pZOT28W22lnsxSvnwDiOmqFoqnc4=;
 b=jSSDplLEqEPamphysc5V/vuMYpdNkV1P4BTUrFl4r4QjdiT2YHR3RPe/YIa+E/YWxgYj
 G/K7dXdsCe34G7Y51ydWpjdVDMm6kf4XIkstJYDj7WKyEXxOW7QPhCylqMIq+jXiZYlc
 5tQTQ2QZoZTA4wusokrkyn+PLQtRy3bi808= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t4915spn4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:19 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 14 Jun 2019 11:22:18 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id BD2A862E1CF4; Fri, 14 Jun 2019 11:22:16 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem) FS
Date: Fri, 14 Jun 2019 11:22:04 -0700
Message-ID: <20190614182204.2673660-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190614182204.2673660-1-songliubraving@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140145
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is (hopefully) the first step to enable THP for non-shmem
filesystems.

This patch enables an application to put part of its text sections to THP
via madvise, for example:

    madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);

We tried to reuse the logic for THP on tmpfs. The following functions are
renamed to reflect the new functionality:

	collapse_shmem()	=>  collapse_file()
	khugepaged_scan_shmem()	=>  khugepaged_scan_file()

Currently, write is not supported for non-shmem THP. This is enforced by
taking negative i_writecount. Therefore, if file has THP pages in the
page cache, open() to write will fail. To update/modify the file, the
user need to remove it first.

An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
feature.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/fs.h |   8 ++++
 mm/Kconfig         |  11 +++++
 mm/filemap.c       |   5 ++-
 mm/khugepaged.c    | 106 ++++++++++++++++++++++++++++++++++++---------
 mm/rmap.c          |  12 +++--
 5 files changed, 116 insertions(+), 26 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d..cda996ddaee1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2871,6 +2871,10 @@ static inline int get_write_access(struct inode *inode)
 {
 	return atomic_inc_unless_negative(&inode->i_writecount) ? 0 : -ETXTBSY;
 }
+static inline int __deny_write_access(struct inode *inode)
+{
+	return atomic_dec_unless_positive(&inode->i_writecount) ? 0 : -ETXTBSY;
+}
 static inline int deny_write_access(struct file *file)
 {
 	struct inode *inode = file_inode(file);
@@ -2880,6 +2884,10 @@ static inline void put_write_access(struct inode * inode)
 {
 	atomic_dec(&inode->i_writecount);
 }
+static inline void __allow_write_access(struct inode *inode)
+{
+	atomic_inc(&inode->i_writecount);
+}
 static inline void allow_write_access(struct file *file)
 {
 	if (file)
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..546d45d9bdab 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -762,6 +762,17 @@ config GUP_BENCHMARK
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
 
+config READ_ONLY_THP_FOR_FS
+	bool "Read-only THP for filesystems (EXPERIMENTAL)"
+	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
+
+	help
+	  Allow khugepaged to put read-only file-backed pages in THP.
+
+	  This is marked experimental because it makes files with thp in
+	  the page cache read-only. To overwrite the file, it need to be
+	  truncated or removed first.
+
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
diff --git a/mm/filemap.c b/mm/filemap.c
index f5b79a43946d..966f24cee711 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -203,8 +203,9 @@ static void unaccount_page_cache_page(struct address_space *mapping,
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
 		if (PageTransHuge(page))
 			__dec_node_page_state(page, NR_SHMEM_THPS);
-	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page), page);
+	} else if (PageTransHuge(page)) {
+		__dec_node_page_state(page, NR_FILE_THPS);
+		__allow_write_access(mapping->host);
 	}
 
 	/*
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a335f7c1fac4..1855ace48488 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -48,6 +48,7 @@ enum scan_result {
 	SCAN_CGROUP_CHARGE_FAIL,
 	SCAN_EXCEED_SWAP_PTE,
 	SCAN_TRUNCATED,
+	SCAN_PAGE_HAS_PRIVATE,
 };
 
 #define CREATE_TRACE_POINTS
@@ -404,7 +405,13 @@ static bool hugepage_vma_check(struct vm_area_struct *vma,
 	    (vm_flags & VM_NOHUGEPAGE) ||
 	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		return false;
+
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	if (shmem_file(vma->vm_file) ||
+	    (vma->vm_file && (vm_flags & VM_DENYWRITE))) {
+#else
 	if (shmem_file(vma->vm_file)) {
+#endif
 		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 			return false;
 		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
@@ -456,8 +463,9 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	unsigned long hstart, hend;
 
 	/*
-	 * khugepaged does not yet work on non-shmem files or special
-	 * mappings. And file-private shmem THP is not supported.
+	 * khugepaged only supports read-only files for non-shmem files.
+	 * khugepaged does not yet work on special mappings. And
+	 * file-private shmem THP is not supported.
 	 */
 	if (!hugepage_vma_check(vma, vm_flags))
 		return 0;
@@ -1284,12 +1292,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 }
 
 /**
- * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
+ * collapse_file - collapse filemap/tmpfs/shmem pages into huge one.
  *
  * Basic scheme is simple, details are more complex:
  *  - allocate and lock a new huge page;
  *  - scan page cache replacing old pages with the new one
- *    + swap in pages if necessary;
+ *    + swap/gup in pages if necessary;
  *    + fill in gaps;
  *    + keep old pages around in case rollback is required;
  *  - if replacing succeeds:
@@ -1301,10 +1309,11 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  *    + restore gaps in the page cache;
  *    + unlock and free huge page;
  */
-static void collapse_shmem(struct mm_struct *mm,
+static void collapse_file(struct vm_area_struct *vma,
 		struct address_space *mapping, pgoff_t start,
 		struct page **hpage, int node)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	gfp_t gfp;
 	struct page *new_page;
 	struct mem_cgroup *memcg;
@@ -1312,7 +1321,11 @@ static void collapse_shmem(struct mm_struct *mm,
 	LIST_HEAD(pagelist);
 	XA_STATE_ORDER(xas, &mapping->i_pages, start, HPAGE_PMD_ORDER);
 	int nr_none = 0, result = SCAN_SUCCEED;
+	bool is_shmem = shmem_file(vma->vm_file);
 
+#ifndef CONFIG_READ_ONLY_THP_FOR_FS
+	VM_BUG_ON(!is_shmem);
+#endif
 	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
 
 	/* Only allocate from the target node */
@@ -1344,7 +1357,8 @@ static void collapse_shmem(struct mm_struct *mm,
 	} while (1);
 
 	__SetPageLocked(new_page);
-	__SetPageSwapBacked(new_page);
+	if (is_shmem)
+		__SetPageSwapBacked(new_page);
 	new_page->index = start;
 	new_page->mapping = mapping;
 
@@ -1359,7 +1373,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		struct page *page = xas_next(&xas);
 
 		VM_BUG_ON(index != xas.xa_index);
-		if (!page) {
+		if (is_shmem && !page) {
 			/*
 			 * Stop if extent has been truncated or hole-punched,
 			 * and is now completely empty.
@@ -1380,7 +1394,7 @@ static void collapse_shmem(struct mm_struct *mm,
 			continue;
 		}
 
-		if (xa_is_value(page) || !PageUptodate(page)) {
+		if (is_shmem && (xa_is_value(page) || !PageUptodate(page))) {
 			xas_unlock_irq(&xas);
 			/* swap in or instantiate fallocated page */
 			if (shmem_getpage(mapping->host, index, &page,
@@ -1388,6 +1402,24 @@ static void collapse_shmem(struct mm_struct *mm,
 				result = SCAN_FAIL;
 				goto xa_unlocked;
 			}
+		} else if (!page || xa_is_value(page)) {
+			unsigned long vaddr;
+
+			VM_BUG_ON(is_shmem);
+
+			vaddr = vma->vm_start +
+				((index - vma->vm_pgoff) << PAGE_SHIFT);
+			xas_unlock_irq(&xas);
+			if (get_user_pages_remote(NULL, mm, vaddr, 1,
+					FOLL_FORCE, &page, NULL, NULL) != 1) {
+				result = SCAN_FAIL;
+				goto xa_unlocked;
+			}
+			lru_add_drain();
+			lock_page(page);
+		} else if (!PageUptodate(page) || PageDirty(page)) {
+			result = SCAN_FAIL;
+			goto xa_locked;
 		} else if (trylock_page(page)) {
 			get_page(page);
 			xas_unlock_irq(&xas);
@@ -1422,6 +1454,12 @@ static void collapse_shmem(struct mm_struct *mm,
 			goto out_unlock;
 		}
 
+		if (page_has_private(page) &&
+		    !try_to_release_page(page, GFP_KERNEL)) {
+			result = SCAN_PAGE_HAS_PRIVATE;
+			break;
+		}
+
 		if (page_mapped(page))
 			unmap_mapping_pages(mapping, index, 1, false);
 
@@ -1459,12 +1497,20 @@ static void collapse_shmem(struct mm_struct *mm,
 		goto xa_unlocked;
 	}
 
-	__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	if (is_shmem)
+		__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	else {
+		__inc_node_page_state(new_page, NR_FILE_THPS);
+		__deny_write_access(mapping->host);
+	}
+
 	if (nr_none) {
 		struct zone *zone = page_zone(new_page);
 
 		__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
-		__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
+		if (is_shmem)
+			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM,
+					      nr_none);
 	}
 
 xa_locked:
@@ -1502,10 +1548,15 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		SetPageUptodate(new_page);
 		page_ref_add(new_page, HPAGE_PMD_NR - 1);
-		set_page_dirty(new_page);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
+
+		if (is_shmem) {
+			set_page_dirty(new_page);
+			lru_cache_add_anon(new_page);
+		} else {
+			lru_cache_add_file(new_page);
+		}
 		count_memcg_events(memcg, THP_COLLAPSE_ALLOC, 1);
-		lru_cache_add_anon(new_page);
 
 		/*
 		 * Remove pte page tables, so we can re-fault the page as huge.
@@ -1520,7 +1571,9 @@ static void collapse_shmem(struct mm_struct *mm,
 		/* Something went wrong: roll back page cache changes */
 		xas_lock_irq(&xas);
 		mapping->nrpages -= nr_none;
-		shmem_uncharge(mapping->host, nr_none);
+
+		if (is_shmem)
+			shmem_uncharge(mapping->host, nr_none);
 
 		xas_set(&xas, start);
 		xas_for_each(&xas, page, end - 1) {
@@ -1560,7 +1613,7 @@ static void collapse_shmem(struct mm_struct *mm,
 	/* TODO: tracepoints */
 }
 
-static void khugepaged_scan_shmem(struct mm_struct *mm,
+static void khugepaged_scan_file(struct vm_area_struct *vma,
 		struct address_space *mapping,
 		pgoff_t start, struct page **hpage)
 {
@@ -1603,6 +1656,17 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 			break;
 		}
 
+		if (page_has_private(page) && trylock_page(page)) {
+			int ret;
+
+			ret = try_to_release_page(page, GFP_KERNEL);
+			unlock_page(page);
+			if (!ret) {
+				result = SCAN_PAGE_HAS_PRIVATE;
+				break;
+			}
+		}
+
 		if (page_count(page) != 1 + page_mapcount(page)) {
 			result = SCAN_PAGE_COUNT;
 			break;
@@ -1628,14 +1692,14 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 			result = SCAN_EXCEED_NONE_PTE;
 		} else {
 			node = khugepaged_find_target_node();
-			collapse_shmem(mm, mapping, start, hpage, node);
+			collapse_file(vma, mapping, start, hpage, node);
 		}
 	}
 
 	/* TODO: tracepoints */
 }
 #else
-static void khugepaged_scan_shmem(struct mm_struct *mm,
+static void khugepaged_scan_file(struct vm_area_struct *vma,
 		struct address_space *mapping,
 		pgoff_t start, struct page **hpage)
 {
@@ -1710,17 +1774,19 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			VM_BUG_ON(khugepaged_scan.address < hstart ||
 				  khugepaged_scan.address + HPAGE_PMD_SIZE >
 				  hend);
-			if (shmem_file(vma->vm_file)) {
+			if (vma->vm_file) {
 				struct file *file;
 				pgoff_t pgoff = linear_page_index(vma,
 						khugepaged_scan.address);
-				if (!shmem_huge_enabled(vma))
+
+				if (shmem_file(vma->vm_file)
+				    && !shmem_huge_enabled(vma))
 					goto skip;
 				file = get_file(vma->vm_file);
 				up_read(&mm->mmap_sem);
 				ret = 1;
-				khugepaged_scan_shmem(mm, file->f_mapping,
-						pgoff, hpage);
+				khugepaged_scan_file(vma, file->f_mapping,
+						     pgoff, hpage);
 				fput(file);
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..87cfa2c19eda 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1192,8 +1192,10 @@ void page_add_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		if (PageSwapBacked(page))
+			__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		else
+			__inc_node_page_state(page, NR_FILE_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page) && page_mapping(page)) {
 			VM_WARN_ON_ONCE(!PageLocked(page));
@@ -1232,8 +1234,10 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		if (PageSwapBacked(page))
+			__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		else
+			__dec_node_page_state(page, NR_FILE_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
-- 
2.17.1


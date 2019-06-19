Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE09C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49A1420B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KhlUIygz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49A1420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4B58E000B; Wed, 19 Jun 2019 02:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 576FB8E0003; Wed, 19 Jun 2019 02:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39EC28E000D; Wed, 19 Jun 2019 02:24:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF2F98E000B
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 140so10985904pfa.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=6FlH20KsDCELbe7kvIBY8oKv4X0OwAVrMOno5QaQ+28=;
        b=J49iqFo/ILagWkKhxiPkPYjA1lU6zzhFlRBSKgB72h4Xb52uHz/bySwhZ55PpUK3fo
         /vJOTW1aqVR+kNzl+6z4YlFn3GLWLqwwPjDyG3OGqZI0pQuCE7Jf9d0L7MaS2HYhtHMa
         wzFBALynpxDJja7kJRAyW66LE5pkYg8114N1N7dTM3H5TWnkNaEZCylTuFXhmQ9Vxkcx
         bVvorZBuWEbburgy4CFOlm9ZPDynPE3gTIoz0W00D3CRJ2d1jzE3JqPy8kSnmGwkV58l
         Lg5K8j9S/4HWWnL52bWPCPNiVd+sP9tqGceXMqzEUztW0C+fpdmetm2fj1a2rneL4/oy
         Dpdw==
X-Gm-Message-State: APjAAAUMDtpO0W9IgsrNDznSYpEJmUIZkGHD8iA78Bpsl4n6ygRCzZ72
	gjUGwKWttNp96XfQM27CXzc1tui5R5Gkz4svLgduJTyfU2KLLDur0arGBsWeqEvhSC+Cm0eMVLl
	uZ/SLXnKWVFfI8ZHZEoj1bzziG7AV1IAQV56D/s6rQuGP5XXfXwNwNt6FM5nkMD+xNQ==
X-Received: by 2002:a17:90a:360b:: with SMTP id s11mr9314927pjb.51.1560925489552;
        Tue, 18 Jun 2019 23:24:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/eoj6IG3VvYrOaF4013PnLYjn6PEVACki2xdfrYyTt9uaMqxinG7MzFmww20z96WFAXld
X-Received: by 2002:a17:90a:360b:: with SMTP id s11mr9314862pjb.51.1560925488585;
        Tue, 18 Jun 2019 23:24:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925488; cv=none;
        d=google.com; s=arc-20160816;
        b=m9iz0sL7ewSjWBuXvqWQI/PhGnLpbbevHOFykuU9nlQO/qYePsGShvAzBPHEFkqo23
         TPAF9yO5jUguqbnR2JWo/JhdQV5iQ00+AAWCbqk3N5rRFo3pWyHI07aAN4nYKv+ghL8Z
         MY5fLsXsfw7Pxu9Cs54Q/rtlnzApE78D6nO990LPtMULW9PIlQvOi1NQ7RJ/pI51ecch
         rz6zsoN713VuaGKBClRAdtO+1KGpPpV4tn8NWlfFbCNq9O3IgvmzEqHoFhsEJf3jMKjx
         gyAuMQLKJjHplhcS5Tgj9YwuQqmCTXi8hia1LVF2Y2lgg+Lf4V/8JUp1oe9+sOScVLzv
         2sHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=6FlH20KsDCELbe7kvIBY8oKv4X0OwAVrMOno5QaQ+28=;
        b=yyrSA+ZFEVbemzP/zfMlzYq+VcMGdk3pI6/6t6lV4TySw01mYM1kF6rfR0u71SaBoH
         weEjPJFRo4XUMeMLby8R2N8iBqMscqBc/ZXfHLSPmFGw6AnaN/d0PsPefq5ZbtS4e5+T
         DSX1kdjqg5nPzEBmhvJbb0NgBEwAekp3xaUa2YR7LPFQQZBJ3OerUPFrEnCOtmnCqdXz
         L2tTCliDfd8lyJvgr0XKZA8ZGFLQDypJ7hZtWcXzwotrEQvWfe6uCs8RyFVrEq0CF7Lm
         4z1fLIoTF2zK1OidjLo4UHG8N657QXpWN0t3UgxgKLSOqRqSMiiwa4tlFEJ2RD5H81VO
         0GbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KhlUIygz;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c3si15419211pfr.27.2019.06.18.23.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KhlUIygz;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5J6OmsB029563
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=6FlH20KsDCELbe7kvIBY8oKv4X0OwAVrMOno5QaQ+28=;
 b=KhlUIygzA/VpDyodFbrRzxxJoZfGT+zac4U61Rv4urFyI0J9JQNicjHFsmMZwu2xu02g
 keq6Pi2j7RcaCbOx/d7NGU8/2NDey5Qy5ntAyNqEwg1WPUAHzC0vRvFEDte+7eNNXxUy
 xo228sPlp/lYAhigklxS+/nyYulRma66FRk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t77yy1dxt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:48 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:24:46 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E0E5862E30AA; Tue, 18 Jun 2019 23:24:44 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 5/6] mm,thp: add read-only THP support for (non-shmem) FS
Date: Tue, 18 Jun 2019 23:24:23 -0700
Message-ID: <20190619062424.3486524-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190619062424.3486524-1-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
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

We tried to reuse the logic for THP on tmpfs.

Currently, write is not supported for non-shmem THP. khugepaged will only
process vma with VM_DENYWRITE. The next patch will handle writes, which
would only happen when the vma with VM_DENYWRITE is unmapped.

An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
feature.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/Kconfig      | 11 ++++++
 mm/filemap.c    |  4 +--
 mm/khugepaged.c | 91 +++++++++++++++++++++++++++++++++++++++++--------
 mm/rmap.c       | 12 ++++---
 4 files changed, 97 insertions(+), 21 deletions(-)

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
index 5f072a113535..e79ceccdc6df 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -203,8 +203,8 @@ static void unaccount_page_cache_page(struct address_space *mapping,
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
 		if (PageTransHuge(page))
 			__dec_node_page_state(page, NR_SHMEM_THPS);
-	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page), page);
+	} else if (PageTransHuge(page)) {
+		__dec_node_page_state(page, NR_FILE_THPS);
 	}
 
 	/*
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index dde8e45552b3..fbcff5a1d65a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -48,6 +48,7 @@ enum scan_result {
 	SCAN_CGROUP_CHARGE_FAIL,
 	SCAN_EXCEED_SWAP_PTE,
 	SCAN_TRUNCATED,
+	SCAN_PAGE_HAS_PRIVATE,
 };
 
 #define CREATE_TRACE_POINTS
@@ -404,7 +405,11 @@ static bool hugepage_vma_check(struct vm_area_struct *vma,
 	    (vm_flags & VM_NOHUGEPAGE) ||
 	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		return false;
-	if (shmem_file(vma->vm_file)) {
+
+	if (shmem_file(vma->vm_file) ||
+	    (IS_ENABLED(CONFIG_READ_ONLY_THP_FOR_FS) &&
+	     vma->vm_file &&
+	     (vm_flags & VM_DENYWRITE))) {
 		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 			return false;
 		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
@@ -456,8 +461,9 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
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
@@ -1287,12 +1293,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 }
 
 /**
- * collapse_file - collapse small tmpfs/shmem pages into huge one.
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
@@ -1316,7 +1322,11 @@ static void collapse_file(struct vm_area_struct *vma,
 	LIST_HEAD(pagelist);
 	XA_STATE_ORDER(xas, &mapping->i_pages, start, HPAGE_PMD_ORDER);
 	int nr_none = 0, result = SCAN_SUCCEED;
+	bool is_shmem = shmem_file(vma->vm_file);
 
+#ifndef CONFIG_READ_ONLY_THP_FOR_FS
+	VM_BUG_ON(!is_shmem);
+#endif
 	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
 
 	/* Only allocate from the target node */
@@ -1348,7 +1358,8 @@ static void collapse_file(struct vm_area_struct *vma,
 	} while (1);
 
 	__SetPageLocked(new_page);
-	__SetPageSwapBacked(new_page);
+	if (is_shmem)
+		__SetPageSwapBacked(new_page);
 	new_page->index = start;
 	new_page->mapping = mapping;
 
@@ -1363,7 +1374,7 @@ static void collapse_file(struct vm_area_struct *vma,
 		struct page *page = xas_next(&xas);
 
 		VM_BUG_ON(index != xas.xa_index);
-		if (!page) {
+		if (is_shmem && !page) {
 			/*
 			 * Stop if extent has been truncated or hole-punched,
 			 * and is now completely empty.
@@ -1384,7 +1395,7 @@ static void collapse_file(struct vm_area_struct *vma,
 			continue;
 		}
 
-		if (xa_is_value(page) || !PageUptodate(page)) {
+		if (is_shmem && (xa_is_value(page) || !PageUptodate(page))) {
 			xas_unlock_irq(&xas);
 			/* swap in or instantiate fallocated page */
 			if (shmem_getpage(mapping->host, index, &page,
@@ -1392,6 +1403,24 @@ static void collapse_file(struct vm_area_struct *vma,
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
@@ -1426,6 +1455,12 @@ static void collapse_file(struct vm_area_struct *vma,
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
 
@@ -1463,12 +1498,18 @@ static void collapse_file(struct vm_area_struct *vma,
 		goto xa_unlocked;
 	}
 
-	__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	if (is_shmem)
+		__inc_node_page_state(new_page, NR_SHMEM_THPS);
+	else
+		__inc_node_page_state(new_page, NR_FILE_THPS);
+
 	if (nr_none) {
 		struct zone *zone = page_zone(new_page);
 
 		__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
-		__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
+		if (is_shmem)
+			__mod_node_page_state(zone->zone_pgdat,
+					      NR_SHMEM, nr_none);
 	}
 
 xa_locked:
@@ -1506,10 +1547,15 @@ static void collapse_file(struct vm_area_struct *vma,
 
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
@@ -1524,7 +1570,9 @@ static void collapse_file(struct vm_area_struct *vma,
 		/* Something went wrong: roll back page cache changes */
 		xas_lock_irq(&xas);
 		mapping->nrpages -= nr_none;
-		shmem_uncharge(mapping->host, nr_none);
+
+		if (is_shmem)
+			shmem_uncharge(mapping->host, nr_none);
 
 		xas_set(&xas, start);
 		xas_for_each(&xas, page, end - 1) {
@@ -1607,6 +1655,17 @@ static void khugepaged_scan_file(struct vm_area_struct *vma,
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
@@ -1714,11 +1773,13 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
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


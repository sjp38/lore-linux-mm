Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52111C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0F7B20896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="QVcEokbt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0F7B20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A102C6B0007; Thu, 13 Jun 2019 01:22:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99A006B000A; Thu, 13 Jun 2019 01:22:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 813986B000C; Thu, 13 Jun 2019 01:22:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0AA6B0007
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:22:10 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id k142so19766847ywa.9
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=T66g3PP14BtucovpCCJbC8g7P1QkEbqCzxMLKLyT1eg=;
        b=a/vcCs542/bY/5lEB6K9B4DTKZAmJMjw7ob4FvcG7FL46aOQIfUG8zBrRpT1bRf0rB
         DDi7EIf78J1q34fk6Q3aJjR2Gb5IP8n47JMCs/H/JQGnV0DDDh33psP95ABJ3XMFbagC
         OseTpBOatgiZRBJDObr3B0CxG6xpFMrJqxDGWlXQKvmKR8vFjqJnK/iTqicm/UtEg24t
         Pig8lgqisE7+G4ojKruQf6+9EZoTzQASAosVwMg5q3VLAhPADoR3Ty5/FZVtBUzjSZpI
         JRabv7dsWRLvOr8NWiE3L6tHPtjszxxx1Zksu2ooMRY8nziwdGN9/RHrLT4PCY0ZhLS+
         81Ow==
X-Gm-Message-State: APjAAAWtsRycn/QzpRC+Ce7Ryeg3FGdG/vVOcc78btqa7FUJcMB4N73A
	gNlmTqth+P2r+DCEo063w9tBVyEXuY46t9E56fG81eI5AwtBwvGuUD5+V6/H/G+I5vdMTbBWwKP
	l1hPB49CDV3NXe4B+XTvC/9ZKHHny9nxjsptm2IeFpUJZ/BLD/P/wF9M1ircwutBpAQ==
X-Received: by 2002:a25:8609:: with SMTP id y9mr5610151ybk.362.1560403330055;
        Wed, 12 Jun 2019 22:22:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQVFtbpcntLNkLVRVaAHa3meMtUIRGVRpJsQC6EZq0/CaTwUdQHFIKUlRJp7tP9X0AFnin
X-Received: by 2002:a25:8609:: with SMTP id y9mr5610131ybk.362.1560403329068;
        Wed, 12 Jun 2019 22:22:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560403329; cv=none;
        d=google.com; s=arc-20160816;
        b=knLsvFpEmjfPffzYAeGITjsaMt6HeUM0zwxhLerQC7RJPKKZ7Ljn+vSfke2OTlhJWE
         eYLsZI6XLWK0nrI2NPrUbMiwctvhABKwoVQ3qrgWfEBY5WQHcRJ8t60u4ytBUk+nHMuH
         a906oxTprJXsRzm1tnT92bs5HW7RQU/T8QaZsUAAMP5NTnAvxe6wYsXA8pxanXtlLoGn
         vqPWIH7LX+4LwSKmbFfHtwKCMPy0QMxhQIAMsRDOh4Ts6B5Fh5TE6Zv83ovnCIJerRnU
         R07yo6FB/gDD7pTENh7tnWoE1TZ3fxDCc2bo25uig6234m1tJCbjiCH+3wtL3R3CbE3D
         7/hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=T66g3PP14BtucovpCCJbC8g7P1QkEbqCzxMLKLyT1eg=;
        b=pKHJjyPhDHLIFXFKeZ+OUtiHoqcUXrM6nCa5UcPARzCDLc4EeJy+fMoCaoVrlJwdL3
         B2VhdzxnVTeTSwfBxf2rHXEgBkGP1lBcnGTapcPUtGvdPkFqpG8FBtsviQwcEgTDtNkJ
         0OuCU3b7nWHWKVHOUNO0d3scVO4S0YT0duJ6kcu5BHw6AsyakK+a67wDdTSDnUuXcOm+
         7eKYOs/9SlFANDMCZyR6H3G28eb6pAmYua/m75inTFyAzUSJBOjMEyt/Ph8mvQlBPyZ8
         r7HbcaTZJnwvAvXwku8se0W0aSRr0t7WxEwnT97c2e/+fqh6Ut3Q1SZXpIkAFqgk/BJ2
         xFQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QVcEokbt;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d192si620095ywd.112.2019.06.12.22.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 22:22:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QVcEokbt;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5D5GclN002365
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=T66g3PP14BtucovpCCJbC8g7P1QkEbqCzxMLKLyT1eg=;
 b=QVcEokbtKhZUwHrUFlV9i7fBe/EVCIbw4yYUd8SL1NurbYVEgGO0K9KvZCkaRhwHUFjT
 F1eNNYWKo1LBiZXer8fEfG6Xq0Gju9iiXASXBVT7sOpGtQ0UdiM8vmxFdC4a8xBGnNjV
 3CZUiM7WCyeVzZGGrWc9qyhy6d/BplYtj7g= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t3a7dgy26-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:08 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 22:22:08 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3301962E2FC5; Wed, 12 Jun 2019 22:22:04 -0700 (PDT)
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
Subject: [PATCH 3/3] mm,thp: add read-only THP support for (non-shmem) FS
Date: Wed, 12 Jun 2019 22:21:51 -0700
Message-ID: <20190613052151.3782835-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613052151.3782835-1-songliubraving@fb.com>
References: <20190613052151.3782835-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130043
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
 mm/khugepaged.c    | 107 ++++++++++++++++++++++++++++++++++++---------
 mm/rmap.c          |  12 +++--
 5 files changed, 116 insertions(+), 27 deletions(-)

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
index a335f7c1fac4..ec5d69114ecc 100644
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
 
@@ -1459,12 +1497,19 @@ static void collapse_shmem(struct mm_struct *mm,
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
+			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
 	}
 
 xa_locked:
@@ -1502,10 +1547,15 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		SetPageUptodate(new_page);
 		page_ref_add(new_page, HPAGE_PMD_NR - 1);
-		set_page_dirty(new_page);
-		mem_cgroup_commit_charge(new_page, memcg, false, true);
+
+		if (is_shmem) {
+			set_page_dirty(new_page);
+			mem_cgroup_commit_charge(new_page, memcg, false, true);
+			lru_cache_add_anon(new_page);
+		} else {
+			lru_cache_add_file(new_page);
+		}
 		count_memcg_events(memcg, THP_COLLAPSE_ALLOC, 1);
-		lru_cache_add_anon(new_page);
 
 		/*
 		 * Remove pte page tables, so we can re-fault the page as huge.
@@ -1520,7 +1570,9 @@ static void collapse_shmem(struct mm_struct *mm,
 		/* Something went wrong: roll back page cache changes */
 		xas_lock_irq(&xas);
 		mapping->nrpages -= nr_none;
-		shmem_uncharge(mapping->host, nr_none);
+
+		if (is_shmem)
+			shmem_uncharge(mapping->host, nr_none);
 
 		xas_set(&xas, start);
 		xas_for_each(&xas, page, end - 1) {
@@ -1560,7 +1612,7 @@ static void collapse_shmem(struct mm_struct *mm,
 	/* TODO: tracepoints */
 }
 
-static void khugepaged_scan_shmem(struct mm_struct *mm,
+static void khugepaged_scan_file(struct vm_area_struct *vma,
 		struct address_space *mapping,
 		pgoff_t start, struct page **hpage)
 {
@@ -1603,6 +1655,17 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
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
@@ -1628,14 +1691,14 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
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
@@ -1710,17 +1773,19 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
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


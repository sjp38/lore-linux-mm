Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC4A2C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:17:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C32B20869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:17:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="osWHLcTG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C32B20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3128E0006; Fri,  1 Feb 2019 17:17:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 472F28E0001; Fri,  1 Feb 2019 17:17:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 313DB8E0006; Fri,  1 Feb 2019 17:17:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1AFC8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:17:30 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id y3so4669935ybp.14
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:17:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=MjcO6mFoDgRTbivxF+5TqPdqW/Klq8Ewvl3W/AS4WPc=;
        b=RipIjA2iIiUO/j2HhUvWJTRbNFsCL97To8/zd9GfStcZ5W5mbTKixlarJQmFKj0ep7
         I5nrWM+zJhmlXH0gCLFA8nT0sxgC70FhYgLvHy4xtZdYwFePmkAQ1zKwT6O2GQ1f8TFZ
         9kcawhmV5W7ZX2VeHumYW5TMfcGWlFi11PIu1eDUMq/T+SK0OdXL31LRk2lvs6/QxQBB
         KYiusaAJXgWC1TfZiVyKMsro7jCIz2WnEgiqc99wdqOHG6t1OOt+0nO4etW3T072mm0X
         Mmul/fnPZbS1mUXV3tWbQu1f6rqvJd/iE+r+FTpIUvslgQFNJzRputGNhijiDAprn1jI
         qFSQ==
X-Gm-Message-State: AJcUukeu6l3Xc6sC3CmTtZ7YlbFTtpUf+ar1JGNdmi8Sv3Sh0eJJmDOu
	5gVYZOs9+ma54aV0VKycWG+9eDeUPeAWGCYYAttN7frhywu+zTR+L6x7I+MngglNUPXKh7Cw442
	Wc/WgE4ZLAUJRZ0STBBOE2M6z1HJqxohcYa0DpdsMLiIVgSGEJ1knMx+1HfJh87Hz9A==
X-Received: by 2002:a0d:dcc5:: with SMTP id f188mr38201477ywe.210.1549059450657;
        Fri, 01 Feb 2019 14:17:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Pi0XhfyRTnVh8VpvXdN/X20yk1pnh2gv9oF78PShTrAegvhZ8GKljyEuwKuIJwoR5MkIs
X-Received: by 2002:a0d:dcc5:: with SMTP id f188mr38201439ywe.210.1549059449797;
        Fri, 01 Feb 2019 14:17:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549059449; cv=none;
        d=google.com; s=arc-20160816;
        b=Bc2ciRBeN/ZUHu0kuwG9Ovn1/7xlisRpCl13Slh5CX7c7jEygqYvL+qan282+lfCeu
         eO6hKRG+tPK0TOUAl3yZeTbsy1S79/NRGCKdF3SvrZMpaOz7imFmGux1QGMjn8Wv5AOH
         6SHfl4ivnknv0X15WwrjZyXwLg+CnejqgCajjTD4biytSwHGYPriBcxMetPPOvw9h+QH
         zWnNBRataA4XAlaGD8F3bafZLVzFfyCVa4VuBDtwiZdU2SMP4E9DLuAppxsCucykJC3e
         /hBggaQRzP4QDgAc27h2a4qu6FJ6cRUCQnCz28oV0ajumZKsCwig4tzgI+a6iyT2iOm4
         CR7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=MjcO6mFoDgRTbivxF+5TqPdqW/Klq8Ewvl3W/AS4WPc=;
        b=e4gjifkSl+w6Y+DEsKPoFY3bhadSPoUKHha9SZAdSUAIv7HMs7EHkRfXZJw5S5H8SF
         VdLojhtvpiuUvV9x/oHvQGiPTOv12T/Gqd66BlaQxsntRtVfyuJZnt9HKTM1F4tVV4oS
         Y8uZRjuV8KARfRjX3mnv0AkRvdttmGw6p5oRozaoIaOE7/ZgHP5DJFDHvMc5uu8zwatJ
         Gw1MGS0BCNixuGIE1LzZBM8SjNu/MA5u75Ic1zd0gR6oB5EvH8LfmAgJRDMS/TtYY1JC
         O7iZ76vnuqQmKyQLsABIVdF+UIU15sUzBpXmndj9WQLOlG24v3ogOtKxIO1by6EW+Yat
         nMZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=osWHLcTG;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 123si5011785ybe.39.2019.02.01.14.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 14:17:29 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=osWHLcTG;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x11MEbcE178407;
	Fri, 1 Feb 2019 22:17:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=MjcO6mFoDgRTbivxF+5TqPdqW/Klq8Ewvl3W/AS4WPc=;
 b=osWHLcTGk2BKpvb5dBThAjHe8dMZGb1hJ9frkmf6sw2OsCAhxLH2zcvJBxDDkRDzbsLW
 bO0VjMyQ9pUoHj41HCQC6DIM8XEQVrydDXhbbOVNpjUk9LUo+GNWHCbSkf4gKfP2XHvZ
 i0hX1k5dfYc1ZUvYUVs4g1gT3n4dn1/iwuIaoUMg837Lltpsj6mHLy3Dq6l+WPW7xQx2
 6l2KoQk5hZu9NiaJQHmbp/wn2KkS0bjRfdexg9aApIzLujWOJm87Lq6s+PVY0aIX0fcM
 I6uvXVZd1xXBT/+CQM7xZv3VY8qdvVKvalvoWwiU4fztyZ0acWACIUhY8+oR6PNp31U9 0A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2q8eyv140v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 01 Feb 2019 22:17:22 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x11MHLpK005172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Feb 2019 22:17:21 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x11MHKON006455;
	Fri, 1 Feb 2019 22:17:20 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 01 Feb 2019 14:17:20 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Prakash Sangappa <prakash.sangappa@oracle.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH RFC v3 2/2] hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
Date: Fri,  1 Feb 2019 14:17:05 -0800
Message-Id: <20190201221705.15622-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20190201221705.15622-1-mike.kravetz@oracle.com>
References: <20190201221705.15622-1-mike.kravetz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9154 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902010157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlbfs page faults can race with truncate and hole punch operations.
Current code in the page fault path attempts to handle this by 'backing
out' operations if we encounter the race.  One obvious omission in the
current code is removing a page newly added to the page cache.  This is
pretty straight forward to address, but there is a more subtle and
difficult issue of backing out hugetlb reservations.  To handle this
correctly, the 'reservation state' before page allocation needs to be
noted so that it can be properly backed out.  There are four distinct
possibilities for reservation state: shared/reserved, shared/no-resv,
private/reserved and private/no-resv.  Backing out a reservation may
require memory allocation which could fail so that needs to be taken
into account as well.

Instead of writing the required complicated code for this rare
occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
mode for the duration of page fault processing.  Hold i_mmap_rwsem in
write mode when modifying i_size.  In this way, truncation can not
proceed when page faults are being processed.  In addition, i_size
will not change during fault processing so a single check can be made
to ensure faults are not beyond (proposed) end of file.  Faults can
still race with hole punch, but that race is handled by existing code
and the use of hugetlb_fault_mutex.

With this modification, checks for races with truncation in the page
fault path can be simplified and removed.  remove_inode_hugepages no
longer needs to take hugetlb_fault_mutex in the case of truncation.
Comments are expanded to explain reasoning behind locking.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 32 ++++++++++++++++++++++----------
 mm/hugetlb.c         | 23 +++++++++++------------
 2 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5280fe3aad2f..039566175b48 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -384,10 +384,9 @@ hugetlb_vmdelete_list(struct rb_root_cached *root, pgoff_t start, pgoff_t end)
  *	In this case, we first scan the range and release found pages.
  *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
  *	maps and global counts.  Page faults can not race with truncation
- *	in this routine.  hugetlb_no_page() prevents page faults in the
- *	truncated range.  It checks i_size before allocation, and again after
- *	with the page table lock for the page held.  The same lock must be
- *	acquired to unmap a page.
+ *	in this routine.  hugetlb_no_page() holds i_mmap_rwsem and prevents
+ *	page faults in the truncated range by checking i_size.  i_size is
+ *	modified while holding i_mmap_rwsem.
  * hole punch is indicated if end is not LLONG_MAX
  *	In the hole punch case we scan the range and release found pages.
  *	Only when releasing a page is the associated region/reserv map
@@ -425,11 +424,19 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			struct page *page = pvec.pages[i];
 			u32 hash;
 
-			index = page->index;
-			hash = hugetlb_fault_mutex_hash(h, current->mm,
+			if (!truncate_op) {
+				/*
+				 * Only need to hold the fault mutex in the
+				 * hole punch case.  This prevents races with
+				 * page faults.  Races are not possible in the
+				 * case of truncation.
+				 */
+				index = page->index;
+				hash = hugetlb_fault_mutex_hash(h, current->mm,
 							&pseudo_vma,
 							mapping, index, 0);
-			mutex_lock(&hugetlb_fault_mutex_table[hash]);
+				mutex_lock(&hugetlb_fault_mutex_table[hash]);
+			}
 
 			/*
 			 * If page is mapped, it was faulted in after being
@@ -472,7 +479,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			}
 
 			unlock_page(page);
-			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			if (!truncate_op)
+				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
 		huge_pagevec_release(&pvec);
 		cond_resched();
@@ -503,8 +511,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	BUG_ON(offset & ~huge_page_mask(h));
 	pgoff = offset >> PAGE_SHIFT;
 
-	i_size_write(inode, offset);
 	i_mmap_lock_write(mapping);
+	i_size_write(inode, offset);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
 		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
 	i_mmap_unlock_write(mapping);
@@ -626,7 +634,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		/* addr is the offset within the file (zero based) */
 		addr = index * hpage_size;
 
-		/* mutex taken here, fault path and hole punch */
+		/*
+		 * fault mutex taken here, protects against fault path
+		 * and hole punch.  inode_lock previously taken protects
+		 * against truncation.
+		 */
 		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
 						index, addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9198b00d25e6..acd3411fd9f0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3858,16 +3858,17 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	/*
-	 * Use page lock to guard against racing truncation
-	 * before we get page_table_lock.
+	 * We can not race with truncation due to holding i_mmap_rwsem.
+	 * i_size is modified when holding i_mmap_rwsem, so check here
+	 * once for faults beyond end of file.
 	 */
+	size = i_size_read(mapping->host) >> huge_page_shift(h);
+	if (idx >= size)
+		goto out;
+
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
-		size = i_size_read(mapping->host) >> huge_page_shift(h);
-		if (idx >= size)
-			goto out;
-
 		/*
 		 * Check for page in userfault range
 		 */
@@ -3957,10 +3958,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	ptl = huge_pte_lock(h, mm, ptep);
-	size = i_size_read(mapping->host) >> huge_page_shift(h);
-	if (idx >= size)
-		goto backout;
-
 	ret = 0;
 	if (!huge_pte_none(huge_ptep_get(ptep)))
 		goto backout;
@@ -4062,8 +4059,10 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/*
 	 * Acquire i_mmap_rwsem before calling huge_pte_alloc and hold
-	 * until finished with ptep.  This prevents huge_pmd_unshare from
-	 * being called elsewhere and making the ptep no longer valid.
+	 * until finished with ptep.  This serves two purposes:
+	 * 1) It prevents huge_pmd_unshare from being called elsewhere
+	 *    and making the ptep no longer valid.
+	 * 2) It synchronizes us with i_size modifications during truncation.
 	 *
 	 * ptep could have already be assigned via huge_pte_offset.  That
 	 * is OK, as huge_pte_alloc will return the same value unless
-- 
2.17.2


Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BBCEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FF1A2173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="F19NqBy9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FF1A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD33F6B0007; Thu, 28 Mar 2019 19:47:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9AE6B0008; Thu, 28 Mar 2019 19:47:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AEFD6B000C; Thu, 28 Mar 2019 19:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 437B46B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:47:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v5so370759plo.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:47:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YIsUhxU4+gts/JPtIOY3p0GcgAlB/Grz4wjUuRKy0gc=;
        b=LMhWilBKYmK+XrUHL+GEXX9BL9yOwrHpb07OfwV8tFMO2n9ovqUidpz0DIwvW4Php5
         r6nluDDztKJOm2rmNfMU8HiDeCHMoJhtRo01ZRhcuDLF6BHR9K0e/B4OqsV4leBRXeiH
         rgGDx40xkXTEcWVNv12P9RnrrXcJccPuWD8b8uGi0XPV5/+m4oQLX5aX2t9QtPasDl9e
         vdEdNkD4o7ddqaDXQkM+q7o8RxnhHilevsJnQDeVdfeWjAQmYlUNrH/y/nyPg/siUkby
         euV5ICjdk2acBFSeohGuws7sbzTu4NEaqKM8kmUtnF0eWnqHQn0I+tWgsFYqNbg4pc6T
         BLRw==
X-Gm-Message-State: APjAAAU3Wy47B+U3JFMY+hjkmmrY8hbZj9xfda1um1gXUtOCStERWb36
	mHG/l5bTk//KavnqFVMgkeIMc76iC3LEW5EsR/2nlqP/hLW1t2mTAVk/OHcDRxrM57ioELEej0z
	EU9R5g1BpKwAiAWc7LvCL9kzaEhnKb9iE5S2YCXvyZYrC1I96ErjUyBKfKPZHK2qdUw==
X-Received: by 2002:a63:8548:: with SMTP id u69mr42514292pgd.85.1553816846896;
        Thu, 28 Mar 2019 16:47:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvdN76lgaFisKN7BjmxE3ZYjkL+98YCuu1QYX5MB/xC+QQf7tLvxwlUCK/2Z8/yf5r10iw
X-Received: by 2002:a63:8548:: with SMTP id u69mr42514256pgd.85.1553816846067;
        Thu, 28 Mar 2019 16:47:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553816846; cv=none;
        d=google.com; s=arc-20160816;
        b=b0fk5IAqLauTVF8xdts0ZbAXaYD7OO1q0orurxx+cfPZ9UVmJZM9CjD5WgYU4PtjdY
         IKBdaAz/rIXtHnXk/b/5B9VzP52H7a15O6eHr2eRnHctc/tjFKrwnwSD7mWe+lRzPOB3
         kZgKHGb+nHdBsm7vselof6Epw7USTiOGxqIKl28feMRhrFjt1jIvQA8QWc7yfJpyVvGJ
         ta3PL0vnsBzsJT6fIBZkV/gnHsScizzVishPhbsw1OpytsfHcX3DuLoTdvAzN+RYniS3
         dchLxGJ70Fpqv6GwhIwQO719Uu96ffBv/92WjXZtsCcldfWspEL7CTOCw5fiBNBBAZHX
         bf1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YIsUhxU4+gts/JPtIOY3p0GcgAlB/Grz4wjUuRKy0gc=;
        b=pi8TMfw88I61ZLk3NA2k3s6gKf02cw9zaRgEvrNomkVy5qrA76cCn4QdogvhOllllp
         i5sU3Pxa2H6z7IOFvN5H0hjHe5GjY47FzWq2HNy/QFDpllQDMmnsT3zJMOrZTR4Nug92
         Gf3Nu+TNY0TA8WPrO/EEAOmHI+00USLW3mBQHhed3GwGF/wgMmch1hVPZ4yZdxrUPaKU
         VFBiYv2sApDZXDTQ5HDpO8gCPllZEUrOCZg3sWaoyEAY7K3jaNkbML5f8L8z8NLAHtn1
         KhaldUX6D6RfkhQ0EEDCdKI8PelRpW+XxNnznr/bsDuheFoiK5nbCpSyc/9aZuGO+huY
         FMgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F19NqBy9;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 22si451322pgd.540.2019.03.28.16.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:47:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=F19NqBy9;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SNiRs1129269;
	Thu, 28 Mar 2019 23:47:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=YIsUhxU4+gts/JPtIOY3p0GcgAlB/Grz4wjUuRKy0gc=;
 b=F19NqBy9epTh+nTN9Tzp4A10Ci+lWRm+5Sbwnc7wMHqwCGpyrdFpcyZkg3mzQs28hXSY
 BadHFdhW9ncY6AsNh2BCx+cIlHPvcbqyoh/+G80jHQPvIFIN/brMUplsVxJT9Yz4gj/1
 DOe2KBQnlo2BUtdFCU3OkJYBTGQaaoAQQLiyrd79OTc3aAjRA+RkUOxsORnM4XLInNWw
 LKvrMSsCEBwUhVwbS/GJ9aVlf3sF4vKR/311pUgLatTW4czGABD60aY6rdTIFvZ8nL3X
 ZfnHY0xE7UJ7MM98N3vRxtR/AKXyvBJgAPr1TuM4SzpPE6+86zD5eQxBjjkgDHCBdg/8 Aw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2re6g19kk2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:21 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SNlL8i015665
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:21 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SNlK0Q016061;
	Thu, 28 Mar 2019 23:47:20 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 16:47:20 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 2/2] hugetlb: use same fault hash key for shared and private mappings
Date: Thu, 28 Mar 2019 16:47:04 -0700
Message-Id: <20190328234704.27083-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328234704.27083-1-mike.kravetz@oracle.com>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=973 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280154
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlb uses a fault mutex hash table to prevent page faults of the
same pages concurrently.  The key for shared and private mappings is
different.  Shared keys off address_space and file index.  Private
keys off mm and virtual address.  Consider a private mappings of a
populated hugetlbfs file.  A write fault will first map the page from
the file and then do a COW to map a writable page.

Hugetlbfs hole punch uses the fault mutex to prevent mappings of file
pages.  It uses the address_space file index key.  However, private
mappings will use a different key and could temporarily map the file
page before COW.  This causes problems (BUG) for the hole punch code
as it expects the mutex to prevent additional uses/mappings of the page.

There seems to be another potential COW issue/race with this approach
of different private and shared keys as notes in commit 8382d914ebf7
("mm, hugetlb: improve page-fault scalability").

Since every hugetlb mapping (even anon and private) is actually a file
mapping, just use the address_space index key for all mappings.  This
results in potentially more hash collisions.  However, this should not
be the common case.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    |  7 ++-----
 include/linux/hugetlb.h |  4 +---
 mm/hugetlb.c            | 22 ++++++----------------
 mm/userfaultfd.c        |  3 +--
 4 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index ec32fece5e1e..6189ba80b57b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -440,9 +440,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			u32 hash;
 
 			index = page->index;
-			hash = hugetlb_fault_mutex_hash(h, current->mm,
-							&pseudo_vma,
-							mapping, index, 0);
+			hash = hugetlb_fault_mutex_hash(h, mapping, index, 0);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 			/*
@@ -639,8 +637,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		addr = index * hpage_size;
 
 		/* mutex taken here, fault path and hole punch */
-		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
-						index, addr);
+		hash = hugetlb_fault_mutex_hash(h, mapping, index, addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 		/* See if already present in mapping to avoid alloc/free */
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ea35263eb76b..3bc0d02649fe 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -123,9 +123,7 @@ void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason);
 void free_huge_page(struct page *page);
 void hugetlb_fix_reserve_counts(struct inode *inode);
 extern struct mutex *hugetlb_fault_mutex_table;
-u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
-				struct vm_area_struct *vma,
-				struct address_space *mapping,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *mapping,
 				pgoff_t idx, unsigned long address);
 
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8651d6a602f9..4409a87434f1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3837,8 +3837,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 			 * handling userfault.  Reacquire after handling
 			 * fault to make calling code simpler.
 			 */
-			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
-							idx, haddr);
+			hash = hugetlb_fault_mutex_hash(h, mapping, idx, haddr);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			ret = handle_userfault(&vmf, VM_UFFD_MISSING);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
@@ -3946,21 +3945,14 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 }
 
 #ifdef CONFIG_SMP
-u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
-			    struct vm_area_struct *vma,
-			    struct address_space *mapping,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
 {
 	unsigned long key[2];
 	u32 hash;
 
-	if (vma->vm_flags & VM_SHARED) {
-		key[0] = (unsigned long) mapping;
-		key[1] = idx;
-	} else {
-		key[0] = (unsigned long) mm;
-		key[1] = address >> huge_page_shift(h);
-	}
+	key[0] = (unsigned long) mapping;
+	key[1] = idx;
 
 	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
 
@@ -3971,9 +3963,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
  * For uniprocesor systems we always use a single mutex, so just
  * return 0 and avoid the hashing overhead.
  */
-u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
-			    struct vm_area_struct *vma,
-			    struct address_space *mapping,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
 {
 	return 0;
@@ -4018,7 +4008,7 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, haddr);
+	hash = hugetlb_fault_mutex_hash(h, mapping, idx, haddr);
 	mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 	entry = huge_ptep_get(ptep);
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d59b5a73dfb3..9932d5755e4c 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -271,8 +271,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		 */
 		idx = linear_page_index(dst_vma, dst_addr);
 		mapping = dst_vma->vm_file->f_mapping;
-		hash = hugetlb_fault_mutex_hash(h, dst_mm, dst_vma, mapping,
-								idx, dst_addr);
+		hash = hugetlb_fault_mutex_hash(h, mapping, idx, dst_addr);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 		err = -ENOMEM;
-- 
2.20.1


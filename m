Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C861C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:19:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A589321907
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:19:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ZFWaqmUM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A589321907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 311786B031C; Wed, 18 Sep 2019 21:19:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C2186B031D; Wed, 18 Sep 2019 21:19:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B09D6B031E; Wed, 18 Sep 2019 21:19:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0176.hostedemail.com [216.40.44.176])
	by kanga.kvack.org (Postfix) with ESMTP id E753E6B031C
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:19:03 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8C458181AC9B6
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:19:03 +0000 (UTC)
X-FDA: 75949911366.05.wood82_89390d5447b2b
X-HE-Tag: wood82_89390d5447b2b
X-Filterd-Recvd-Size: 8097
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:19:02 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8J1ETCf047234;
	Thu, 19 Sep 2019 01:18:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2019-08-05; bh=Ch2HJE+ao/XO4Zo6dYUJC5rMUKG56FG1SeoCl8PNcq0=;
 b=ZFWaqmUM1jfh7MTipYBnUuhTIVwH6FcxbEWmWoKsPwqa1D+LgidKy6bgayqlzZOsmzSR
 fY91UzlTct4Qv+bmYp8DjzQmhYgYdMwuA1JARehPMprLE9ybIik8xwEKXHLCR/ZJsy2X
 f3nHGTEs23Bn1jU8aUpbISQ/MpywqlZ32TEJkfSiRXcIjyzhBS3mSb+1TGvX0NeGKwYN
 Cdtmp3Vk4/Ts6mfBljsl4aoIjBB+zSuvEq4W+OzdejByGj4gh95t1AlCVDAHdwNziAjG
 hgzCHVsEQD1QNRXndFYIQPUhnfNSvc1xbGr/ev5S3sYoqPhejWbCgygsbm6BwyEiGg/0 aw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2v3vb50n5d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 19 Sep 2019 01:18:57 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8J1Drg2090667;
	Thu, 19 Sep 2019 01:18:56 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2v3vb4c9xd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 19 Sep 2019 01:18:56 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x8J1ItqB011438;
	Thu, 19 Sep 2019 01:18:55 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 18:18:54 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        clang-built-linux@googlegroups.com
Cc: Nathan Chancellor <natechancellor@gmail.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Ilie Halip <ilie.halip@gmail.com>,
        David Bolvansky <david.bolvansky@gmail.com>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: hugetlb_fault_mutex_hash cleanup
Date: Wed, 18 Sep 2019 18:18:47 -0700
Message-Id: <20190919011847.18400-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909190009
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909190009
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A new clang diagnostic (-Wsizeof-array-div) warns about the calculation
to determine the number of u32's in an array of unsigned longs. Suppress
warning by adding parentheses.

While looking at the above issue, noticed that the 'address' parameter
to hugetlb_fault_mutex_hash is no longer used. So, remove it from the
definition and all callers.

No functional change.

Reported-by: Nathan Chancellor <natechancellor@gmail.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    |  4 ++--
 include/linux/hugetlb.h |  2 +-
 mm/hugetlb.c            | 10 +++++-----
 mm/userfaultfd.c        |  2 +-
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a478df035651..6e5eadee6b0d 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -440,7 +440,7 @@ static void remove_inode_hugepages(struct inode *inod=
e, loff_t lstart,
 			u32 hash;
=20
 			index =3D page->index;
-			hash =3D hugetlb_fault_mutex_hash(h, mapping, index, 0);
+			hash =3D hugetlb_fault_mutex_hash(h, mapping, index);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
=20
 			/*
@@ -644,7 +644,7 @@ static long hugetlbfs_fallocate(struct file *file, in=
t mode, loff_t offset,
 		addr =3D index * hpage_size;
=20
 		/* mutex taken here, fault path and hole punch */
-		hash =3D hugetlb_fault_mutex_hash(h, mapping, index, addr);
+		hash =3D hugetlb_fault_mutex_hash(h, mapping, index);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
=20
 		/* See if already present in mapping to avoid alloc/free */
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edfca4278319..5bf11fffbbd4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -106,7 +106,7 @@ void free_huge_page(struct page *page);
 void hugetlb_fix_reserve_counts(struct inode *inode);
 extern struct mutex *hugetlb_fault_mutex_table;
 u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *map=
ping,
-				pgoff_t idx, unsigned long address);
+				pgoff_t idx);
=20
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *p=
ud);
=20
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296dd11b8..3705d3c69e32 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3847,7 +3847,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct =
*mm,
 			 * handling userfault.  Reacquire after handling
 			 * fault to make calling code simpler.
 			 */
-			hash =3D hugetlb_fault_mutex_hash(h, mapping, idx, haddr);
+			hash =3D hugetlb_fault_mutex_hash(h, mapping, idx);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			ret =3D handle_userfault(&vmf, VM_UFFD_MISSING);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
@@ -3975,7 +3975,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct =
*mm,
=20
 #ifdef CONFIG_SMP
 u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *map=
ping,
-			    pgoff_t idx, unsigned long address)
+			    pgoff_t idx)
 {
 	unsigned long key[2];
 	u32 hash;
@@ -3983,7 +3983,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, stru=
ct address_space *mapping,
 	key[0] =3D (unsigned long) mapping;
 	key[1] =3D idx;
=20
-	hash =3D jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
+	hash =3D jhash2((u32 *)&key, sizeof(key)/(sizeof(u32)), 0);
=20
 	return hash & (num_fault_mutexes - 1);
 }
@@ -3993,7 +3993,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, stru=
ct address_space *mapping,
  * return 0 and avoid the hashing overhead.
  */
 u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *map=
ping,
-			    pgoff_t idx, unsigned long address)
+			    pgoff_t idx)
 {
 	return 0;
 }
@@ -4037,7 +4037,7 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	hash =3D hugetlb_fault_mutex_hash(h, mapping, idx, haddr);
+	hash =3D hugetlb_fault_mutex_hash(h, mapping, idx);
 	mutex_lock(&hugetlb_fault_mutex_table[hash]);
=20
 	entry =3D huge_ptep_get(ptep);
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index c7ae74ce5ff3..640ff2bd9a69 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -269,7 +269,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb=
(struct mm_struct *dst_mm,
 		 */
 		idx =3D linear_page_index(dst_vma, dst_addr);
 		mapping =3D dst_vma->vm_file->f_mapping;
-		hash =3D hugetlb_fault_mutex_hash(h, mapping, idx, dst_addr);
+		hash =3D hugetlb_fault_mutex_hash(h, mapping, idx);
 		mutex_lock(&hugetlb_fault_mutex_table[hash]);
=20
 		err =3D -ENOMEM;
--=20
2.20.1



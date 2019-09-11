Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0F9ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D45D5207FC
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D45D5207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 824486B0273; Wed, 11 Sep 2019 11:06:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DC636B0274; Wed, 11 Sep 2019 11:06:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EC336B0275; Wed, 11 Sep 2019 11:06:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB706B0273
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:06:31 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0092352CC
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:30 +0000 (UTC)
X-FDA: 75922966182.10.books00_38d62b28b6706
X-HE-Tag: books00_38d62b28b6706
X-Filterd-Recvd-Size: 5405
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:30 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6C9BB300DA3A;
	Wed, 11 Sep 2019 15:06:29 +0000 (UTC)
Received: from llong.com (ovpn-125-196.rdu2.redhat.com [10.10.125.196])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CCD7D5D9E2;
	Wed, 11 Sep 2019 15:06:22 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Davidlohr Bueso <dave@stgolabs.net>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge PMD
Date: Wed, 11 Sep 2019 16:05:37 +0100
Message-Id: <20190911150537.19527-6-longman@redhat.com>
In-Reply-To: <20190911150537.19527-1-longman@redhat.com>
References: <20190911150537.19527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 11 Sep 2019 15:06:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When allocating a large amount of static hugepages (~500-1500GB) on a
system with large number of CPUs (4, 8 or even 16 sockets), performance
degradation (random multi-second delays) was observed when thousands
of processes are trying to fault in the data into the huge pages. The
likelihood of the delay increases with the number of sockets and hence
the CPUs a system has.  This only happens in the initial setup phase
and will be gone after all the necessary data are faulted in.

These random delays, however, are deemed unacceptable. The cause of
that delay is the long wait time in acquiring the mmap_sem when trying
to share the huge PMDs.

To remove the unacceptable delays, we have to limit the amount of wait
time on the mmap_sem. So the new down_write_timedlock() function is
used to acquire the write lock on the mmap_sem with a timeout value of
10ms which should not cause a perceivable delay. If timeout happens,
the task will abandon its effort to share the PMD and allocate its own
copy instead.

When too many timeouts happens (threshold currently set at 256), the
system may be too large for PMD sharing to be useful without undue delay.
So the sharing will be disabled in this case.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/fs.h |  7 +++++++
 mm/hugetlb.c       | 24 +++++++++++++++++++++---
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 997a530ff4e9..e9d3ad465a6b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -40,6 +40,7 @@
 #include <linux/fs_types.h>
 #include <linux/build_bug.h>
 #include <linux/stddef.h>
+#include <linux/ktime.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -519,6 +520,12 @@ static inline void i_mmap_lock_write(struct address_space *mapping)
 	down_write(&mapping->i_mmap_rwsem);
 }
 
+static inline bool i_mmap_timedlock_write(struct address_space *mapping,
+					 ktime_t timeout)
+{
+	return down_write_timedlock(&mapping->i_mmap_rwsem, timeout);
+}
+
 static inline void i_mmap_unlock_write(struct address_space *mapping)
 {
 	up_write(&mapping->i_mmap_rwsem);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296dd11b8..445af661ae29 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4750,6 +4750,8 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 	}
 }
 
+#define PMD_SHARE_DISABLE_THRESHOLD	(1 << 8)
+
 /*
  * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
  * and returns the corresponding pte. While this is not necessary for the
@@ -4770,11 +4772,24 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	pte_t *spte = NULL;
 	pte_t *pte;
 	spinlock_t *ptl;
+	static atomic_t timeout_cnt;
 
-	if (!vma_shareable(vma, addr))
-		return (pte_t *)pmd_alloc(mm, pud, addr);
+	/*
+	 * Don't share if it is not sharable or locking attempt timed out
+	 * after 10ms. After 256 timeouts, PMD sharing will be permanently
+	 * disabled as it is just too slow.
+	 */
+	if (!vma_shareable(vma, addr) ||
+	   (atomic_read(&timeout_cnt) >= PMD_SHARE_DISABLE_THRESHOLD))
+		goto out_no_share;
+
+	if (!i_mmap_timedlock_write(mapping, ms_to_ktime(10))) {
+		if (atomic_inc_return(&timeout_cnt) ==
+		    PMD_SHARE_DISABLE_THRESHOLD)
+			pr_info("Hugetlbfs PMD sharing disabled because of timeouts!\n");
+		goto out_no_share;
+	}
 
-	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -4806,6 +4821,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
 	i_mmap_unlock_write(mapping);
 	return pte;
+
+out_no_share:
+	return (pte_t *)pmd_alloc(mm, pud, addr);
 }
 
 /*
-- 
2.18.1



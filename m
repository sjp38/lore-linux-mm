Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3145FC072AD
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5EE321019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5EE321019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876EB6B000E; Tue, 21 May 2019 00:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8025A6B0266; Tue, 21 May 2019 00:53:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DB9F6B0269; Tue, 21 May 2019 00:53:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0236E6B000E
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so28733565edm.16
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RhKrHx4coH9CCJ8us/PPaV6G9Z+XqAHBa9IVwCw9ZVA=;
        b=DzqftKWGwPdICRp+h+1Dq+agyh4PcgR5SfrtsOdUdV8geholDaMbFQGn4TB2OspzUE
         PRMo7owkd54vSFA8YivEpceeaykpG9VqECXsUQsjJ6IWwiRXwoLvJPj/4DhUWjR+jVcj
         mA3elGFMsBuPYnRMkjE2j+2OfxNpftV9G7WXttfJYHfgEek+shqQwNfYZaxuX5vgdp1t
         BPfhnx7k7IrLu+hJg4dJp/PDMQqPiYr3SmYMQJsdYVqshHmayp6xxXpxsEXQDwTgL0WP
         3lVq6ILH64kV/bunP188whB4XtFXExviQFb9X6WReCsj3RWhNSSEPWb9LxrYD6csA3Ie
         ncsw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAXzwnBeC7pOI6eNH9w5Q5O+T+Bn2giOkjqTTspScQPJtkV1hOMq
	9UK/ixVEnAdmqsp5uPdBx4qfdXqkrRN8jALu1aidO0bnVbBZDTlcN6zT1WZ2h4PS+W+0BV880Pp
	6bTiZNUTFrZztFVb+ekjHptF0JhYQAbbnECR24tWXZ4f29t9lxB7yWAUmAJKynYw=
X-Received: by 2002:a17:906:3b8f:: with SMTP id u15mr47866972ejf.6.1558414418476;
        Mon, 20 May 2019 21:53:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTm8o0iPoHidyqHRhulSpaxdZ4WEa1oAZ4u6uQ0EpQDBYF8LzTRtD7W3ozZClRlrd5MLAH
X-Received: by 2002:a17:906:3b8f:: with SMTP id u15mr47866905ejf.6.1558414416963;
        Mon, 20 May 2019 21:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414416; cv=none;
        d=google.com; s=arc-20160816;
        b=uAzqdoHPfwyeKy0fgMXhcHqzM0YPgQdWZT8yIY1PC3NL7DDOoYp7sufU1uTNZVNR9w
         8Y6MStTQoTaOR2Dw8ssJWvjLiynaufueXPgktd76nIHMe6QYJgJTUP48GjoxOH00/KlO
         yKUsFr+a1q1RLhLrPqaDpqRiQ6tPzC8YHOtsx1z9JQUtPUsnyoKcKhlUm/hMs7uCtLex
         cJWqvS0l+CWUFNYCXSsdpuCZNQIrBPjdXbd4spmxRsAay8IOC7TuWbwAtWMbYRcJmIhj
         BX+Oh6hiHVbibrPgadSLDXkauNpohBMcqL8Beh8ST34Ku1IkTDLTsTdo3xp1KDl8SqrF
         b8wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RhKrHx4coH9CCJ8us/PPaV6G9Z+XqAHBa9IVwCw9ZVA=;
        b=uiFKeRj9TjrYCno8eBUSo0B2ny5uGNsC2bOdlYTRSDUxzggD5MN4EcMS+s5lX0+cgl
         q8Y3BoW49juKd3tIRDrGQxDBIn14dYerdmAJD8u2Y4SNvZK507zrgOCe9B11tlRcpQga
         JkBuPzk1Mio+UIjps0HAsoVmYIpe04OIf5j5EEukfa4O5NfciQWQGDgXnDUJod3FqLH8
         PKJVS1yiVjte7U0MM1kkBZWzck8jSMxuGHGMH+lv6jKYYreok4sr2LYoh1+tPeeHYVYx
         3kej7Csg2O1OZtBjZZ1JtjOwg949CK+bedruYuLElr76cw08JWDszdYRlZz90O+lbMeN
         w/7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id r16si2715773ejj.69.2019.05.20.21.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:36 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:06 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 05/14] mm: remove some BUG checks wrt mmap_sem
Date: Mon, 20 May 2019 21:52:33 -0700
Message-Id: <20190521045242.24378-6-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a collection of hacks that shamelessly remove
mmap_sem state checks in order to not have to teach file_operations
about range locking; for thp and huge pagecache: By dropping the
rwsem_is_locked checks in zap_pmd_range() and zap_pud_range() we can
avoid having to teach file_operations about mmrange. For example in
xfs: iomap_dio_rw() is called by .read_iter file callbacks.

We also avoid mmap_sem trylock in vm_insert_page(): The rules to
this function state that mmap_sem must be acquired by the caller:

- for write if used in f_op->mmap() (by far the most common case)
- for read if used from vma_op->fault()(with VM_MIXEDMAP)

The only exception is:
  mmap_vmcore()
   remap_vmalloc_range_partial()
      mmap_vmcore()

But there is no concurrency here, thus mmap_sem is not held.
After auditing the kernel, the following drivers use the fault
path and correctly set VM_MIXEDMAP):

.fault = etnaviv_gem_fault
.fault = udl_gem_fault
tegra_bo_fault()

As such, drop the reader trylock BUG_ON() for the common case.
This avoids having file_operations know about mmranges, as
mmap_sem is held during, mmap() for example.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/huge_mm.h | 2 --
 mm/memory.c             | 2 --
 mm/mmap.c               | 4 ++--
 mm/pagewalk.c           | 3 ---
 4 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..a4a9cfa78d8f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -194,7 +194,6 @@ static inline int is_swap_pmd(pmd_t pmd)
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma);
 	else
@@ -203,7 +202,6 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 		struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pud_trans_huge(*pud) || pud_devmap(*pud))
 		return __pud_trans_huge_lock(pud, vma);
 	else
diff --git a/mm/memory.c b/mm/memory.c
index 9516c95108a1..73971f859035 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1212,7 +1212,6 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 		next = pud_addr_end(addr, end);
 		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
 			if (next - addr != HPAGE_PUD_SIZE) {
-				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				split_huge_pud(vma, pud, addr);
 			} else if (zap_huge_pud(tlb, vma, pud, addr))
 				goto next;
@@ -1519,7 +1518,6 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 	if (!page_count(page))
 		return -EINVAL;
 	if (!(vma->vm_flags & VM_MIXEDMAP)) {
-		BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
 		BUG_ON(vma->vm_flags & VM_PFNMAP);
 		vma->vm_flags |= VM_MIXEDMAP;
 	}
diff --git a/mm/mmap.c b/mm/mmap.c
index af228ae3508d..a03ded49f9eb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3466,7 +3466,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		down_write_nest_lock(&anon_vma->root->rwsem, &mm->mmap_sem);
+		down_write(&mm->mmap_sem);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->root->rwsem. If some other vma in this mm shares
@@ -3496,7 +3496,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
+		down_write(&mm->mmap_sem);
 	}
 }
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3084ff2569d..6246acf17054 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -303,8 +303,6 @@ int walk_page_range(unsigned long start, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
-
 	vma = find_vma(walk->mm, start);
 	do {
 		if (!vma) { /* after the last vma */
@@ -346,7 +344,6 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
 	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
-- 
2.16.4


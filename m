Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.8 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE6DC3A5A2
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 00:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72C1C21897
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 00:58:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72C1C21897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFE8C6B0003; Tue,  3 Sep 2019 20:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAFD36B0006; Tue,  3 Sep 2019 20:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9E516B0007; Tue,  3 Sep 2019 20:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 998666B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:58:47 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3CC9E906D
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 00:58:47 +0000 (UTC)
X-FDA: 75895428294.08.match18_697c94f395707
X-HE-Tag: match18_697c94f395707
X-Filterd-Recvd-Size: 4995
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 00:58:44 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 76655344;
	Tue,  3 Sep 2019 17:58:43 -0700 (PDT)
Received: from entos-thunderx2-02.shanghai.arm.com (entos-thunderx2-02.shanghai.arm.com [10.169.40.54])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 91F0A3F246;
	Tue,  3 Sep 2019 17:58:40 -0700 (PDT)
From: Jia He <justin.he@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Dave Airlie <airlied@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Jia He <justin.he@arm.com>
Subject: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Date: Wed,  4 Sep 2019 08:58:31 +0800
Message-Id: <20190904005831.153934-1-justin.he@arm.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we tested pmdk unit test [1] vmmalloc_fork TEST1 in arm64 guest, there
will be a double page fault in __copy_from_user_inatomic of cow_user_page.

Below call trace is from arm64 do_page_fault for debugging purpose
[  110.016195] Call trace:
[  110.016826]  do_page_fault+0x5a4/0x690
[  110.017812]  do_mem_abort+0x50/0xb0
[  110.018726]  el1_da+0x20/0xc4
[  110.019492]  __arch_copy_from_user+0x180/0x280
[  110.020646]  do_wp_page+0xb0/0x860
[  110.021517]  __handle_mm_fault+0x994/0x1338
[  110.022606]  handle_mm_fault+0xe8/0x180
[  110.023584]  do_page_fault+0x240/0x690
[  110.024535]  do_mem_abort+0x50/0xb0
[  110.025423]  el0_da+0x20/0x24

The pte info before __copy_from_user_inatomic is(PTE_AF is cleared):
[ffff9b007000] pgd=000000023d4f8003, pud=000000023da9b003, pmd=000000023d4b3003, pte=360000298607bd3

The keypoint is: we don't always have a hardware-managed access flag on
arm64.

The root cause is in copy_one_pte, it will clear the PTE_AF for COW
pages. Generally, when it is accessed by user, the COW pages will be set
as accessed(PTE_AF bit on arm64) by hardware if hardware feature is
supported. But on some arm64 platforms, the PTE_AF needs to be set by
software.

This patch fix it by calling pte_mkyoung. Also, the parameter is
changed because vmf should be passed to cow_user_page()

[1] https://github.com/pmem/pmdk/tree/master/src/test/vmmalloc_fork

Reported-by: Yibo Cai <Yibo.Cai@arm.com>
Signed-off-by: Jia He <justin.he@arm.com>
---
 mm/memory.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..b1f9ace2e943 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2140,7 +2140,8 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 	return same;
 }
 
-static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
+static inline void cow_user_page(struct page *dst, struct page *src,
+				struct vm_fault *vmf)
 {
 	debug_dma_assert_idle(src);
 
@@ -2152,20 +2153,30 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 	 */
 	if (unlikely(!src)) {
 		void *kaddr = kmap_atomic(dst);
-		void __user *uaddr = (void __user *)(va & PAGE_MASK);
+		void __user *uaddr = (void __user *)(vmf->address & PAGE_MASK);
+		pte_t entry;
 
 		/*
 		 * This really shouldn't fail, because the page is there
 		 * in the page tables. But it might just be unreadable,
 		 * in which case we just give up and fill the result with
-		 * zeroes.
+		 * zeroes. If PTE_AF is cleared on arm64, it might
+		 * cause double page fault here. so makes pte young here
 		 */
+		if (!pte_young(vmf->orig_pte)) {
+			entry = pte_mkyoung(vmf->orig_pte);
+			if (ptep_set_access_flags(vmf->vma, vmf->address,
+				vmf->pte, entry, vmf->flags & FAULT_FLAG_WRITE))
+				update_mmu_cache(vmf->vma, vmf->address,
+						vmf->pte);
+		}
+
 		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
 			clear_page(kaddr);
 		kunmap_atomic(kaddr);
 		flush_dcache_page(dst);
 	} else
-		copy_user_highpage(dst, src, va, vma);
+		copy_user_highpage(dst, src, vmf->address, vmf->vma);
 }
 
 static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
@@ -2318,7 +2329,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 				vmf->address);
 		if (!new_page)
 			goto oom;
-		cow_user_page(new_page, old_page, vmf->address, vma);
+		cow_user_page(new_page, old_page, vmf);
 	}
 
 	if (mem_cgroup_try_charge_delay(new_page, mm, GFP_KERNEL, &memcg, false))
-- 
2.17.1



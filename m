Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6702082F6D
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:05:16 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so44324978qkb.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:05:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 69si9739842qgt.1.2015.10.21.13.05.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:05:15 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 14/15] HMM: Add support for hugetlb.
Date: Wed, 21 Oct 2015 17:00:09 -0400
Message-Id: <1445461210-2605-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Support hugetlb vma allmost like other vma. Exception being that we
will not support migration of hugetlb memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 61 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6ed1081..9e5017a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -809,6 +809,65 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 	return ret;
 }
 
+static int hmm_mirror_fault_hugetlb_entry(pte_t *ptep,
+					  unsigned long hmask,
+					  unsigned long addr,
+					  unsigned long end,
+					  struct mm_walk *walk)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	struct hmm_mirror_fault *mirror_fault = walk->private;
+	struct hmm_event *event = mirror_fault->event;
+	struct hmm_pt_iter *iter = mirror_fault->iter;
+	bool write = (event->etype == HMM_DEVICE_WFAULT);
+	unsigned long pfn, next;
+	dma_addr_t *hmm_pte;
+	pte_t pte;
+
+	/*
+	 * Hugepages under user process are always in RAM and never
+	 * swapped out, but theoretically it needs to be checked.
+	 */
+	if (!ptep)
+		return -ENOENT;
+
+	pte = huge_ptep_get(ptep);
+	pfn = pte_pfn(pte);
+	if (!huge_pte_none(pte) || (write && !huge_pte_write(pte)))
+		return -ENOENT;
+
+	hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
+	if (!hmm_pte)
+		return -ENOMEM;
+	hmm_pt_iter_directory_lock(iter);
+	for (; addr != end; addr += PAGE_SIZE, ++pfn, ++hmm_pte) {
+		/* Switch to another HMM page table directory ? */
+		if (addr == next) {
+			hmm_pt_iter_directory_unlock(iter);
+			hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
+			if (!hmm_pte)
+				return -ENOMEM;
+			hmm_pt_iter_directory_lock(iter);
+		}
+
+		if (hmm_pte_test_valid_dma(hmm_pte))
+			continue;
+
+		if (!hmm_pte_test_valid_pfn(hmm_pte)) {
+			*hmm_pte = hmm_pte_from_pfn(pfn);
+			hmm_pt_iter_directory_ref(iter);
+		}
+		BUG_ON(hmm_pte_pfn(*hmm_pte) != pfn);
+		if (write)
+			hmm_pte_set_write(hmm_pte);
+	}
+	hmm_pt_iter_directory_unlock(iter);
+#else
+	BUG();
+#endif
+	return 0;
+}
+
 static int hmm_mirror_dma_map(struct hmm_mirror *mirror,
 			      struct hmm_pt_iter *iter,
 			      unsigned long start,
@@ -916,6 +975,7 @@ static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
 		walk.mm = mirror->hmm->mm;
 		walk.private = &mirror_fault;
 		walk.pmd_entry = hmm_mirror_fault_pmd;
+		walk.hugetlb_entry = hmm_mirror_fault_hugetlb_entry;
 		walk.pte_hole = hmm_pte_hole;
 		ret = walk_page_range(addr, event->end, &walk);
 		if (ret)
@@ -1002,7 +1062,7 @@ retry:
 		goto out;
 	}
 	event->end = min(event->end, vma->vm_end) & PAGE_MASK;
-	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP | VM_HUGETLB))) {
+	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP))) {
 		ret = -EFAULT;
 		goto out;
 	}
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

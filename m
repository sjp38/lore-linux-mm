Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 44CF36B026B
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:47:13 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id x1so10711979qkc.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:47:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si4500974qhk.72.2016.03.08.11.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:47:12 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v12 14/29] HMM: Add support for hugetlb.
Date: Tue,  8 Mar 2016 15:43:07 -0500
Message-Id: <1457469802-11850-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
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
index 7cab6cb..ad44325 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -813,6 +813,65 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
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
@@ -920,6 +979,7 @@ static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
 		walk.mm = mirror->hmm->mm;
 		walk.private = &mirror_fault;
 		walk.pmd_entry = hmm_mirror_fault_pmd;
+		walk.hugetlb_entry = hmm_mirror_fault_hugetlb_entry;
 		walk.pte_hole = hmm_pte_hole;
 		ret = walk_page_range(addr, event->end, &walk);
 		if (ret)
@@ -1006,7 +1066,7 @@ retry:
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id A8ED582F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:15:12 -0400 (EDT)
Received: by qkca6 with SMTP id a6so44714451qkc.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:15:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b81si9766621qkb.28.2015.10.21.13.15.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:15:11 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 13/14] HMM: CPU page fault on migrated memory.
Date: Wed, 21 Oct 2015 17:10:18 -0400
Message-Id: <1445461819-2675-14-git-send-email-jglisse@redhat.com>
In-Reply-To: <1445461819-2675-1-git-send-email-jglisse@redhat.com>
References: <1445461819-2675-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

When CPU try to access memory that have been migrated to device memory
we have to copy it back to system memory. This patch implement the CPU
page fault handler for special HMM pte swap entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 53 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b473fe9..efffb8d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -469,7 +469,59 @@ int hmm_handle_cpu_fault(struct mm_struct *mm,
 			pmd_t *pmdp, unsigned long addr,
 			unsigned flags, pte_t orig_pte)
 {
-	return VM_FAULT_SIGBUS;
+	unsigned long start, end;
+	struct hmm_event event;
+	swp_entry_t entry;
+	struct hmm *hmm;
+	dma_addr_t dst;
+	pte_t new_pte;
+	int ret;
+
+	/* First check for poisonous entry. */
+	entry = pte_to_swp_entry(orig_pte);
+	if (is_hmm_entry_poisonous(entry))
+		return VM_FAULT_SIGBUS;
+
+	hmm = hmm_ref(mm->hmm);
+	if (!hmm) {
+		pte_t poison = swp_entry_to_pte(make_hmm_entry_poisonous());
+		spinlock_t *ptl;
+		pte_t *ptep;
+
+		/* Check if cpu pte is already updated. */
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		if (!pte_same(*ptep, orig_pte)) {
+			pte_unmap_unlock(ptep, ptl);
+			return 0;
+		}
+		set_pte_at(mm, addr, ptep, poison);
+		pte_unmap_unlock(ptep, ptl);
+		return VM_FAULT_SIGBUS;
+	}
+
+	/*
+	 * TODO we likely want to migrate more then one page at a time, we need
+	 * to call into the device driver to get good hint on the range to copy
+	 * back to system memory.
+	 *
+	 * For now just live with the one page at a time solution.
+	 */
+	start = addr & PAGE_MASK;
+	end = start + PAGE_SIZE;
+	hmm_event_init(&event, hmm, start, end, HMM_COPY_FROM_DEVICE);
+
+	ret = hmm_migrate_back(hmm, &event, mm, vma, &new_pte,
+			       &dst, start, end);
+	hmm_unref(hmm);
+	switch (ret) {
+	case 0:
+		return VM_FAULT_MAJOR;
+	case -ENOMEM:
+		return VM_FAULT_OOM;
+	case -EINVAL:
+	default:
+		return VM_FAULT_SIGBUS;
+	}
 }
 EXPORT_SYMBOL(hmm_handle_cpu_fault);
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

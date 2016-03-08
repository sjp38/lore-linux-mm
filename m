Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 79CEB828E6
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:47:55 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id w104so22058647qge.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:47:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 129si4521358qhr.40.2016.03.08.11.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:47:54 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v12 27/29] HMM: fork copy migrated memory into system memory for child process.
Date: Tue,  8 Mar 2016 15:43:20 -0500
Message-Id: <1457469802-11850-28-git-send-email-jglisse@redhat.com>
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

When forking if process being fork had any memory migrated to some
device memory, we need to make a system copy for the child process.
Latter patches can revisit this and use the same COW semantic for
device memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 435e376..4dcd98f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -483,7 +483,37 @@ int hmm_mm_fork(struct mm_struct *src_mm,
 		unsigned long start,
 		unsigned long end)
 {
-	return -ENOMEM;
+	unsigned long npages = (end - start) >> PAGE_SHIFT;
+	struct hmm_event event;
+	dma_addr_t *dst;
+	struct hmm *hmm;
+	pte_t *new_pte;
+	int ret;
+
+	hmm = hmm_ref(src_mm->hmm);
+	if (!hmm)
+		return -EINVAL;
+
+
+	dst = kcalloc(npages, sizeof(*dst), GFP_KERNEL);
+	if (!dst) {
+		hmm_unref(hmm);
+		return -ENOMEM;
+	}
+	new_pte = kcalloc(npages, sizeof(*new_pte), GFP_KERNEL);
+	if (!new_pte) {
+		kfree(dst);
+		hmm_unref(hmm);
+		return -ENOMEM;
+	}
+
+	hmm_event_init(&event, hmm, start, end, HMM_FORK);
+	ret = hmm_migrate_back(hmm, &event, dst_mm, dst_vma, new_pte,
+			       dst, start, end);
+	hmm_unref(hmm);
+	kfree(new_pte);
+	kfree(dst);
+	return ret;
 }
 EXPORT_SYMBOL(hmm_mm_fork);
 
@@ -665,6 +695,12 @@ static void hmm_mirror_update_pte(struct hmm_mirror *mirror,
 	}
 
 	if (hmm_pte_test_valid_dev(hmm_pte)) {
+		/*
+		 * On fork device memory is duplicated so no need to write
+		 * protect it.
+		 */
+		if (event->etype == HMM_FORK)
+			return;
 		*hmm_pte &= event->pte_mask;
 		if (!hmm_pte_test_valid_dev(hmm_pte))
 			hmm_pt_iter_directory_unref(iter);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

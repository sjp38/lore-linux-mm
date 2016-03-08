Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9E63A828E6
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:47:32 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id w104so22047978qge.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:47:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t90si4549429qkl.5.2016.03.08.11.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:47:31 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v12 20/29] HMM: handle HMM device page table entry on mirror page table fault and update.
Date: Tue,  8 Mar 2016 15:43:13 -0500
Message-Id: <1457469802-11850-21-git-send-email-jglisse@redhat.com>
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

When faulting or updating the device page table properly handle the case of
device memory entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index a5706d2..9455443 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -616,6 +616,13 @@ static void hmm_mirror_update_pte(struct hmm_mirror *mirror,
 		goto out;
 	}
 
+	if (hmm_pte_test_valid_dev(hmm_pte)) {
+		*hmm_pte &= event->pte_mask;
+		if (!hmm_pte_test_valid_dev(hmm_pte))
+			hmm_pt_iter_directory_unref(iter);
+		return;
+	}
+
 	if (!hmm_pte_test_valid_dma(hmm_pte))
 		return;
 
@@ -808,6 +815,12 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 		ptep = pte_offset_map(pmdp, start);
 		hmm_pt_iter_directory_lock(iter);
 		do {
+			if (hmm_pte_test_valid_dev(&hmm_pte[i])) {
+				if (write)
+					hmm_pte_set_write(&hmm_pte[i]);
+				continue;
+			}
+
 			if (!pte_present(*ptep) ||
 			    (write && !pte_write(*ptep)) ||
 			    pte_protnone(*ptep)) {
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

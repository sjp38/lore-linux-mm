Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 569E282966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:34:22 -0400 (EDT)
Received: by qgez61 with SMTP id z61so43353406qge.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:22 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id n40si17729747qkh.89.2015.05.21.12.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:34:21 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so59403629qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:21 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 19/36] HMM: handle HMM device page table entry on mirror page table fault and update.
Date: Thu, 21 May 2015 15:31:28 -0400
Message-Id: <1432236705-4209-20-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

When faulting or updating the device page table properly handle the case of device
memory entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 761905a..e4585b7 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -613,6 +613,13 @@ static void hmm_mirror_update_pte(struct hmm_mirror *mirror,
 		goto out;
 	}
 
+	if (hmm_pte_test_valid_dev(hmm_pte)) {
+		*hmm_pte &= event->pte_mask;
+		if (!hmm_pte_test_valid_dev(hmm_pte))
+			hmm_pt_iter_directory_unref(iter, mirror->pt.llevel);
+		return;
+	}
+
 	if (!hmm_pte_test_valid_dma(hmm_pte))
 		return;
 
@@ -813,6 +820,13 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 		do {
 			next = hmm_pt_level_next(&mirror->pt, addr, hmm_end,
 						 mirror->pt.llevel);
+
+			if (hmm_pte_test_valid_dev(&hmm_pte[i])) {
+				if (write)
+					hmm_pte_set_write(&hmm_pte[i]);
+				continue;
+			}
+
 			if (!pte_present(*ptep) || (write && !pte_write(*ptep))) {
 				ret = -ENOENT;
 				ptep++;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

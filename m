Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id D6795900015
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:33:57 -0400 (EDT)
Received: by qgfa63 with SMTP id a63so27667610qgf.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:57 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id 12si5831041qhx.61.2015.05.21.12.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:33:57 -0700 (PDT)
Received: by qgez61 with SMTP id z61so43345399qge.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:57 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 12/36] HMM: add dirty range helper (to toggle dirty bit inside mirror page table).
Date: Thu, 21 May 2015 15:31:21 -0400
Message-Id: <1432236705-4209-13-git-send-email-j.glisse@gmail.com>
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

Device driver must properly toggle the dirty inside the mirror page table so
dirtyness is properly accounted when core mm code needs to know. Provide a
simple helper to toggle that bit for a range of address.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h |  3 +++
 mm/hmm.c            | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ec05df8..186f497 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -253,6 +253,9 @@ int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
 void hmm_mirror_range_discard(struct hmm_mirror *mirror,
 			      unsigned long start,
 			      unsigned long end);
+void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
+			    unsigned long start,
+			    unsigned long end);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index 4cab3f2..21fda9f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -940,6 +940,53 @@ void hmm_mirror_range_discard(struct hmm_mirror *mirror,
 }
 EXPORT_SYMBOL(hmm_mirror_range_discard);
 
+/* hmm_mirror_range_dirty() - toggle dirty bit for a range of address.
+ *
+ * @mirror: The mirror struct.
+ * @start: Start address of the range to discard (inclusive).
+ * @end: End address of the range to discard (exclusive).
+ *
+ * Call when device driver want to toggle the dirty bit for a range of address.
+ * Usefull when the device driver just want to toggle the bit for whole range
+ * without walking the mirror page table itself.
+ *
+ * Note this function does not directly dirty the page behind an address, but
+ * this will happen once address is invalidated or discard by device driver or
+ * core mm code.
+ */
+void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
+			    unsigned long start,
+			    unsigned long end)
+{
+	struct hmm_pt_iter iter;
+	unsigned long addr;
+
+	hmm_pt_iter_init(&iter);
+	for (addr = start; addr != end;) {
+		unsigned long cend, next;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
+		if (!hmm_pte) {
+			addr = hmm_pt_iter_next(&iter, &mirror->pt,
+						addr, end);
+			continue;
+		}
+		cend = hmm_pt_level_next(&mirror->pt, addr, end,
+					 mirror->pt.llevel - 1);
+		do {
+			next = hmm_pt_level_next(&mirror->pt, addr, cend,
+						 mirror->pt.llevel);
+			if (!hmm_pte_test_valid_pfn(hmm_pte) ||
+			    !hmm_pte_test_write(hmm_pte))
+				continue;
+			hmm_pte_set_dirty(hmm_pte);
+		} while (addr = next, hmm_pte++, addr != cend);
+	}
+	hmm_pt_iter_fini(&iter, &mirror->pt);
+}
+EXPORT_SYMBOL(hmm_mirror_range_dirty);
+
 /* hmm_mirror_register() - register mirror against current process for a device.
  *
  * @mirror: The mirror struct being registered.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

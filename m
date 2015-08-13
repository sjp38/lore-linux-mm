Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A3E4D6B0260
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:16:22 -0400 (EDT)
Received: by qged69 with SMTP id d69so37726627qge.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:16:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j2si5333506qkh.104.2015.08.13.12.16.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:16:20 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 12/15] HMM: add dirty range helper (toggle dirty bit inside mirror page table) v2.
Date: Thu, 13 Aug 2015 15:15:25 -0400
Message-Id: <1439493328-1028-13-git-send-email-jglisse@redhat.com>
In-Reply-To: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
References: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Device driver must properly toggle the dirty inside the mirror page table
so dirtyness is properly accounted when core mm code needs to know. Provide
a simple helper to toggle that bit for a range of address.

Changed since v1:
  - Adapt to HMM page table changes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h |  3 +++
 mm/hmm.c            | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 10e1558..4bc132a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -268,6 +268,9 @@ int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
 void hmm_mirror_range_discard(struct hmm_mirror *mirror,
 			      unsigned long start,
 			      unsigned long end);
+void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
+			    unsigned long start,
+			    unsigned long end);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index f271441..2c6530e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -920,6 +920,44 @@ void hmm_mirror_range_discard(struct hmm_mirror *mirror,
 }
 EXPORT_SYMBOL(hmm_mirror_range_discard);
 
+/* hmm_mirror_range_dirty() - toggle dirty bit for a range of address.
+ *
+ * @mirror: The mirror struct.
+ * @start: Start address of the range to discard (inclusive).
+ * @end: End address of the range to discard (exclusive).
+ *
+ * Call when device driver want to toggle the dirty bit for a range of address.
+ * Useful when the device driver just want to toggle the bit for whole range
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
+	hmm_pt_iter_init(&iter, &mirror->pt);
+	for (addr = start; addr != end;) {
+		unsigned long next = end;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_walk(&iter, &addr, &next);
+		for (; hmm_pte && addr != next; hmm_pte++, addr += PAGE_SIZE) {
+			if (!hmm_pte_test_valid_pfn(hmm_pte) ||
+			    !hmm_pte_test_write(hmm_pte))
+				continue;
+			hmm_pte_set_dirty(hmm_pte);
+		}
+	}
+	hmm_pt_iter_fini(&iter);
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

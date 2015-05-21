Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 76F91900015
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:33:54 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so64242599qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:54 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id b69si5677471qgb.50.2015.05.21.12.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:33:53 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so59391347qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:53 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 11/36] HMM: add discard range helper (to clear and free resources for a range).
Date: Thu, 21 May 2015 15:31:20 -0400
Message-Id: <1432236705-4209-12-git-send-email-j.glisse@gmail.com>
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

A common use case is for device driver to stop caring for a range of address
long before said range is munmapped by userspace program. To avoid keeping
track of such range provide an helper function that will free HMM resources
for a range of address.

NOTE THAT DEVICE DRIVER MUST MAKE SURE THE HARDWARE WILL NO LONGER ACCESS THE
RANGE BECAUSE CALLING THIS HELPER !

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h |  3 +++
 mm/hmm.c            | 24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index fdb1975..ec05df8 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -250,6 +250,9 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
+void hmm_mirror_range_discard(struct hmm_mirror *mirror,
+			      unsigned long start,
+			      unsigned long end);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index 8ec9ffa..4cab3f2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -916,6 +916,30 @@ out:
 }
 EXPORT_SYMBOL(hmm_mirror_fault);
 
+/* hmm_mirror_range_discard() - discard a range of address.
+ *
+ * @mirror: The mirror struct.
+ * @start: Start address of the range to discard (inclusive).
+ * @end: End address of the range to discard (exclusive).
+ *
+ * Call when device driver want to stop mirroring a range of address and free
+ * any HMM resources associated with that range (including dma mapping if any).
+ *
+ * THIS FUNCTION ASSUME THAT DRIVER ALREADY STOPPED USING THE RANGE OF ADDRESS
+ * AND THUS DO NOT PERFORM ANY SYNCHRONIZATION OR UPDATE WITH THE DRIVER TO
+ * INVALIDATE SAID RANGE.
+ */
+void hmm_mirror_range_discard(struct hmm_mirror *mirror,
+			      unsigned long start,
+			      unsigned long end)
+{
+	struct hmm_event event;
+
+	hmm_event_init(&event, mirror->hmm, start, end, HMM_MUNMAP);
+	hmm_mirror_update_pt(mirror, &event, NULL);
+}
+EXPORT_SYMBOL(hmm_mirror_range_discard);
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

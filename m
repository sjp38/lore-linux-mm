Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA356B0266
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:47:03 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id s68so10684367qkh.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:47:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h68si4510778qgf.82.2016.03.08.11.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:47:02 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v12 11/29] HMM: add discard range helper (to clear and free resources for a range).
Date: Tue,  8 Mar 2016 15:43:04 -0500
Message-Id: <1457469802-11850-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

A common use case is for device driver to stop caring for a range of
address long before said range is munmapped by userspace program. To
avoid keeping track of such range provide an helper function that will
free HMM resources for a range of address.

NOTE THAT DEVICE DRIVER MUST MAKE SURE THE HARDWARE WILL NO LONGER
ACCESS THE RANGE BECAUSE CALLING THIS HELPER !

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm.h |  3 +++
 mm/hmm.c            | 24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index d819ec9..10e1558 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -265,6 +265,9 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
 void hmm_mirror_unref(struct hmm_mirror **mirror);
 int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
+void hmm_mirror_range_discard(struct hmm_mirror *mirror,
+			      unsigned long start,
+			      unsigned long end);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index 7b6ba6a..548f0c5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -921,6 +921,30 @@ out:
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

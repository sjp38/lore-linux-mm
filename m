Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6DB46B0008
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y17so7231462qth.11
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f53si918183qtf.132.2018.03.16.12.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:20 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is destroyed v2
Date: Fri, 16 Mar 2018 15:14:08 -0400
Message-Id: <20180316191414.3223-4-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: Ralph Campbell <rcampbell@nvidia.com>

The hmm_mirror_register() function registers a callback for when
the CPU pagetable is modified. Normally, the device driver will
call hmm_mirror_unregister() when the process using the device is
finished. However, if the process exits uncleanly, the struct_mm
can be destroyed with no warning to the device driver.

Changed since v1:
  - dropped VM_BUG_ON()
  - cc stable

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: stable@vger.kernel.org
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 10 ++++++++++
 mm/hmm.c            | 18 +++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ef6044d08cc5..61b0e1c05ee1 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -218,6 +218,16 @@ enum hmm_update_type {
  * @update: callback to update range on a device
  */
 struct hmm_mirror_ops {
+	/* release() - release hmm_mirror
+	 *
+	 * @mirror: pointer to struct hmm_mirror
+	 *
+	 * This is called when the mm_struct is being released.
+	 * The callback should make sure no references to the mirror occur
+	 * after the callback returns.
+	 */
+	void (*release)(struct hmm_mirror *mirror);
+
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
diff --git a/mm/hmm.c b/mm/hmm.c
index 320545b98ff5..6088fa6ed137 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -160,6 +160,21 @@ static void hmm_invalidate_range(struct hmm *hmm,
 	up_read(&hmm->mirrors_sem);
 }
 
+static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct hmm *hmm = mm->hmm;
+	struct hmm_mirror *mirror;
+	struct hmm_mirror *mirror_next;
+
+	down_write(&hmm->mirrors_sem);
+	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
+		list_del_init(&mirror->list);
+		if (mirror->ops->release)
+			mirror->ops->release(mirror);
+	}
+	up_write(&hmm->mirrors_sem);
+}
+
 static void hmm_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
 				       unsigned long start,
@@ -185,6 +200,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
+	.release		= hmm_release,
 	.invalidate_range_start	= hmm_invalidate_range_start,
 	.invalidate_range_end	= hmm_invalidate_range_end,
 };
@@ -230,7 +246,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
-	list_del(&mirror->list);
+	list_del_init(&mirror->list);
 	up_write(&hmm->mirrors_sem);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
-- 
2.14.3

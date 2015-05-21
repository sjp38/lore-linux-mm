Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C3F066B01A3
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:05 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so96885630wgf.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c8si5220673wjw.93.2015.05.21.13.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:02 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 22/36] HMM: add new callback for copying memory from and to device memory.
Date: Thu, 21 May 2015 16:22:58 -0400
Message-Id: <1432239792-5002-3-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Jerome Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: Jerome Glisse <jglisse@redhat.com>

This patch only adds the new callback device driver must implement
to copy memory from and to device memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h | 103 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/hmm.c            |   2 +
 2 files changed, 105 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f243eb5..eb30418 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -66,6 +66,8 @@ enum hmm_etype {
 	HMM_DEVICE_RFAULT,
 	HMM_DEVICE_WFAULT,
 	HMM_WRITE_PROTECT,
+	HMM_COPY_FROM_DEVICE,
+	HMM_COPY_TO_DEVICE,
 };
 
 /* struct hmm_event - memory event information.
@@ -157,6 +159,107 @@ struct hmm_device_ops {
 	 * All other return value trigger warning and are transformed to -EIO.
 	 */
 	int (*update)(struct hmm_mirror *mirror,const struct hmm_event *event);
+
+	/* copy_from_device() - copy from device memory to system memory.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @event: The event that triggered the copy.
+	 * @dst: Array containing hmm_pte of destination memory.
+	 * @start: Start address of the range (sub-range of event) to copy.
+	 * @end: End address of the range (sub-range of event) to copy.
+	 * Returns: 0 on success, error code otherwise {-ENOMEM, -EIO}.
+	 *
+	 * Called when migrating memory from device memory to system memory.
+	 * The dst array contains valid DMA address for the device of the page
+	 * to copy to (or pfn of page if hmm_device.device == NULL).
+	 *
+	 * If event.etype == HMM_FORK then device driver only need to schedule
+	 * a copy to the system pages given in the dst hmm_pte array. Do not
+	 * update the device page, and do not pause/stop the device threads
+	 * that are using this address space. Just copy memory.
+	 *
+	 * If event.type == HMM_COPY_FROM_DEVICE then device driver must first
+	 * write protect the range then schedule the copy, then update its page
+	 * table to use the new system memory given the dst array. Some device
+	 * can perform all this in an atomic fashion from device point of view.
+	 * The device driver must also free the device memory once the copy is
+	 * done.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill and CPU page table set to HWPOISON entry.
+	 *
+	 * Note that device driver must clear the valid bit of the dst entry it
+	 * failed to copy.
+	 *
+	 * On failure the mirror will be kill by HMM which will do a HMM_MUNMAP
+	 * invalidation of all the memory when this happen the device driver
+	 * can free the device memory.
+	 *
+	 * Note also that there can be hole in the range being copied ie some
+	 * entry of dst array will not have the valid bit set, device driver
+	 * must simply ignore non valid entry.
+	 *
+	 * Finaly device driver must set the dirty bit for each page that was
+	 * modified since it was copied inside the device memory. This must be
+	 * conservative ie if device can not determine that with certainty then
+	 * it must set the dirty bit unconditionally.
+	 *
+	 * Return 0 on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*copy_from_device)(struct hmm_mirror *mirror,
+				const struct hmm_event *event,
+				dma_addr_t *dst,
+				unsigned long start,
+				unsigned long end);
+
+	/* copy_to_device() - copy to device memory from system memory.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @event: The event that triggered the copy.
+	 * @dst: Array containing hmm_pte of destination memory.
+	 * @start: Start address of the range (sub-range of event) to copy.
+	 * @end: End address of the range (sub-range of event) to copy.
+	 * Returns: 0 on success, error code otherwise {-ENOMEM, -EIO}.
+	 *
+	 * Called when migrating memory from system memory to device memory.
+	 * The dst array is empty, all of its entry are equal to zero. Device
+	 * driver must allocate the device memory and populate each entry using
+	 * hmm_pte_from_device_pfn() only the valid device bit and hardware
+	 * specific bit will be preserve (write and dirty will be taken from
+	 * the original entry inside the mirror page table). It is advice to
+	 * set the device pfn to match the physical address of device memory
+	 * being use. The event.etype will be equals to HMM_COPY_TO_DEVICE.
+	 *
+	 * Device driver that can atomically copy a page and update its page
+	 * table entry to point to the device memory can do that. Partial
+	 * failure is allowed, entry that have not been migrated must have
+	 * the HMM_PTE_VALID_DEV bit clear inside the dst array. HMM will
+	 * update the CPU page table of failed entry to point back to the
+	 * system page.
+	 *
+	 * Note that device driver is responsible for allocating and freeing
+	 * the device memory and properly updating to dst array entry with
+	 * the allocated device memory.
+	 *
+	 * Return 0 on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 * Errors means that the migration is aborted. So in case of partial
+	 * failure if device do not want to fully abort it must return 0.
+	 * Device driver can update device page table only if it knows it will
+	 * not return failure.
+	 */
+	int (*copy_to_device)(struct hmm_mirror *mirror,
+			      const struct hmm_event *event,
+			      dma_addr_t *dst,
+			      unsigned long start,
+			      unsigned long end);
 };
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index e4585b7..9dbb1e43 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -87,6 +87,8 @@ static inline int hmm_event_init(struct hmm_event *event,
 	case HMM_ISDIRTY:
 	case HMM_DEVICE_RFAULT:
 	case HMM_DEVICE_WFAULT:
+	case HMM_COPY_TO_DEVICE:
+	case HMM_COPY_FROM_DEVICE:
 		break;
 	case HMM_FORK:
 	case HMM_WRITE_PROTECT:
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

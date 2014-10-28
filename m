Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id CDAB3900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:14:24 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gq15so1019269lab.7
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:14:23 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id u5si3411795laj.135.2014.10.28.10.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 10:14:20 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 1/3] mmu_notifier: Add mmu_notifier_invalidate_range()
Date: Tue, 28 Oct 2014 18:13:58 +0100
Message-Id: <1414516440-910-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1414516440-910-1-git-send-email-joro@8bytes.org>
References: <1414516440-910-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

This notifier closes an important gap in the current
mmu_notifier implementation, the existing call-backs are
called too early or too late to reliably manage a non-CPU
TLB.  Specifically, invalidate_range_start() is called when
all pages are still mapped and invalidate_range_end() when
all pages are unmapped and potentially freed.

This is fine when the users of the mmu_notifiers manage
their own SoftTLB, like KVM does. When the TLB is managed in
software it is easy to wipe out entries for a given range
and prevent new entries to be established until
invalidate_range_end is called.

But when the user of mmu_notifiers has to manage a hardware
TLB it can still wipe out TLB entries in
invalidate_range_start, but it can't make sure that no new
TLB entries in the given range are established between
invalidate_range_start and invalidate_range_end.

To avoid silent data corruption the entries in the non-CPU
TLB need to be flushed when the pages are unmapped (at this
point in time no _new_ TLB entries can be established in the
non-CPU TLB) but not yet freed (as the non-CPU TLB may still
have _existing_ entries pointing to the pages about to be
freed).

To fix this problem we need to catch the moment when the
Linux VMM flushes remote TLBs (as a non-CPU TLB is not very
different in its flushing requirements from any other remote
CPU TLB), as this is the point in time when the pages are
unmapped but _not_ yet freed.

The mmu_notifier_invalidate_range() function aims to catch
that moment.

IOMMU code will be one user of the notifier-callback.
Currently this is only the AMD IOMMUv2 driver, but its code
is about to be more generalized and converted to a generic
IOMMU-API extension to fit the needs of similar
functionality in other IOMMUs as well.

The current attempt in the AMD IOMMUv2 driver to work around
the invalidate_range_start/end() shortcoming is to assign an
empty page table to the non-CPU TLB between any
invalidata_range_start/end calls. With the empty page-table
assigned, every page-table walk to re-fill the non-CPU TLB
will cause a page-fault reported to the IOMMU driver via an
interrupt, possibly causing interrupt storms.

The page-fault handler in the AMD IOMMUv2 driver doesn't
handle the fault if an invalidate_range_start/end pair is
active, it just reports back SUCESS to the device and let it
refault the page. But existing hardware (newer Radeon GPUs)
that makes use of this feature don't re-fault indefinitly,
after a certain number of faults for the same address the
device enters a failure state and needs to be resetted.

To avoid the GPUs entering a failure state we need to get
rid of the empty-page-table workaround and use the
mmu_notifier_invalidate_range() function introduced with
this patch.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 include/linux/mmu_notifier.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 88787bb..1790790 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -242,6 +242,11 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		__mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 	mm->mmu_notifier_mm = NULL;
@@ -342,6 +347,11 @@ static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 }
 
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 }
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

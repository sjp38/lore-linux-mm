Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68DDD6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:35:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q62so373005367oih.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:35:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y25si3764825ioi.188.2016.08.02.08.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 08:35:04 -0700 (PDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] x86/mm: Add barriers and document switch_mm()-vs-flush synchronization follow-up
Date: Tue,  2 Aug 2016 11:34:49 -0400
Message-Id: <88fb045963d1e51cd14c05c9c4d283a1ccd29c80.1470151425.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, luto@kernel.org, aarcange@redhat.com, lwoodman@redhat.com, riel@redhat.com, mgorman@suse.de, akpm@linux-foundation.org

While backporting 71b3c126e611 ("x86/mm: Add barriers and document switch_mm()-vs-flush synchronization")
we stumbled across a possibly missing barrier at flush_tlb_page().

Following the reasoning presented while introducing the synchronization
barrier at flush_tlb_mm_range(), for the current->active_mm != mm checkpoint:

        if (current->active_mm != mm) {
                /* Synchronize with switch_mm. */
                smp_mb();

                goto out;
        }

it suggests the same barrier should be introduced for the similar
outcome at flush_tlb_page(). This patch add that mentioned missing
barrier and documents its case.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 arch/x86/mm/tlb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 4dbe656..3b4addc 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -375,6 +375,12 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 			/* Synchronize with switch_mm. */
 			smp_mb();
 		}
+	} else {
+		/*
+		 * current->active_mm != mm
+		 * Synchronize with switch_mm.
+		 */
+		smp_mb();
 	}
 
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

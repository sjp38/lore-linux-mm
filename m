Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C92116B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:29:09 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id l13so39488654itl.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:29:09 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a76si5579095pfc.86.2016.10.11.13.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 13:29:08 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Don't touch single threaded PTEs which are on the right node
Date: Tue, 11 Oct 2016 13:28:58 -0700
Message-Id: <1476217738-10451-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

We had some problems with pages getting unmapped in single threaded
affinitized processes. It was tracked down to NUMA scanning.

In this case it doesn't make any sense to unmap pages if the
process is single threaded and the page is already on the
node the process is running on.

Add a check for this case into the numa protection code,
and skip unmapping if true.

In theory the process could be migrated later, but we
will eventually rescan and unmap and migrate then.

In theory this could be made more fancy: remembering this
state per process or even whole mm. However that would
need extra tracking and be more complicated, and the
simple check seems to work fine so far.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/mprotect.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index a4830f0325fe..e8028658e817 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -94,6 +94,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
+
+				/*
+				 * Don't mess with PTEs if page is already on the node
+				 * a single-threaded process is running on.
+				 */
+				if (atomic_read(&vma->vm_mm->mm_users) == 1 &&
+				    cpu_to_node(raw_smp_processor_id()) == page_to_nid(page))
+					continue;
 			}
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

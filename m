Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 873816B005C
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:09:04 -0400 (EDT)
Date: Thu, 27 Aug 2009 19:07:20 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv5 2/3] mm: reduce atomic use on use_mm fast path
Message-ID: <20090827160720.GC23722@redhat.com>
References: <cover.1251388414.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1251388414.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

When mm switched to matches that of active mm, we don't need to
increment and then drop the mm count. Making that conditional reduces
contention on that cache line on SMP systems.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/mmu_context.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 9989c2f..0777654 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -27,13 +27,16 @@ void use_mm(struct mm_struct *mm)
 
 	task_lock(tsk);
 	active_mm = tsk->active_mm;
-	atomic_inc(&mm->mm_count);
+	if (active_mm != mm) {
+		atomic_inc(&mm->mm_count);
+		tsk->active_mm = mm;
+	}
 	tsk->mm = mm;
-	tsk->active_mm = mm;
 	switch_mm(active_mm, mm, tsk);
 	task_unlock(tsk);
 
-	mmdrop(active_mm);
+	if (active_mm != mm)
+		mmdrop(active_mm);
 }
 EXPORT_SYMBOL_GPL(use_mm);
 
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0D736B0253
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 17:12:01 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y200so16288924itc.7
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 14:12:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b63sor4887726ioe.123.2017.12.11.14.12.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 14:12:01 -0800 (PST)
Date: Mon, 11 Dec 2017 14:11:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, oom: avoid reaping only for mm's with blockable
 invalidate callbacks
In-Reply-To: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1712111411290.196232@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This uses the new annotation to determine if an mm has mmu notifiers with
blockable invalidate range callbacks to avoid oom reaping.  Otherwise, the
callbacks are used around unmap_page_range().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -514,15 +514,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * If the mm has notifiers then we would need to invalidate them around
-	 * unmap_page_range and that is risky because notifiers can sleep and
-	 * what they do is basically undeterministic.  So let's have a short
+	 * If the mm has invalidate_{start,end}() notifiers that could block,
 	 * sleep to give the oom victim some more time.
 	 * TODO: we really want to get rid of this ugly hack and make sure that
-	 * notifiers cannot block for unbounded amount of time and add
-	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range
+	 * notifiers cannot block for unbounded amount of time
 	 */
-	if (mm_has_notifiers(mm)) {
+	if (mm_has_blockable_invalidate_notifiers(mm)) {
 		up_read(&mm->mmap_sem);
 		schedule_timeout_idle(HZ);
 		goto unlock_oom;
@@ -565,10 +562,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		 * count elevated without a good reason.
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
-			tlb_gather_mmu(&tlb, mm, vma->vm_start, vma->vm_end);
-			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
-					 NULL);
-			tlb_finish_mmu(&tlb, vma->vm_start, vma->vm_end);
+			const unsigned long start = vma->vm_start;
+			const unsigned long end = vma->vm_end;
+
+			tlb_gather_mmu(&tlb, mm, start, end);
+			mmu_notifier_invalidate_range_start(mm, start, end);
+			unmap_page_range(&tlb, vma, start, end, NULL);
+			mmu_notifier_invalidate_range_end(mm, start, end);
+			tlb_finish_mmu(&tlb, start, end);
 		}
 	}
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

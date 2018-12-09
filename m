Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2E598E0004
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 02:21:44 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so7219427pfa.1
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 23:21:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor12206425pgv.69.2018.12.08.23.21.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Dec 2018 23:21:43 -0800 (PST)
From: gchen.guomin@gmail.com
Subject: [PATCH]  Fix mm->owner point to a task that does not exists
Date: Sun,  9 Dec 2018 15:21:17 +0800
Message-Id: <1544340077-11491-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: guominchen <guominchen@tencent.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org

From: guominchen <guominchen@tencent.com>

  Under normal circumstances,When do_exit exits, mm->owner will
  be updated, but when the kernel process calls unuse_mm and exits,
  mm->owner cannot be updated. And will point to a task that has
  been released.

  Below is my issue on vhost_net:
    A, B are two kernel processes(such as vhost_worker),
    C is a user space process(such as qemu), and all
    three use the mm of the user process C.
    Now, because user process C exits abnormally, the owner of this
    mm becomes A. When A calls unuse_mm and exits, this mm->ower
    still points to the A that has been released.
    When B accesses this mm->owner again, A has been released.

  Process A		Process B
 vhost_worker()	       vhost_worker()
  ---------    		---------
  use_mm()		use_mm()
   ...
  unuse_mm()
     tsk->mm=NULL
   do_exit()     	page fault
    exit_mm()	 	access mm->owner
   can't update owner	kernel Oops

			unuse_mm()

Cc: <linux-mm@kvack.org>
Cc: <linux-kernel@vger.kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: <netdev@vger.kernel.org>
Signed-off-by: guominchen <guominchen@tencent.com>
---
 mm/mmu_context.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 3e612ae..185bb23 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -56,7 +56,6 @@ void unuse_mm(struct mm_struct *mm)
 
 	task_lock(tsk);
 	sync_mm_rss(mm);
-	tsk->mm = NULL;
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);
 	task_unlock(tsk);
-- 
1.8.3.1

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C68E18E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 22:42:50 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h11so13927491pfj.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 19:42:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor23036310pgk.84.2018.12.17.19.42.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 19:42:49 -0800 (PST)
From: gchen.guomin@gmail.com
Subject: [PATCH] Export mm_update_next_owner function for unuse_mm.
Date: Tue, 18 Dec 2018 11:42:11 +0800
Message-Id: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, guominchen@tencent.com
Cc: guomin chen <gchen.guomin@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: guomin chen <gchen.guomin@gmail.com>

When mm->owner is modified by exit_mm, if the new owner directly calls
unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
directly sets tsk->mm=NULL.

 Under normal circumstances,When do_exit exits, mm->owner will
 be updated on exit_mm(). but when the kernel process calls
 unuse_mm() and then exits,mm->owner cannot be updated. And it
 will point to a task that has been released.

The current issue flow is as follows:
Process C              Process A         Process B
qemu-system-x86_64:     kernel:vhost_net  kernel: vhost_net
open /dev/vhost-net
  VHOST_SET_OWNER   create kthread vhost-%d  create kthread vhost-%d
  network init           use_mm()          use_mm()
   ...                   ...
   Abnormal exited
   ...
  do_exit
  exit_mm()
  update mm->owner to A
  exit_files()
   close_files()
   kthread_should_stop() unuse_mm()
    Stop Process A       tsk->mm=NULL
                         do_exit()
                         can't update owner
                         A exit completed  vhost-%d  rcv first package
                                           vhost-%d build rcv buffer for vq
                                           page fault
                                           access mm & mm->owner
                                           NOW,mm->owner still pointer A
                                           kernel UAF
    stop Process B

Although I am having this issue on vhost_net,But it affects all users of
unuse_mm.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: guomin chen <gchen.guomin@gmail.com>
---
 kernel/exit.c    | 1 +
 mm/mmu_context.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/kernel/exit.c b/kernel/exit.c
index 0e21e6d..9e046dd 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -486,6 +486,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 	task_unlock(c);
 	put_task_struct(c);
 }
+EXPORT_SYMBOL(mm_update_next_owner);
 #endif /* CONFIG_MEMCG */
 
 /*
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 3e612ae..9eb81aa 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);
 	task_unlock(tsk);
+	mm_update_next_owner(mm);
 }
 EXPORT_SYMBOL_GPL(unuse_mm);
-- 
1.8.3.1

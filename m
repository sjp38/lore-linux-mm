Return-Path: <linux-kernel-owner@vger.kernel.org>
From: gchen.guomin@gmail.com
Subject: [PATCH] Fix mm->owner point to a tsk that has been free
Date: Tue, 18 Dec 2018 13:24:44 +0800
Message-Id: <1545110684-8730-1-git-send-email-gchen.guomin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, guominchen@tencent.com
Cc: guomin chen <gchen.guomin@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: guomin chen <gchen.guomin@gmail.com>

When mm->owner is modified by exit_mm, if the new owner directly calls
unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
directly sets tsk->mm=NULL.

 Under normal circumstances,When do_exit exits, mm->owner will
 be updated on exit_mm(). but when the kernel process calls
 unuse_mm() and then exits,mm->owner cannot be updated. And it
 will point to a task that has been released.

The current issue flow is as follows: (Process A,B,C use the same mm)
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
 mm/mmu_context.c | 1 +
 1 file changed, 1 insertion(+)

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

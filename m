Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 11A276B072B
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:34:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o201so4865610wmg.3
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:34:02 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id x7si3070665ede.330.2017.08.04.01.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 01:34:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id x64so4897828wmg.1
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:34:00 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: fix double mmap_sem unlock on MMF_UNSTABLE enforced SIGBUS
Date: Fri,  4 Aug 2017 10:33:49 +0200
Message-Id: <20170804083350.470-1-mhocko@kernel.org>
In-Reply-To: <20170804083205.GH26029@dhcp22.suse.cz>
References: <20170804083205.GH26029@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has noticed that MMF_UNSTABLE SIGBUS path in
handle_mm_fault causes a lockdep splat
[   58.539455] Out of memory: Kill process 1056 (a.out) score 603 or sacrifice child
[   58.543943] Killed process 1056 (a.out) total-vm:4268108kB, anon-rss:2246048kB, file-rss:0kB, shmem-rss:0kB
[   58.544245] a.out (1169) used greatest stack depth: 11664 bytes left
[   58.557471] DEBUG_LOCKS_WARN_ON(depth <= 0)
[   58.557480] ------------[ cut here ]------------
[   58.564407] WARNING: CPU: 6 PID: 1339 at kernel/locking/lockdep.c:3617 lock_release+0x172/0x1e0
[   58.599401] CPU: 6 PID: 1339 Comm: a.out Not tainted 4.13.0-rc3-next-20170803+ #142
[   58.604126] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   58.609790] task: ffff9d90df888040 task.stack: ffffa07084854000
[   58.613944] RIP: 0010:lock_release+0x172/0x1e0
[   58.617622] RSP: 0000:ffffa07084857e58 EFLAGS: 00010082
[   58.621533] RAX: 000000000000001f RBX: ffff9d90df888040 RCX: 0000000000000000
[   58.626074] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffffa30d4ba4
[   58.630572] RBP: ffffa07084857e98 R08: 0000000000000000 R09: 0000000000000001
[   58.635016] R10: 0000000000000000 R11: 000000000000001f R12: ffffa07084857f58
[   58.639694] R13: ffff9d90f60d6cd0 R14: 0000000000000000 R15: ffffffffa305cb6e
[   58.644200] FS:  00007fb932730740(0000) GS:ffff9d90f9f80000(0000) knlGS:0000000000000000
[   58.648989] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   58.652903] CR2: 000000000040092f CR3: 0000000135229000 CR4: 00000000000606e0
[   58.657280] Call Trace:
[   58.659989]  up_read+0x1a/0x40
[   58.662825]  __do_page_fault+0x28e/0x4c0
[   58.665946]  do_page_fault+0x30/0x80
[   58.668911]  page_fault+0x28/0x30

The reason is that the page fault path might have dropped the mmap_sem
and returned with VM_FAULT_RETRY. MMF_UNSTABLE check however rewrites
the error path to VM_FAULT_SIGBUS and we always expect mmap_sem taken in
that path. Fix this by taking mmap_sem when VM_FAULT_RETRY is held in
the MMF_UNSTABLE path. We cannot simply add VM_FAULT_SIGBUS to the
existing error code because all arch specific page fault handlers and
g-u-p would have to learn a new error code combination.

Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Fixes: 3f70dc38cec2 ("mm: make sure that kthreads will not refault oom reaped memory")
Cc: stable # 4.9+
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 0e517be91a89..4fe5b6254688 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3881,8 +3881,18 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	 * further.
 	 */
 	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
-				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
+				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
+
+		/*
+		 * We are going to enforce SIGBUS but the PF path might have
+		 * dropped the mmap_sem already so take it again so that
+		 * we do not break expectations of all arch specific PF paths
+		 * and g-u-p
+		 */
+		if (ret & VM_FAULT_RETRY)
+			down_read(&vma->vm_mm->mmap_sem);
 		ret = VM_FAULT_SIGBUS;
+	}
 
 	return ret;
 }
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

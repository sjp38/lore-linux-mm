Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 568666B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:55:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so20948549pfb.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:55:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f67si1647523pff.317.2017.03.24.03.55.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 03:55:22 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
Date: Fri, 24 Mar 2017 19:53:28 +0900
Message-Id: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Jisheng Zhang <jszhang@marvell.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joel Fernandes <joelaf@google.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>

Commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem
as potentially sleeping") added might_sleep() to remove_vm_area() from
vfree(), and is causing

[    2.616064] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
[    2.616125] in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
[    2.616156] 2 locks held by plymouthd/341:
[    2.616158]  #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
[    2.616256]  #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
[    2.616270] CPU: 2 PID: 341 Comm: plymouthd Not tainted 4.11.0-0.rc3.git0.1.kmallocwd.fc25.x86_64+debug #1
[    2.616271] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[    2.616273] Call Trace:
[    2.616281]  dump_stack+0x86/0xc3
[    2.616285]  ___might_sleep+0x17d/0x250
[    2.616289]  __might_sleep+0x4a/0x80
[    2.616293]  remove_vm_area+0x22/0x90
[    2.616296]  __vunmap+0x2e/0x110
[    2.616299]  vfree+0x42/0x90
[    2.616304]  kvfree+0x2c/0x40
[    2.616312]  drm_ht_remove+0x1a/0x30 [drm]
[    2.616317]  ttm_object_file_release+0x50/0x90 [ttm]
[    2.616324]  vmw_postclose+0x47/0x60 [vmwgfx]
[    2.616331]  drm_release+0x290/0x3b0 [drm]
[    2.616338]  __fput+0xf8/0x210
[    2.616342]  ____fput+0xe/0x10
[    2.616345]  task_work_run+0x85/0xc0
[    2.616351]  exit_to_usermode_loop+0xb4/0xc0
[    2.616355]  do_syscall_64+0x185/0x1f0
[    2.616359]  entry_SYSCALL64_slow_path+0x25/0x25

warning.

But commit f9e09977671b618a ("mm: turn vmap_purge_lock into a mutex") did
not make vfree() potentially sleeping because try_purge_vmap_area_lazy()
is still using mutex_trylock(). Thus, this is a false positive warning.

___might_sleep() via cond_resched_lock() in __purge_vmap_area_lazy() from
try_purge_vmap_area_lazy() from free_vmap_area_noflush() from
free_unmap_vmap_area() from remove_vm_area() which might trigger same
false positive warning is remaining. But so far we haven't heard about
warning from that path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jisheng Zhang <jszhang@marvell.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: John Dias <joaodias@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
---
 mm/vmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 68eb002..32be3c4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1477,8 +1477,6 @@ struct vm_struct *remove_vm_area(const void *addr)
 {
 	struct vmap_area *va;
 
-	might_sleep();
-
 	va = find_vmap_area((unsigned long)addr);
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

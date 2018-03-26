Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 258AB6B000E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 06:19:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a4so10935011pff.2
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 03:19:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c2-v6si14052373plo.116.2018.03.26.03.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 03:19:19 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] lockdep: Show address of "struct lockdep_map" at print_lock().
Date: Mon, 26 Mar 2018 19:18:33 +0900
Message-Id: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Borislav Petkov <bp@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Thomas Gleixner <tglx@linutronix.de>

Currently, print_lock() is printing hlock->acquire_ip field in both
"[<%px>]" and "%pS" format. But "[<%px>]" is little useful nowadays, for
we use scripts/faddr2line which receives "%pS" for finding the location
in the source code.

Since "struct lockdep_map" is embedded into lock objects, we can know
which instance of a lock object is acquired using hlock->instance field.
This will help finding which threads are causing a lock contention when
e.g. the OOM reaper failed to acquire an OOM victim's mmap_sem for read.

Thus, this patch replaces "[<%px>]" for printing hlock->acquire_ip field
with "[%px]" for printing hlock->instance field.

----------------------------------------
[  561.490202] Out of memory: Kill process 58945 (anacron) score 0 or sacrifice child
[  561.494119] Killed process 58945 (anacron) total-vm:123220kB, anon-rss:232kB, file-rss:4kB, shmem-rss:0kB
(...snipped...)
[  562.208348] Out of memory: Kill process 636 (atd) score 0 or sacrifice child
[  562.212077] Killed process 636 (atd) total-vm:25868kB, anon-rss:204kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  562.944890] Out of memory: Kill process 971 (agetty) score 0 or sacrifice child
[  562.948586] Killed process 971 (agetty) total-vm:110056kB, anon-rss:124kB, file-rss:4kB, shmem-rss:0kB
(...snipped...)
[  563.599714] Out of memory: Kill process 116521 (a.out) score 0 or sacrifice child
[  563.603599] Killed process 118444 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  564.664223] oom_reaper: unable to reap pid:118444 (a.out)
[  564.667311]
[  564.667311] Showing all locks held in the system:
(...snipped...)
[  564.731611] 1 lock held by kswapd0/76:
[  564.734415]  #0: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  564.864860] 1 lock held by atd/636:
[  564.868524]  #0: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
[  564.874354] 1 lock held by agetty/971:
[  564.878085]  #0: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  564.977497] 1 lock held by anacron/58945:
[  564.981365]  #0: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  569.866283] 3 locks held by a.out/118444:
[  569.869992]  #0: [ffffa3b4df1c0c88] (&mm->mmap_sem){++++}, at: copy_process.part.40+0x1090/0x1fa0
[  569.876392]  #1: [ffffa3b4dfeaae48] (&mm->mmap_sem/1){+.+.}, at: copy_process.part.40+0x10b9/0x1fa0
[  569.882393]  #2: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.40+0x12ad/0x1fa0
(...snipped...)
[  581.237572] 3 locks held by a.out/121276:
[  581.241318]  #0: [ffffa3b40cd071c8] (&mm->mmap_sem){++++}, at: copy_process.part.40+0x1090/0x1fa0
[  581.247326]  #1: [ffffa3b465bb44c8] (&mm->mmap_sem/1){+.+.}, at: copy_process.part.40+0x10b9/0x1fa0
[  581.253370]  #2: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  589.357139] 1 lock held by a.out/122960:
[  589.363224]  #0: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  594.255168] 3 locks held by a.out/124002:
[  594.258956]  #0: [ffffa3b42fead008] (&mm->mmap_sem){++++}, at: copy_process.part.40+0x1090/0x1fa0
[  594.265047]  #1: [ffffa3b4e7b52308] (&mm->mmap_sem/1){+.+.}, at: copy_process.part.40+0x10b9/0x1fa0
[  594.271051]  #2: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.40+0x12ad/0x1fa0
(...snipped...)
[  594.286952] 3 locks held by a.out/124004:
[  594.290884]  #0: [ffffa3b42feac4c8] (&mm->mmap_sem){++++}, at: copy_process.part.40+0x1090/0x1fa0
[  594.296956]  #1: [ffffa3b3db86db48] (&mm->mmap_sem/1){+.+.}, at: copy_process.part.40+0x10b9/0x1fa0
[  594.303139]  #2: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  604.765878] 2 locks held by a.out/126388:
[  604.769899]  #0: [ffffa3b3c70cb988] (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
[  604.775890]  #1: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  614.240787] 2 locks held by a.out/128585:
[  614.244655]  #0: [ffffa3b461e1a308] (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
[  614.250489]  #1: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
(...snipped...)
[  628.863629] 2 locks held by a.out/1165:
[  628.867533]  #0: [ffffa3b438472e48] (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
[  628.873570]  #1: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0
----------------------------------------

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 kernel/locking/lockdep.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 12a2805..7835233 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -556,9 +556,9 @@ static void print_lock(struct held_lock *hlock)
 		return;
 	}
 
+	printk(KERN_CONT "[%px]", hlock->instance);
 	print_lock_name(lock_classes + class_idx - 1);
-	printk(KERN_CONT ", at: [<%px>] %pS\n",
-		(void *)hlock->acquire_ip, (void *)hlock->acquire_ip);
+	printk(KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
 }
 
 static void lockdep_print_held_locks(struct task_struct *curr)
-- 
1.8.3.1

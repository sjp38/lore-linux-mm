Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 639B26B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 06:28:30 -0400 (EDT)
Received: by mail-oi0-f48.google.com with SMTP id s79so52267927oie.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 03:28:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 62si755969oto.115.2016.04.06.03.28.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 03:28:29 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
	<201604052012.IGJ69231.VFtMSHFJOOLOFQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201604052012.IGJ69231.VFtMSHFJOOLOFQ@I-love.SAKURA.ne.jp>
Message-Id: <201604061928.EGC17674.OFFSMOtFVQLJOH@I-love.SAKURA.ne.jp>
Date: Wed, 6 Apr 2016 19:28:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

This ext4 livelock case shows a race window which commit 36324a990cf5
("oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space")
did not care about.

----------
[  186.620979] Out of memory: Kill process 4458 (file_io.24) score 997 or sacrifice child
[  186.627897] Killed process 4458 (file_io.24) total-vm:4336kB, anon-rss:116kB, file-rss:1024kB, shmem-rss:0kB
[  186.688345] oom_reaper: reaped process 4458 (file_io.24), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

[  245.572082] MemAlloc: file_io.24(4715) flags=0x400040 switches=8650 uninterruptible dying victim
[  245.578876] file_io.24      D 0000000000000000     0  4715      1 0x00100084
[  245.584122]  ffff88002fd9c000 ffff88002fda4000 ffff880036221870 00000000000035a2
[  245.589618]  0000000000000000 ffff880036221870 0000000000000000 ffffffff81587dec
[  245.595428]  ffff880036221800 ffffffff8123b821 0000000000000000 ffff88002fd9c000
[  245.601370] Call Trace:
[  245.603428]  [<ffffffff81587dec>] ? schedule+0x2c/0x80
[  245.607680]  [<ffffffff8123b821>] ? wait_transaction_locked+0x81/0xc0           /* linux-4.6-rc2/fs/jbd2/transaction.c:163 */
[  245.613586]  [<ffffffff810a1ee0>] ? wait_woken+0x80/0x80                        /* linux-4.6-rc2/kernel/sched/wait.c:292   */
[  245.618074]  [<ffffffff8123ba9a>] ? add_transaction_credits+0x21a/0x2a0         /* linux-4.6-rc2/fs/jbd2/transaction.c:191 */
[  245.623497]  [<ffffffff81178abc>] ? mem_cgroup_commit_charge+0x7c/0xf0
[  245.628352]  [<ffffffff8123bceb>] ? start_this_handle+0x18b/0x400               /* linux-4.6-rc2/fs/jbd2/transaction.c:357 */
[  245.632755]  [<ffffffff8110fb6e>] ? add_to_page_cache_lru+0x6e/0xd0
[  245.637274]  [<ffffffff8123c294>] ? jbd2__journal_start+0xf4/0x190              /* linux-4.6-rc2/fs/jbd2/transaction.c:459 */
[  245.642298]  [<ffffffff81205ca4>] ? ext4_da_write_begin+0x114/0x360             /* linux-4.6-rc2/fs/ext4/inode.c:2883      */
[  245.647035]  [<ffffffff8111116e>] ? generic_perform_write+0xce/0x1d0            /* linux-4.6-rc2/mm/filemap.c:2639         */
[  245.651651]  [<ffffffff8119c440>] ? file_update_time+0xc0/0x110
[  245.656166]  [<ffffffff81111f2d>] ? __generic_file_write_iter+0x16d/0x1c0       /* linux-4.6-rc2/mm/filemap.c:2765         */
[  245.660835]  [<ffffffff811fbafa>] ? ext4_file_write_iter+0x12a/0x340            /* linux-4.6-rc2/fs/ext4/file.c:170        */
[  245.665292]  [<ffffffff810226ad>] ? __switch_to+0x20d/0x3f0
[  245.669604]  [<ffffffff81182ddb>] ? __vfs_write+0xcb/0x100
[  245.673904]  [<ffffffff81183968>] ? vfs_write+0x98/0x190
[  245.678174]  [<ffffffff81184d2d>] ? SyS_write+0x4d/0xc0
[  245.682376]  [<ffffffff810034a7>] ? do_syscall_64+0x57/0xf0
[  245.686845]  [<ffffffff8158b1e1>] ? entry_SYSCALL64_slow_path+0x25/0x25
----------

ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from) {
  ret = __generic_file_write_iter(iocb, from) {
    written = generic_perform_write(file, from, iocb->ki_pos) {
      if (fatal_signal_pending(current)) {
        status = -EINTR;
        break;
      }
      status = a_ops->write_begin(file, mapping, pos, bytes, flags, &page, &fsdata) /* ext4_da_write_begin */ { /***** Event1 *****/
        handle = ext4_journal_start(inode, EXT4_HT_WRITE_PAGE, ext4_da_write_credits(inode, pos, len)) /* __ext4_journal_start */ {
          __ext4_journal_start_sb(inode->i_sb, line, type, blocks, rsv_blocks) {
            jbd2__journal_start(journal, blocks, rsv_blocks, GFP_NOFS, type, line) {
              err = start_this_handle(journal, handle, gfp_mask) {
                if (!journal->j_running_transaction) {
                  /*
                   * If __GFP_FS is not present, then we may be being called from
                   * inside the fs writeback layer, so we MUST NOT fail.
                   */
                  if ((gfp_mask & __GFP_FS) == 0)
                    gfp_mask |= __GFP_NOFAIL;
                  new_transaction = kmem_cache_zalloc(transaction_cache, gfp_mask); /***** Event2 *****/
                  if (!new_transaction)
                    return -ENOMEM;
                }
                /* We may have dropped j_state_lock - restart in that case */
                add_transaction_credits(journal, blocks, rsv_blocks) {
                  /*
                   * If the current transaction is locked down for commit, wait
                   * for the lock to be released.
                   */
                  if (t->t_state == T_LOCKED) { /***** Event3 *****/
                    wait_transaction_locked(journal); /***** Event4 *****/
                    return 1;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

Event1 ... The OOM killer sent SIGKILL to file_io.24(4715) because
           file_io.24(4715) was sharing memory with file_io.24(4458).

Event2 ... file_io.24(4715) silently got TIF_MEMDIE using a shortcut
           fatal_signal_pending(current) in out_of_memory() because
           kmem_cache_zalloc() is allowed to call out_of_memory() due to
           __GFP_NOFAIL.

Event3 ... The OOM reaper completed reaping memory used by file_io.24(4458)
           and marked file_io.24(4458) as no longer OOM-killable by now.
           But since the OOM reaper cleared TIF_MEMDIE from only
           file_io.24(4458), TIF_MEMDIE in file_io.24(4715) still remains.

Event4 ... file_io.24(4715) (which used GFP_NOFS | __GFP_NOFAIL) is waiting
           for kworker/u128:1(51) (which used GFP_NOFS) to complete wb_workfn.
           But both kworker/u128:1(51) (which used GFP_NOFS) and kworker/0:2(285)
           (which used GFP_NOIO) cannot make forward progress because the OOM
           reaper does not clear TIF_MEMDIE from file_io.24(4715), and the OOM
           killer does not select next OOM victim due to TIF_MEMDIE in
           file_io.24(4715).

If we remove these shortcuts and set TIF_MEMDIE to all OOM-killed threads
sharing the victim's memory at oom_kill_process() and clear TIF_MEMDIE from
all threads sharing the victim's memory at __oom_reap_task() (or do equivalent
thing using per a signal_struct flag or per a mm_struct flag or a timer), we
wouldn't have hit this race window. Thus, I say again, "I think that removing
these shortcuts is better." unless we add a guaranteed unlocking mechanism
like a timer.

Also, I again want to say that, making current thread's current allocation
request completed by giving TIF_MEMDIE does not guarantee that the current
thread will be able to arrive at do_exit() shortly. It is possible that
the current thread is blocked at unkillable wait if current allocation
succeeded.

Also, is it acceptable to make allocation requests by kworker/u128:1(51) and
kworker/0:2(285) fail because they are !__GFP_FS && !__GFP_NOFAIL when
file_io.24(4715) has managed to allocate memory for journal's transaction
using GFP_NOFS | __GFP_NOFAIL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

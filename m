Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5D936B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 19:35:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k82so4500091oih.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:35:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w65si1801812oia.341.2017.08.08.16.35.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 16:35:48 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when oom_reaper races with writer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170807113839.16695-1-mhocko@kernel.org>
	<20170807113839.16695-3-mhocko@kernel.org>
	<20170808174855.GK25347@redhat.com>
In-Reply-To: <20170808174855.GK25347@redhat.com>
Message-Id: <201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp>
Date: Wed, 9 Aug 2017 08:35:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Andrea Arcangeli wrote:
> Overall OOM killing to me was reliable also before the oom reaper was
> introduced.

I don't think so. We spent a lot of time in order to remove possible locations
which can lead to failing to invoke the OOM killer when out_of_memory() is called.

> 
> I just did a search in bz for RHEL7 and there's a single bugreport
> related to OOM issues but it's hanging in a non-ext4 filesystem, and
> not nested in alloc_pages (but in wait_for_completion) and it's not
> reproducible with ext4. And it's happening only in an artificial
> specific "eatmemory" stress test from QA, there seems to be zero
> customer related bugreports about OOM hangs.

Since RHEL7 changed default filesystem from ext4 to xfs, OOM related problems
became much easier to occur, for xfs involves many kernel threads where
TIF_MEMDIE based access to memory reserves cannot work among relevant threads.

Judging from my experience at a support center, it is too difficult for customers
to report OOM hangs. It requires customers to stand by in front of the console
twenty-four seven so that we get SysRq-t etc. whenever an OOM related problem is
suspected. We can't ask customers for such effort. There is no report does not mean
OOM hang is not occurring without artificial memory stress tests.

> 
> A couple of years ago I could trivially trigger OOM deadlocks on
> various ext4 paths that loops or use GFP_NOFAIL, but that was just a
> matter of letting GFP_NOIO/NOFS/NOFAIL kind of allocation go through
> memory reserves below the low watermark.
> 
> It is also fine to kill a few more processes in fact. It's not the end
> of the world if two tasks are killed because the first one couldn't
> reach exit_mmap without oom reaper assistance. The fs kind of OOM
> hangs in kernel threads are major issues if the whole filesystem in
> the journal or something tends to prevent a multitude of tasks to
> handle SIGKILL, so it has to be handled with reserves and it looked
> like it was working fine already.
> 
> The main point of the oom reaper nowadays is to free memory fast
> enough so a second task isn't killed as a false positive, but it's not
> like anybody will notice much of a difference if a second task is
> killed, it wasn't commonly happening either.

The OOM reaper does not need to free memory fast enough, for the OOM killer
does not select the second task for kill until the OOM reaper sets
MMF_OOM_SKIP or __mmput() sets MMF_OOM_SKIP.

I think that the main point of the OOM reaper nowadays are that
"how can we allow the OOM reaper to take mmap_sem for read (because
khugepaged might take mmap_sem of the OOM victim for write)"

----------
[  493.787997] Out of memory: Kill process 3163 (a.out) score 739 or sacrifice child
[  493.791708] Killed process 3163 (a.out) total-vm:4268108kB, anon-rss:2754236kB, file-rss:0kB, shmem-rss:0kB
[  494.838382] oom_reaper: unable to reap pid:3163 (a.out)
[  494.847768] 
[  494.847768] Showing all locks held in the system:
[  494.861357] 1 lock held by oom_reaper/59:
[  494.865903]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff9f0c202d>] debug_show_all_locks+0x3d/0x1a0
[  494.872934] 1 lock held by khugepaged/63:
[  494.877426]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f1d5a4d>] khugepaged+0x99d/0x1af0
[  494.884165] 3 locks held by kswapd0/75:
[  494.888628]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff9f16c638>] shrink_slab.part.44+0x48/0x2b0
[  494.894125]  #1:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
[  494.898328]  #2:  (&pag->pag_ici_reclaim_lock){+.+.-.}, at: [<ffffffffc03aeafd>] xfs_reclaim_inodes_ag+0x3ad/0x4d0 [xfs]
[  494.902703] 3 locks held by kworker/u128:31/387:
[  494.905404]  #0:  ("writeback"){.+.+.+}, at: [<ffffffff9f08ddcc>] process_one_work+0x1fc/0x480
[  494.909237]  #1:  ((&(&wb->dwork)->work)){+.+.+.}, at: [<ffffffff9f08ddcc>] process_one_work+0x1fc/0x480
[  494.913205]  #2:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
[  494.916954] 1 lock held by xfsaild/sda1/422:
[  494.919288]  #0:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffc03b8828>] xfs_ilock_nowait+0x148/0x240 [xfs]
[  494.923470] 1 lock held by systemd-journal/491:
[  494.926102]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
[  494.929942] 1 lock held by gmain/745:
[  494.932368]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
[  494.936505] 1 lock held by tuned/1009:
[  494.938856]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
[  494.942824] 2 locks held by agetty/982:
[  494.944900]  #0:  (&tty->ldisc_sem){++++.+}, at: [<ffffffff9f78503f>] ldsem_down_read+0x1f/0x30
[  494.948244]  #1:  (&ldata->atomic_read_lock){+.+...}, at: [<ffffffff9f4108bf>] n_tty_read+0xbf/0x8e0
[  494.952118] 1 lock held by sendmail/984:
[  494.954408]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
[  494.958370] 5 locks held by a.out/3163:
[  494.960544]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f05ca34>] __do_page_fault+0x154/0x4c0
[  494.964191]  #1:  (shrinker_rwsem){++++..}, at: [<ffffffff9f16c638>] shrink_slab.part.44+0x48/0x2b0
[  494.967922]  #2:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
[  494.971548]  #3:  (&pag->pag_ici_reclaim_lock){+.+.-.}, at: [<ffffffffc03ae7fe>] xfs_reclaim_inodes_ag+0xae/0x4d0 [xfs]
[  494.975644]  #4:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffc03b8580>] xfs_ilock+0xc0/0x1b0 [xfs]
[  494.979194] 1 lock held by a.out/3164:
[  494.981220]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
[  494.984448] 1 lock held by a.out/3165:
[  494.986554]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
[  494.989841] 1 lock held by a.out/3166:
[  494.992089]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
[  494.995388] 1 lock held by a.out/3167:
[  494.997420]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
----------

  collapse_huge_page at mm/khugepaged.c:1001
   (inlined by) khugepaged_scan_pmd at mm/khugepaged.c:1209
   (inlined by) khugepaged_scan_mm_slot at mm/khugepaged.c:1728
   (inlined by) khugepaged_do_scan at mm/khugepaged.c:1809
   (inlined by) khugepaged at mm/khugepaged.c:1854

and "how can we close race between checking MMF_OOM_SKIP and doing last alloc_page_from_freelist()
attempt (because that race allows needlessly selecting the second task for kill)" in addition to
"how can we close race between unmap_page_range() and the page faults with retry fallback".

> 
> Certainly it's preferable to get two tasks killed than corrupted core
> dumps or corrupted memory, so if oom reaper will stay we need to
> document how  we guarantee it's mutually exclusive against core dumping
> and it'd better not slowdown page fault fast paths considering it's
> possible to do so by arming page-less migration entries that can wait
> for sigkill to be delivered in do_swap_page.
> 
> It's a big hammer feature that is nice to have but doing it safely and
> without adding branches to the fast paths, is somewhat more complex
> than current code.

The subject of this thread is "how can we close race between unmap_page_range()
and the page faults with retry fallback". Are you suggesting that we should remove
the OOM reaper so that we don't need to change page faults and/or __mmput() paths?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

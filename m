Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 520856B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 14:36:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i143so33808518qke.14
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 11:36:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x70si3737113qka.487.2017.08.09.11.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 11:36:31 -0700 (PDT)
Date: Wed, 9 Aug 2017 20:36:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170809183626.GO25347@redhat.com>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <20170808174855.GK25347@redhat.com>
 <201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Wed, Aug 09, 2017 at 08:35:36AM +0900, Tetsuo Handa wrote:
> I don't think so. We spent a lot of time in order to remove possible locations
> which can lead to failing to invoke the OOM killer when out_of_memory() is called.

It's not clear the connection between failing to invoke the OOM killer
and the OOM reaper. I assume you mean failing to kill the task after
the OOM killer has been invoked through out_of_memory().

You should always see in the logs "%s: Kill process %d (%s) score %u
or sacrifice child\n", the invocation itself should never been an
issue and it's unrelated to the OOM reaper.

> Since RHEL7 changed default filesystem from ext4 to xfs, OOM related problems
> became much easier to occur, for xfs involves many kernel threads where
> TIF_MEMDIE based access to memory reserves cannot work among relevant threads.

I could reproduce similar issues where the TIF_MEMDIE task was hung on
fs locks hold by kernel threads in ext4 too but those should have been
solved by other means.

> Judging from my experience at a support center, it is too difficult for customers
> to report OOM hangs. It requires customers to stand by in front of the console
> twenty-four seven so that we get SysRq-t etc. whenever an OOM related problem is
> suspected. We can't ask customers for such effort. There is no report does not mean
> OOM hang is not occurring without artificial memory stress tests.

The printk above is likely to show in the logs after reboot, but I
agree in the cloud a node hanging on OOM is probably hidden and there
are all sort of management provisions possible to prevent hitting a
real OOM too. For example memcg.

Still having no apparent customer complains I think is significant
because it means they easily tackle the problem by other means, be it
watchdogs or they prevent it in the first place with memcg.

I'm not saying it's a minor issue, to me it's totally annoying if my
system hangs on OOM so it should be reliable in practice. I'm only not
sure if tacking the OOM issues with the big hammer that still cannot
guarantee anything 100%, is justified, considering the complexity it
brings to the VM core and there's still no guarantee of not hanging.

> The OOM reaper does not need to free memory fast enough, for the OOM killer
> does not select the second task for kill until the OOM reaper sets
> MMF_OOM_SKIP or __mmput() sets MMF_OOM_SKIP.

Right, there's no need to be fast there.

> I think that the main point of the OOM reaper nowadays are that
> "how can we allow the OOM reaper to take mmap_sem for read (because
> khugepaged might take mmap_sem of the OOM victim for write)"

The main point of the OOM reaper is to avoid killing more tasks. Not
just because it would be a false positive but also because even if we
kill more tasks, they may be all stuck on the same fs locks hold by
kernel threads that cannot be killed and loop asking for more memory.

So the OOM reaper tends to reduce the risk of OOM hangs but sure thing
it cannot guarantee perfection either.

Incidentally the OOM reaper still has a timeout where it gives up and
it moves to kill another task after the timeout.

khugepaged doesn't allocate memory while holding the mmap_sem for
writing.

It's not exactly clear how in the below dump khugepaged is the problem
because 3163 is also definitely holding the mmap_sem for reading and
it cannot release it independent of khugepaged. However khugepaged
could try to grab it for writing and the fairness provisions of the
rwsem would prevent down_read_trylock to go ahead.

There's nothing specific about khugepaged here, you can try to do a
pthread_create() to create a thread in your a.out program and then
call mmap munmap in a loop (no need to touch any memory). Eventually
you'll get the page fault in your a.out process holding the mmap_sem
for reading and the child thread trying to take it for writing. Which
should be enough to block the OOM reaper entirely with the child stuck
in D state.

I already have a patch in my tree that let exit_mmap and OOM reapear
to take down pagetables concurrently only serialized by the PT lock
(upstream the OOM reaper can only run before exit_mmap starts while
mm_users is still > 0). This lets the OOM reaper run even if mm_users
of the TIF_MEMDIE task already reached 0. However to avoid taking the
mmap_sem in __oom_reap_task_mm for reading you would need to do the
opposite of upstream and then it would only solve OOM hangs between
the last mmput and exit_mmap.

To zap pagetables without mmap_sem I think quite some overhaul is
needed (likely much bigger than the one required to fix the memory and
coredump corruption). If that is done it should be done to run
MADV_DONTNEED without mmap_sem if something. OOM reaper increased
accuracy wouldn't be enough of a motivation to justify such an
increase in complexity and constant fast-path overhead (be it to
release vmas with RCU through callbacks with delayed freeing or
anything else required to drop the mmap_sem while still allowing the
OOM reapear to run while mm_users is still > 0). It'd be quite
challenging to do that because the vma bits are also protected by
mmap_sem and you can only replace rbtree nodes with RCU, not to
rebalance with argumentation.

Assuming we do all that work and slowdown the fast paths further, just
for the OOM reaper, what would then happen if the process hung has no
anonymous memory to free and instead it runs on shmem only? Would we
be back to square one and hang with the below dump?

What if we fix xfs instead to get rid of the below problem? Wouldn't
then the OOM reaper become irrelevant if removed or not?

> ----------
> [  493.787997] Out of memory: Kill process 3163 (a.out) score 739 or sacrifice child
> [  493.791708] Killed process 3163 (a.out) total-vm:4268108kB, anon-rss:2754236kB, file-rss:0kB, shmem-rss:0kB
> [  494.838382] oom_reaper: unable to reap pid:3163 (a.out)
> [  494.847768] 
> [  494.847768] Showing all locks held in the system:
> [  494.861357] 1 lock held by oom_reaper/59:
> [  494.865903]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff9f0c202d>] debug_show_all_locks+0x3d/0x1a0
> [  494.872934] 1 lock held by khugepaged/63:
> [  494.877426]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f1d5a4d>] khugepaged+0x99d/0x1af0
> [  494.884165] 3 locks held by kswapd0/75:
> [  494.888628]  #0:  (shrinker_rwsem){++++..}, at: [<ffffffff9f16c638>] shrink_slab.part.44+0x48/0x2b0
> [  494.894125]  #1:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
> [  494.898328]  #2:  (&pag->pag_ici_reclaim_lock){+.+.-.}, at: [<ffffffffc03aeafd>] xfs_reclaim_inodes_ag+0x3ad/0x4d0 [xfs]
> [  494.902703] 3 locks held by kworker/u128:31/387:
> [  494.905404]  #0:  ("writeback"){.+.+.+}, at: [<ffffffff9f08ddcc>] process_one_work+0x1fc/0x480
> [  494.909237]  #1:  ((&(&wb->dwork)->work)){+.+.+.}, at: [<ffffffff9f08ddcc>] process_one_work+0x1fc/0x480
> [  494.913205]  #2:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
> [  494.916954] 1 lock held by xfsaild/sda1/422:
> [  494.919288]  #0:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffc03b8828>] xfs_ilock_nowait+0x148/0x240 [xfs]
> [  494.923470] 1 lock held by systemd-journal/491:
> [  494.926102]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
> [  494.929942] 1 lock held by gmain/745:
> [  494.932368]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
> [  494.936505] 1 lock held by tuned/1009:
> [  494.938856]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
> [  494.942824] 2 locks held by agetty/982:
> [  494.944900]  #0:  (&tty->ldisc_sem){++++.+}, at: [<ffffffff9f78503f>] ldsem_down_read+0x1f/0x30
> [  494.948244]  #1:  (&ldata->atomic_read_lock){+.+...}, at: [<ffffffff9f4108bf>] n_tty_read+0xbf/0x8e0
> [  494.952118] 1 lock held by sendmail/984:
> [  494.954408]  #0:  (&(&ip->i_mmaplock)->mr_lock){++++++}, at: [<ffffffffc03b85da>] xfs_ilock+0x11a/0x1b0 [xfs]
> [  494.958370] 5 locks held by a.out/3163:
> [  494.960544]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f05ca34>] __do_page_fault+0x154/0x4c0
> [  494.964191]  #1:  (shrinker_rwsem){++++..}, at: [<ffffffff9f16c638>] shrink_slab.part.44+0x48/0x2b0
> [  494.967922]  #2:  (&type->s_umount_key#30){++++++}, at: [<ffffffff9f1f30f6>] trylock_super+0x16/0x50
> [  494.971548]  #3:  (&pag->pag_ici_reclaim_lock){+.+.-.}, at: [<ffffffffc03ae7fe>] xfs_reclaim_inodes_ag+0xae/0x4d0 [xfs]
> [  494.975644]  #4:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffc03b8580>] xfs_ilock+0xc0/0x1b0 [xfs]
> [  494.979194] 1 lock held by a.out/3164:
> [  494.981220]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
> [  494.984448] 1 lock held by a.out/3165:
> [  494.986554]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
> [  494.989841] 1 lock held by a.out/3166:
> [  494.992089]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
> [  494.995388] 1 lock held by a.out/3167:
> [  494.997420]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff9f076d05>] do_exit+0x175/0xbb0
> ----------
> 
>   collapse_huge_page at mm/khugepaged.c:1001
>    (inlined by) khugepaged_scan_pmd at mm/khugepaged.c:1209
>    (inlined by) khugepaged_scan_mm_slot at mm/khugepaged.c:1728
>    (inlined by) khugepaged_do_scan at mm/khugepaged.c:1809
>    (inlined by) khugepaged at mm/khugepaged.c:1854
> 
> and "how can we close race between checking MMF_OOM_SKIP and doing last alloc_page_from_freelist()
> attempt (because that race allows needlessly selecting the second task for kill)" in addition to
> "how can we close race between unmap_page_range() and the page faults with retry fallback".

Yes. And the "how is OOM reaper guaranteed not to run already while
coredumping is starting" should be added to the above list of things
to fix or explain.

I'm just questioning if all this energy isn't better spent in fixing
XFS with a memory reserve in xfs_reclaim_inode for kmem_alloc (like we
have mempools for bio) and drop the OOM reaper leaving the VM fast
paths alone.

> The subject of this thread is "how can we close race between unmap_page_range()
> and the page faults with retry fallback". Are you suggesting that we should remove
> the OOM reaper so that we don't need to change page faults and/or __mmput() paths?

Well certainly if it's not fixed, I think we'd be better off to remove
it because the risk of an hang is preferable than risk of memory
corruption or corrupted core dumps.

If it was that simple as it is currently it was nice to have, but
doing it safe without risk to corrupt memory and coredumps and without
slowing down the VM fast paths, sounds overkill. Last but not the
least it hides reproducible of issues like the above hang you posted,
that I think it can't do anything about even if you remove khugepaged...

... unless we drop the mmap_sem from MADV_DONTNEED but it's not easily
feasible if unmap_page_range has to run while mm_users may still be
still > 0. Doing more VM changes that are OOM reaper specific doesn't
seem attractive to me.

I'd rather prefer if we can fix the issues in xfs the old fashioned
way that won't end up again in a hang, if after all that work, the
TIF_MEMDIE task happened to have 0 anon mem allocated in it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

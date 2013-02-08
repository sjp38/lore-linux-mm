Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 85B246B000A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 00:03:10 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_if_PF=5FNO=5FMEMCG=5FOOM_is_set?=
Date: Fri, 08 Feb 2013 06:03:04 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121230020947.AA002F34@pobox.sk>, <20121230110815.GA12940@dhcp22.suse.cz>, <20130125160723.FAE73567@pobox.sk>, <20130125163130.GF4721@dhcp22.suse.cz>, <20130205134937.GA22804@dhcp22.suse.cz>, <20130205154947.CD6411E2@pobox.sk>, <20130205160934.GB22804@dhcp22.suse.cz>, <20130206021721.1AE9E3C7@pobox.sk>, <20130206140119.GD10254@dhcp22.suse.cz>, <20130206142219.GF10254@dhcp22.suse.cz> <20130206160051.GG10254@dhcp22.suse.cz>
In-Reply-To: <20130206160051.GG10254@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130208060304.799F362F@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

Michal, thank you very much but it just didn't work and broke everything :(

This happened:
Problem started to occur really often immediately after booting the new kernel, every few minutes for one of my users. But everything other seems to work fine so i gave it a try for a day (which was a mistake). I grabbed some data for you and go to sleep:
http://watchdog.sk/lkml/memcg-bug-4.tar.gz

Few hours later i was woke up from my sweet sweet dreams by alerts smses - Apache wasn't working and our system failed to restart it. When i observed the situation, two apache processes (of that user as above) were still running and it wasn't possible to kill them by any way. I grabbed some data for you:
http://watchdog.sk/lkml/memcg-bug-5.tar.gz

Then I logged to the console and this was waiting for me:
http://watchdog.sk/lkml/error.jpg

Finally i rebooted into different kernel, wrote this e-mail and go to my lovely bed ;)



______________________________________________________________
> Od: "Michal Hocko" <mhocko@suse.cz>
> Komu: azurIt <azurit@pobox.sk>
> DA!tum: 06.02.2013 17:00
> Predmet: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM is set
>
> CC: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "Johannes Weiner" <hannes@cmpxchg.org>
>On Wed 06-02-13 15:22:19, Michal Hocko wrote:
>> On Wed 06-02-13 15:01:19, Michal Hocko wrote:
>> > On Wed 06-02-13 02:17:21, azurIt wrote:
>> > > >5-memcg-fix-1.patch is not complete. It doesn't contain the folloup I
>> > > >mentioned in a follow up email. Here is the full patch:
>> > > 
>> > > 
>> > > Here is the log where OOM, again, killed MySQL server [search for "(mysqld)"]:
>> > > http://www.watchdog.sk/lkml/oom_mysqld6
>> > 
>> > [...]
>> > WARNING: at mm/memcontrol.c:2409 T.1149+0x2d9/0x610()
>> > Hardware name: S5000VSA
>> > gfp_mask:4304 nr_pages:1 oom:0 ret:2
>> > Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
>> > Call Trace:
>> >  [<ffffffff8105502a>] warn_slowpath_common+0x7a/0xb0
>> >  [<ffffffff81055116>] warn_slowpath_fmt+0x46/0x50
>> >  [<ffffffff81108163>] ? mem_cgroup_margin+0x73/0xa0
>> >  [<ffffffff8110b6f9>] T.1149+0x2d9/0x610
>> >  [<ffffffff812af298>] ? blk_finish_plug+0x18/0x50
>> >  [<ffffffff8110c6b4>] mem_cgroup_cache_charge+0xc4/0xf0
>> >  [<ffffffff810ca6bf>] add_to_page_cache_locked+0x4f/0x140
>> >  [<ffffffff810ca7d2>] add_to_page_cache_lru+0x22/0x50
>> >  [<ffffffff810cad32>] filemap_fault+0x252/0x4f0
>> >  [<ffffffff810eab18>] __do_fault+0x78/0x5a0
>> >  [<ffffffff810edcb4>] handle_pte_fault+0x84/0x940
>> >  [<ffffffff810e2460>] ? vma_prio_tree_insert+0x30/0x50
>> >  [<ffffffff810f2508>] ? vma_link+0x88/0xe0
>> >  [<ffffffff810ee6a8>] handle_mm_fault+0x138/0x260
>> >  [<ffffffff8102709d>] do_page_fault+0x13d/0x460
>> >  [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
>> >  [<ffffffff815b61ff>] page_fault+0x1f/0x30
>> > ---[ end trace 8817670349022007 ]---
>> > apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
>> > apache2 cpuset=uid mems_allowed=0
>> > Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
>> > Call Trace:
>> >  [<ffffffff810ccd2e>] dump_header+0x7e/0x1e0
>> >  [<ffffffff810ccc2f>] ? find_lock_task_mm+0x2f/0x70
>> >  [<ffffffff810cd1f5>] oom_kill_process+0x85/0x2a0
>> >  [<ffffffff810cd8a5>] out_of_memory+0xe5/0x200
>> >  [<ffffffff810cda7d>] pagefault_out_of_memory+0xbd/0x110
>> >  [<ffffffff81026e76>] mm_fault_error+0xb6/0x1a0
>> >  [<ffffffff8102734e>] do_page_fault+0x3ee/0x460
>> >  [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
>> >  [<ffffffff815b61ff>] page_fault+0x1f/0x30
>> > 
>> > The first trace comes from the debugging WARN and it clearly points to
>> > a file fault path. __do_fault pre-charges a page in case we need to
>> > do CoW (copy-on-write) for the returned page. This one falls back to
>> > memcg OOM and never returns ENOMEM as I have mentioned earlier. 
>> > However, the fs fault handler (filemap_fault here) can fallback to
>> > page_cache_read if the readahead (do_sync_mmap_readahead) fails
>> > to get page to the page cache. And we can see this happening in
>> > the first trace. page_cache_read then calls add_to_page_cache_lru
>> > and eventually gets to add_to_page_cache_locked which calls
>> > mem_cgroup_cache_charge_no_oom so we will get ENOMEM if oom should
>> > happen. This ENOMEM gets to the fault handler and kaboom.
>> > 
>> > So the fix is really much more complex than I thought. Although
>> > add_to_page_cache_locked sounded like a good place it turned out to be
>> > not in fact.
>> > 
>> > We need something more clever appaerently. One way would be not misusing
>> > __GFP_NORETRY for GFP_MEMCG_NO_OOM and give it a real flag. We have 32
>> > bits for those flags in gfp_t so there should be some room there. 
>> > Or we could do this per task flag, same we do for NO_IO in the current
>> > -mm tree.
>> > The later one seems easier wrt. gfp_mask passing horror - e.g.
>> > __generic_file_aio_write doesn't pass flags and it can be called from
>> > unlocked contexts as well.
>> 
>> Ouch, PF_ flags space seem to be drained already because
>> task_struct::flags is just unsigned int so there is just one bit left. I
>> am not sure this is the best use for it. This will be a real pain!
>
>OK, so this something that should help you without any risk of false
>OOMs. I do not believe that something like that would be accepted
>upstream because it is really heavy. We will need to come up with
>something more clever for upstream.
>I have also added a warning which will trigger when the charge fails. If
>you see too many of those messages then there is something bad going on
>and the lack of OOM causes userspace to loop without getting any
>progress.
>
>So there you go - your personal patch ;) You can drop all other patches.
>Please note I have just compile tested it. But it should be pretty
>trivial to check it is correct
>---
>From 6f155187f77c971b45caf05dbc80ca9c20bc278c Mon Sep 17 00:00:00 2001
>From: Michal Hocko <mhocko@suse.cz>
>Date: Wed, 6 Feb 2013 16:45:07 +0100
>Subject: [PATCH 1/2] memcg: do not trigger OOM if PF_NO_MEMCG_OOM is set
>
>memcg oom killer might deadlock if the process which falls down to
>mem_cgroup_handle_oom holds a lock which prevents other task to
>terminate because it is blocked on the very same lock.
>This can happen when a write system call needs to allocate a page but
>the allocation hits the memcg hard limit and there is nothing to reclaim
>(e.g. there is no swap or swap limit is hit as well and all cache pages
>have been reclaimed already) and the process selected by memcg OOM
>killer is blocked on i_mutex on the same inode (e.g. truncate it).
>
>Process A
>[<ffffffff811109b8>] do_truncate+0x58/0xa0		# takes i_mutex
>[<ffffffff81121c90>] do_last+0x250/0xa30
>[<ffffffff81122547>] path_openat+0xd7/0x440
>[<ffffffff811229c9>] do_filp_open+0x49/0xa0
>[<ffffffff8110f7d6>] do_sys_open+0x106/0x240
>[<ffffffff8110f950>] sys_open+0x20/0x30
>[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
>[<ffffffffffffffff>] 0xffffffffffffffff
>
>Process B
>[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>[<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
>[<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
>[<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
>[<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
>[<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
>[<ffffffff81193a18>] ext3_write_begin+0x88/0x270
>[<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
>[<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
>[<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
>[<ffffffff8111156a>] do_sync_write+0xea/0x130
>[<ffffffff81112183>] vfs_write+0xf3/0x1f0
>[<ffffffff81112381>] sys_write+0x51/0x90
>[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
>[<ffffffffffffffff>] 0xffffffffffffffff
>
>This is not a hard deadlock though because administrator can still
>intervene and increase the limit on the group which helps the writer to
>finish the allocation and release the lock.
>
>This patch heals the problem by forbidding OOM from dangerous context.
>Memcg charging code has no way to find out whether it is called from a
>locked context we have to help it via process flags. PF_OOM_ORIGIN flag
>removed recently will be reused for PF_NO_MEMCG_OOM which signals that
>the memcg OOM killer could lead to a deadlock.
>Only locked callers of __generic_file_aio_write are currently marked. I
>am pretty sure there are more places (I didn't check shmem and hugetlb
>uses fancy instantion mutex during page fault and filesystems might
>use some locks during the write) but I've ignored those as this will
>probably be just a user specific patch without any way to get upstream
>in the current form.
>
>Reported-by: azurIt <azurit@pobox.sk>
>Signed-off-by: Michal Hocko <mhocko@suse.cz>
>---
> drivers/staging/pohmelfs/inode.c |    2 ++
> include/linux/sched.h            |    1 +
> mm/filemap.c                     |    2 ++
> mm/memcontrol.c                  |   18 ++++++++++++++----
> 4 files changed, 19 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/staging/pohmelfs/inode.c b/drivers/staging/pohmelfs/inode.c
>index 7a19555..523de82e 100644
>--- a/drivers/staging/pohmelfs/inode.c
>+++ b/drivers/staging/pohmelfs/inode.c
>@@ -921,7 +921,9 @@ ssize_t pohmelfs_write(struct file *file, const char __user *buf,
> 	if (ret)
> 		goto err_out_unlock;
> 
>+	current->flags |= PF_NO_MEMCG_OOM;
> 	ret = __generic_file_aio_write(&kiocb, &iov, 1, &kiocb.ki_pos);
>+	current->flags &= ~PF_NO_MEMCG_OOM;
> 	*ppos = kiocb.ki_pos;
> 
> 	mutex_unlock(&inode->i_mutex);
>diff --git a/include/linux/sched.h b/include/linux/sched.h
>index 1e86bb4..f275c8f 100644
>--- a/include/linux/sched.h
>+++ b/include/linux/sched.h
>@@ -1781,6 +1781,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
> #define PF_FROZEN	0x00010000	/* frozen for system suspend */
> #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
> #define PF_KSWAPD	0x00040000	/* I am kswapd */
>+#define PF_NO_MEMCG_OOM	0x00080000	/* Memcg OOM could lead to a deadlock */
> #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
> #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
> #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
>diff --git a/mm/filemap.c b/mm/filemap.c
>index 556858c..58a316b 100644
>--- a/mm/filemap.c
>+++ b/mm/filemap.c
>@@ -2617,7 +2617,9 @@ ssize_t generic_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
> 
> 	mutex_lock(&inode->i_mutex);
> 	blk_start_plug(&plug);
>+	current->flags |= PF_NO_MEMCG_OOM;
> 	ret = __generic_file_aio_write(iocb, iov, nr_segs, &iocb->ki_pos);
>+	current->flags &= ~PF_NO_MEMCG_OOM;
> 	mutex_unlock(&inode->i_mutex);
> 
> 	if (ret > 0 || ret == -EIOCBQUEUED) {
>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>index c8425b1..128b615 100644
>--- a/mm/memcontrol.c
>+++ b/mm/memcontrol.c
>@@ -2397,6 +2397,14 @@ done:
> 	return 0;
> nomem:
> 	*ptr = NULL;
>+	if (printk_ratelimit())
>+		printk(KERN_WARNING"%s: task:%s pid:%d got ENOMEM without OOM for memcg:%p."
>+				" If this message shows up very often for the"
>+				" same task then there is a risk that the"
>+				" process is not able to make any progress"
>+				" because of the current limit. Try to enlarge"
>+				" the hard limit.\n", __FUNCTION__,
>+				current->comm, current->pid, memcg);
> 	return -ENOMEM;
> bypass:
> 	*ptr = NULL;
>@@ -2703,7 +2711,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> 	struct mem_cgroup *memcg = NULL;
> 	unsigned int nr_pages = 1;
> 	struct page_cgroup *pc;
>-	bool oom = true;
>+	bool oom = !(current->flags & PF_NO_MEMCG_OOM);
> 	int ret;
> 
> 	if (PageTransHuge(page)) {
>@@ -2770,6 +2778,7 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
> int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> 				gfp_t gfp_mask)
> {
>+	bool oom = !(current->flags & PF_NO_MEMCG_OOM);
> 	struct mem_cgroup *memcg = NULL;
> 	int ret;
> 
>@@ -2782,7 +2791,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> 		mm = &init_mm;
> 
> 	if (page_is_file_cache(page)) {
>-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
>+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, oom);
> 		if (ret || !memcg)
> 			return ret;
> 
>@@ -2818,6 +2827,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> 				 struct page *page,
> 				 gfp_t mask, struct mem_cgroup **ptr)
> {
>+	bool oom = !(current->flags & PF_NO_MEMCG_OOM);
> 	struct mem_cgroup *memcg;
> 	int ret;
> 
>@@ -2840,13 +2850,13 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> 	if (!memcg)
> 		goto charge_cur_mm;
> 	*ptr = memcg;
>-	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, true);
>+	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, oom);
> 	css_put(&memcg->css);
> 	return ret;
> charge_cur_mm:
> 	if (unlikely(!mm))
> 		mm = &init_mm;
>-	return __mem_cgroup_try_charge(mm, mask, 1, ptr, true);
>+	return __mem_cgroup_try_charge(mm, mask, 1, ptr, oom);
> }
> 
> static void
>-- 
>1.7.10.4
>
>-- 
>Michal Hocko
>SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

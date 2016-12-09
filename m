Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A38FF6B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 09:23:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c4so20771449pfb.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 06:23:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h38si34153915plb.115.2016.12.09.06.23.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 06:23:15 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20161207081555.GB17136@dhcp22.suse.cz>
	<201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
	<20161208132714.GA26530@dhcp22.suse.cz>
In-Reply-To: <20161208132714.GA26530@dhcp22.suse.cz>
Message-Id: <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
Date: Fri, 9 Dec 2016 23:23:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 08-12-16 00:29:26, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> > > > If the OOM killer is invoked when many threads are looping inside the
> > > > page allocator, it is possible that the OOM killer is preempted by other
> > > > threads.
> > > 
> > > Hmm, the only way I can see this would happen is when the task which
> > > actually manages to take the lock is not invoking the OOM killer for
> > > whatever reason. Is this what happens in your case? Are you able to
> > > trigger this reliably?
> > 
> > Regarding http://I-love.SAKURA.ne.jp/tmp/serial-20161206.txt.xz ,
> > somebody called oom_kill_process() and reached
> > 
> >   pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> > 
> > line but did not reach
> > 
> >   pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > 
> > line within tolerable delay.
> 
> I would be really interested in that. This can happen only if
> find_lock_task_mm fails. This would mean that either we are selecting a
> child without mm or the selected victim has no mm anymore. Both cases
> should be ephemeral because oom_badness will rule those tasks on the
> next round. So the primary question here is why no other task has hit
> out_of_memory.

This can also happen due to AB-BA livelock (oom_lock v.s. console_sem).

>                Have you tried to instrument the kernel and see whether
> GFP_NOFS contexts simply preempted any other attempt to get there?
> I would find it quite unlikely but not impossible. If that is the case
> we should really think how to move forward. One way is to make the oom
> path fully synchronous as suggested below. Other is to tweak GFP_NOFS
> some more and do not take the lock while we are evaluating that. This
> sounds quite messy though.

Do you mean "tweak GFP_NOFS" as something like below patch?

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3036,6 +3036,17 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
+	if (!(gfp_mask & (__GFP_FS | __GFP_NOFAIL))) {
+		if ((current->flags & PF_DUMPCORE) ||
+		    (order > PAGE_ALLOC_COSTLY_ORDER) ||
+		    (ac->high_zoneidx < ZONE_NORMAL) ||
+		    (pm_suspended_storage()) ||
+		    (gfp_mask & __GFP_THISNODE))
+			return NULL;
+		*did_some_progress = 1;
+		return NULL;
+	}
+
 	/*
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.

Then, serial-20161209-gfp.txt in http://I-love.SAKURA.ne.jp/tmp/20161209.tar.xz is
console log with above patch applied. Spinning without invoking the OOM killer.
It did not avoid locking up.

[  879.772089] Killed process 14529 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  884.746246] Killed process 14530 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  885.162475] Killed process 14531 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  885.399802] Killed process 14532 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  889.497044] a.out: page allocation stalls for 10001ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.507193] a.out: page allocation stalls for 10016ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.560741] systemd-journal: page allocation stalls for 10020ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  889.590231] a.out: page allocation stalls for 10079ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.600207] a.out: page allocation stalls for 10091ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.607186] a.out: page allocation stalls for 10105ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.611057] a.out: page allocation stalls for 10001ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.646180] a.out: page allocation stalls for 10065ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  889.655083] tuned: page allocation stalls for 10001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
(...snipped...)
[ 1139.516867] a.out: page allocation stalls for 260007ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[ 1139.530790] a.out: page allocation stalls for 260034ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[ 1139.555816] a.out: page allocation stalls for 260038ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[ 1142.097226] NetworkManager: page allocation stalls for 210003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1142.747370] systemd-journal: page allocation stalls for 220003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1142.747443] page allocation stalls for 220003ms, order:0 [<ffffffff81226c20>] __do_fault+0x80/0x130
[ 1142.750326] irqbalance: page allocation stalls for 220001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1142.763366] postgres: page allocation stalls for 220003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1143.139489] master: page allocation stalls for 220003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1143.292492] mysqld: page allocation stalls for 260001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1143.313282] mysqld: page allocation stalls for 260002ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1143.543551] mysqld: page allocation stalls for 250003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1143.726339] postgres: page allocation stalls for 260003ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1147.408614] smbd: page allocation stalls for 220001ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)

> 
> [...]
> 
> > > So, why don't you simply s@mutex_trylock@mutex_lock_killable@ then?
> > > The trylock is simply an optimistic heuristic to retry while the memory
> > > is being freed. Making this part sync might help for the case you are
> > > seeing.
> > 
> > May I? Something like below? With patch below, the OOM killer can send
> > SIGKILL smoothly and printk() can report smoothly (the frequency of
> > "** XXX printk messages dropped **" messages is significantly reduced).
> 
> Well, this has to be properly evaluated. The fact that
> __oom_reap_task_mm requires the oom_lock makes it more complicated. We
> definitely do not want to starve it. On the other hand the oom
> invocation path shouldn't stall for too long and even when we have
> hundreds of tasks blocked on the lock and blocking the oom reaper then
> the reaper should run _eventually_. It might take some time but this a
> glacial slow path so it should be acceptable.
> 
> That being said, this should be OK. But please make sure to mention all
> these details in the changelog. Also make sure to document the actual
> failure mode as mentioned above.

stall-20161209-1.png and stall-20161209-2.png in 20161209.tar.xz are
screen shots and serial-20161209-stall.txt is console log without any patch.
We can see that console log is unreadably dropped and all CPUs are spinning
without invoking the OOM killer.

[  130.084200] Killed process 2613 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  130.297981] Killed process 2614 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  130.509444] Killed process 2615 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  130.725497] Killed process 2616 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  140.886508] a.out: page allocation stalls for 10004ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  140.888637] a.out: page allocation stalls for 10006ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  140.890348] a.out: page allocation stalls for 10008ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
** 49 printk messages dropped ** [  140.892119]  [<ffffffff81293685>] __vfs_write+0xe5/0x140
** 45 printk messages dropped ** [  140.892994]  [<ffffffff81306f10>] ? iomap_write_end+0x80/0x80
** 93 printk messages dropped ** [  140.898500]  [<ffffffff811e802d>] __page_cache_alloc+0x15d/0x1a0
** 45 printk messages dropped ** [  140.900144]  [<ffffffff811f58e9>] warn_alloc+0x149/0x180
** 94 printk messages dropped ** [  140.900785] CPU: 1 PID: 3372 Comm: a.out Not tainted 4.9.0-rc8+ #70
** 89 printk messages dropped ** [  147.049875] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
** 96 printk messages dropped ** [  150.110000] Node 0 DMA32: 9*4kB (H) 4*8kB (UH) 8*16kB (UEH) 187*32kB (UMEH) 75*64kB (UEH) 108*128kB (UME) 49*256kB (UME) 12*512kB (UME) 1*1024kB (U) 0*2048kB 0*4096kB = 44516kB
** 303 printk messages dropped ** [  150.893480] lowmem_reserve[]: 0 0 0 0
** 148 printk messages dropped ** [  153.480652] Node 0 DMA free:6700kB min:440kB low:548kB high:656kB active_anon:9144kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
** 191 printk messages dropped ** [  160.110155] Node 0 DMA free:6700kB min:440kB low:548kB high:656kB active_anon:9144kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
** 1551 printk messages dropped ** [  178.654905] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
** 43 printk messages dropped ** [  179.057226]  ffffc90003377a08 ffffffff813c9d4d ffffffff81a29518 0000000000000001
** 95 printk messages dropped ** [  180.109388]  ffffc90002283a08 ffffffff813c9d4d ffffffff81a29518 0000000000000001
** 94 printk messages dropped ** [  180.889628] 0 pages hwpoisoned
[  180.895764] a.out: page allocation stalls for 50013ms, order:0, mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
** 240 printk messages dropped ** [  183.318598] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
(...snipped...)
** 188 printk messages dropped ** [  452.747159] 0 pages HighMem/MovableOnly
** 44 printk messages dropped ** [  452.773748] 4366 total pagecache pages
** 48 printk messages dropped ** [  452.803376] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
** 537 printk messages dropped ** [  460.107887] lowmem_reserve[]: 0 0 0 0

> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2c6d5f6..ee0105b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> >  	 * Acquire the oom lock.  If that fails, somebody else is
> >  	 * making progress for us.
> >  	 */
> > -	if (!mutex_trylock(&oom_lock)) {
> > +	if (mutex_lock_killable(&oom_lock)) {
> >  		*did_some_progress = 1;
> >  		schedule_timeout_uninterruptible(1);
> >  		return NULL;
> 

nostall-20161209-1.png and nostall-20161209-2.png are screen shots and
serial-20161209-nostall.txt is console log with mutex_lock_killable() patch applied.
We can see that console log is less dropped and only 1 CPU is spinning with
invoking the OOM killer.

[  421.630240] Killed process 4568 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  421.643236] Killed process 4569 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  421.842463] Killed process 4570 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  421.899778] postgres: page allocation stalls for 11376ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  421.900569] Killed process 4571 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  421.900792] postgres: page allocation stalls for 185751ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  421.900920] systemd-logind: page allocation stalls for 162980ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  421.901027] master: page allocation stalls for 86144ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  421.912876] pickup: page allocation stalls for 18360ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  422.007323] Killed process 4572 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  422.011580] Killed process 4573 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  422.017043] Killed process 4574 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  422.027035] Killed process 4575 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB

So, I think serializing with mutex_lock_killable() is preferable for avoiding lockups
even if it might defer !__GFP_FS && !__GFP_NOFAIL allocations or the OOM reaper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

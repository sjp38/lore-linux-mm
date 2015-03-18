Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 630C16B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:33:16 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so29437152obc.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 04:33:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v1si9135762oer.95.2015.03.18.04.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 04:33:15 -0700 (PDT)
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150315121317.GA30685@dhcp22.suse.cz>
	<201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
	<20150316074607.GA24885@dhcp22.suse.cz>
	<201503172013.HCI87500.QFHtOOMLOVFSJF@I-love.SAKURA.ne.jp>
	<20150317131501.GH28112@dhcp22.suse.cz>
In-Reply-To: <20150317131501.GH28112@dhcp22.suse.cz>
Message-Id: <201503182033.CFI43269.FOJFOFtQHLSOMV@I-love.SAKURA.ne.jp>
Date: Wed, 18 Mar 2015 20:33:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > Tetsuo Handa wrote:
> > > I also tested on XFS. One is Linux 3.19 and the other is Linux 3.19
> > > with debug printk patch shown above. According to console logs,
> > > oom_kill_process() is trivially called via pagefault_out_of_memory()
> > > for the former kernel. Due to giving up !GFP_FS allocations immediately?
> > >
> > > (From http://I-love.SAKURA.ne.jp/tmp/serial-20150223-3.19-xfs-unpatched.txt.xz )
> > > ---------- xfs / Linux 3.19 ----------
> > > [  793.283099] su invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
> > > [  793.283102] su cpuset=/ mems_allowed=0
> > > [  793.283104] CPU: 3 PID: 9552 Comm: su Not tainted 3.19.0 #40
> > > [  793.283159] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > > [  793.283161]  0000000000000000 ffff88007ac03bf8 ffffffff816ae9d4 000000000000bebe
> > > [  793.283162]  ffff880078b0d740 ffff88007ac03c98 ffffffff816ac7ac 0000000000000206
> > > [  793.283163]  0000000481f30298 ffff880073e55850 ffff88007ac03c88 ffff88007a20bef8
> > > [  793.283164] Call Trace:
> > > [  793.283169]  [<ffffffff816ae9d4>] dump_stack+0x45/0x57
> > > [  793.283171]  [<ffffffff816ac7ac>] dump_header+0x7f/0x1f1
> > > [  793.283174]  [<ffffffff8114b36b>] oom_kill_process+0x22b/0x390
> > > [  793.283177]  [<ffffffff810776d0>] ? has_capability_noaudit+0x20/0x30
> > > [  793.283178]  [<ffffffff8114bb72>] out_of_memory+0x4b2/0x500
> > > [  793.283179]  [<ffffffff8114bc37>] pagefault_out_of_memory+0x77/0x90
> > > [  793.283180]  [<ffffffff816aab2c>] mm_fault_error+0x67/0x140
> > > [  793.283182]  [<ffffffff8105a9f6>] __do_page_fault+0x3f6/0x580
> > > [  793.283185]  [<ffffffff810aed1d>] ? remove_wait_queue+0x4d/0x60
> > > [  793.283186]  [<ffffffff81070fcb>] ? do_wait+0x12b/0x240
> > > [  793.283187]  [<ffffffff8105abb1>] do_page_fault+0x31/0x70
> > > [  793.283189]  [<ffffffff816b83e8>] page_fault+0x28/0x30
> > > ---------- xfs / Linux 3.19 ----------
> >
> > Are all memory allocations caused by page fault __GFP_FS allocation?
> 
> They should be GFP_HIGHUSER_MOVABLE or GFP_KERNEL. There should be no
> reason to have GFP_NOFS there because the page fault doesn't come from a
> fs path.

Excuse me, but are you sure? I am seeing 0x2015a (!__GFP_NOFS) allocation
failures from page fault. SystemTap also reports that 0x2015a is used from
page fault.

----------
[root@localhost ~]# stap -p4 -d xfs -m pagefault -g -DSTP_NO_OVERLOAD -e '
global traces_bt[65536];
probe begin { printf("Probe start!\n"); }
probe kernel.function("__alloc_pages_nodemask") {
  if ($gfp_mask == 0x2015a && execname() != "stapio") {
    bt = backtrace();
    if (traces_bt[bt]++ == 0) {
      printf("%s (%u) order:%u gfp:0x%x\n", execname(), tid(), $order, $gfp_mask);
      print_stack(bt);
      printf("\n\n");
    }
  }
}
probe end { delete traces_bt; }'
pagefault.ko
[root@localhost ~]# staprun pagefault.ko
Probe start!
rsyslogd (1852) order:0 gfp:0x2015a
 0xffffffff81130030 : __alloc_pages_nodemask+0x0/0x9a0 [kernel]
 0xffffffff81170d87 : alloc_pages_current+0xa7/0x170 [kernel]
 0xffffffff81126d07 : __page_cache_alloc+0xb7/0xd0 [kernel]
 0xffffffff811287a5 : filemap_fault+0x1b5/0x440 [kernel]
 0xffffffff811502ff : __do_fault+0x3f/0xc0 [kernel]
 0xffffffff811518e1 : handle_mm_fault+0x5e1/0x13b0 [kernel]
 0xffffffff810463ef : __do_page_fault+0x18f/0x430 [kernel]
 0xffffffff8104676c : do_page_fault+0xc/0x10 [kernel]
 0xffffffff814d67a2 : page_fault+0x22/0x30 [kernel]
----------

So, your patch introduces a trigger to involve OOM killer for !__GFP_FS
allocation. I myself think that we should trigger OOM killer for !__GFP_FS
allocation in order to make forward progress in case the OOM victim is blocked.
What is the reason we did not involve OOM killer for !__GFP_FS allocation?

Below is an example from http://I-love.SAKURA.ne.jp/tmp/serial-20150318.txt.xz
which is Linux 4.0-rc4 + your patch applied with sysctl_nr_alloc_retry == 1
which has fallen into infinite "XFS: possible memory allocation deadlock in
xfs_buf_allocate_memory (mode:0x250)" retry trap called OOM-deadlock by
running multiple memory stressing processes described at
http://www.spinics.net/lists/linux-ext4/msg47216.html .

----------
[  584.766247] Out of memory: Kill process 27800 (a.out) score 17 or sacrifice child
[  584.766248] Killed process 27800 (a.out) total-vm:69516kB, anon-rss:33236kB, file-rss:4kB
(...snipped...)
[  587.097942] XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
(...snipped...)
[  891.677310] a.out           D ffff880069c3fb78     0 27800      1 0x00100084
[  891.679239]  ffff880069c3fb78 ffff880057b2f570 ffff88007cfaf3b0 0000000000000000
[  891.681368]  ffff88007fffdb08 0000000000000000 ffff880069c3c010 ffff88007cfaf3b0
[  891.683519]  ffff88007bde5dc4 00000000ffffffff ffff88007bde5dc8 ffff880069c3fb98
[  891.685654] Call Trace:
[  891.686350]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[  891.687645]  [<ffffffff814d1d0e>] schedule_preempt_disabled+0xe/0x10
[  891.689289]  [<ffffffff814d2c42>] __mutex_lock_slowpath+0x92/0x100
[  891.690898]  [<ffffffff81190c16>] ? unlazy_walk+0xe6/0x150
[  891.692333]  [<ffffffff814d2cd3>] mutex_lock+0x23/0x40
[  891.693671]  [<ffffffff8119145d>] lookup_slow+0x3d/0xc0
[  891.695036]  [<ffffffff811946c5>] link_path_walk+0x375/0x910
[  891.696523]  [<ffffffff81194d28>] path_init+0xc8/0x460
[  891.697864]  [<ffffffff811970c2>] path_openat+0x72/0x680
[  891.699280]  [<ffffffff81177f72>] ? fallback_alloc+0x192/0x200
[  891.700852]  [<ffffffff811771d8>] ? kmem_getpages+0x58/0x110
[  891.702334]  [<ffffffff8119771a>] do_filp_open+0x4a/0xa0
[  891.703769]  [<ffffffff811a382d>] ? __alloc_fd+0xcd/0x140
[  891.705200]  [<ffffffff81183d45>] do_sys_open+0x145/0x240
[  891.706650]  [<ffffffff81183e7e>] SyS_open+0x1e/0x20
[  891.707976]  [<ffffffff814d4d32>] system_call_fastpath+0x12/0x17
(...snipped...)
[  899.777423] init: page allocation failure: order:0, mode:0x2015a
[  899.777424] CPU: 2 PID: 1 Comm: init Tainted: G            E   4.0.0-rc4+ #13
[  899.777425] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  899.777426]  0000000000000000 ffff88007d07ba98 ffffffff814d0ee5 0000000000000001
[  899.777426]  000000000002015a ffff88007d07bb28 ffffffff8112f2ba ffff88007fffdb28
[  899.777427]  ffff88007d07bab8 0000000000000020 000000000002015a 0000000000000000
[  899.777428] Call Trace:
[  899.777430]  [<ffffffff814d0ee5>] dump_stack+0x48/0x5b
[  899.777431]  [<ffffffff8112f2ba>] warn_alloc_failed+0xea/0x130
[  899.777432]  [<ffffffff81130699>] __alloc_pages_nodemask+0x669/0x9a0
[  899.777434]  [<ffffffff81170d87>] alloc_pages_current+0xa7/0x170
[  899.777435]  [<ffffffff81126d07>] __page_cache_alloc+0xb7/0xd0
[  899.777436]  [<ffffffff811287a5>] filemap_fault+0x1b5/0x440
[  899.777437]  [<ffffffff811502ff>] __do_fault+0x3f/0xc0
[  899.777438]  [<ffffffff811518e1>] handle_mm_fault+0x5e1/0x13b0
[  899.777441]  [<ffffffff8108098a>] ? set_next_entity+0x2a/0x60
[  899.777442]  [<ffffffff810463ef>] __do_page_fault+0x18f/0x430
[  899.777443]  [<ffffffff8104676c>] do_page_fault+0xc/0x10
[  899.777445]  [<ffffffff814d67a2>] page_fault+0x22/0x30
(...snipped...)
[ 1013.096701] XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
----------

We have mutex_lock() which prevented effectively GFP_NOFAIL allocation
at xfs_buf_allocate_memory() from making forward progress when the OOM
victim is blocked at mutex_lock(). As long as there is GFP_NOFAIL users,
we need some heuristic mechanism for detecting stalls.

While your patch seems to shorten the duration of !__GFP_FS allocations,
I can't feel that the I/O layer is making forward progress because the
system is stalling as if forever retrying !__GFP_FS allocations than
return I/O error to the caller. Maybe somewhere in the I/O layer is
stalling due to use of the same watermark threshold for GFP_NOIO /
GFP_NOFS / GFP_KERNEL allocations, though I didn't check for details...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

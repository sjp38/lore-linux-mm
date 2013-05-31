Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 7F34B6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 02:04:23 -0400 (EDT)
Date: Fri, 31 May 2013 16:04:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running
 xfstests)
Message-ID: <20130531060415.GU29466@dastard>
References: <510292845.4997401.1369279175460.JavaMail.root@redhat.com>
 <1985929268.4997720.1369279277543.JavaMail.root@redhat.com>
 <20130523035115.GY24543@dastard>
 <986348673.5787542.1369385526612.JavaMail.root@redhat.com>
 <20130527053608.GS29466@dastard>
 <1588848128.8530921.1369885528565.JavaMail.root@redhat.com>
 <20130530052049.GK29466@dastard>
 <1824023060.8558101.1369892432333.JavaMail.root@redhat.com>
 <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: xfs@oss.sgi.com, stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, May 30, 2013 at 11:03:35PM -0400, CAI Qian wrote:
> OK, so the minimal workload to trigger this I found so far was to
> run trinity, ltp and then xfstests. I have been able to easily
> reproduced on 3 servers so far, and I'll post full logs here for
> LKML and linux-mm as this may unrelated to XFS only. As far as
> I can tell from the previous testing results, this has never been
> reproduced back in 3.9 GA time. This seems also been reproduced
> on 3.10-rc3 mostly on s390x so far.
> CAI Qian
> 
> 1)
> [10948.104344] XFS (dm-2): Mounting Filesystem 
> [10948.257335] XFS (dm-2): Ending clean mount 
> [10949.753951] XFS (dm-0): Mounting Filesystem 
> [10950.012824] XFS (dm-0): Ending clean mount 
> [10951.115722] BUG: unable to handle kernel paging request at ffff88003a9ca478 
> [10951.122727] IP: [<ffffffff810f7f47>] __call_rcu.constprop.47+0x77/0x230 

Note the timestamp there  -I'll come back to it.

This has blown up in rcu processing on a idle CPU....

> [10951.527453] BUG: unable to handle kernel paging request at ffff88003db52000 
> [10951.527459] IP: [<ffffffff81302301>] memmove+0x51/0x1a0 

.. aproximately 400ms before XFS has tripped over in
xfs_attr_leaf_compact().

And for the second crash:

> 2)
> [20914.575680] XFS (dm-2): Mounting Filesystem 
> [20914.653966] XFS (dm-2): Ending clean mount 
> [20915.812263] XFS (dm-0): Mounting Filesystem 
> [20916.628209] XFS (dm-0): Ending clean mount 
> [20917.997069] divide error: 0000 [#1] SMP  

A divide by zero error in the scheduler find_busiest_group()
function during CPU idle work, with no XFS traces at all.

> 3)
> [10721.161888] XFS (dm-0): Ending clean mount 
> [10722.090855] XFS (dm-2): Mounting Filesystem 
> [10722.143682] XFS (dm-2): Ending clean mount 
> [10722.584327] XFS (dm-0): Mounting Filesystem 
> [10722.949519] XFS (dm-0): Ending clean mount 
> [10723.579704] BUG: unable to handle kernel paging request at ffff8801b55cc000 
> [10723.619185] IP: [<ffffffff81302305>] memmove+0x55/0x1a0 

XFS trips over, almost simultaneously with:

> [10724.128760] WARNING: at mm/mmap.c:2711 exit_mmap+0x166/0x170() 

A warning in exit_mmap() in a singal handler..

> [10724.128901] BUG: Bad rss-counter state mm:ffff8801fb90af40 idx:0 val:5 
> [10724.128901] BUG: Bad rss-counter state mm:ffff8801fb90af40 idx:1 val:3 

A bunch of obviously bad mm state warnings, and

> [10724.128927] rhts-test-runne[48621]: segfault at 19cc ip 00000000004401c4 sp 00007fff27f840e0 error 6 in bash[400000+db000] 
> [10724.129726] ============================================================================= 
> [10724.129727] BUG kmalloc-4096 (Tainted: GF       W   ): Padding overwritten. 0xffff88019152fc28-0xffff88019152ffff 
> [10724.129727] ----------------------------------------------------------------------------- 
> [10724.129727]  
> [10724.129728] INFO: Slab 0xffffea0006454a00 objects=7 used=7 fp=0x          (null) flags=0x20000000004080 
> [10724.129729] Pid: 43729, comm: kworker/0:0 Tainted: GF   B   W    3.9.4 #1 
> [10724.129729] Call Trace: 
> [10724.129730]  [<ffffffff81181ed2>] slab_err+0xc2/0xf0 
> [10724.129733]  [<ffffffff812f8007>] ? kset_init+0x27/0x40 
> [10724.129735]  [<ffffffff81181ff5>] slab_pad_check.part.41+0xf5/0x170 
> [10724.129736]  [<ffffffff810ce4d2>] ? cgroup_release_agent+0x42/0x180 
> [10724.129739]  [<ffffffff811820e3>] check_slab+0x73/0x100 
> [10724.129740]  [<ffffffff81606b50>] alloc_debug_processing+0x21/0x118 
> [10724.129742]  [<ffffffff8160772f>] __slab_alloc+0x3b8/0x4a2 
> [10724.129744]  [<ffffffff8109f5d8>] ? load_balance+0x108/0x7d0 
> [10724.129746]  [<ffffffff810ce4d2>] ? cgroup_release_agent+0x42/0x180 
> [10724.129747]  [<ffffffff8108fa7c>] ? update_rq_clock.part.67+0x1c/0x170 
> [10724.129749]  [<ffffffff81184dd1>] kmem_cache_alloc_trace+0x1b1/0x200 
> [10724.129751]  [<ffffffff810ce4d2>] cgroup_release_agent+0x42/0x180 

cgroup slab memory poison overwrite warning.

> [10724.135254] systemd[1]: segfault at 45 ip 00007f93e348c780 sp 00007fff4deb3a9e error 4 in libdbus-1.so.3.7.2[7f93e3479000+45000] 
> [10724.135272] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb34f8 error:0 in systemd[7f93e496d000+f6000] 
> [10724.135281] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb2f38 error:0 in systemd[7f93e496d000+f6000] 
> [10724.135289] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb2978 error:0 in systemd[7f93e496d000+f6000] 
> [10724.135297] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb23b8 error:0 in systemd[7f93e496d000+f6000] 
> [10724.135304] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb1df8 error:0 in systemd[7f93e496d000+f6000] 
> [10724.135312] traps: systemd[1] trap invalid opcode ip:7f93e498c490 sp:7fff4deb1838 error:0 in systemd[7f93e496d000+f6000] 

A bunch of nasty systemd trap warnings for illegal operations.

FWIW:

> [10748.689674] general protection fault: 0000 [#7] SMP  
> [10749.217082] CPU 2  
> [10749.227162] Pid: 464, comm: flush-253:1 Tainted: GF   B D W    3.9.4 #1 HP ProLiant DL120 G7 
...
> [10749.882823] Call Trace: 
> [10749.895832]  [<ffffffff81157aa2>] vma_interval_tree_iter_first+0x22/0x30 
> [10749.932506]  [<ffffffff8116714e>] page_mkclean+0x6e/0x1d0 
> [10749.960173]  [<ffffffff8113dbb8>] clear_page_dirty_for_io+0x48/0xc0 
> [10749.991604]  [<ffffffff8113de4a>] write_cache_pages+0x21a/0x4b0 
> [10750.020918]  [<ffffffff8113d4b0>] ? global_dirtyable_memory+0x50/0x50 
> [10750.053649]  [<ffffffff8113e120>] generic_writepages+0x40/0x60 
> [10750.083106]  [<ffffffffa01449e5>] xfs_vm_writepages+0x35/0x40 [xfs] 
> [10750.113998]  [<ffffffff8113f02e>] do_writepages+0x1e/0x40 
> [10750.141300]  [<ffffffff811c2ec0>] __writeback_single_inode+0x40/0x210 
> [10750.173209]  [<ffffffff811c4b77>] writeback_sb_inodes+0x197/0x400 
> [10750.204613]  [<ffffffff811c4e7f>] __writeback_inodes_wb+0x9f/0xd0 
> [10750.235080]  [<ffffffff811c5543>] wb_writeback+0x233/0x2b0 
> [10750.263128]  [<ffffffff811c6f65>] wb_do_writeback+0x1e5/0x1f0 
> [10750.291413]  [<ffffffff811c6ffb>] bdi_writeback_thread+0x8b/0x210 
> [10750.321825]  [<ffffffff811c6f70>] ? wb_do_writeback+0x1f0/0x1f0 

There's a clear indication that VM system is completely screwed up -
The flusher thread crashed trying to clear the dirty page bit during
data writeback.

There's memory corruption all over the place.  It is most likely
that trinity is causing this - it's purpose is to trigger corruption
issues, but they aren't always immediately seen.  If you can trigger
this xfs trace without trinity having been run and without all the
RCU/idle/scheduler/cgroup issues occuring at the same time, then
it's likely to be caused by XFS. But right now, I'd say XFS is just
an innocent bystander caught in the crossfire. There's nothing I can
do from an XFS persepctive to track this down...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

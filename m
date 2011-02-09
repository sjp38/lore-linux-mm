Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 867C18D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 01:51:21 -0500 (EST)
Date: Wed, 9 Feb 2011 15:50:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
Message-Id: <20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, 9 Feb 2011 15:10:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> In environment
>   - Host: kernel-2.6.32xxx (RHEL6)
>   - Guest: mm-of-the-moment snapshot 2011-02-04-15-15
> 
> I saw this when I ran make -j8 under 200M limit of memcg with 4vcpu.
> But it seems this doesn't directly related to memcg or virtualization.
> 
> Anyway, log is here. I'm sorry if this is a fixed one.
> My .config is attached. and a brief note is below
> 
> 
> ==
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.076861] BUG: Bad page state in process khugepaged  pfn:1e9800
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.077601] page:ffffea0006b14000 count:0 mapcount:0 mapping:          (null) index:0x2800
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.078674] page flags: 0x40000000004000(head)
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.079294] pc:ffff880214a30000 pc->flags:2146246697418756 pc->mem_cgroup:ffffc9000177a000
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.082177] (/A)
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.082500] Pid: 31, comm: khugepaged Not tainted 2.6.38-rc3-mm1 #1
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.083412] Call Trace:
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.083678]  [<ffffffff810f4454>] ? bad_page+0xe4/0x140
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.084240]  [<ffffffff810f53e6>] ? free_pages_prepare+0xd6/0x120
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.084837]  [<ffffffff8155621d>] ? rwsem_down_failed_common+0xbd/0x150
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.085509]  [<ffffffff810f5462>] ? __free_pages_ok+0x32/0xe0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.086110]  [<ffffffff810f552b>] ? free_compound_page+0x1b/0x20
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.086699]  [<ffffffff810fad6c>] ? __put_compound_page+0x1c/0x30
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.087333]  [<ffffffff810fae1d>] ? put_compound_page+0x4d/0x200
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.087935]  [<ffffffff810fb015>] ? put_page+0x45/0x50
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.097361]  [<ffffffff8113f779>] ? khugepaged+0x9e9/0x1430
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.098364]  [<ffffffff8107c870>] ? autoremove_wake_function+0x0/0x40
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.099121]  [<ffffffff8113ed90>] ? khugepaged+0x0/0x1430
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.099780]  [<ffffffff8107c236>] ? kthread+0x96/0xa0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.100452]  [<ffffffff8100dda4>] ? kernel_thread_helper+0x4/0x10
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.101214]  [<ffffffff8107c1a0>] ? kthread+0x0/0xa0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.101842]  [<ffffffff8100dda0>] ? kernel_thread_helper+0x0/0x10
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.102575] ------------[ cut here ]------------
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.103190] kernel BUG at include/linux/mm.h:420!
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.103803] invalid opcode: 0000 [#1] SMP
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.104309] last sysfs file: /sys/devices/system/cpu/online
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.104991] CPU 0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.105244] Modules linked in: autofs4 sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 virtio_balloon virtio_net virtio_blk virtio_pci virtio_ring virtio [last unloaded: scsi_wait_scan]
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.108135]
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.108303] Pid: 31, comm: khugepaged Not tainted 2.6.38-rc3-mm1 #1 /KVM
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.109098] RIP: 0010:[<ffffffff810f4486>]  [<ffffffff810f4486>] bad_page+0x116/0x140
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.110086] RSP: 0000:ffff880211f99ca0  EFLAGS: 00010202
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.110747] RAX: 00000000ffffffff RBX: ffffea0006b14000 RCX: 0000000000000712
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.111601] RDX: 00000000ffffffff RSI: 0000000000000001 RDI: ffff880211f99f58
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.112491] RBP: ffff880211f99cb0 R08: ffffffff81b41b80 R09: 0000000000000200
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.119933] R10: 0000000000000006 R11: 0000000000000001 R12: 0000000000000200
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.120764] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.121623] FS:  0000000000000000(0000) GS:ffff8800dfc00000(0000) knlGS:0000000000000000
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.122523] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.123195] CR2: 0000000000b9dd90 CR3: 00000001ffeaf000 CR4: 00000000000006f0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.123951] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.124765] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.125610] Process khugepaged (pid: 31, threadinfo ffff880211f98000, task ffff880211f34590)
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.126529] Stack:
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.126793]  ffff880211f99cb0 ffffea0006b14000 ffff880211f99d00 ffffffff810f53e6
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.127725]  ffff880211f99d20 ffffffff8155621d dead000000100100 ffffea0006b14000
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.130864]  0000000000000009 0000000000000019 0000000000000000 0000000000000447
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.131766] Call Trace:
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.132236]  [<ffffffff810f53e6>] free_pages_prepare+0xd6/0x120
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.132891]  [<ffffffff8155621d>] ? rwsem_down_failed_common+0xbd/0x150
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.133864]  [<ffffffff810f5462>] __free_pages_ok+0x32/0xe0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.134518]  [<ffffffff810f552b>] free_compound_page+0x1b/0x20
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.135244]  [<ffffffff810fad6c>] __put_compound_page+0x1c/0x30
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.135934]  [<ffffffff810fae1d>] put_compound_page+0x4d/0x200
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.136659]  [<ffffffff810fb015>] put_page+0x45/0x50
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.137232]  [<ffffffff8113f779>] khugepaged+0x9e9/0x1430
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.137801]  [<ffffffff8107c870>] ? autoremove_wake_function+0x0/0x40
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.138527]  [<ffffffff8113ed90>] ? khugepaged+0x0/0x1430
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.139166]  [<ffffffff8107c236>] kthread+0x96/0xa0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.139707]  [<ffffffff8100dda4>] kernel_thread_helper+0x4/0x10
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.140334]  [<ffffffff8107c1a0>] ? kthread+0x0/0xa0
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.140901]  [<ffffffff8100dda0>] ? kernel_thread_helper+0x0/0x10
> Feb  9 14:39:54 rhel6-test kernel: [ 4209.141582] Code: 35 f0 19 c1 00 48 85 f6 75 25 48 c7 05 e8 19 c1 00 01 00 00 00 48 8b 05 49 54 a5 00 48 05 60 ea 00 00 48 89 05 dc 19 c1 00 eb 83 <0f> 0b eb fe 48 c7 c7 30 5a 7a 81 31 c0 e8 e0 f0 45 00 48 c7 05
> 
> ==
> 
> 2nd log, "kernel BUG at include/linux/mm.h:420!" is  This one.
> ==
> static inline void __ClearPageBuddy(struct page *page)
> {
>         VM_BUG_ON(!PageBuddy(page));
>         atomic_set(&page->_mapcount, -1);
> }
> ==
> But this is just a tail of bad_page().
> ==
> static void bad_page(struct page *page)
> {
>         static unsigned long resume;
>         static unsigned long nr_shown;
>         static unsigned long nr_unshown;
> ...
>         dump_stack();
> out:
>         /* Leave bad fields for debug, except PageBuddy could make trouble */
>         __ClearPageBuddy(page);
>         add_taint(TAINT_BAD_PAGE);
> }
> ==
> So, what important is bad_page().
> 
> BAD page says
> ==
> BUG: Bad page state in process khugepaged  pfn:1e9800
> page:ffffea0006b14000 count:0 mapcount:0 mapping:          (null) index:0x2800
> page flags: 0x40000000004000(head)
> pc:ffff880214a30000 pc->flags:2146246697418756 pc->mem_cgroup:ffffc9000177a000
> ==
> 
> Maybe page_mapcount(page) was > 0. and ->mapping was NULL.
> 
> BTW, I think pc->flags should be printed in hex...Nishimura-san, how do you think ?
> 
Agreed.
I don't enough time this week, so I'll prepare a patch in next week if necessary.

> 
> In hex, pc->flags was 7A00000000004 and this means PCG_USED bit is set.
> This implies page_remove_rmap() may not be called but ->mapping is NULL. Hmm?
> (7A is encoding of section number.)
> 
Sigh.. it seems another freed-but-not-uncharged problem..

> make -j 8 under 200M limit is highly busy with swap.
> 
I'll try, and look at the issue too.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

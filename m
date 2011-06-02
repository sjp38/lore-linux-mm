Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A06836B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 11:37:21 -0400 (EDT)
Date: Thu, 2 Jun 2011 08:36:41 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602153641.GJ23047@sequoia.sous-sol.org>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602143143.GI23047@sequoia.sous-sol.org>
 <20110602143622.GE19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602143622.GE19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@sous-sol.org>, CAI Qian <caiqian@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> On Thu, Jun 02, 2011 at 07:31:43AM -0700, Chris Wright wrote:
> > * CAI Qian (caiqian@redhat.com) wrote:
> > > madvise(0x2210000, 4096, 0xc /* MADV_??? */) = 0
> > > --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> > 
> > Right, that's just what the program is trying to do, segfault.
> > 
> > > +++ killed by SIGSEGV (core dumped) +++
> > > Segmentation fault (core dumped)
> > > 
> > > Did I miss anything?
> > 
> > I found it works but not 100% of the time.
> > 
> > So I just run the bug in a loop.
> 
> echo 0 >scan_millisecs helps.

BTW, here's my stack trace (I dropped back to 2.6.39 just to see if it
happened to be recent regression).  It looks like mm_slot is off the list:

R10: dead000000200200 R11: dead000000100100

w/ ->mm == NULL.  Smells like use after free, but doesn't quite all add up.

BUG: unable to handle kernel 
ksmd-bug[14824]: segfault at 0 ip 0000000000400677 sp 00007fff987cb8b0 error 6 in ksmd-bug[400000+1000]
NULL pointer dereference at 0000000000000060
IP: [<ffffffff815be345>] down_read+0x19/0x28
PGD 0 
Oops: 0002 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu15/cache/index2/shared_cpu_map
CPU 6 
Modules linked in: bridge stp vhost_net macvtap macvlan tun kvm_intel kvm ixgbe mdio igb [last unloaded: scsi_wait_scan]

Pid: 825, comm: ksmd Not tainted 2.6.39+ #23 Supermicro X8DTN/X8DTN
RIP: 0010:[<ffffffff815be345>]  [<ffffffff815be345>] down_read+0x19/0x28
RSP: 0018:ffff8801b5325e10  EFLAGS: 00010246
RAX: 0000000000000060 RBX: 0000000000000060 RCX: 00000000ffffffff
RDX: 0000000000000000 RSI: 0000000000000286 RDI: 0000000000000060
RBP: ffff8801b5325e20 R08: ffffffffffffffff R09: ffff8801b5325db0
R10: dead000000200200 R11: dead000000100100 R12: 0000000000000000
R13: ffffffff81a20e60 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88033fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000060 CR3: 0000000001a03000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksmd (pid: 825, threadinfo ffff8801b5324000, task ffff8801b55196b0)
Stack:
 ffff8801b5325e20 0000000000000060 ffff8801b5325ee0 ffffffff810eec3a
 ffff88033fd51cc0 ffff8801b5325e80 ffff8801b5325ee0 ffffffff00000000
 ffff8801b55196b0 ffff8801b5325e98 ffff8801b5324000 00000064b5324010
Call Trace:
 [<ffffffff810eec3a>] ksm_scan_thread+0x12d/0xc47
 [<ffffffff8105a6e7>] ? wake_up_bit+0x2a/0x2a
 [<ffffffff810eeb0d>] ? try_to_merge_with_ksm_page+0x498/0x498
 [<ffffffff8105a25e>] kthread+0x82/0x8a
 [<ffffffff815c6354>] kernel_thread_helper+0x4/0x10
 [<ffffffff8105a1dc>] ? kthread_worker_fn+0x13f/0x13f
 [<ffffffff815c6350>] ? gs_change+0xb/0xb
Code: 48 0f c1 10 48 85 d2 74 05 e8 98 84 c8 ff 58 5b c9 c3 55 48 89 e5 53 48 83 ec 08 0f 1f 44 00 00 48 89 fb e8 85 f4 ff ff 48 89 d8 <f0> 48 ff 00 79 05 e8 40 84 c8 ff 5a 5b c9 c3 55 48 89 e5 0f 1f 
RIP  [<ffffffff815be345>] down_read+0x19/0x28
 RSP <ffff8801b5325e10>
CR2: 0000000000000060

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

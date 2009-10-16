Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C37866B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 05:19:06 -0400 (EDT)
From: Arnout Vandecappelle <arnout@mind.be>
Subject: Re: [Bug 14403] New: Kernel freeze when going out of memory
Date: Fri, 16 Oct 2009 11:16:50 +0200
References: <bug-14403-27@http.bugzilla.kernel.org/> <20091015163345.4898b34e.akpm@linux-foundation.org>
In-Reply-To: <20091015163345.4898b34e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_CoD2KDw3DDl7SWJ"
Message-Id: <200910161116.50893.arnout@mind.be>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Peter Trekels <peter.trekels@quesd.com>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_CoD2KDw3DDl7SWJ
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

On Friday 16 Oct 2009 01:33:45 Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 14 Oct 2009 11:44:08 GMT
> 
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=14403
> >
> >            Summary: Kernel freeze when going out of memory
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.24.6 through 2.6.31.1
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: arnout@mind.be
> >                 CC: arnout@mind.be
> >         Regression: No
> >
> >
> > Created an attachment (id=23404)
> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=23404)
> > console log during freeze (bzip2)
> >
> > I get very frequent kernel freezes on two of my systems when they go out
> > of memory.  This happens with all kernels I tried (2.6.24 through
> > 2.6.31).  These systems run a set of applications that occupy most of the
> > memory, they have no swap space, and they have very high network and disk
> > activity (xfs).  The network chip varies (tg3, bnx2, r8169).
> >
> > Symptoms are that no user processes make any progress, though SysRq
> > interaction is still possible.  SysRq-I recovers the system (init starts
> > new gettys).
> >
> > During the freeze, there are a lot of page allocation failures from the
> > network interrupt handler.  There doesn't seem to be any invocation of
> > the OOM killer (I can't find any 'kill process ... score ...' messages),
> > although before the freeze the OOM killer is usually called successfully
> > a couple of times.  Note that the killed processes are restarted soon
> > after (but with lower memory consumption).
> >
> > During the freeze, pinging and arping the system is (usually) still
> > possible. There is very little traffic on the network interface, most of
> > it is broadcast. There are also TCP ACKs still going around.  The amount
> > of page allocation failures seems to correspond more or less with the
> > amount of traffic on the interface, but it's hard to be sure (serial line
> > has delay and printks are not timestamped).  Still, some skb allocations
> > must be successful or the ping would never get a reply.
> >
> > Manual invocation of the OOM killer doesn't seem to do anything (nothing
> > is killed, no memory is freed).
> >
> > Attached is a long log taken over the serial console.  In the beginning
> > there are some invocations of the OOM killer which bring userspace back
> > (as can be seen from the syslog output that appears after a while). 
> > Then, while the system is frozen there is a continuous stream of page
> > allocation failures (2158 in this hour).  This log corresponds to about 1
> > hour of frozen time (from 11:48 till 12:47).  In this time I did a couple
> > of SysRq-T's, a SysRq-F with no results, a SysRq-E with no results (not
> > surprising since userspace is never invoked), and finally a SysRq-I where
> > the SysRq-M immediately before and after show that it was successful.
> >
> > About the memory usage: 620MB is due to files in tmpfs that I created in
> > order to trigger the out of memory situation sooner.
> 
> It would help if we could see the result of the sysrq-t output when the
> kernel is frozen.
> 
> - enable and configure a serial console or netconsole
>   (Documentation/networking/netconsole.txt)
> 
> - boot with log_buf_len=1M
> 
> - run `dmesg -n 7'
> 
> - freeze the kernel
> 
> - hit sysrq-t
> 
> - send us the resulting output.  Please don't let it get wordwrapped
>   by your email client!

 Hoi,

 The SysRq-t output was already in my original bug report.  For your 
convenience, I've extracted just the SysRq-T part in the attached log.  The 
output was intermingled with some page allocation failures, but these I've 
removed again.  I've left in a few page allocation failures, hung tasks and a 
SysRq-l for good measure.

 I'm now trying to reproduce it with fewer processes and loaded modules.

 Regards,
 Arnout

-- 
Arnout Vandecappelle                               arnout at mind be
Senior Embedded Software Architect                 +32-16-286540
Essensium/Mind                                     http://www.mind.be
G.Geenslaan 9, 3001 Leuven, Belgium                BE 872 984 063 RPR Leuven
LinkedIn profile: http://www.linkedin.com/in/arnoutvandecappelle
GPG fingerprint:  D206 D44B 5155 DF98 550D  3F2A 2213 88AA A1C7 C933

--Boundary-00=_CoD2KDw3DDl7SWJ
Content-Type: text/x-log;
  charset="ISO-8859-1";
  name="zero.ttyS0.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="zero.ttyS0.log"

SysRq : Show State
  task                        PC stack   pid father
init          R  running task        0     1      0
 ffff88007fb798f8 0000000000000082 00000001001b43fb ffffffff8024ea20
 ffffffff807bb000 ffff88007fb76040 ffff88004c3da400 ffff88007fb76380
 000000037fb798a8 ffffffff8054af27 ffffffff806c8918 ffff88007fb798a8
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] ? __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] ? congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e1a4>] ? throttle_vm_writeout+0x94/0xb0
 [<ffffffff80292ddd>] ? shrink_zone+0x2ad/0x350
 [<ffffffff80294052>] ? try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff802b5e00>] ? check_poison_obj+0x40/0x1d0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd707>] ? poll_select_copy_remaining+0xf7/0x150
 [<ffffffff802ced0c>] ? sys_select+0x5c/0x110
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
kthreadd      S ffff880064349d60     0     2      0
 ffff88007fb7ded0 0000000000000046 0000000000000082 ffff880064349d90
 ffffffff807bb000 ffff88007fb7a080 ffff880078836940 ffff88007fb7a3c0
 000000017fb7de60 ffffffff8023b5ad ffff88007fb7a3c0 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8025a548>] kthreadd+0x198/0x1a0
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a3b0>] ? kthreadd+0x0/0x1a0
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
migration/0   S 0000000000000000     0     3      2
 ffff88007fb83ed0 0000000000000046 0000000000000082 ffff880002f17e50
 ffffffff807bb000 ffff88007fb800c0 ffff88007f068480 ffff88007fb80400
 000000007fb83e60 ffff88007f068480 ffff88007fb80400 ffff880001020460
Call Trace:
 [<ffffffff802347b8>] ? move_one_task_fair+0x58/0xc0
 [<ffffffff8023f934>] migration_thread+0x1e4/0x290
 [<ffffffff8023f750>] ? migration_thread+0x0/0x290
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ksoftirqd/0   S ffffffff80560200     0     4      2
 ffff88007fb87f00 0000000000000046 ffff88001ffce400 ffff88007fb84448
 ffffffff807bb000 ffff88007fb84100 ffffffff806b0340 ffff88007fb84440
 000000007fb87f20 00000001001a4b31 ffff88007fb84440 0000000000000000
Call Trace:
 [<ffffffff80249625>] ksoftirqd+0xb5/0x100
 [<ffffffff80249570>] ? ksoftirqd+0x0/0x100
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
watchdog/0    S 000000000000018b     0     5      2
 ffff88007fb8bed0 0000000000000046 ffff88007fb8be50 0000000000000282
 ffffffff807bb000 ffff88007fb88140 ffff8800139888c0 ffff88007fb88480
 0000000001019b40 ffffffff807c2b40 ffff88007fb88480 ffffffff802601e3
Call Trace:
 [<ffffffff802601e3>] ? sched_clock_cpu+0x143/0x190
 [<ffffffff8027d82d>] watchdog+0x7d/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
migration/1   S ffffffff80560200     0     6      2
 ffff88007fb91ed0 0000000000000046 0000000000000082 ffff88002194be50
 ffffffff807bb000 ffff88007fb8e180 ffff88007fba0240 ffff88007fb8e4c0
 000000017fb91e60 0000000100181cc9 ffff88007fb8e4c0 ffffffff8023428a
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8023f934>] migration_thread+0x1e4/0x290
 [<ffffffff8023f750>] ? migration_thread+0x0/0x290
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ksoftirqd/1   S 0000000000000001     0     7      2
 ffff88007fb99f00 0000000000000046 ffff880002f8a900 ffff88007fb92508
 ffffffff807bb000 ffff88007fb921c0 ffff880036dee500 ffff88007fb92500
 0000000100000000 0000000100181e18 ffff88007fb92500 ffff88007fb99fd8
Call Trace:
 [<ffffffff803e9460>] ? kobject_release+0x0/0xa0
 [<ffffffff80249625>] ksoftirqd+0xb5/0x100
 [<ffffffff80249570>] ? ksoftirqd+0x0/0x100
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
watchdog/1    S ffffffff8027d7b0     0     8      2
 ffff88007fb9ded0 0000000000000046 ffff88007fb9de50 0000000000000282
 ffffffff807bb000 ffff88007fb9a200 ffff880002f8a900 ffff88007fb9a540
 0000000101025b40 ffffffff807c2b40 ffff88007fb9a540 ffffffff802601e3
Call Trace:
 [<ffffffff802601e3>] ? sched_clock_cpu+0x143/0x190
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d82d>] watchdog+0x7d/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
migration/2   S ffffffff80560200     0     9      2
 ffff88007fbcbed0 0000000000000046 ffff88007fbcbe40 ffff88007bc06680
 ffffffff807bb000 ffff88007fbc8280 ffff88007f1de300 ffff88007fbc85c0
 00000002802346db ffff88007bc06680 ffff88007fbc85c0 ffff8800010145a0
Call Trace:
 [<ffffffff802347ef>] ? move_one_task_fair+0x8f/0xc0
 [<ffffffff8023f934>] migration_thread+0x1e4/0x290
 [<ffffffff8023f750>] ? migration_thread+0x0/0x290
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ksoftirqd/2   S 0000000000000001     0    10      2
 ffff88007fbd3f00 0000000000000046 ffff880008adc280 ffff88007fbd0608
 ffffffff807bb000 ffff88007fbd02c0 ffff8800369b4380 ffff88007fbd0600
 0000000202ec2ce0 0000000100181d6c ffff88007fbd0600 ffff88007fbd3fd8
Call Trace:
 [<ffffffff80249625>] ksoftirqd+0xb5/0x100
 [<ffffffff80249570>] ? ksoftirqd+0x0/0x100
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
watchdog/2    S ffffffff8027d7b0     0    11      2
 ffff88007fbd9ed0 0000000000000046 ffff88007fbd9e50 0000000000000282
 ffffffff807bb000 ffff88007fbd6300 ffff88007f2e40c0 ffff88007fbd6640
 0000000201031b40 ffffffff807c2b40 ffff88007fbd6640 ffffffff802601e3
Call Trace:
 [<ffffffff802601e3>] ? sched_clock_cpu+0x143/0x190
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d82d>] watchdog+0x7d/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
migration/3   S ffffffff80560200     0    12      2
 ffff88007f007ed0 0000000000000046 ffff88007f007e40 ffff8800368c8300
 ffffffff807bb000 ffff88007f004380 ffff88007f076540 ffff88007f0046c0
 00000003802346db ffff8800368c8300 ffff88007f0046c0 ffff88000102c460
Call Trace:
 [<ffffffff802347ef>] ? move_one_task_fair+0x8f/0xc0
 [<ffffffff8023f934>] migration_thread+0x1e4/0x290
 [<ffffffff8023f750>] ? migration_thread+0x0/0x290
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ksoftirqd/3   S 0000000000000001     0    13      2
 ffff88007f02ff00 0000000000000046 ffff880002e1c100 ffff88007f02c708
 ffffffff807bb000 ffff88007f02c3c0 ffff8800688aa100 ffff88007f02c700
 000000037f02ff20 00000001001b00e5 ffff88007f02c700 0000000000000000
Call Trace:
 [<ffffffff80249625>] ksoftirqd+0xb5/0x100
 [<ffffffff80249570>] ? ksoftirqd+0x0/0x100
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
watchdog/3    S ffffffff8027d7b0     0    14      2
 ffff88007f033ed0 0000000000000046 ffff88007f033e50 0000000000000282
 ffffffff807bb000 ffff88007f030400 ffff880011c72140 ffff88007f030740
 000000030103db40 ffffffff807c2b40 ffff88007f030740 ffffffff802601e3
Call Trace:
 [<ffffffff802601e3>] ? sched_clock_cpu+0x143/0x190
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8027d82d>] watchdog+0x7d/0x230
 [<ffffffff8027d7b0>] ? watchdog+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
events/0      S ffff88007f010768     0    15      2
 ffff88007f06bec0 0000000000000046 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88007f068480 ffff8800795441c0 ffff88007f0687c0
 000000007f010770 ffff88007fb7df00 ffff88007f0687c0 ffffffff80256ed5
Call Trace:
 [<ffffffff80256ed5>] ? queue_delayed_work_on+0x95/0xc0
 [<ffffffff8025728c>] ? queue_delayed_work+0x1c/0x30
 [<ffffffff802572b9>] ? schedule_delayed_work+0x19/0x20
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
events/1      R  running task        0    16      2
 ffff88007f06fec0 0000000000000046 ffff88007f0106d0 ffff8800795b6098
 ffffffff807bb000 ffff88007f06c4c0 ffff8800688aa100 ffff88007f06c800
 00000001379dcdd8 ffff8800379dcd58 ffff88007f06c800 ffff8800379dccc0
Call Trace:
 [<ffffffff8044eba0>] ? flush_to_ldisc+0x0/0x1f0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
events/2      R  running task        0    17      2
 ffff88007f073ec0 0000000000000046 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88007f070500 ffff88002b952180 ffff88007f070840
 000000027f010640 ffff88007fb7df00 ffff88007f070840 ffffffff80256ed5
Call Trace:
 [<ffffffff80256ed5>] ? queue_delayed_work_on+0x95/0xc0
 [<ffffffff8025728c>] ? queue_delayed_work+0x1c/0x30
 [<ffffffff802572b9>] ? schedule_delayed_work+0x19/0x20
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
events/3      R  running task        0    18      2
 ffff88007f079ec0 0000000000000046 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88007f076540 ffff88007f1e2340 ffff88007f076880
 000000037f0105a8 ffff88007fb7df00 ffff88007f076880 ffffffff80256ed5
Call Trace:
 [<ffffffff80256ed5>] ? queue_delayed_work_on+0x95/0xc0
 [<ffffffff8025728c>] ? queue_delayed_work+0x1c/0x30
 [<ffffffff802572b9>] ? schedule_delayed_work+0x19/0x20
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
khelper       S ffff88007f010508     0    19      2
 ffff88007f07dec0 0000000000000046 0000000000000000 ffff88007f07c000
 ffffffff807bb000 ffff88007f07a580 ffff880067da86c0 ffff88007f07a8c0
 00000001802561f0 0000000000000000 ffff88007f07a8c0 0000000000000010
Call Trace:
 [<ffffffff80255e14>] ? __call_usermodehelper+0x64/0x80
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kstop/0       S ffffffff80560200     0    22      2
 ffff88007f08bec0 0000000000000046 ffff88007f08be50 ffffffff8023428a
 ffffffff807bb000 ffff88007f088640 ffffffff806b0340 ffff88007f088980
 000000007f010d60 00000001000bc64a ffff88007f088980 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kstop/1       S ffff88007f010cc0     0    23      2
 ffff88007f091ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f08e680 ffff8800369b4380 ffff88007f08e9c0
 00000001807c2280 00000000fffedb83 ffff88007f08e9c0 0000000000000000
Call Trace:
 [<ffffffff803e7bfe>] ? __first_cpu+0xe/0x20
 [<ffffffff80278361>] ? stop_cpu+0xa1/0xf0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kstop/2       S ffffffff80560200     0    24      2
 ffff88007f095ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f0926c0 ffff88007fbda340 ffff88007f092a00
 00000002807c2280 00000001000bc64a ffff88007f092a00 0000000000000000
Call Trace:
 [<ffffffff803e7bfe>] ? __first_cpu+0xe/0x20
 [<ffffffff80278361>] ? stop_cpu+0xa1/0xf0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kstop/3       S ffffffff80560200     0    25      2
 ffff88007f099ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f096700 ffff88007f034440 ffff88007f096a40
 00000003807c2280 00000001000bc64a ffff88007f096a40 0000000000000000
Call Trace:
 [<ffffffff803e7bfe>] ? __first_cpu+0xe/0x20
 [<ffffffff80278361>] ? stop_cpu+0xa1/0xf0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kblockd/0     S ffff88007f0de430     0    94      2
 ffff88007f215ec0 0000000000000046 ffff88007f215e30 ffffffff803d7f6b
 ffffffff807bb000 ffff88007f2123c0 ffff88007d934540 ffff88007f212700
 0000000000000282 ffff8800375674a0 ffff88007f212700 ffffffff803d6ac7
Call Trace:
 [<ffffffff803d7f6b>] ? __generic_unplug_device+0x2b/0x40
 [<ffffffff803d6ac7>] ? blk_unplug_work+0x67/0x80
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kblockd/1     S ffff88007f0de398     0    95      2
 ffff88007f219ec0 0000000000000046 ffff88007f219e30 ffffffff803d7f6b
 ffffffff807bb000 ffff88007f216400 ffff88007f06c4c0 ffff88007f216740
 0000000100000282 ffff8800375674a0 ffff88007f216740 ffffffff803d6ac7
Call Trace:
 [<ffffffff803d7f6b>] ? __generic_unplug_device+0x2b/0x40
 [<ffffffff803d6ac7>] ? blk_unplug_work+0x67/0x80
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kblockd/2     S ffff88007f0de300     0    96      2
 ffff88007f21dec0 0000000000000046 ffff88007f21de30 ffffffff803d7f6b
 ffffffff807bb000 ffff88007f21a440 ffff88005c570280 ffff88007f21a780
 0000000200000282 ffff8800375674a0 ffff88007f21a780 ffffffff803d6ac7
Call Trace:
 [<ffffffff803d7f6b>] ? __generic_unplug_device+0x2b/0x40
 [<ffffffff803d6ac7>] ? blk_unplug_work+0x67/0x80
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kblockd/3     S ffff88007f0de268     0    97      2
 ffff88007f223ec0 0000000000000046 ffff88007f223e60 ffffffffa0031fc1
 ffffffff807bb000 ffff88007f220480 ffff88007f18c5c0 ffff88007f2207c0
 0000000300000282 ffff88007f0de270 ffff88007f2207c0 ffff88007fb7df00
Call Trace:
 [<ffffffffa0031fc1>] ? scsi_request_fn+0xd1/0x4a0 [scsi_mod]
 [<ffffffff803e34ab>] ? cfq_kick_queue+0x3b/0x50
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kacpid        S ffff88007f0debe8     0    99      2
 ffff88007f22dec0 0000000000000046 ffff88007f22de40 ffff88007fb7a080
 ffffffff807bb000 ffff88007f22a500 ffff88007fb7a080 ffff88007f22a840
 00000000807c2280 0000000000000000 ffff88007f22a840 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kacpi_notify  S ffffffff80560200     0   100      2
 ffff88007f231ec0 0000000000000046 ffff88007f231e40 ffff88007fb7a080
 ffffffff807bb000 ffff88007f22e540 ffff88007fba0240 ffff88007f22e880
 00000001807c2280 00000000fffedb8e ffff88007f22e880 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ksuspend_usbd S ffffffff80560200     0   187      2
 ffff88007f18bec0 0000000000000046 ffff88007fb7dee0 0000000000000000
 ffffffff807bb000 ffff88007f1424c0 ffff88007fbda340 ffff88007f142800
 00000002369b8ba8 000000010012757d ffff88007f142800 ffffffff80490160
Call Trace:
 [<ffffffff80490160>] ? usb_autopm_do_device+0xc0/0x110
 [<ffffffff80490930>] ? usb_autosuspend_work+0x0/0x20
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
khubd         S ffffffff80560200     0   193      2
 ffff88007f0b3da0 0000000000000046 ffff88007f0b3d10 ffffffff80233df8
 ffffffff807bb000 ffff88007f146500 ffff88007fbda340 ffff88007f146840
 000000023691af68 000000010012738a ffff88007f146840 ffff8800369b87b0
Call Trace:
 [<ffffffff80233df8>] ? activate_task+0x28/0x40
 [<ffffffff8048a19e>] hub_thread+0xdde/0x13b0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804893c0>] ? hub_thread+0x0/0x13b0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kseriod       S ffff88003794e560     0   196      2
 ffff88007f105eb0 0000000000000046 ffff88007f105e40 ffffffff802b6998
 ffffffff807bb000 ffff88007f14a540 ffff88007f2e40c0 ffff88007f14a880
 000000007f105ec0 0000000000000286 ffff88007f14a880 0000000000000286
Call Trace:
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8047d430>] ? __driver_attach+0x0/0xa0
 [<ffffffff8049f436>] serio_thread+0x356/0x400
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8049f0e0>] ? serio_thread+0x0/0x400
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kswapd0       R  running task        0   267      2
 ffff88003782fde0 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007f18c5c0 ffff88007b962580 ffff88007f18c900
 000000003782fd70 0000000000000000 ffff88007f18c900 ffffffff806c8840
Call Trace:
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80292fc7>] ? shrink_slab+0x147/0x180
 [<ffffffff802939fb>] kswapd+0x72b/0x740
 [<ffffffff802932d0>] ? kswapd+0x0/0x740
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802932d0>] ? kswapd+0x0/0x740
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
aio/0         S ffffffff80560200     0   268      2
 ffff880037805ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f154600 ffffffff806b0340 ffff88007f154940
 00000000807c2280 00000000fffee647 ffff88007f154940 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
aio/1         S ffffffff80560200     0   269      2
 ffff880037801ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f286780 ffff88007fba0240 ffff88007f286ac0
 00000001807c2280 00000000fffee647 ffff88007f286ac0 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
aio/2         S ffffffff80560200     0   270      2
 ffff880037831ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f290800 ffff88007fbda340 ffff88007f290b40
 00000002807c2280 00000000fffee647 ffff88007f290b40 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
aio/3         S ffffffff80560200     0   271      2
 ffff880037833ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f282740 ffff88007f034440 ffff88007f282a80
 00000003807c2280 00000000fffee647 ffff88007f282a80 ffff880001031280
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfs_mru_cache S ffffffff80560200     0   272      2
 ffff880037847ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007f274680 ffff88007fba0240 ffff88007f2749c0
 00000001807c2280 00000000fffee66d ffff88007f2749c0 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfslogd/0     S ffff88003781ec80     0   273      2
 ffff88003784bec0 0000000000000046 ffff88003784be20 ffffffff803956dc
 ffffffff807bb000 ffff880076fc4700 ffff880067d60440 ffff880076fc4a40
 000000003784be70 ffffffff80395510 ffff880076fc4a40 ffffffff803955c0
Call Trace:
 [<ffffffff803956dc>] ? xfs_buf_ioend+0x7c/0xb0
 [<ffffffff80395510>] ? xfs_buf_rele+0xb0/0xd0
 [<ffffffff803955c0>] ? xfs_buf_iodone_work+0x0/0xa0
 [<ffffffff803955eb>] ? xfs_buf_iodone_work+0x2b/0xa0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfslogd/1     S ffff88003781ebe8     0   274      2
 ffff88003784dec0 0000000000000046 ffff88003784de20 ffffffff803956dc
 ffffffff807bb000 ffff88007f2a8900 ffff88007d998880 ffff88007f2a8c40
 000000013784de70 ffffffff80395510 ffff88007f2a8c40 ffffffff803955c0
Call Trace:
 [<ffffffff803956dc>] ? xfs_buf_ioend+0x7c/0xb0
 [<ffffffff80395510>] ? xfs_buf_rele+0xb0/0xd0
 [<ffffffff803955c0>] ? xfs_buf_iodone_work+0x0/0xa0
 [<ffffffff803955eb>] ? xfs_buf_iodone_work+0x2b/0xa0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfslogd/2     S ffff88003781eb50     0   275      2
 ffff88003784fec0 0000000000000046 ffff88003784fe20 ffffffff803956dc
 ffffffff807bb000 ffff88007f1aa100 ffff8800795441c0 ffff88007f1aa440
 000000023784fe70 ffffffff80395510 ffff88007f1aa440 ffffffff803955c0
Call Trace:
 [<ffffffff803956dc>] ? xfs_buf_ioend+0x7c/0xb0
 [<ffffffff80395510>] ? xfs_buf_rele+0xb0/0xd0
 [<ffffffff803955c0>] ? xfs_buf_iodone_work+0x0/0xa0
 [<ffffffff803955eb>] ? xfs_buf_iodone_work+0x2b/0xa0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfslogd/3     S ffff88003781eab8     0   276      2
 ffff880037851ec0 0000000000000046 ffff880037851e20 ffffffff803956dc
 ffffffff807bb000 ffff88007f2b2980 ffff8800688aa100 ffff88007f2b2cc0
 0000000337851e70 ffffffff80395510 ffff88007f2b2cc0 ffffffff803955c0
Call Trace:
 [<ffffffff803956dc>] ? xfs_buf_ioend+0x7c/0xb0
 [<ffffffff80395510>] ? xfs_buf_rele+0xb0/0xd0
 [<ffffffff803955c0>] ? xfs_buf_iodone_work+0x0/0xa0
 [<ffffffff803955eb>] ? xfs_buf_iodone_work+0x2b/0xa0
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsdatad/0    D ffff880037873600     0   277      2
 ffff8800378735f0 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007f2b89c0 ffff88007b962580 ffff88007f2b8d00
 00000000378735a0 ffffffff8024ee66 ffff88007f2b8d00 ffff880037873600
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359f18>] xfs_btree_read_bufl+0x68/0x80
 [<ffffffff80356fa7>] xfs_bmbt_lookup+0x137/0x540
 [<ffffffff803573ea>] xfs_bmbt_lookup_eq+0x1a/0x20
 [<ffffffff8034d6fa>] xfs_bmap_add_extent_unwritten_real+0x43a/0xfd0
 [<ffffffff8037b4d8>] ? xlog_state_get_iclog_space+0x58/0x2d0
 [<ffffffff8034fab2>] xfs_bmap_add_extent+0x332/0x420
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff80359f6f>] ? xfs_btree_init_cursor+0x3f/0x220
 [<ffffffff803542f4>] xfs_bmapi+0xc14/0x12d0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8037d0ee>] ? xlog_grant_log_space+0x2be/0x430
 [<ffffffff803916b5>] ? kmem_zone_zalloc+0x35/0x50
 [<ffffffff803768f7>] xfs_iomap_write_unwritten+0x127/0x210
 [<ffffffff80392065>] xfs_end_bio_unwritten+0x65/0x80
 [<ffffffff80392000>] ? xfs_end_bio_unwritten+0x0/0x80
 [<ffffffff80256560>] run_workqueue+0x70/0x120
 [<ffffffff802566b7>] worker_thread+0xa7/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsdatad/1    D ffff880037875600     0   278      2
 ffff8800378755f0 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007f0a62c0 ffff88007f06c4c0 ffff88007f0a6600
 00000001378755a0 ffffffff8024ee66 ffff88007f0a6600 ffff880037875600
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359f18>] xfs_btree_read_bufl+0x68/0x80
 [<ffffffff80356fa7>] xfs_bmbt_lookup+0x137/0x540
 [<ffffffff803573ea>] xfs_bmbt_lookup_eq+0x1a/0x20
 [<ffffffff8034d83b>] xfs_bmap_add_extent_unwritten_real+0x57b/0xfd0
 [<ffffffff8034fab2>] xfs_bmap_add_extent+0x332/0x420
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff80359f6f>] ? xfs_btree_init_cursor+0x3f/0x220
 [<ffffffff803542f4>] xfs_bmapi+0xc14/0x12d0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8037d0ee>] ? xlog_grant_log_space+0x2be/0x430
 [<ffffffff803916b5>] ? kmem_zone_zalloc+0x35/0x50
 [<ffffffff803768f7>] xfs_iomap_write_unwritten+0x127/0x210
 [<ffffffff80392065>] xfs_end_bio_unwritten+0x65/0x80
 [<ffffffff80392000>] ? xfs_end_bio_unwritten+0x0/0x80
 [<ffffffff80256560>] run_workqueue+0x70/0x120
 [<ffffffff802566b7>] worker_thread+0xa7/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsdatad/2    R  running task        0   279      2
 ffff880037877270 0000000000000046 0000000000000000 ffff88005dc32920
 ffffffff807bb000 ffff88007f1de300 ffff8800368b2740 ffff88007f1de648
 0000000237877240 ffffffff802a1ea6 ffff88007f1de640 ffffffff802a1d93
Call Trace:
 [<ffffffff802a1ea6>] ? page_referenced_one+0xb6/0x120
 [<ffffffff802a1d93>] ? page_lock_anon_vma+0x33/0x40
 [<ffffffff80290c09>] ? isolate_pages_global+0xb9/0x250
 [<ffffffff8023fa00>] __cond_resched+0x20/0x50
 [<ffffffff8054bdf5>] _cond_resched+0x35/0x50
 [<ffffffff802921ea>] shrink_active_list+0x15a/0x470
 [<ffffffff80292a55>] shrink_list+0x555/0x630
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff80292d8b>] shrink_zone+0x25b/0x350
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359f18>] xfs_btree_read_bufl+0x68/0x80
 [<ffffffff80356fa7>] xfs_bmbt_lookup+0x137/0x540
 [<ffffffff803573ea>] xfs_bmbt_lookup_eq+0x1a/0x20
 [<ffffffff8034de31>] xfs_bmap_add_extent_unwritten_real+0xb71/0xfd0
 [<ffffffff8037b4d8>] ? xlog_state_get_iclog_space+0x58/0x2d0
 [<ffffffff8034fab2>] xfs_bmap_add_extent+0x332/0x420
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff80359f6f>] ? xfs_btree_init_cursor+0x3f/0x220
 [<ffffffff803542f4>] xfs_bmapi+0xc14/0x12d0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8037d0ee>] ? xlog_grant_log_space+0x2be/0x430
 [<ffffffff803916b5>] ? kmem_zone_zalloc+0x35/0x50
 [<ffffffff803768f7>] xfs_iomap_write_unwritten+0x127/0x210
 [<ffffffff80392065>] xfs_end_bio_unwritten+0x65/0x80
 [<ffffffff80392000>] ? xfs_end_bio_unwritten+0x0/0x80
 [<ffffffff80256560>] run_workqueue+0x70/0x120
 [<ffffffff802566b7>] worker_thread+0xa7/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsdatad/3    R  running task        0   280      2
 ffff880037879450 0000000000000046 ffffe200019c19e0 0000000000000000
 ffffffff807bb000 ffff88007f1e2340 ffff88007d934540 ffff88007f1e2680
 0000000337879400 ffffffff8024ee66 ffff88007f1e2680 ffff880037879460
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80292454>] ? shrink_active_list+0x3c4/0x470
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e1a4>] throttle_vm_writeout+0x94/0xb0
 [<ffffffff80292ddd>] shrink_zone+0x2ad/0x350
 [<ffffffff8024eefa>] ? try_to_del_timer_sync+0x5a/0x70
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359f18>] xfs_btree_read_bufl+0x68/0x80
 [<ffffffff80356fa7>] xfs_bmbt_lookup+0x137/0x540
 [<ffffffff803573ea>] xfs_bmbt_lookup_eq+0x1a/0x20
 [<ffffffff8034de31>] xfs_bmap_add_extent_unwritten_real+0xb71/0xfd0
 [<ffffffff8037b4d8>] ? xlog_state_get_iclog_space+0x58/0x2d0
 [<ffffffff8034fab2>] xfs_bmap_add_extent+0x332/0x420
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff80359f6f>] ? xfs_btree_init_cursor+0x3f/0x220
 [<ffffffff803542f4>] xfs_bmapi+0xc14/0x12d0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8037d0ee>] ? xlog_grant_log_space+0x2be/0x430
 [<ffffffff803916b5>] ? kmem_zone_zalloc+0x35/0x50
 [<ffffffff803768f7>] xfs_iomap_write_unwritten+0x127/0x210
 [<ffffffff80392065>] xfs_end_bio_unwritten+0x65/0x80
 [<ffffffff80392000>] ? xfs_end_bio_unwritten+0x0/0x80
 [<ffffffff80256560>] run_workqueue+0x70/0x120
 [<ffffffff802566b7>] worker_thread+0xa7/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kipmi0        R  running task        0   384      2
 ffff8800379efe90 0000000000000046 ffffffff80466dd0 ffff88007fb68d90
 ffffffff807bb000 ffff88007f2e40c0 ffff8800795441c0 ffff88007f2e4400
 00000001379efe40 00000001001b4e69 ffff88007f2e4400 ffff8800379efea0
Call Trace:
 [<ffffffff80466dd0>] ? free_smi_msg+0x10/0x20
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8046abe9>] ? start_next_msg+0xf9/0x140
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8046b61d>] ipmi_thread+0x6d/0xa0
 [<ffffffff8046b5b0>] ? ipmi_thread+0x0/0xa0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ata/0         S ffff880036df46d0     0   891      2
 ffff880036c0dec0 0000000000000046 ffff880036c0de40 ffff88007f2e8100
 ffffffff807bb000 ffff88007f2ae940 ffff88007f2e8100 ffff88007f2aec80
 00000000807c2280 0000000000000000 ffff88007f2aec80 ffff88007fb7dee0
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ata/1         S ffffffff80560200     0   895      2
 ffff8800375f5ec0 0000000000000046 ffff88007e841ca0 ffffffff8024ea20
 ffffffff807bb000 ffff88003753e400 ffff88007fba0240 ffff88003753e740
 000000017e840000 00000000fffeee33 ffff88003753e740 ffff88007fb7df00
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffffa00dd737>] ? ata_pio_task+0x37/0x110 [libata]
 [<ffffffffa00dd700>] ? ata_pio_task+0x0/0x110 [libata]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_0     S ffffffff80560200     0   899      2
 ffff880036d8be70 0000000000000046 ffff880036544200 ffff880036544238
 ffffffff807bb000 ffff880036544200 ffff88007fbda340 ffff880036544540
 0000000200000001 00000000fffeea89 ffff880036544540 ffff88007f2e8148
Call Trace:
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
mpt_poll_0    S ffff880036df4df0     0   901      2
 ffff8800375f1ec0 0000000000000046 0000000000000082 ffff880037972000
 ffffffff807bb000 ffff8800375ae280 ffff88007e8bc940 ffff8800375ae5c0
 00000000375f1e50 ffffffff80256ed5 ffff8800375ae5c0 0000000000000246
Call Trace:
 [<ffffffff80256ed5>] ? queue_delayed_work_on+0x95/0xc0
 [<ffffffffa00bdb27>] ? mpt_fault_reset_work+0x87/0x170 [mptbase]
 [<ffffffffa00bdaa0>] ? mpt_fault_reset_work+0x0/0x170 [mptbase]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ata/2         S ffffffff80560200     0   902      2
 ffff880036da5ec0 0000000000000046 ffff88007e840180 ffff88007fb7a080
 ffffffff807bb000 ffff880036da22c0 ffff88007fbda340 ffff880036da2600
 000000027e840000 00000000fffeee33 ffff880036da2600 ffff88007fb7df00
Call Trace:
 [<ffffffffa00dd737>] ? ata_pio_task+0x37/0x110 [libata]
 [<ffffffffa00dd700>] ? ata_pio_task+0x0/0x110 [libata]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ata/3         S ffffffff80560200    0   903      2
 ffff880036d27ec0 0000000000000046 ffff88007e840180 ffff88007fb7a080
 ffffffff807bb000 ffff88003756e200 ffff88007f034440 ffff88003756e540
 000000037e840000 00000000fffeee33 ffff88003756e540 ffff88007fb7df00
Call Trace:
 [<ffffffffa00dd737>] ? ata_pio_task+0x37/0x110 [libata]
 [<ffffffffa00dd700>] ? ata_pio_task+0x0/0x110 [libata]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ata_aux       S ffffffff80560200     0   904      2
 ffff880036c1bec0 0000000000000046 ffff880036c1be40 ffff880036ff8600
 ffffffff807bb000 ffff880036c30300 ffff88007fba0240 ffff880036c30640
 00000001807c2280 00000000fffeea8d ffff880036c30640 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_1     S ffff88003699a688     0   915      2
 ffff8800365ffe70 0000000000000046 0000000000000082 0000000000000082
 ffffffff807bb000 ffff8800369ba5c0 ffff880036c66780 ffff8800369ba900
 0000000200000282 000000000000000f ffff8800369ba900 0000000000000246
Call Trace:
 [<ffffffffa002c467>] ? __scsi_iterate_devices+0x67/0xa0 [scsi_mod]
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_2     S ffffffff80560200     0   950      2
 ffff88003741be70 0000000000000046 0000000000000082 0000000000000082
 ffffffff807bb000 ffff880036d3e4c0 ffff88007f034440 ffff880036d3e800
 0000000300000282 00000000fffeee33 ffff880036d3e800 0000000000000246
Call Trace:
 [<ffffffffa002c467>] ? __scsi_iterate_devices+0x67/0xa0 [scsi_mod]
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
aacraid       S ffff88003741dde0     0   957      2
 ffff88003741ddd0 0000000000000046 ffffffff80250f21 ffff880077c63458
 ffffffff807bb000 ffff880037594280 ffff88005e930840 ffff8800375945c0
 000000033741dd80 ffffffff8024ee66 ffff8800375945c0 ffff88003741dde0
Call Trace:
 [<ffffffff80250f21>] ? complete_signal+0x121/0x220
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffffa0118f60>] ? aac_command_thread+0x0/0x8c0 [aacraid]
 [<ffffffffa01194fb>] aac_command_thread+0x59b/0x8c0 [aacraid]
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffffa0118f60>] ? aac_command_thread+0x0/0x8c0 [aacraid]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_3     S ffffffff80560200     0   960      2
 ffff880036d95e70 0000000000000046 ffff88003656a580 ffff88003656a5b8
 ffffffff807bb000 ffff88003656a580 ffff88007f034440 ffff88003656a8c0
 0000000300000001 00000000fffeed87 ffff88003656a8c0 ffff88007fb7a0c8
Call Trace:
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
usb-storage   S 7fffffffffffffff     0   961      2
 ffff8800378a1dd0 0000000000000046 ffff8800378a1d70 ffffffffa0134196
 ffffffff807bb000 ffff880036dee500 ffff88007fbd02c0 ffff880036dee840
 000000027fbd02f8 0000000000000001 ffff880036dee840 ffffffff80238ab8
Call Trace:
 [<ffffffffa0134196>] ? usb_stor_msg_common+0x126/0x180 [usb_storage]
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff802337a9>] ? wakeup_preempt_entity+0x59/0x60
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffffa0134976>] ? usb_stor_invoke_transport+0x186/0x2c0 [usb_storage]
 [<ffffffff8054b1b5>] wait_for_common+0x145/0x170
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8054b238>] wait_for_completion_interruptible+0x18/0x30
 [<ffffffffa0136197>] usb_stor_control_thread+0x67/0x220 [usb_storage]
 [<ffffffffa0136130>] ? usb_stor_control_thread+0x0/0x220 [usb_storage]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
hid_compat    S ffffffff80560200     0  1013      2
 ffff880037515ec0 0000000000000046 ffff880037515e40 ffff88007fb7a080
 ffffffff807bb000 ffff880036c32600 ffff88007fbda340 ffff880036c32940
 00000002807c2280 00000000fffeef6b ffff880036c32940 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_4     S ffff88003792c000     0  1043      2
 ffff880036893e70 0000000000000046 ffff880036893e60 0000000000000000
 ffffffff807bb000 ffff88003788c180 ffff880076fba680 ffff88003788c4c0
 0000000100000001 0000000000000000 ffff88003788c4c0 ffff880001025280
Call Trace:
 [<ffffffff8023e69f>] ? finish_task_switch+0x2f/0xd0
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
usb-storage   S 7fffffffffffffff     0  1045      2
 ffff8800379cbdd0 0000000000000046 ffff8800379cbd70 ffffffffa0134196
 ffffffff807bb000 ffff880037894200 ffff88007fb921c0 ffff880037894540
 000000017fb921f8 0000000000000001 ffff880037894540 ffffffff80238be4
Call Trace:
 [<ffffffffa0134196>] ? usb_stor_msg_common+0x126/0x180 [usb_storage]
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff802337a9>] ? wakeup_preempt_entity+0x59/0x60
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffffa0134976>] ? usb_stor_invoke_transport+0x186/0x2c0 [usb_storage]
 [<ffffffff8054b1b5>] wait_for_common+0x145/0x170
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8054b238>] wait_for_completion_interruptible+0x18/0x30
 [<ffffffffa0136197>] usb_stor_control_thread+0x67/0x220 [usb_storage]
 [<ffffffffa0136130>] ? usb_stor_control_thread+0x0/0x220 [usb_storage]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
scsi_eh_5     S ffffffff80560200     0  1105      2
 ffff88003743de70 0000000000000046 ffff8800375ea280 ffff8800375ea2b8
 ffffffff807bb000 ffff8800375ea280 ffffffff806b0340 ffff8800375ea5c0
 0000000000000001 00000000fffefbda ffff8800375ea5c0 000000000000043d
Call Trace:
 [<ffffffff80233d86>] ? dequeue_task+0x96/0xe0
 [<ffffffffa0030a54>] scsi_error_handler+0x74/0x380 [scsi_mod]
 [<ffffffffa00309e0>] ? scsi_error_handler+0x0/0x380 [scsi_mod]
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kjournald     S ffff88003643656c     0  1311      2
 ffff880036dddea0 0000000000000046 0000000036ddde00 ffff88003e05603c
 ffffffff807bb000 ffff88003753a540 ffff880067d60440 ffff88003753a880
 000000021b4be6d0 000000008024ee66 ffff88003753a880 ffff8800364365d8
Call Trace:
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
udevd         S ffffffff80560200     0  1394      1
 ffff8800378b3978 0000000000000082 ffff880036c1e1c0 0000000000000000
 ffffffff807bb000 ffff880036c1e1c0 ffffffff806b0340 ffff880036c1e500
 0000000000000000 00000001000c04b6 ffff880036c1e500 ffff880000002c00
Call Trace:
 [<ffffffff802b2d2c>] ? shmem_swp_entry+0x10c/0x190
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff802ce60c>] do_select+0x4ec/0x6a0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff803ef639>] ? snprintf+0x59/0x60
 [<ffffffff802cff7a>] ? dput+0xaa/0x160
 [<ffffffff802c7132>] ? __follow_mount+0x32/0xb0
 [<ffffffff802c73d7>] ? do_lookup+0x147/0x260
 [<ffffffff803ae65c>] ? security_inode_permission+0x1c/0x20
 [<ffffffff802c6d5e>] ? inode_permission+0x8e/0xc0
 [<ffffffff802ce978>] core_sys_select+0x1b8/0x2e0
 [<ffffffff802d14f1>] ? __d_lookup+0xb1/0x150
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802ca77c>] ? do_rmdir+0xbc/0x120
 [<ffffffff8025ac66>] ? remove_wait_queue+0x46/0x60
 [<ffffffff802473d0>] ? do_wait+0x2b0/0x350
 [<ffffffff802cecfa>] sys_select+0x4a/0x110
 [<ffffffff80247511>] ? sys_wait4+0xa1/0xf0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
kjournald     S ffffffff80560200     0  2328      2
 ffff88007e83dea0 0000000000000046 ffff88007e83de00 0000000000000005
 ffffffff807bb000 ffff88007acbc800 ffff88007fba0240 ffff88007acbcb40
 000000017e83de60 00000000ffff0ec8 ffff88007acbcb40 ffff8800364367f0
Call Trace:
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
rsyslogd      R  running task        0  2511      1
 ffff88007b955a38 0000000000000082 ffff88007b9559b8 0000000000000080
 ffffffff807bb000 ffff8800369b0340 ffff88002b952180 ffff8800369b0680
 000000007b9559e8 ffffffff8024ee66 ffff8800369b0680 ffff88007b955a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff80251151>] ? send_signal+0x131/0x2e0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd707>] ? poll_select_copy_remaining+0xf7/0x150
 [<ffffffff802ced0c>] ? sys_select+0x5c/0x110
 [<ffffffff8054de79>] error_exit+0x0/0x51
rsyslogd      S 0000000000000000     0  2513      1
 ffff880036cd7978 0000000000000082 ffff880036cd78e8 ffffffff802e6581
 ffffffff807bb000 ffff880037466700 ffff880002ee0040 ffff880037466a40
 0000000236cd7928 ffffffff803d5b6b ffff880037466a40 ffff8800173eee28
Call Trace:
 [<ffffffff802e6581>] ? bio_phys_segments+0x21/0x30
 [<ffffffff803d5b6b>] ? __elv_add_request+0x7b/0xd0
 [<ffffffff803d8927>] ? __make_request+0xf7/0x4b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8052bca8>] ? unix_dgram_poll+0x118/0x1d0
 [<ffffffff802ce60c>] do_select+0x4ec/0x6a0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff804bd9d7>] ? kfree_skb+0x17/0x40
 [<ffffffff804c00d4>] ? skb_free_datagram+0x14/0x40
 [<ffffffff8052a9d0>] ? unix_dgram_recvmsg+0x1f0/0x370
 [<ffffffff804b6489>] ? sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802ce978>] core_sys_select+0x1b8/0x2e0
 [<ffffffff802678d3>] ? do_futex+0x93/0xad0
 [<ffffffff804b77eb>] ? sys_recvfrom+0xeb/0x110
 [<ffffffff802cecfa>] sys_select+0x4a/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
rsyslogd      D ffff88007c0b5a48     0  2514      1
 ffff88007c0b5a38 0000000000000082 0000000000070309 0000000000000080
 ffffffff807bb000 ffff8800369b4380 ffff88005b1b8500 ffff8800369b46c0
 000000017c0b59e8 ffffffff8024ee66 ffff8800369b46c0 ffff88007c0b5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff802373b1>] dequeue_task_fair+0x281/0x290
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802453d8>] do_syslog+0x3a8/0x480
 [<ffffffff8025a970>] autoremove_wake_function+0x0/0x40
 [<ffffffff803049a3>] pde_users_dec+0x23/0x60
 [<ffffffff80304d02>] proc_reg_read+0x82/0xb0
 [<ffffffff802bf239>] vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
acpid         S 0000000000000000     0  2554      1
 ffff88007b9c5ac8 0000000000000082 ffff88007b9c5a38 ffffffff80233df8
 ffffffff807bb000 ffff88007ad9a400 ffff88007ad8a700 ffff88007ad9a740
 0000000136986cc8 0000000000000282 ffff88007ad9a740 ffff8800379b2940
Call Trace:
 [<ffffffff80233df8>] ? activate_task+0x28/0x40
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b6627>] ? sock_sendmsg+0x127/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff802c9fa5>] ? do_path_lookup+0xd5/0x1b0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff804b6a4a>] ? sys_sendto+0xea/0x120
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
dbus-daemon   D ffff880037427a48     0  2564      1
 ffff880037427a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff88007e8aa740 ffff88007af7c600 ffff88007e8aaa80
 00000001374279e8 ffffffff8024ee66 ffff88007e8aaa80 ffff880037427a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
sshd          S ffffffff80560200     0  2593      1
 ffff88007a4e9978 0000000000000082 ffff88007a4e98e8 ffffffff802e6581
 ffffffff807bb000 ffff880036cce9c0 ffff88007fba0240 ffff880036cced00
 000000017a4e9928 0000000100128651 ffff880036cced00 ffff8800306d3370
Call Trace:
 [<ffffffff802e6581>] ? bio_phys_segments+0x21/0x30
 [<ffffffff803d8927>] ? __make_request+0xf7/0x4b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802ce60c>] do_select+0x4ec/0x6a0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff803052d0>] ? proc_delete_inode+0x0/0x60
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff80304794>] ? proc_destroy_inode+0x14/0x20
 [<ffffffff803ef639>] ? snprintf+0x59/0x60
 [<ffffffff802d2f36>] ? destroy_inode+0x36/0x60
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8024157b>] ? __cleanup_signal+0x3b/0x50
 [<ffffffff802ce978>] core_sys_select+0x1b8/0x2e0
 [<ffffffff802467ee>] ? wait_consider_task+0x8e/0x9c0
 [<ffffffff8025ac66>] ? remove_wait_queue+0x46/0x60
 [<ffffffff80214e88>] ? init_fpu+0x58/0x140
 [<ffffffff8021588d>] ? restore_i387_xstate+0xfd/0x130
 [<ffffffff8020c199>] ? sys_rt_sigreturn+0x319/0x340
 [<ffffffff802cecfa>] sys_select+0x4a/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
ipmievd       S 0000000000000000     0  2602      1
 ffff88003651fac8 0000000000000082 001200d26b6b6b6b 0000004036cc3390
 ffffffff807bb000 ffff88007acd2080 ffff880037466700 ffff88007acd23c0
 0000000100000000 0000000000000001 ffff88007acd23c0 ffff8800364565e8
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8046976d>] ? ipmi_poll+0x5d/0x70
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff804b6a4a>] ? sys_sendto+0xea/0x120
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
ntpd          R  running task        0  2617      1
 ffff88007a4d1a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88007f2e8100 ffff8800658503c0 ffff88007f2e8440
 0000000000000000 ffffffff8024ee66 ffff88007f2e8440 ffff88007a4d1a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80215652>] ? save_i387_xstate+0x1b2/0x1e0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8054de79>] error_exit+0x0/0x51
hald          D ffff88003746fa48     0  2628      1
 ffff88003746fa38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff88007e83e100 ffff880011ca6700 ffff88007e83e440
 000000013746f9e8 ffffffff8024ee66 ffff88007e83e440 ffff88003746fa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
hald-runner   S ffffffff80560200     0  2629   2628
 ffff88003690dac8 0000000000000082 ffff88003690da58 ffffffff80238ab8
 ffffffff807bb000 ffff8800788643c0 ffff88007fba0240 ffff880078864700
 0000000100000001 00000001000c061b ffff880078864700 ffffffff80233ce0
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff80233df8>] ? activate_task+0x28/0x40
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b59c2>] ? sock_aio_write+0x172/0x190
 [<ffffffff802d2f36>] ? destroy_inode+0x36/0x60
 [<ffffffff8022e982>] ? ptep_set_access_flags+0x22/0x30
 [<ffffffff804b5850>] ? sock_aio_write+0x0/0x190
 [<ffffffff802be31b>] ? do_sync_readv_writev+0xeb/0x130
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff802bfa48>] ? __fput+0x168/0x1e0
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
hald-addon-in R  running task        0  2648   2629
 ffff880077015a38 0000000000000082 ffff8800770159b8 ffffffff8028e8b8
 ffffffff807bb000 ffff8800375fa6c0 ffff88006d0420c0 ffff8800375faa00
 00000000770159e8 ffffffff8024ee66 ffff8800375faa00 ffff880077015a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028cbc9>] __alloc_pages_internal+0x489/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff8023b5a0>] default_wake_function+0x0/0x10
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] do_readv_writev+0x153/0x1e0
 [<ffffffff804a6c94>] evdev_read+0xc4/0x2b0
 [<ffffffff803ae8a1>] security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
hald-addon-ac S 7fffffffffffffff     0  2656   2629
 ffff8800368dbb98 0000000000000082 ffff8800368dbbb8 ffff8800368dbd48
 ffffffff807bb000 ffff88007acd0580 ffff88007e83e100 ffff88007acd08c0
 0000000037808458 ffff88007a4fea68 ffff88007acd08c0 ffff8800368dbbb8
Call Trace:
 [<ffffffff802cff7a>] ? dput+0xaa/0x160
 [<ffffffff802d14f1>] ? __d_lookup+0xb1/0x150
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b5b60>] sock_aio_read+0x180/0x190
 [<ffffffff8029ee11>] ? vma_merge+0x141/0x370
 [<ffffffff802be591>] do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf286>] vfs_read+0x176/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
hald-addon-st D ffff88003698fa48     0  2657   2629
 ffff88003698fa38 0000000000000082 ffff88003698f9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff88007ad8a700 ffff88005ed5c240 ffff88007ad8aa40
 000000013698f9e8 ffffffff8024ee66 ffff88007ad8aa40 ffff88003698fa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff802e875c>] ? blkdev_open+0x6c/0xc0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff80479855>] ? put_device+0x15/0x20
 [<ffffffffa01c2c74>] ? scsi_disk_put+0x44/0x50 [sd_mod]
 [<ffffffff802d253b>] ? iput+0x2b/0x70
 [<ffffffff802e7f26>] ? __blkdev_put+0x86/0x1c0
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
hald-addon-st D ffff880036dd9838     0  2663   2629
 ffff880036dd9828 0000000000000082 ffffe2000043f5a0 0000000000000000
 ffffffff807bb000 ffff8800368b2740 ffff8800030b4800 ffff8800368b2a80
 0000000236dd97d8 ffffffff8024ee66 ffff8800368b2a80 ffff880036dd9838
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80292454>] ? shrink_active_list+0x3c4/0x470
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e1a4>] throttle_vm_writeout+0x94/0xb0
 [<ffffffff80292ddd>] shrink_zone+0x2ad/0x350
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff802e875c>] ? blkdev_open+0x6c/0xc0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff80479855>] ? put_device+0x15/0x20
 [<ffffffff802d253b>] ? iput+0x2b/0x70
 [<ffffffff802e7f26>] ? __blkdev_put+0x86/0x1c0
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
cron          D ffff8800369a3908     0  2718      1
 ffff8800369a38f8 0000000000000082 ffff8800369a3878 ffff88000103d280
 ffffffff807bb000 ffff88007acba680 ffff88006c092840 ffff88007acba9c0
 00000002369a38a8 ffffffff8024ee66 ffff88007acba9c0 ffff8800369a3908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff802b5e00>] ? check_poison_obj+0x40/0x1d0
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025e0df>] ? hrtimer_try_to_cancel+0x3f/0x80
 [<ffffffff8025e13a>] ? hrtimer_cancel+0x1a/0x30
 [<ffffffff8054c770>] ? do_nanosleep+0x40/0xc0
 [<ffffffff8025e393>] ? hrtimer_nanosleep+0xa3/0x120
 [<ffffffff8025dad0>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff880037475a48     0  2732      1
 ffff880037475a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff880036862600 ffff88007b078180 ffff880036862940
 00000000374759e8 ffffffff8024ee66 ffff880036862940 ffff880037475a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd707>] ? poll_select_copy_remaining+0xf7/0x150
 [<ffffffff802ced0c>] ? sys_select+0x5c/0x110
 [<ffffffff8054de79>] error_exit+0x0/0x51
dbus-daemon   D ffff880036d99908     0  2761      1
 ffff880036d998f8 0000000000000082 ffffffff803ec708 ffff88000103d280
 ffffffff807bb000 ffff88007c098080 ffff8800124c0240 ffff88007c0983c0
 0000000236d998a8 ffffffff8024ee66 ffff88007c0983c0 ffff880036d99908
Call Trace:
 [<ffffffff803ec708>] ? rb_insert_color+0x98/0x140
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3ksyslog     D ffff88007c089a48     0  2768      1
 ffff88007c089a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff8800375a65c0 ffff88006d0420c0 ffff8800375a6900
 000000007c0899e8 ffffffff8024ee66 ffff8800375a6900 ffff88007c089a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802cb19e>] ? do_filp_open+0x1fe/0x970
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kevent      D ffff88007dc53a48     0  2791      1
 ffff88007dc53a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff880036414100 ffff88005798e9c0 ffff880036414440
 000000017dc539e8 ffffffff8024ee66 ffff880036414440 ffff88007dc53a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kmonitor    D ffff88007e881a48     0  2800      1
 ffff88007e881a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff8800369a4200 ffff88006a10c340 ffff8800369a4540
 000000007e8819e8 ffffffff8024ee66 ffff8800369a4540 ffff88007e881a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kdetect     S ffffffff80560200     0  2819      1
 ffff880077005e68 0000000000000082 0000000001f52d08 0000000000000007
 ffffffff807bb000 ffff8800799e4780 ffff88007f034440 ffff8800799e4ac0
 0000000302f8a938 0000000100181979 ffff8800799e4ac0 ffff8800799e4780
Call Trace:
 [<ffffffff80247396>] do_wait+0x276/0x350
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80247506>] sys_wait4+0x96/0xf0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3kindexer    D ffff88007c0b9a48     0  2845      1
 ffff88007c0b9a38 0000000000000082 ffff88007c0b99b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880036ce2940 ffff88002fd280c0 ffff880036ce2c80
 000000017c0b99e8 ffffffff8024ee66 ffff880036ce2c80 ffff88007c0b9a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kindexer    S ffff88006a465cd8     0 11782      1
 ffff88006a465cc8 0000000000000082 0000000000000000 0000000000000001
 ffffffff807bb000 ffff88003ff34600 ffff880065132680 ffff88003ff34940
 000000006a465ed8 0000000000000000 ffff88003ff34940 0000000000000001
Call Trace:
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
 [<ffffffff802c5e43>] pipe_wait+0x63/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802c6882>] pipe_read+0x3f2/0x4d0
 [<ffffffff802be591>] do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecmon     R  running task        0  2949      1
 ffff880037933a38 0000000000000082 0000000000070309 ffffffff8028e8b8
 ffffffff807bb000 ffff8800368c8300 ffff8800643c6600 ffff8800368c8640
 00000001379339e8 ffffffff8024ee66 ffff8800368c8640 ffff880037933a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecmon     S ffff88007dc57cd8     0  5446      1
 ffff88007dc57cc8 0000000000000082 0000000000000000 ffff88000101f100
 ffffffff807bb000 ffff880036c342c0 ffff88001902a240 ffff880036c34600
 0000000100000000 ffff88007dc57c98 ffff880036c34600 ffffffff802661a9
Call Trace:
 [<ffffffff802661a9>] ? futex_wait+0x369/0x4a0
 [<ffffffff802c5e43>] pipe_wait+0x63/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802c6882>] pipe_read+0x3f2/0x4d0
 [<ffffffff802be591>] do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8021588d>] ? restore_i387_xstate+0xfd/0x130
 [<ffffffff8020c199>] ? sys_rt_sigreturn+0x319/0x340
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecprofman D ffff880079911a48     0  2992      1
 ffff880079911a38 0000000000000082 0000000000070309 0000000000000080
 ffffffff807bb000 ffff88007b964540 ffff880016974800 ffff88007b964880
 00000001799119e8 ffffffff8024ee66 ffff88007b964880 ffff880079911a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kwatchdog   S ffffffff80560200     0  3066      1
 ffff880079599e68 0000000000000082 0000000001b21808 0000000000000007
 ffffffff807bb000 ffff880077462380 ffff88007fbda340 ffff8800774626c0
 00000002030466f8 0000000100181d07 ffff8800774626c0 ffff880077462380
Call Trace:
 [<ffffffff80247396>] do_wait+0x276/0x350
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80247506>] sys_wait4+0x96/0xf0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
login         S ffff880036402900     0  3082      1
 ffff880036975e68 0000000000000082 00000000006085e8 0000000000000007
 ffffffff807bb000 ffff880036402900 ffff880037466700 ffff880036402c40
 0000000178906778 0000000000000000 ffff880036402c40 ffff880036402900
Call Trace:
 [<ffffffff80247396>] do_wait+0x276/0x350
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80247506>] sys_wait4+0x96/0xf0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
bash          D ffff880077421a48     0  8944   3082
 ffff880077421a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880078906740 ffff880011f20980 ffff880078906a80
 00000000774219e8 ffffffff8024ee66 ffff880078906a80 ffff880077421a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff80248cd2>] ? current_fs_time+0x22/0x30
 [<ffffffff8044e4da>] ? tty_ldisc_deref+0x5a/0x80
 [<ffffffff804467ea>] ? tty_read+0xca/0xf0
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
sshd          D ffff88007a135a48     0  9580   2593
 ffff88007a135a38 0000000000000082 ffff88007a1359b8 0000000000000080
 ffffffff807bb000 ffff88007b078180 ffff8800183d6800 ffff88007b0784c0
 000000007a1359e8 ffffffff8024ee66 ffff88007b0784c0 ffff88007a135a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80248cd2>] ? current_fs_time+0x22/0x30
 [<ffffffff802ced0c>] ? sys_select+0x5c/0x110
 [<ffffffff8054de79>] error_exit+0x0/0x51
bash          S 7fffffffffffffff     0  9588   9580
 ffff880036193d78 0000000000000082 0000000000000009 ffffffff8022e982
 ffffffff807bb000 ffff88007c0ae300 ffff88007b078180 ffff88007c0ae640
 000000037a87e030 0000000000c55008 ffff88007c0ae640 000000001a131100
Call Trace:
 [<ffffffff8022e982>] ? ptep_set_access_flags+0x22/0x30
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
getty         S ffffffff80560200     0  4279      1
 ffff880037943d78 0000000000000082 ffff8800365a7270 0000000000000000
 ffffffff807bb000 ffff88007885c080 ffffffff806b0340 ffff88007885c3c0
 0000000037943de8 000000010004008a ffff88007885c3c0 0000000000000202
Call Trace:
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802445cd>] ? release_console_sem+0x1bd/0x210
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
getty         S ffffffff80560200     0  4280      1
 ffff880078937d78 0000000000000082 ffff88007adf96a0 0000000000000000
 ffffffff807bb000 ffff88007ac2e480 ffff88007fba0240 ffff88007ac2e7c0
 0000000178937de8 000000010004008a ffff88007ac2e7c0 0000000000000202
Call Trace:
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802445cd>] ? release_console_sem+0x1bd/0x210
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
getty         S ffffffff80560200     0  4284      1
 ffff88007ac0bd78 0000000000000082 ffff88007adf98b8 0000000000000000
 ffffffff807bb000 ffff88007d8d2780 ffffffff806b0340 ffff88007d8d2ac0
 000000007ac0bde8 000000010004008b ffff88007d8d2ac0 0000000000000202
Call Trace:
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802445cd>] ? release_console_sem+0x1bd/0x210
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
getty         S ffffffff80560200     0  4285      1
 ffff88007ac2bd78 0000000000000082 ffff88007adf9ad0 0000000000000000
 ffffffff807bb000 ffff880077cf8680 ffff88007fba0240 ffff880077cf89c0
 000000017ac2bde8 000000010004008b ffff880077cf89c0 0000000000000202
Call Trace:
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802445cd>] ? release_console_sem+0x1bd/0x210
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
getty         S ffffffff80560200     0  4288      1
 ffff88007bd1dd78 0000000000000082 ffff88007adf9ce8 0000000000000000
 ffffffff807bb000 ffff88007acfe0c0 ffff88007fba0240 ffff88007acfe400
 000000017bd1dde8 000000010004008b ffff88007acfe400 0000000000000202
Call Trace:
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802445cd>] ? release_console_sem+0x1bd/0x210
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff8044b2ed>] n_tty_read+0x59d/0x920
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8044e513>] ? tty_ldisc_ref_wait+0x13/0xb0
 [<ffffffff804467c9>] tty_read+0xa9/0xf0
 [<ffffffff802bf1d8>] vfs_read+0xc8/0x180
 [<ffffffff802bf380>] sys_read+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff880068947a48     0  8920   2732
 ffff880068947a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007b8e63c0 ffff88005743a880 ffff88007b8e6700
 00000001689479e8 ffffffff8024ee66 ffff88007b8e6700 ffff880068947a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  9569   2732
 ffff880077c01b28 0000000000000082 ffff880077c01a98 ffffffff802b6741
 ffffffff807bb000 ffff88007b01e180 ffff880010f3c400 ffff88007b01e4c0
 00000001804bdab5 ffff880039fcbd30 ffff88007b01e4c0 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
kstriped      S ffff8800770e8e48     0 14652      2
 ffff880078891ec0 0000000000000046 ffff88007fb7dee0 ffff88007fb7df00
 ffffffff807bb000 ffff88007bce4800 ffff8800795441c0 ffff88007bce4b40
 00000003807c2280 0000000000000000 ffff88007bce4b40 0000000000000000
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
v3kstorage    D ffff88007ac29908     0 16496      1
 ffff88007ac298f8 0000000000000082 ffff88007ac29878 ffff88000103d280
 ffffffff807bb000 ffff880077016900 ffff88005440c700 ffff880077016c40
 000000027ac298a8 ffffffff8024ee66 ffff880077016c40 ffff88007ac29908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
kjournald     S ffff880078947294     0 16539      2
 ffff88003657bea0 0000000000000046 ffff88003657be00 0000000000000005
 ffffffff807bb000 ffff88007c1ee180 ffff88007f2e40c0 ffff88007c1ee4c0
 000000033657be60 ffffffff8023428a ffff88007c1ee4c0 ffff880078947300
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kdmflush      S ffffffff80560200     0 16564      2
 ffff880077465ec0 0000000000000046 ffff880077465e50 ffffffff8023428a
 ffffffff807bb000 ffff88007c1c2840 ffff88007fba0240 ffff88007c1c2b80
 0000000167d930a8 00000001000bf18f ffff88007c1c2b80 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd_io    S ffff880067c4ea60     0 16565      2
 ffff88007a4c1ec0 0000000000000046 ffff88007a4c1e50 ffffffff802e67f9
 ffffffff807bb000 ffff88007e8a42c0 ffff88007f18c5c0 ffff88007e8a4600
 000000037b4211f0 ffff88007adb42f0 ffff88007e8a4600 ffffffffa02a0854
Call Trace:
 [<ffffffff802e67f9>] ? bio_alloc_bioset+0x59/0x100
 [<ffffffffa02a0854>] ? kcryptd_io+0xf4/0x140 [dm_crypt]
 [<ffffffffa02a0760>] ? kcryptd_io+0x0/0x140 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd       S ffff880067c4ed58     0 16566      2
 ffff880036cb7ec0 0000000000000046 0000000000000001 0000000000000000
 ffffffff807bb000 ffff88007e890140 ffff8800795441c0 ffff88007e890480
 0000000336d7bbd8 000000001d1da448 ffff88007e890480 ffff88007e9ada38
Call Trace:
 [<ffffffffa02a0e50>] ? kcryptd_crypt+0x0/0x4e0 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsbufd       S ffffffff80560200     0 16584      2
 ffff88007e95fe80 0000000000000046 ffff88007e95e000 ffff880001022780
 ffffffff807bb000 ffff8800688aa100 ffff88007b962580 ffff8800688aa440
 000000017e95fe30 ffffffff8024ee66 ffff8800688aa440 ffff88007e95fe90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff803959da>] xfsbufd+0x7a/0x170
 [<ffffffff80395960>] ? xfsbufd+0x0/0x170
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsaild       S ffff88007e89fe90     0 16585      2
 ffff88007e89fe80 0000000000000046 ffff88007e89e000 ffff88000102e8a0
 ffffffff807bb000 ffff88007a8e6940 ffff88007e8bc940 ffff88007a8e6c80
 000000007e89fe30 ffffffff8024ee66 ffff88007a8e6c80 ffff88007e89fe90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d5c5>] xfsaild+0x65/0xb0
 [<ffffffff8039d560>] ? xfsaild+0x0/0xb0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfssyncd      S ffff880077ca1e60     0 16586      2
 ffff880077ca1e50 0000000000000046 ffff880077ca1de0 ffffffff8038cc59
 ffffffff807bb000 ffff88007c1dc4c0 ffff88007f2e40c0 ffff88007c1dc800
 0000000277ca1e00 ffffffff8024ee66 ffff88007c1dc800 ffff880077ca1e60
Call Trace:
 [<ffffffff8038cc59>] ? xfs_finish_reclaim+0x59/0x1a0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d0b0>] xfssyncd+0x70/0x1f0
 [<ffffffff8039d040>] ? xfssyncd+0x0/0x1f0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kjournald     S ffff88007c0be4ac     0 16626      2
 ffff88007c819ea0 0000000000000046 ffff88007c819e00 0000000000000005
 ffffffff807bb000 ffff88007a4cc480 ffff880036414100 ffff88007a4cc7c0
 000000037c819e60 ffffffff8023428a ffff88007a4cc7c0 ffff88007c0be518
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kdmflush      S ffff88006585bf20     0 16645      2
 ffff880078895ec0 0000000000000046 ffff880078895e50 ffffffff8023428a
 ffffffff807bb000 ffff8800798fc040 ffff8800795441c0 ffff8800798fc380
 000000036585bf28 0000000000000286 ffff8800798fc380 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd_io    S ffff88007a5e5898     0 16649      2
 ffff88007991fec0 0000000000000046 ffff88007991fe50 ffffffff802e67f9
 ffffffff807bb000 ffff88007bd68240 ffff880037914380 ffff88007bd68580
 00000000488ddb90 ffff88003796e0d8 ffff88007bd68580 ffffffffa02a0854
Call Trace:
 [<ffffffff802e67f9>] ? bio_alloc_bioset+0x59/0x100
 [<ffffffffa02a0854>] ? kcryptd_io+0xf4/0x140 [dm_crypt]
 [<ffffffffa02a0760>] ? kcryptd_io+0x0/0x140 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd       S ffff880036debab8     0 16650      2
 ffff88007b521ec0 0000000000000046 0000000000000001 0000000000000000
 ffffffff807bb000 ffff880067d60440 ffff880048a868c0 ffff880067d60780
 0000000036debac0 0000000000528310 ffff880067d60780 ffff880013955528
Call Trace:
 [<ffffffffa02a0e50>] ? kcryptd_crypt+0x0/0x4e0 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsbufd       S ffff88007d179e90     0 16660      2
 ffff88007d179e80 0000000000000046 ffff88007d179e80 0000000000000000
 ffffffff807bb000 ffff88007b962580 ffff8800688aa100 ffff88007b9628c0
 ffff88007d179e30 ffffffff8024ee66 ffff88007b9628c0 ffff88007d179e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff803959da>] xfsbufd+0x7a/0x170
 [<ffffffff80395960>] ? xfsbufd+0x0/0x170
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsaild       S ffff88007a463e90     0 16661      2
 ffff88007a463e80 0000000000000046 ffff880077c21304 ffff88007a463e80
 ffffffff807bb000 ffff88007e8bc940 ffff8800375ae280 ffff88007e8bcc80
 000000007a463e30 ffffffff8024ee66 ffff88007e8bcc80 ffff88007a463e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d5c5>] xfsaild+0x65/0xb0
 [<ffffffff8039d560>] ? xfsaild+0x0/0xb0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfssyncd      S ffff880077427e60     0 16663      2
 ffff880077427e50 0000000000000046 ffff880077427de0 ffffffff8038cc59
 ffffffff807bb000 ffff8800770527c0 ffff8800795441c0 ffff880077052b00
 0000000377427e00 ffffffff8024ee66 ffff880077052b00 ffff880077427e60
Call Trace:
 [<ffffffff8038cc59>] ? xfs_finish_reclaim+0x59/0x1a0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d0b0>] xfssyncd+0x70/0x1f0
 [<ffffffff8039d040>] ? xfssyncd+0x0/0x1f0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kjournald     S ffff8800789b3d8c     0 16703      2
 ffff880036153ea0 0000000000000046 ffff880036153e00 0000000000000005
 ffffffff807bb000 ffff88007e4c8500 ffff88007c936440 ffff88007e4c8840
 0000000336153e60 ffffffff8023428a ffff88007e4c8840 ffff8800789b3df8
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kdmflush      S ffff88007e8920a0     0 16723      2
 ffff88007c541ec0 0000000000000046 ffff88007c541e50 ffffffff8023428a
 ffffffff807bb000 ffff880076cde840 ffff88007ade8780 ffff880076cdeb80
 000000017e8920a8 0000000000000286 ffff880076cdeb80 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd_io    S ffff88007d10fdf0     0 16724      2
 ffff880068911ec0 0000000000000046 ffff880068911e50 ffffffff802e67f9
 ffffffff807bb000 ffff880079934400 ffff88007f220480 ffff880079934740
 00000003795c9560 ffff88007c821118 ffff880079934740 ffffffffa02a0854
Call Trace:
 [<ffffffff802e67f9>] ? bio_alloc_bioset+0x59/0x100
 [<ffffffffa02a0854>] ? kcryptd_io+0xf4/0x140 [dm_crypt]
 [<ffffffffa02a0760>] ? kcryptd_io+0x0/0x140 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd       S ffff88007d10f178     0 16725      2
 ffff88007706fec0 0000000000000046 0000000000000001 0000000000000000
 ffffffff807bb000 ffff88007a958700 ffff880066970180 ffff88007a958a40
 0000000200000000 0000000003c22520 ffff88007a958a40 ffff88007e986c58
Call Trace:
 [<ffffffffa02a0e50>] ? kcryptd_crypt+0x0/0x4e0 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsbufd       R  running task        0 16740      2
 ffff88007bc85e80 0000000000000046 000000000000012b ffff88007e95fe90
 ffffffff807bb000 ffff8800795441c0 ffff8800688aa100 ffff880079544500
 000000007bc85e30 ffffffff8024ee66 ffff880079544500 ffff88007bc85e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff803959da>] xfsbufd+0x7a/0x170
 [<ffffffff80395960>] ? xfsbufd+0x0/0x170
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsaild       S ffff880079193e90     0 16741      2
 ffff880079193e80 0000000000000046 ffff88007a876094 0000000000000000
 ffffffff807bb000 ffff88007adcc2c0 ffff88007e57e0c0 ffff88007adcc600
 0000000179193e30 ffffffff8024ee66 ffff88007adcc600 ffff880079193e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d5c5>] xfsaild+0x65/0xb0
 [<ffffffff8039d560>] ? xfsaild+0x0/0xb0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfssyncd      S ffff88007ac79e60     0 16743      2
 ffff88007ac79e50 0000000000000046 ffff88007ac79de0 ffffffff8038cc59
 ffffffff807bb000 ffff8800794b2740 ffff88007c1dc4c0 ffff8800794b2a80
 000000027ac79e00 ffffffff8024ee66 ffff8800794b2a80 ffff88007ac79e60
Call Trace:
 [<ffffffff8038cc59>] ? xfs_finish_reclaim+0x59/0x1a0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d0b0>] xfssyncd+0x70/0x1f0
 [<ffffffff8039d040>] ? xfssyncd+0x0/0x1f0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kjournald     S ffff88007d031d0c     0 16783      2
 ffff8800378cdea0 0000000000000046 ffff8800378cde00 0000000000000005
 ffffffff807bb000 ffff88007b9ce300 ffff88007b17a600 ffff88007b9ce640
 00000003378cde60 ffffffff8023428a ffff88007b9ce640 ffff88007d031d78
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kdmflush      S ffff8800795c70a0     0 16800      2
 ffff8800799fdec0 0000000000000046 ffff8800799fde50 ffffffff8023428a
 ffffffff807bb000 ffff8800365b4640 ffff88007e4a8140 ffff8800365b4980
 00000003795c70a8 0000000000000286 ffff8800365b4980 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd_io    S ffff88007b479800     0 16801      2
 ffff88007b177ec0 0000000000000046 ffff88007b177e50 ffffffff802e67f9
 ffffffff807bb000 ffff88007c92e6c0 ffff880067d60440 ffff88007c92ea00
 000000001398c1f0 ffff88003796eb50 ffff88007c92ea00 ffffffffa02a0854
Call Trace:
 [<ffffffff802e67f9>] ? bio_alloc_bioset+0x59/0x100
 [<ffffffffa02a0854>] ? kcryptd_io+0xf4/0x140 [dm_crypt]
 [<ffffffffa02a0760>] ? kcryptd_io+0x0/0x140 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd       S ffff88007b479cc0     0 16803      2
 ffff880067cbdec0 0000000000000046 0000000000000001 0000000000000000
 ffffffff807bb000 ffff880037914380 ffff88005aa722c0 ffff8800379146c0
 0000000100000000 00000000574f3ee8 ffff8800379146c0 ffff8800187bba38
Call Trace:
 [<ffffffffa02a0e50>] ? kcryptd_crypt+0x0/0x4e0 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsbufd       R  running task        0 16818      2
 ffff8800791ebe80 0000000000000046 ffff8800791ebe50 0000000000000000
 ffffffff807bb000 ffff88007e91c400 ffff8800688aa100 ffff88007e91c740
 00000000791ebe30 ffffffff8024ee66 ffff88007e91c740 ffff8800791ebe90
Call Trace:
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff803959da>] xfsbufd+0x7a/0x170
 [<ffffffff80395960>] ? xfsbufd+0x0/0x170
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsaild       S ffff88007b911e90     0 16819      2
 ffff88007b911e80 0000000000000046 ffff88007b53ebec 0000000000000000
 ffffffff807bb000 ffff88007e57e0c0 ffff88007f06c4c0 ffff88007e57e400
 000000017b911e30 ffffffff8024ee66 ffff88007e57e400 ffff88007b911e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d5c5>] xfsaild+0x65/0xb0
 [<ffffffff8039d560>] ? xfsaild+0x0/0xb0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfssyncd      D ffff8800788e7890     0 16820      2
 ffff8800788e7880 0000000000000046 ffff8800788e79a0 ffff88000103d280
 ffffffff807bb000 ffff88007c1c06c0 ffff88007b962580 ffff88007c1c0a00
 00000002788e7830 ffffffff8024ee66 ffff88007c1c0a00 ffff8800788e7890
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8038cd2b>] xfs_finish_reclaim+0x12b/0x1a0
 [<ffffffff8038ce77>] xfs_finish_reclaim_all+0xd7/0x100
 [<ffffffff8038b614>] xfs_syncsub+0x64/0x300
 [<ffffffff8038b8f7>] xfs_sync+0x47/0x70
 [<ffffffff8039d24f>] xfs_sync_worker+0x1f/0x50
 [<ffffffff8039d1a3>] xfssyncd+0x163/0x1f0
 [<ffffffff8039d040>] ? xfssyncd+0x0/0x1f0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kjournald     S ffff8800365a7d0c     0 16860      2
 ffff88007c193ea0 0000000000000046 ffff88007c193e00 0000000000000005
 ffffffff807bb000 ffff88007e4a8140 ffff88007f2e40c0 ffff88007e4a8480
 000000017c193e60 ffffffff8023428a ffff88007e4a8480 ffff8800365a7d78
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8032f943>] kjournald+0x213/0x230
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8032f730>] ? kjournald+0x0/0x230
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kdmflush      S ffffffff80560200     0 16880      2
 ffff880067515ec0 0000000000000046 ffff880067515e50 ffffffff8023428a
 ffffffff807bb000 ffff88007ddcc0c0 ffff88007fbda340 ffff88007ddcc400
 00000002788595a8 00000001000c04a9 ffff88007ddcc400 ffffffff802362fa
Call Trace:
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff80256960>] ? wq_barrier_func+0x0/0x10
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd_io    S ffff88007e44f398     0 16884      2
 ffff880079139ec0 0000000000000046 ffff880079139e50 ffffffff802e67f9
 ffffffff807bb000 ffff880079d987c0 ffff880079934400 ffff880079d98b00
 000000037c40d770 ffff88007adf9270 ffff880079d98b00 ffffffffa02a0854
Call Trace:
 [<ffffffff802e67f9>] ? bio_alloc_bioset+0x59/0x100
 [<ffffffffa02a0854>] ? kcryptd_io+0xf4/0x140 [dm_crypt]
 [<ffffffffa02a0760>] ? kcryptd_io+0x0/0x140 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
kcryptd       S ffff88007e44f5f8     0 16885      2
 ffff88007913bec0 0000000000000046 0000000000000001 0000000000000000
 ffffffff807bb000 ffff880077072600 ffff880037914380 ffff880077072940
 0000000100000000 000000001c7e8500 ffff880077072940 ffff880076c438a0
Call Trace:
 [<ffffffffa02a0e50>] ? kcryptd_crypt+0x0/0x4e0 [dm_crypt]
 [<ffffffff802566f5>] worker_thread+0xe5/0x120
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80256610>] ? worker_thread+0x0/0x120
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsbufd       R  running task        0 16895      2
 ffff88007e9b7e80 0000000000000046 ffff88007e9b6000 ffff880001022780
 ffffffff807bb000 ffff88007d934540 ffff88007b962580 ffff88007d934888
 000000017e9b7e30 00000001001b6296 ffff88007d934880 ffff88007e9b7e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff803959da>] xfsbufd+0x7a/0x170
 [<ffffffff80395960>] ? xfsbufd+0x0/0x170
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfsaild       S ffff880067cb3e90     0 16896      2
 ffff880067cb3e80 0000000000000046 ffff880067cb2000 0000030d00014900
 ffffffff807bb000 ffff880068998840 ffff88007adcc2c0 ffff880068998b80
 0000000167cb3e30 ffffffff8024ee66 ffff880068998b80 ffff880067cb3e90
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf99>] schedule_timeout_interruptible+0x19/0x20
 [<ffffffff8039d5c5>] xfsaild+0x65/0xb0
 [<ffffffff8039d560>] ? xfsaild+0x0/0xb0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
xfssyncd      D ffff88007d99b960     0 16898      2
 ffff88007d99b950 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007d998880 ffff88007f0a62c0 ffff88007d998bc0
 000000017d99b900 ffffffff8024ee66 ffff88007d998bc0 ffff88007d99b960
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8037ae71>] ? xlog_state_sync_all+0x1c1/0x230
 [<ffffffff8038cd2b>] xfs_finish_reclaim+0x12b/0x1a0
 [<ffffffff8038ce77>] xfs_finish_reclaim_all+0xd7/0x100
 [<ffffffff8038b614>] xfs_syncsub+0x64/0x300
 [<ffffffff8038b8f7>] xfs_sync+0x47/0x70
 [<ffffffff8039d24f>] xfs_sync_worker+0x1f/0x50
 [<ffffffff8039d1a3>] xfssyncd+0x163/0x1f0
 [<ffffffff8039d040>] ? xfssyncd+0x0/0x1f0
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
apache2       D ffff88007d821a48     0 17304   2732
 ffff88007d821a38 0000000000000082 ffff88007d8219b8 0000000000000080
 ffffffff807bb000 ffff880076cc4400 ffff88005d6141c0 ffff880076cc4740
 000000017d8219e8 ffffffff8024ee66 ffff880076cc4740 ffff88007d821a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3kout        D ffff8800799dba48     0 17918      1
 ffff8800799dba38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007e5ec780 ffff8800516f2900 ffff88007e5ecac0
 00000001799db9e8 ffffffff8024ee66 ffff88007e5ecac0 ffff8800799dba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802beba3>] ? do_readv_writev+0x153/0x1e0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0 30810   2732
 ffff880079d63b28 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff880067c185c0 ffff880048ac0500 ffff880067c18900
 000000017fb679a0 ffff880077cb5a78 ffff880067c18900 ffffffff802b6998
Call Trace:
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     ? ffff880066970180     0  2303   2949
 ffff880065919c78 0000000000000046 ffff880065919be8 ffffffff803e3048
 ffffffff807bb000 ffff880066970180 ffff88007f2e8100 ffff8800669704c0
 0000000200000282 0000000000000282 ffff8800669704c0 ffffffff803e3185
Call Trace:
 [<ffffffff803e3048>] ? cfq_exit_cfqq+0x28/0x80
 [<ffffffff803e3185>] ? cfq_exit_single_io_context+0x55/0x70
 [<ffffffff803e31ca>] ? cfq_exit_io_context+0x2a/0x40
 [<ffffffff80247cae>] do_exit+0x67e/0x920
 [<ffffffff8024fe38>] ? __sigqueue_free+0x38/0x40
 [<ffffffff80247f90>] do_group_exit+0x40/0xb0
 [<ffffffff80252d37>] get_signal_to_deliver+0x197/0x380
 [<ffffffff8020b60a>] do_notify_resume+0xba/0x910
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8020c8bd>] retint_signal+0x3d/0x80
v3krecord     D ffff880067d41a58     0  2529   2949
 ffff880067d41a48 0000000000000082 ffff880067d419a8 ffffffff8028d9cf
 ffffffff807bb000 ffff8800771bc700 ffff880002f38940 ffff8800771bca40
 0000000167d419f8 ffffffff8024ee66 ffff8800771bca40 ffff880067d41a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  7792   2732
 ffff8800589ebb28 0000000000000082 ffff8800589eba98 ffffffff802b6741
 ffffffff807bb000 ffff88005b4a6800 ffff8800030ee300 ffff88005b4a6b40
 00000001804bdab5 ffff88000b05d6d8 ffff88005b4a6b40 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  8291   2732
 ffff88005b593b28 0000000000000082 ffff88005b593a98 ffffffff802b6741
 ffffffff807bb000 ffff880066892540 ffff88005c0188c0 ffff880066892880
 00000000804bdab5 ffff88000a7e2c48 ffff880066892880 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff88007bc75a48     0  8294   2732
 ffff88007bc75a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005807c600 ffff880067de6180 ffff88005807c940
 000000007bc759e8 ffffffff8024ee66 ffff88005807c940 ffff88007bc75a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       R  running task        0 17169   2732
 ffff8800759dba38 0000000000000082 ffff8800759db9b8 0000000000000080
 ffffffff807bb000 ffff88006d0420c0 ffff8800172d41c0 ffff88006d042400
 00000000759db9e8 ffffffff8024ee66 ffff88006d042400 ffff8800759dba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0 21665   2732
 ffff88000b265b28 0000000000000082 ffff88000b265a98 ffffffff802b6741
 ffffffff807bb000 ffff88000d1e0040 ffff8800758f8340 ffff88000d1e0380
 00000000804bdab5 ffff88007b58a080 ffff88000d1e0380 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  1891   2732
 ffff880003219b28 0000000000000082 0000000000000004 ffffffff803f00b5
 ffffffff807bb000 ffff8800030b61c0 ffff88000322e680 ffff8800030b6500
 0000000203219af8 ffffffff802b8e80 ffff8800030b6500 ffff88007f021930
Call Trace:
 [<ffffffff803f00b5>] ? memmove+0x45/0x60
 [<ffffffff802b8e80>] ? cache_flusharray+0x120/0x160
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  2254   2732
 ffff8800097dfb28 0000000000000082 ffff8800097dfa98 ffffffff802b6741
 ffffffff807bb000 ffff880014f5e2c0 ffff88006d058200 ffff880014f5e600
 00000002804bdab5 ffff88000a7c8338 ffff880014f5e600 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  2255   2732
 ffff880079537b28 0000000000000082 0000000000000004 ffffffff803f00b5
 ffffffff807bb000 ffff880051702940 ffff88005b4a6800 ffff880051702c80
 000000017f804d00 ffff88003188c250 ffff880051702c80 ffffffff802b6998
Call Trace:
 [<ffffffff803f00b5>] ? memmove+0x45/0x60
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  2256   2732
 ffff88007c9ffb28 0000000000000082 ffff88007c9ffa98 ffffffff802b6741
 ffffffff807bb000 ffff880010b020c0 ffff8800758f8340 ffff880010b02400
 00000000804bdab5 ffff88005fbe6508 ffff880010b02400 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff880004971a48     0  2258   2732
 ffff880004971a38 0000000000000082 ffff8800049719b8 0000000000000064
 ffffffff807bb000 ffff880017334380 ffff88005c51c2c0 ffff8800173346c0
 00000000049719e8 ffffffff8024ee66 ffff8800173346c0 ffff880004971a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
pcscd         S 0000000000000000     0  3930      1
 ffff88007b091978 0000000000000082 ffff88007b0918e8 ffffffff802e6581
 ffffffff807bb000 ffff88007e5e47c0 ffff880037914380 ffff88007e5e4b00
 000000027b091928 ffffffff803d5b6b ffff88007e5e4b00 ffff880061ff4680
Call Trace:
 [<ffffffff802e6581>] ? bio_phys_segments+0x21/0x30
 [<ffffffff803d5b6b>] ? __elv_add_request+0x7b/0xd0
 [<ffffffff803d8927>] ? __make_request+0xf7/0x4b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802ce60c>] do_select+0x4ec/0x6a0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8054bd47>] ? io_schedule+0x37/0x50
 [<ffffffff8054c016>] ? __wait_on_bit_lock+0x76/0xb0
 [<ffffffff80285680>] ? sync_page+0x0/0x60
 [<ffffffff80285664>] ? __lock_page+0x64/0x70
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff80289d33>] ? __rmqueue+0xd3/0x270
 [<ffffffff80294ced>] ? zone_statistics+0x7d/0xa0
 [<ffffffff802ce978>] core_sys_select+0x1b8/0x2e0
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff80238c9a>] ? task_new_fair+0xaa/0xf0
 [<ffffffff802cecfa>] sys_select+0x4a/0x110
 [<ffffffff8020c2eb>] ? system_call_fastpath+0x16/0x1b
 [<ffffffff8020a763>] ? sys_clone+0x23/0x30
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
pcscd         D ffff88000321fa48     0  3931      1
 ffff88000321fa38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff8800030bc400 ffff88005807c600 ffff8800030bc740
 000000000321f9e8 ffffffff8024ee66 ffff8800030bc740 ffff88000321fa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025e0df>] ? hrtimer_try_to_cancel+0x3f/0x80
 [<ffffffff8025e13a>] ? hrtimer_cancel+0x1a/0x30
 [<ffffffff8054c770>] ? do_nanosleep+0x40/0xc0
 [<ffffffff8025e393>] ? hrtimer_nanosleep+0xa3/0x120
 [<ffffffff8025dad0>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8054de79>] error_exit+0x0/0x51
pcscd         S ffffffff80560200     0  3932      1
 ffff880013171ac8 0000000000000082 f16313ebb4d297e9 5173cb08b6dac9b1
 ffffffff807bb000 ffff8800688d8540 ffff88007f034440 ffff8800688d8880
 000000033c29e3f4 00000001001273a1 ffff8800688d8880 71bc15717266df2c
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000b1e5a48     0 15377   2949
 ffff88000b1e5a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880002e1c100 ffff88004c3da400 ffff880002e1c440
 000000000b1e59e8 ffffffff8024ee66 ffff880002e1c440 ffff88000b1e5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 15442   2949
 ffff88007ac63c58 0000000000000082 0000000000000298 0000000000000298
 ffffffff807bb000 ffff880057504580 ffff88005d6141c0 ffff8800575048c0
 000000037ac63be8 ffffffff8054dcef ffff8800575048c0 ffffffff804b8e27
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff804f4b75>] ? tcp_recvmsg+0x625/0xd60
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 15443   2949
 ffff880065497a78 0000000000000082 ffff88000103d280 0000000000000000
 ffffffff807bb000 ffff88001f380780 ffff88005edd0240 ffff88001f380ac0
 000000007f803ac0 ffff88007f803ac0 ffff88001f380ac0 ffffffff802b7c61
Call Trace:
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880036169a58     0 15477   2949
 ffff880036169a48 0000000000000082 ffff8800361699a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880067480580 ffff88002d360300 ffff8800674808c0
 00000000361699f8 ffffffff8024ee66 ffff8800674808c0 ffff880036169a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 15478   2949
 ffff88000478dc58 0000000000000082 ffff88000478dc58 ffff88000478dc58
 ffffffff807bb000 ffff88007d8e83c0 ffff880009aea6c0 ffff88007d8e8700
 00000003575045b8 0000000000000001 ffff88007d8e8700 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000d8f7a48     0 15400   2949
 ffff88000d8f7a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88006b3b8600 ffff88001724c780 0000000000000005
 000000010d8f79e8 ffffffff8024ee66 ffff88006b3b8940 ffff88000d8f7a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 15430   2949
 ffff880009aefc58 0000000000000082 ffff88007f020d80 ffff88005c9ea050
 ffffffff807bb000 ffff880011eae8c0 ffff88007fba0240 ffff880011eaec00
 0000000109aefbe8 0000000100181e0a ffff880011eaec00 ffffffff804b8e27
Call Trace:
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff804f4b75>] ? tcp_recvmsg+0x625/0xd60
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 15431   2949
 ffff88007c4b1a78 0000000000000082 2e699266c8a46cd2 1f376e93654edc37
 ffffffff807bb000 ffff88005edd0240 ffff880026c2c480 ffff88005edd0580
 000000004da83eb9 1d59b8b65422dddb ffff88005edd0580 3acc6bfce8955a71
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 15466   2949
 ffff880010a6bc58 0000000000000082 ffff880010a6bc58 ffff880010a6bbe8
 ffffffff807bb000 ffff88000e6484c0 ffff88007a958700 ffff88000e648800
 0000000210a6bdd8 0000000100181dfc ffff88000e648800 00000000000094fd
Call Trace:
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001ffe3a58     0 15467   2949
 ffff88001ffe3a48 0000000000000082 ffff88001ffe39a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88007a84c8c0 ffff88005e8d8980 ffff88007a84cc00
 000000011ffe39f8 ffffffff8024ee66 ffff88007a84cc00 ffff88001ffe3a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff80248790>] ? timespec_trunc+0x0/0x40
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002d2a7a48     0 15728   2949
 ffff88002d2a7a38 0000000000000082 ffff88002d2a79b8 ffffffff8028e8b8
 ffffffff807bb000 ffff8800172d41c0 ffff88007b4f2140 ffff8800172d4500
 000000002d2a79e8 ffffffff8024ee66 ffff8800172d4500 ffff88002d2a7a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800771f5a48     0 15753   2949
 ffff8800771f5a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88006a10c340 ffff880036ce2940 ffff88006a10c680
 00000001771f59e8 ffffffff8024ee66 ffff88006a10c680 ffff8800771f5a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 15754   2949
 ffff88002b917a78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88001f1a8040 ffff88006a10c340 ffff88001f1a8380
 0000000200000000 0000000000000000 ffff88001f1a8380 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d833a58     0 15810   2949
 ffff88007d833a48 0000000000000082 ffff88007d8339a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880002f38940 ffff88007981e480 ffff880002f38c80
 000000017d8339f8 ffffffff8024ee66 ffff880002f38c80 ffff88007d833a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 15811   2949
 ffff880009aedc58 0000000000000082 ffff88006a10c378 ffff880009aedbe8
 ffffffff807bb000 ffff88000ebe8940 ffff880014f1c040 ffff88000ebe8c80
 000000036a10c378 0000000100181d59 ffff88000ebe8c80 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005d01da48     0 16199   2949
 ffff88005d01da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880002e646c0 ffff880065184540 ffff880002e64a00
 000000005d01d9e8 ffffffff8024ee66 ffff880002e64a00 ffff88005d01da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880010e7fa48     0 16242   2949
 ffff880010e7fa38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005798e9c0 ffff880018c7c5c0 ffff88005798ed00
 0000000010e7f9e8 ffffffff8024ee66 ffff88005798ed00 ffff880010e7fa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 16243   2949
 ffff880061f43a78 0000000000000082 ffff880061f43a08 ffffffff802afa5c
 ffffffff807bb000 ffff8800795ee100 ffff880002e646c0 ffff8800795ee440
 0000000061f43a08 ffff880061f43a28 ffff8800795ee440 ffffffff80299a00
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff80299a00>] ? handle_mm_fault+0x530/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880026f21578     0 16383   2949
 ffff880026f21568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88000ad46900 ffff88000314a840 ffff88000ad46c40
 0000000126f21518 ffffffff8024ee66 ffff88000ad46c40 ffff880026f21578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 16385   2949
 ffff880016a2dc58 0000000000000082 ffff88005798e9f8 ffff880016a2dbe8
 ffffffff807bb000 ffff88005e902940 ffff88001dec0940 ffff88005e902c80
 000000005798e9f8 0000000100181ce9 ffff88005e902c80 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
pdflush       D ffff880002e99d70     0 22879      2
 ffff880002e99d60 0000000000000046 ffff880002e99cc0 ffffffff8028d9cf
 ffffffff807bb000 ffff880068916780 ffff880016842500 ffff880068916ac0
 0000000102e99d10 ffffffff8024ee66 ffff880068916ac0 ffff880002e99d70
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802dd49a>] ? writeback_inodes+0x6a/0xf0
 [<ffffffff8028e081>] background_writeout+0x51/0xe0
 [<ffffffff8028e754>] pdflush+0x144/0x220
 [<ffffffff8028e030>] ? background_writeout+0x0/0xe0
 [<ffffffff8028e610>] ? pdflush+0x0/0x220
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
v3krecord     D ffff88000e63da48     0 23034   2949
 ffff88000e63da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88000324a040 ffff880017334380 ffff88000324a380
 000000000e63d9e8 ffffffff8024ee66 ffff88000324a380 ffff88000e63da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 23039   2949
 ffff8800580839c8 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff880017ba8700 ffff880067522080 ffff880017ba8a40
 00000001580839e8 ffffffff8024ee66 ffff880017ba8a40 ffff880058083a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23041   2949
 ffff88001381fa78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88006686c280 ffff88000324a040 ffff88006686c5c0
 000000006b6b6b6b 6b6b6b6b6b6b6b6b ffff88006686c5c0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff80287a42>] ? mempool_free_slab+0x12/0x20
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff80233df8>] ? activate_task+0x28/0x40
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23042   2949
 ffff880026e93c58 0000000000000082 ffff880026e93c58 ffff880026e93be8
 ffffffff807bb000 ffff88002fd78300 ffff88002d360300 ffff88002fd78640
 0000000017ba8738 0000000100181d4b ffff88002fd78640 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002d3d7a58     0 23043   2949
 ffff88002d3d7a48 0000000000000082 ffff88002d3d79a8 000000000000000b
 ffffffff807bb000 ffff8800124d41c0 ffff88000adb40c0 ffff8800124d4500
 000000002d3d79f8 ffffffff8024ee66 ffff8800124d4500 ffff88002d3d7a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80266357>] ? wake_futex+0x27/0x40
 [<ffffffff8026644d>] ? futex_wake+0xdd/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001870da48     0 23035   2949
 ffff88001870da38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff88007d4d8940 ffff88007b1f2600 ffff88007d4d8c80
 000000011870d9e8 ffffffff8024ee66 ffff88007d4d8c80 ffff88001870da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 23038   2949
 ffff880010c61a38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff880058b12340 ffff8800369b4380 ffff880058b12680
 0000000110c619e8 ffffffff8024ee66 ffff880058b12680 ffff880010c61a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23040   2949
 ffff88005d1dda78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88005a234040 ffff88007d4d8940 ffff88005a234380
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff88005a234380 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80287a42>] ? mempool_free_slab+0x12/0x20
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23046   2949
 ffff8800140efc58 0000000000000082 ffff8800140efbb8 ffffffff8023b5ad
 ffffffff807bb000 ffff88005d63e0c0 ffff88001ffce400 ffff88005d63e400
 0000000358b12378 0000000100181e12 ffff88005d63e400 ffffffff80238ab8
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88004c325a58     0 23047   2949
 ffff88004c325a48 0000000000000082 ffff88004c3259a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88007e53e180 ffff880016a065c0 ffff88007e53e4c0
 000000014c3259f8 ffffffff8024ee66 ffff88007e53e4c0 ffff88004c325a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880019071a48     0 23050   2949
 ffff880019071a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800663847c0 ffff880049912600 ffff880066384b00
 00000000190719e8 ffffffff8024ee66 ffff880066384b00 ffff880019071a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880079d59a48     0 23052   2949
 ffff880079d59a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800031543c0 ffff88005b6ac580 ffff880003154700
 0000000079d599e8 ffffffff8024ee66 ffff880003154700 ffff880079d59a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 23053   2949
 ffff8800674afa78 0000000000000082 67f3ce41275ed3dc 3e04684d0e336471
 ffffffff807bb000 ffff880019076040 ffffffff806b0340 ffff880019076380
 000000002938a6f6 000000010015e3a8 ffff880019076380 60dfb9e5aedd2399
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23069   2949
 ffff880065821c58 0000000000000082 ffff880065821bb8 ffffffff8023b5ad
 ffffffff807bb000 ffff880013c32980 ffff88000a7142c0 ffff880013c32cc0
 0000000365821be8 0000000100181cfd ffff880013c32cc0 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001fb01a58     0 23070   2949
 ffff88001fb01a48 0000000000000082 ffff88001fb019a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88000326c7c0 ffff8800124d41c0 ffff88000326cb00
 000000001fb019f8 ffffffff8024ee66 ffff88000326cb00 ffff88001fb01a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880004699a48     0 23107   2949
 ffff880004699a38 0000000000000082 00000000000702c9 0000000000000080
 ffffffff807bb000 ffff880048a361c0 ffff88005e930840 ffff880048a36500
 00000001046999e8 ffffffff8024ee66 ffff880048a36500 ffff880004699a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] read_tsc+0x9/0x20
 [<ffffffff802611e9>] getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23111   2949
 ffff88007c979c58 0000000000000082 00000000000000fd 00000000000000fd
 ffffffff807bb000 ffff88005d75a200 ffff8800655303c0 ffff88005d75a540
 000000017c979be8 ffffffff8054dcef ffff88005d75a540 ffffffff804b8e27
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff8023650f>] ? task_rq_lock+0x4f/0xa0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 23112   2949
 ffff880009a97a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff8800790e61c0 ffffffff806b0340 ffff8800790e6500
 000000006b6b6b6b 000000010015e4b6 ffff8800790e6500 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23127   2949
 ffff880011fa1c58 0000000000000082 ffff880011fa1c38 ffff880011fa1be8
 ffffffff807bb000 ffff880011d2e040 ffff88005d75a200 ffff880011d2e380
 000000015d75a238 0000000000000001 ffff880011d2e380 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880013deda58     0 23129   2949
 ffff880013deda48 0000000000000082 ffff880013ded9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880025f946c0 ffff88005e3fa4c0 ffff880025f94a00
 0000000013ded9f8 ffffffff8024ee66 ffff880025f94a00 ffff880013deda58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005c537a48     0 23138   2949
 ffff88005c537a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff88005b1b8500 ffff880002e76400 ffff88005b1b8840
 000000015c5379e8 ffffffff8024ee66 ffff88005b1b8840 ffff88005c537a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23145   2949
 ffff8800588f9c58 0000000000000082 0000003800000038 0000000000000001
 ffffffff807bb000 ffff880040090980 ffff88001fa8c180 ffff880040090cc0
 00000000588f9be8 0000000000000000 ffff880040090cc0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23146   2949
 ffff88006d129a78 0000000000000082 a49429ae03a7e473 48ae64dda3829acb
 ffffffff807bb000 ffff880022340240 ffff88005b1b8500 ffff880022340580
 00000000ea691fae 5d23559dcc7cd0a7 ffff880022340580 93e22251a5c751f8
Call Trace:
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23148   2949
 ffff880048a29c58 0000000000000082 ffff880048a29c58 ffff880048a29c58
 ffffffff807bb000 ffff88000b17e740 ffff88005b1209c0 ffff88000b17ea80
 00000000400909b8 0000000100181e0f ffff88000b17ea80 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006504ba58     0 23151   2949
 ffff88006504ba48 0000000000000082 ffff88006504b9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88007a8207c0 ffff8800655303c0 ffff88007a820b00
 000000016504b9f8 ffffffff8024ee66 ffff88007a820b00 ffff88006504ba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80266357>] ? wake_futex+0x27/0x40
 [<ffffffff8026644d>] ? futex_wake+0xdd/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880014eafa48     0 23160   2949
 ffff880014eafa38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007b4f2140 ffff88005b1ba600 ffff88007b4f2480
 0000000014eaf9e8 ffffffff8024ee66 ffff88007b4f2480 ffff880014eafa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff88002f0e5a48     0 23162   2949
 ffff88002f0e5a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88002b806140 ffff88005e930840 ffff88002b806480
 000000002f0e59e8 ffffffff8024ee66 ffff88002b806480 ffff88002f0e5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 23163   2949
 ffff88000ad87a78 0000000000000082 59770cf6c3d2a161 2101caecbb21210d
 ffffffff807bb000 ffff88007d05c680 ffffffff806b0340 ffff88007d05c9c0
 00000000cb802d90 000000010015e541 ffff88007d05c9c0 912ce979767452e2
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23168   2949
 ffff88007d9e7c58 0000000000000082 ffff88007d9e7bb8 ffffffff8023b5ad
 ffffffff807bb000 ffff8800758a6500 ffff88005b1209c0 ffff8800758a6840
 000000007d9e7be8 0000000100181d10 ffff8800758a6840 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 23169   2949
 ffff88005a299a48 0000000000000082 ffff88005a2999a8 ffffffff8028d9cf
 ffffffff807bb000 ffff8800774ee780 ffff88007a8207c0 ffff8800774eeac0
 000000015a2999f8 ffffffff8024ee66 ffff8800774eeac0 ffff88005a299a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 23171   2949
 ffff880079d9fa38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880016974800 ffff88007e4002c0 ffff880016974b40
 0000000179d9f9e8 ffffffff8024ee66 ffff880016974b40 ffff880079d9fa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 23179   2949
 ffff88006595da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005d1389c0 ffff880078906740 ffff88005d138d00
 000000016595d9e8 ffffffff8024ee66 ffff88005d138d00 ffff88006595da48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff80290b50>] isolate_pages_global+0x0/0x250
 [<ffffffff8024ea20>] process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] security_file_permission+0x11/0x20
 [<ffffffff802bf239>] vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 23180   2949
 ffff880067455a78 0000000000000082 4582939a7365ab95 36d0148e650dab44
 ffffffff807bb000 ffff88007dd0e040 ffffffff806b0340 ffff88007dd0e380
 000000000acc14b3 000000010015e55d ffff88007dd0e380 a882f2b1df547094
Call Trace:
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80246635>] ? release_task+0x305/0x430
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23190   2949
 ffff88006699bc58 0000000000000082 ffff88006699bbb8 ffff88006699bbe8
 ffffffff807bb000 ffff88002b8b2080 ffff8800748b0800 ffff88002b8b23c0
 000000035d1389f8 0000000000000001 ffff88002b8b23c0 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d4bfa58     0 23191   2949
 ffff88007d4bfa48 0000000000000082 ffff88007d4bf9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88005e8d8980 ffff880032f12680 ffff88005e8d8cc0
 000000017d4bf9f8 ffffffff8024ee66 ffff88005e8d8cc0 ffff88007d4bfa58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880003b01a48     0 23177   2949
 ffff880003b01a38 0000000000000082 ffff880003b019b8 0000000000000080
 ffffffff807bb000 ffff88007d14e940 ffff88007d4d8940 ffff88007d14ec80
 0000000103b019e8 ffffffff8024ee66 ffff88007d14ec80 ffff880003b01a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23184   2949
 ffff880077db9c58 0000000000000082 ffff880077db9bb8 ffffffff8023b5ad
 ffffffff807bb000 ffff88006543c140 ffff88007fbd02c0 ffff88006543c480
 0000000277db9be8 ffffffff8025a9e1 ffff88006543c480 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8025a9e1>] ? wake_bit_function+0x31/0x40
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 23185   2949
 ffff88004c297a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88007d8b6180 ffff88007fba0240 ffff88007d8b64c0
 000000016b6b6b6b 000000010015e562 ffff88007d8b64c0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23202   2949
 ffff88007a525c58 0000000000000082 ffff88007a525c58 ffff88007a525be8
 ffffffff807bb000 ffff8800177ce440 ffff8800030a6040 ffff8800177ce780
 000000026543c178 0000000000000001 ffff8800177ce780 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002d2f9a58     0 23203   2949
 ffff88002d2f9a48 0000000000000082 ffff88002d2f99a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88007981e480 ffff88007e53e180 ffff88007981e7c0
 000000012d2f99f8 ffffffff8024ee66 ffff88007981e7c0 ffff88002d2f9a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 23186   2949
 ffff88007a7f9a38 0000000000000082 ffff88007a7f99b8 ffffffff8028e8b8
 ffffffff807bb000 ffff8800343fe1c0 ffff8800030bc400 ffff8800343fe500
 000000007a7f99e8 ffffffff8024ee66 ffff8800343fe500 ffff88007a7f9a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23192   2949
 ffff880003b77c58 0000000000000082 ffff8800368c8300 ffff88000103d2f0
 ffffffff807bb000 ffff880077114400 ffff8800368c8300 ffff880077114740
 000000030103d280 ffff8800368c8300 ffff880077114740 ffff88000103d280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23196   2949
 ffff88005d791a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88001fe52980 ffff8800343fe1c0 ffff88001fe52cc0
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff88001fe52cc0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23208   2949
 ffff880034319c58 0000000000000082 ffff880034319c58 ffff880034319be8
 ffffffff807bb000 ffff8800794e2580 ffff880077114400 ffff8800794e28c0
 0000000377114438 0000000100181d7a ffff8800794e28c0 0000000000000092
Call Trace:
 [<ffffffff8021e41a>] ? native_smp_send_reschedule+0x3a/0x50
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880003f1ba58     0 23209   2949
 ffff880003f1ba48 0000000000000082 ffff880003f1b9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880016a065c0 ffff88007981e480 ffff880016a06900
 0000000103f1b9f8 ffffffff8024ee66 ffff880016a06900 ffff880003f1ba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c46ba48     0 23207   2949
 ffff88007c46ba38 0000000000000082 ffff88007c46b9b8 0000000000000080
 ffffffff807bb000 ffff880034316540 ffff8800663847c0 ffff880034316880
 000000017c46b9e8 ffffffff8024ee66 ffff880034316880 ffff88007c46ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23212   2949
 ffff880011fb7c58 0000000000000082 ffff8800368c8300 ffff8800010312f0
 ffffffff807bb000 ffff88001dfc4680 ffff88004895c7c0 ffff88001dfc49c0
 0000000101031280 ffff8800368c8300 ffff88001dfc49c0 ffff880001031280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23213   2949
 ffff88005e90ba78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88000c2e46c0 ffff880034316540 ffff88000c2e4a00
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff88000c2e4a00 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23218   2949
 ffff88005d029c58 0000000000000082 ffff88005d029c38 ffff88005d029be8
 ffffffff807bb000 ffff88004895c7c0 ffff880048ac0500 ffff88004895cb00
 000000011dfc46b8 0000000100181297 ffff88004895cb00 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80265e41>] ? futex_wait+0x1/0x4a0
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880018dd1a58     0 23221   2949
 ffff880018dd1a48 0000000000000082 ffff880018dd19a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880009afc800 ffff880014f1c040 ffff880009afcb40
 0000000118dd19f8 ffffffff8024ee66 ffff880009afcb40 ffff880018dd1a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23230   2949
 ffff880078c59c58 0000000000000082 ffff8800368c8300 ffff88000103d2f0
 ffffffff807bb000 ffff880031984840 ffff8800368c8300 ffff880031984b80
 000000030103d280 ffff8800368c8300 ffff880031984b80 ffff88000103d280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23240   2949
 ffff88000b09bc58 0000000000000082 0000000000000222 0000000000000222
 ffffffff807bb000 ffff88005c8d65c0 ffff880031984840 ffff88005c8d6900
 000000000b09bbe8 ffffffff8054dcef ffff88005c8d6900 ffffffff804b8e27
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff804f4b75>] ? tcp_recvmsg+0x625/0xd60
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23241   2949
 ffff8800361b5a78 0000000000000082 ffffffff807bb000 ffff8800177545c0
 ffffffff807bb000 ffff88007b8f4580 ffff88005c8d65c0 ffff88007b8f48c0
 0000000217754900 ffff88000c25e880 ffff88007b8f48c0 ffffffff802b6998
Call Trace:
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff80391705>] ? kmem_free+0x35/0x40
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23259   2949
 ffff880065975c58 0000000000000082 ffff880065975c58 ffff880065975c58
 ffffffff807bb000 ffff880012554140 ffff880059e88400 ffff880012554480
 000000025c8d65f8 00000001001803ac ffff880012554480 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 7fffffffffffffff     0 23262   2949
 ffff88005d019568 0000000000000082 ffff88005d0194d8 ffffffff80233df8
 ffffffff807bb000 ffff880014f78140 ffff88000d986980 ffff880014f78480
 000000030103d280 000000003a352fc0 ffff880014f78480 ffff880067cbded0
Call Trace:
 [<ffffffff80233df8>] ? activate_task+0x28/0x40
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff802e63f3>] ? __bio_add_page+0x123/0x230
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803415f5>] xfs_alloc_vextent+0x1c5/0x4f0
 [<ffffffff80350872>] xfs_bmap_btalloc+0x612/0xb10
 [<ffffffff80350d8c>] xfs_bmap_alloc+0x1c/0x40
 [<ffffffff803540ce>] xfs_bmapi+0x9ee/0x12d0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8038bdbe>] xfs_alloc_file_space+0x1ee/0x450
 [<ffffffff80390b0e>] xfs_change_file_space+0x2be/0x320
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff80396e99>] xfs_ioc_space+0xc9/0xe0
 [<ffffffff8039898d>] xfs_ioctl+0x14d/0x860
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff80396785>] xfs_file_ioctl+0x35/0x80
 [<ffffffff802cc771>] vfs_ioctl+0x31/0xa0
 [<ffffffff802cc854>] do_vfs_ioctl+0x74/0x480
 [<ffffffff802cccf9>] sys_ioctl+0x99/0xa0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000b1bfa48     0 23242   2949
 ffff88000b1bfa38 0000000000000082 ffff88000b1bf9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff88007b08e500 ffff8800795441c0 ffff88007b08e840
 000000000b1bf9e8 ffffffff8024ee66 ffff88007b08e840 ffff88000b1bfa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800545d9a48     0 23249   2949
 ffff8800545d9a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880011f20980 ffff880058b12340 ffff880011f20cc0
 00000001545d99e8 ffffffff8024ee66 ffff880011f20cc0 ffff8800545d9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 23250   2949
 ffff880008bdda78 0000000000000082 ffffffff807bb000 ffff880027526480
 ffffffff807bb000 ffff8800795ca9c0 ffff88007fbda340 ffff8800795cad00
 00000002275267c0 000000010015e5b7 ffff8800795cad00 ffffffff802b6998
Call Trace:
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff80391705>] ? kmem_free+0x35/0x40
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803dafba>] ? put_io_context+0x6a/0x80
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23309   2949
 ffff88000c3c5c58 0000000000000082 ffff880011f209b8 ffff88000c3c5be8
 ffffffff807bb000 ffff8800169628c0 ffff88005d1389c0 ffff880016962c00
 0000000011f209b8 0000000100181d5b ffff880016962c00 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23311   2949
 ffff88007b8dbc58 0000000000000082 ffff88007b8dbbe8 ffffffff802e27c8
 ffffffff807bb000 ffff880010e08800 ffff88002f6021c0 ffff880010e08b40
 00000000000002b9 0000000000000008 ffff880010e08b40 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001def9a48     0 23256   2949
 ffff88001def9a38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff8800795a8080 ffff880002f8a900 000000000000000a
 000000011def99e8 ffffffff8024ee66 ffff8800795a83c0 ffff88001def9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff88005e803a48     0 23265   2949
 ffff88005e803a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88002f6021c0 ffff88001724c780 ffff88002f602500
 000000005e8039e8 ffffffff8024ee66 ffff88002f602500 ffff88005e803a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23266   2949
 ffff88005a335a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880057582880 ffff8800795a8080 ffff880057582bc0
 000000006b6b6b6b 6b6b6b6b6b6b6b6b ffff880057582bc0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006549b578     0 23308   2949
 ffff88006549b568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff880016842500 ffff88000314a840 ffff880016842840
 000000016549b518 ffffffff8024ee66 ffff880016842840 ffff88006549b578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23310   2949
 ffff880048937c58 0000000000000082 ffff88002f6021f8 ffff880048937be8
 ffffffff807bb000 ffff88007d084540 ffff880009a24600 ffff88007d084880
 000000002f6021f8 0000000000000001 ffff88007d084880 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880065451a48     0 23270   2949
 ffff880065451a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005ed5c240 ffff880076cc4400 ffff88005ed5c580
 00000000654519e8 ffffffff8024ee66 ffff88005ed5c580 ffff880065451a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800183f9908     0 23279   2949
 ffff8800183f98f8 0000000000000082 ffffffff803ec779 ffff880001025280
 ffffffff807bb000 ffff880032fc25c0 ffff880016ac2940 ffff880032fc2900
 00000002183f98a8 ffffffff8024ee66 ffff880032fc2900 ffff8800183f9908
Call Trace:
 [<ffffffff803ec779>] ? rb_insert_color+0x109/0x140
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23282   2949
 ffff880048895a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff8800223ac440 ffff88005ed5c240 ffff8800223ac780
 000000026b6b6b6b 6b6b6b6b6b6b6b6b ffff8800223ac780 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23315   2949
 ffff88005b007c58 0000000000000082 ffff88005b007c58 ffff88005b007c58
 ffffffff807bb000 ffff88001912e580 ffff88007e890140 ffff88001912e8c0
 000000037b553ca0 ffff88007b553c98 ffff88001912e8c0 ffffffff80805db0
Call Trace:
 [<ffffffff803f4422>] ? plist_add+0x42/0xb0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002b919a58     0 23316   2949
 ffff88002b919a48 0000000000000082 ffff88002b9199a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880014f1c040 ffff880032f12680 ffff880014f1c380
 000000012b9199f8 ffffffff8024ee66 ffff880014f1c380 ffff88002b919a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 23272   2949
 ffff8800794bfa38 0000000000000082 ffff8800794bf9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880000002c28 ffff88005d10e8c0 ffff88007e400600
 00000001794bf9e8 ffffffff8024ee66 ffff88007e400600 ffffffff80294076
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff88002d251a48     0 23278   2949
 ffff88002d251a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880011f6c380 ffff8800139888c0 ffff880011f6c6c0
 000000002d2519e8 ffffffff8024ee66 ffff880011f6c6c0 ffff88002d251a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23280   2949
 ffff88004888da78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff8800545703c0 ffff88007e4002c0 ffff880054570700
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff880054570700 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23327   2949
 ffff88007a0c7c58 0000000000000082 ffff880011f6c3b8 ffff88007a0c7be8
 ffffffff807bb000 ffff880014e9a080 ffff880025ec8380 ffff880014e9a3c0
 0000000211f6c3b8 0000000000000001 ffff880014e9a3c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23328   2949
 ffff88007d813c58 0000000000000082 ffff88007d813be8 ffffffff802e27c8
 ffffffff807bb000 ffff880020a700c0 ffff880011f6c380 ffff880020a70400
 0000000200000d5c 0000000000000008 ffff880020a70400 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007bcd5a48     0 23340   2949
 ffff88007bcd5a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880020a961c0 ffff88007ad8a700 ffff880020a96500
 000000007bcd59e8 ffffffff8024ee66 ffff880020a96500 ffff88007bcd5a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880051675a48     0 23450   2949
 ffff880051675a38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff88005d6141c0 ffff88004c214900 ffff88005d614500
 00000000516759e8 ffffffff8024ee66 ffff88005d614500 ffff880051675a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23451   2949
 ffff880078c3fa78 0000000000000082 06e5112040d83587 bfd2fe5b69cdebeb
 ffffffff807bb000 ffff88007e43c2c0 ffff88005807c600 ffff88007e43c600
 0000000384caca93 cef16350a7091f8d ffff88007e43c600 8d242c017eedde14
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23472   2949
 ffff8800168efc58 0000000000000082 ffff8800168efbb8 ffffffff8023b5ad
 ffffffff807bb000 ffff88000c33e440 ffff88007b962580 ffff88000c33e780
 00000001168efdd8 ffff8800168efdd8 ffff88000c33e780 00000000000071f5
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001866ba58     0 23473   2949
 ffff88001866ba48 0000000000000082 ffff88001866b9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880009a24600 ffff880048b8e500 ffff880009a24940
 000000011866b9f8 ffffffff8024ee66 ffff880009a24940 ffff88001866ba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000c2b5a48     0 23420   2949
 ffff88000c2b5a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800658503c0 ffff88007c5ae4c0 ffff880065850700
 000000000c2b59e8 ffffffff8024ee66 ffff880065850700 ffff88000c2b5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880017b19a48     0 23477   2949
 ffff880017b19a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005d01a740 ffff8800342b82c0 ffff88005d01aa80
 0000000117b199e8 ffffffff8024ee66 ffff88005d01aa80 ffff880017b19a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23478   2949
 ffff88002e56da78 0000000000000082 e464798c22ca0a75 8a8431efaafadffd
 ffffffff807bb000 ffff880002ff8100 ffff88005c570280 ffff880002ff8440
 00000003cb14dd8d 0512a6163764692b ffff880002ff8440 5bea746d292b35c0
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23505   2949
 ffff880076d71c58 0000000000000082 ffff880076d71bb8 ffffffff8023b5ad
 ffffffff807bb000 ffff880048a40900 ffff8800758f8340 ffff880048a40c40
 000000005d01a778 0000000100181d43 ffff880048a40c40 ffffffff80238be4
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880003bbba58     0 23506   2949
 ffff880003bbba48 0000000000000082 ffff880003bbb9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880059e88400 ffff880009a24600 ffff880059e88740
 0000000103bbb9f8 ffffffff8024ee66 ffff880059e88740 ffff880003bbba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001833da48     0 23460   2949
 ffff88001833da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007a4ec6c0 ffff88007b078180 ffff88007a4eca00
 000000011833d9e8 ffffffff8024ee66 ffff88007a4eca00 ffff88001833da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b1>] ? read_tsc+0x1/0x20
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23479   2949
 ffff88005e887c58 0000000000000082 0000000000000539 0000000000000539
 ffffffff807bb000 ffff88007906e7c0 ffff88007a8207c0 ffff88007906eb00
 000000005e887be8 ffffffff8054dcef ffff88007906eb00 ffffffff8028548b
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8023650f>] ? task_rq_lock+0x4f/0xa0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23481   2949
 ffff88005edf5a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88000d988200 ffff88007a4ec6c0 ffff88000d988540
 000000026b6b6b6b 6b6b6b6b6b6b6b6b ffff88000d988540 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23496   2949
 ffff88000d0edc58 0000000000000082 0000000000000000 00000000ffffffff
 ffffffff807bb000 ffff8800798c2980 ffff88007906e7c0 ffff8800798c2cc0
 000000007906e7f8 0000000000000001 ffff8800798c2cc0 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 0000000000000002     0 23498   2949
 ffff880018369568 0000000000000082 ffff880018369508 ffffffffa028b602
 ffffffff807bb000 ffff88001ffe8440 ffff8800662ae480 ffff88001ffe8780
 0000000200000001 ffff880011e12d68 ffff88001ffe8780 ffff880011e128a0
Call Trace:
 [<ffffffffa028b602>] ? __map_bio+0x42/0x160 [dm_mod]
 [<ffffffffa028c309>] ? __split_bio+0xe9/0x4a0 [dm_mod]
 [<ffffffff8054d95d>] __down_read+0x8d/0xba
 [<ffffffff8054c879>] down_read+0x9/0x10
 [<ffffffff8036f5d5>] xfs_ilock+0x55/0xa0
 [<ffffffff8036f63e>] xfs_ilock_map_shared+0x1e/0x50
 [<ffffffff80377955>] xfs_iomap+0x1a5/0x300
 [<ffffffffa028d07d>] ? dm_merge_bvec+0xbd/0x120 [dm_mod]
 [<ffffffff803d705e>] ? submit_bio+0x6e/0xf0
 [<ffffffff80392786>] xfs_map_blocks+0x36/0x90
 [<ffffffff803931c1>] xfs_page_state_convert+0x291/0x760
 [<ffffffff803ebb90>] ? radix_tree_gang_lookup_tag_slot+0xc0/0xe0
 [<ffffffff80393998>] xfs_vm_writepage+0x68/0x110
 [<ffffffff8028cc22>] __writepage+0x12/0x50
 [<ffffffff8028d777>] write_cache_pages+0x227/0x460
 [<ffffffff8028cc10>] ? __writepage+0x0/0x50
 [<ffffffff8028d9cf>] generic_writepages+0x1f/0x30
 [<ffffffff803938f4>] xfs_vm_writepages+0x54/0x70
 [<ffffffff8028da08>] do_writepages+0x28/0x50
 [<ffffffff802dc7b0>] __writeback_single_inode+0xa0/0x4c0
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c555a48     0 23475   2949
 ffff88007c555a38 0000000000000082 ffff88007c5559b8 ffffffff8028e8b8
 ffffffff807bb000 ffff88005c570280 ffff88005b1ba600 ffff88005c5705c0
 000000007c5559e8 ffffffff8024ee66 ffff88005c5705c0 ffff88007c555a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800794dfc18     0 23484   2949
 ffff8800794dfc08 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800758f8340 ffff88000324a040 ffff8800758f8680
 00000000794dfbb8 ffffffff8024ee66 ffff8800758f8680 ffff8800794dfc18
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802afa5c>] alloc_page_vma+0x6c/0x200
 [<ffffffff802999d0>] handle_mm_fault+0x500/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23486   2949
 ffff880032e8fa78 0000000000000082 0c09734d8adf737d 00af52f993fae424
 ffffffff807bb000 ffff88007a7e6380 ffff88005c570280 ffff88007a7e66c0
 000000039a1cd047 d7e339ce91a64872 ffff88007a7e66c0 4403e0f48c51fa38
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23517   2949
 ffff88003191bc58 0000000000000082 ffff88003191bc08 ffffffff80285664
 ffffffff807bb000 ffff88000c328400 ffff880067da86c0 ffff88000c328740
 000000008025a9b0 0000000100181d5a ffff88000c328740 ffffffff8028548b
Call Trace:
 [<ffffffff80285664>] ? __lock_page+0x64/0x70
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff80285818>] ? find_lock_page+0x58/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007dc19a58     0 23518   2949
 ffff88007dc19a48 0000000000000082 ffff88007dc199a8 ffffffff8028d9cf
 ffffffff807bb000 ffff8800589e4640 ffff8800662ae480 ffff8800589e4980
 000000007dc199f8 ffffffff8024ee66 ffff8800589e4980 ffff88007dc19a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800187d7a48     0 23485   2949
 ffff8800187d7a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff88005e930840 ffff88007af7c600 ffff88005e930b80
 00000000187d79e8 ffffffff8024ee66 ffff88005e930b80 ffff8800187d7a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800319b5a48     0 23510   2949
 ffff8800319b5a38 ffffffff80292f10 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800323248c0 ffff8800342b82c0 ffff880032324c00
 00000001319b59e8 ffffffff8024ee66 ffff880032324c00 ffff8800319b5a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff80294076>] ? try_to_free_pages+0x266/0x3b0
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23511   2949
 ffff88005d097a78 0000000000000082 ffff88005d097a08 ffffffff802afa5c
 ffffffff807bb000 ffff88001ff96640 ffff88005e930840 ffff88001ff96980
 000000035d097a08 ffff88005d097a28 ffff88001ff96980 ffffffff80299a00
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff80299a00>] ? handle_mm_fault+0x530/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80237107>] ? pick_next_task_fair+0x77/0xa0
 [<ffffffff8054b9c8>] ? thread_return+0x306/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23552   2949
 ffff880016877c58 0000000000000082 ffff8800323248f8 ffff880016877be8
 ffffffff807bb000 ffff8800221de880 ffff880075708740 ffff8800221debc0
 00000002323248f8 0000000000000001 ffff8800221debc0 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff8028f584>] ? release_pages+0x204/0x250
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8025e7f9>] ? up_write+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002e597a58     0 23553   2949
 ffff88002e597a48 0000000000000082 ffff88002e5979a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880032f12680 ffff88007e53e180 ffff880032f129c0
 000000012e5979f8 ffffffff8024ee66 ffff880032f129c0 ffff88002e597a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880067cf9a48     0 23564   2949
 ffff880067cf9a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88007883c340 ffff88007e91c400 ffff88007883c680
 0000000067cf99e8 ffffffff8024ee66 ffff88007883c680 ffff880067cf9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 23572   2949
 ffff88000d8b5c58 0000000000000082 0000003800000038 0000000000000001
 ffffffff807bb000 ffff880017286480 ffff8800795441c0 ffff8800172867c0
 000000010d8b5be8 0000000000000000 ffff8800172867c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23573   2949
 ffff88002f73ba78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88007a642080 ffff88007883c340 ffff88007a6423c0
 0000000200000000 0000000000000000 ffff88007a6423c0 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880010cffa58     0 23597   2949
 ffff880010cffa48 0000000000000082 ffff880010cff9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880011d94080 ffff8800774ee780 ffff880011d943c0
 0000000110cff9f8 ffffffff8024ee66 ffff880011d943c0 ffff880010cffa58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 23598   2949
 ffff880017b55c58 0000000000000082 ffff880017b55c58 ffff880017b55c58
 ffffffff807bb000 ffff880015008880 ffff88007fba0240 ffff880015008bc0
 00000001172864b8 0000000100181e12 ffff880015008bc0 0000000000000092
Call Trace:
 [<ffffffff8021e41a>] ? native_smp_send_reschedule+0x3a/0x50
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007a567a48     0 23829   2949
 ffff88007a567a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880065184540 ffff880002f86440 ffff880065184880
 000000017a5679e8 ffffffff8024ee66 ffff880065184880 ffff88007a567a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80214159>] ? native_read_tsc+0x9/0x20
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff88005d099a48     0 23847   2949
 ffff88005d099a38 0000000000000082 ffff88005d0999b8 0000000000000080
 ffffffff807bb000 ffff880067de6180 ffff88005b1b8500 ffff880067de64c0
 000000015d0999e8 ffffffff8024ee66 ffff880067de64c0 ffff88005d099a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 23848   2949
 ffff880011ed3a78 0000000000000082 ffff880011ed3b38 ffff88005eca44b0
 ffffffff807bb000 ffff880010e024c0 ffff88007fbda340 ffff880010e02800
 0000000211ed3a38 000000010015e886 ffff880010e02800 ffffffff8028fb40
Call Trace:
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 23907   2949
 ffff880031875c58 0000000000000082 ffff880031875c58 ffff880031875be8
 ffffffff807bb000 ffff880002e62200 ffff88000b18c200 ffff880002e62540
 0000000167de61b8 0000000000000001 ffff880002e62540 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff803ec989>] ? rb_erase+0x1d9/0x350
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880079967a58     0 23908   2949
 ffff880079967a48 0000000000000082 ffff8800799679a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88000e64c780 ffff880014f1c040 ffff88000e64cac0
 00000001799679f8 ffffffff8024ee66 ffff88000e64cac0 ffff880079967a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff8800662eba48     0 24340   2732
 ffff8800662eba38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff880011ca6700 ffff88007885a380 ffff880011ca6a40
 00000001662eb9e8 ffffffff8024ee66 ffff880011ca6a40 ffff8800662eba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff88001fa91a48     0 24343   2732
 ffff88001fa91a38 0000000000000082 ffff88001fa919b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880019160300 ffff880012434880 ffff880019160640
 000000001fa919e8 ffffffff8024ee66 ffff880019160640 ffff88001fa91a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0 24638   2732
 ffff880061fefb28 0000000000000082 ffff880061fefa98 ffffffff802b6741
 ffffffff807bb000 ffff88005a220280 ffff88007add4500 ffff88005a2205c0
 0000000361fefaf8 ffffffff802b8e80 ffff88005a2205c0 ffff88007f021930
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b8e80>] ? cache_flusharray+0x120/0x160
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880061fcd838     0 27669   2949
 ffff880061fcd828 0000000000000082 ffffe200008dd3b0 0000000000000000
 ffffffff807bb000 ffff8800030b4800 ffff88005a28e5c0 ffff8800030b4b40
 0000000261fcd7d8 ffffffff8024ee66 ffff8800030b4b40 ffff880061fcd838
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80292454>] ? shrink_active_list+0x3c4/0x470
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e1a4>] throttle_vm_writeout+0x94/0xb0
 [<ffffffff80292ddd>] shrink_zone+0x2ad/0x350
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 27672   2949
 ffff880017201c58 0000000000000082 0000000000000131 0000000000000131
 ffffffff807bb000 ffff880024a586c0 ffff88000ac36140 ffff880024a58a00
 0000000217201be8 ffffffff8054dcef ffff880024a58a00 ffffffff804b8e27
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff8023650f>] ? task_rq_lock+0x4f/0xa0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 27673   2949
 ffff88005d6a9a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88005bc4e540 ffff8800030b4800 ffff88005bc4e880
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff88005bc4e880 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 27722   2949
 ffff88000e6efc58 0000000000000082 ffff88000e6efc58 ffff88000e6efbe8
 ffffffff807bb000 ffff880002f64980 ffff88000e6484c0 ffff880002f64cc0
 0000000224a586f8 0000000000000001 ffff880002f64cc0 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880022109a48     0 27723   2949
 ffff880022109a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005d08c780 ffff88007fb76040 ffff88005d08cac0
 00000001221099e8 ffffffff8024ee66 ffff88005d08cac0 ffff880022109a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028cbc9>] __alloc_pages_internal+0x489/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] security_file_permission+0x11/0x20
 [<ffffffff802bef7c>] vfs_write+0x12c/0x190
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0 30032   2732
 ffff880003165b28 0000000000000082 0000000000000004 ffffffff803f00b5
 ffffffff807bb000 ffff880010f7c0c0 ffff880000d16880 ffff880010f7c400
 000000007f804d00 ffff88006598b7c0 ffff880010f7c400 ffffffff802b6998
Call Trace:
 [<ffffffff803f00b5>] ? memmove+0x45/0x60
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff88007b0c1a48     0 30104   2732
 ffff88007b0c1a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800516f2900 ffff88004cddc440 ffff8800516f2c40
 000000007b0c19e8 ffffffff8024ee66 ffff8800516f2c40 ffff88007b0c1a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880002e35d48     0   744   2949
 ffff880002e35d38 0000000000000082 ffff88006c8623f8 ffff88003c0a4eb8
 ffffffff807bb000 ffff8800774d8240 ffff88007a958700 ffff8800774d8580
 0000000302e35ce8 ffffffff803938f4 ffff8800774d8580 ffff88006c8622d8
Call Trace:
 [<ffffffff803938f4>] ? xfs_vm_writepages+0x54/0x70
 [<ffffffff8028da08>] ? do_writepages+0x28/0x50
 [<ffffffff8039e155>] vn_iowait+0x85/0xc0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80396b13>] ? xfs_flush_pages+0x83/0xa0
 [<ffffffff803907f8>] xfs_setattr+0xbd8/0xc30
 [<ffffffff80399d38>] xfs_vn_setattr+0x18/0x20
 [<ffffffff802d3f9a>] notify_change+0x19a/0x360
 [<ffffffff802bd5c3>] do_truncate+0x63/0x90
 [<ffffffff802c254e>] ? sys_newfstat+0x2e/0x40
 [<ffffffff802bd6d2>] sys_ftruncate+0xe2/0x130
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0   748   2949
 ffff880002fcfc58 0000000000000082 ffff8800368c8300 ffff8800010252f0
 ffffffff807bb000 ffff8800574aa840 ffff8800368c8300 ffff8800574aab80
 0000000101025280 ffff8800368c8300 ffff8800574aab80 ffff880001025280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0   750   2949
 ffff88001de37a78 0000000000000082 3a706084edc47678 86e1163aa8b62872
 ffffffff807bb000 ffff88000c2cc780 ffff880037914380 ffff88000c2ccac0
 00000000ab2c15c3 e9acf5e340cc6cba ffff88000c2ccac0 687f110c41ac15a3
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0   755   2949
 ffff8800790bbc58 0000000000000082 ffff8800790bbc58 ffff8800790bbc58
 ffffffff807bb000 ffff88007a45e100 ffff880009a24600 ffff88007a45e440
 00000000790bbfd8 0000000000000000 ffff88007a45e440 ffff8800574aa840
Call Trace:
 [<ffffffff8054b757>] ? thread_return+0x95/0x64e
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0   756   2949
 ffff880003215c58 0000000000000082 0000003800000038 0000000000000001
 ffffffff807bb000 ffff880002ed4840 ffff88002b806140 ffff880002ed4b80
 0000000303215c28 0000000000000000 ffff880002ed4b80 0000000000000000
Call Trace:
 [<ffffffff80289d33>] ? __rmqueue+0xd3/0x270
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80257836>] ? alloc_pid+0x26/0x400
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff80257836>] ? alloc_pid+0x26/0x400
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8023b793>] ? wake_up_new_task+0xc3/0x100
 [<ffffffff802433d1>] ? do_fork+0x131/0x330
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 15664   2949
 ffff880002f1bc58 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88000c3ee300 ffff88007fbda340 ffff88000c3ee640
 000000026b6b6b6b 0000000100181522 ffff88000c3ee640 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800223e1a48     0  3624   2949
 ffff8800223e1a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880002f10200 ffff880002f86440 ffff880002f10540
 00000001223e19e8 ffffffff8024ee66 ffff880002f10540 ffff8800223e1a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] ? schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] ? __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
v3krecord     S 0000000000000000     0  3628   2949
 ffff88005aa1dc58 0000000000000082 ffff88007f020d80 ffff88005c9eb830
 ffffffff807bb000 ffff88002e05c500 ffff880067d60440 ffff88002e05c840
 000000005aa1dbe8 ffffffff8054dcef ffff88002e05c840 ffffffff804b8e27
Call Trace:
 [<ffffffff8054dcef>] ? _spin_unlock_bh+0xf/0x20
 [<ffffffff804b8e27>] ? release_sock+0xb7/0xd0
 [<ffffffff804f4b75>] ? tcp_recvmsg+0x625/0xd60
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  3629   2949
 ffff880016627a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88007a034840 ffff880002f10200 ffff88007a034b80
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff88007a034b80 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  3855   2949
 ffff880017685c58 0000000000000082 ffff880017685c58 ffff880017685be8
 ffffffff807bb000 ffff88005b46c8c0 ffff880067480580 ffff88005b46cc00
 000000012e05c538 00000001001811bd ffff88005b46cc00 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800030f3a58     0  3864   2949
 ffff8800030f3a48 0000000000000082 ffff8800030f39a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880048b8e500 ffff88005aa722c0 ffff880048b8e840
 00000000030f39f8 ffffffff8024ee66 ffff880048b8e840 ffff8800030f3a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff8800030bfa48     0  3851   2732
 ffff8800030bfa38 0000000000000082 ffff8800030bf9b8 0000000000000080
 ffffffff807bb000 ffff8800187ee740 ffff8800758f8340 ffff8800187eea80
 00000000030bf9e8 ffffffff8024ee66 ffff8800187eea80 ffff8800030bfa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff88004fe61a48     0  3983   2732
 ffff88004fe61a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88000315c800 ffff88007fb76040 ffff88000315cb40
 000000014fe619e8 ffffffff8024ee66 ffff88000315cb40 ffffffff80294076
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  3985   2732
 ffff88003fc19b28 0000000000000082 ffff88003fc19a98 ffffffff802b6741
 ffffffff807bb000 ffff880025d542c0 ffff880068916780 ffff880025d54600
 00000003804bdab5 ffff88002062d5f0 ffff880025d54600 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  4089   2732
 ffff8800124e3b28 0000000000000082 0000000000000004 ffffffff803f00b5
 ffffffff807bb000 ffff880003266740 ffff880014f5e2c0 ffff880003266a80
 000000027f804d00 ffff88001495d168 ffff880003266a80 ffffffff802b6998
Call Trace:
 [<ffffffff803f00b5>] ? memmove+0x45/0x60
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  4104   2732
 ffff880002fe9b28 0000000000000082 ffff880002fe9a98 ffffffff802b6741
 ffffffff807bb000 ffff880003268780 ffff8800032389c0 ffff880003268ac0
 00000000804bdab5 ffff8800651f28a8 ffff880003268ac0 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       R  running task        0  4105   2732
 ffff880003229a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880002f86440 ffff88007b4f2140 ffff880002f86780
 00000001032299e8 ffffffff8024ee66 ffff880002f86780 ffff880003229a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  4106   2732
 ffff88000327bb28 0000000000000082 ffff88000327ba98 ffffffff802b6741
 ffffffff807bb000 ffff8800032389c0 ffff880025e4a980 ffff880003238d00
 00000000804bdab5 ffff880006697420 ffff880003238d00 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff88007a4f9a48     0  4311   2732
 ffff88007a4f9a38 0000000000000082 0000000000070309 ffffffff8028e8b8
 ffffffff807bb000 ffff88004c3da400 ffff880048ac0500 ffff88004c3da740
 000000017a4f99e8 ffffffff8024ee66 ffff88004c3da740 ffff88007a4f9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  4319   2732
 ffff880014e03b28 0000000000000082 ffff880014e03a98 ffffffff802b6741
 ffffffff807bb000 ffff88000b064900 ffff88000a0b8700 ffff88000b064c40
 00000001804bdab5 ffff880061e8f250 ffff88000b064c40 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880032ed3a48     0  4344   2949
 ffff880032ed3a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800643c6600 ffff8800544e8400 ffff8800643c6940
 0000000032ed39e8 ffffffff8024ee66 ffff8800643c6940 ffff880032ed3a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0  4383   2949
 ffff88000a6b3c58 0000000000000082 ffff8800368c8300 ffff8800010252f0
 ffffffff807bb000 ffff880009aae880 ffff880011d2e040 ffff880009aaebc0
 0000000301025280 ffff8800368c8300 ffff880009aaebc0 ffff880001025280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  4384   2949
 ffff88002d2f5a78 0000000000000082 5d172199d1f7e83d 7c5d7c7b275c1dbd
 ffffffff807bb000 ffff880011ee6080 ffff8800643c6600 ffff880011ee63c0
 00000001a52143fb 6512975da838c7d8 ffff880011ee63c0 05f3819937128485
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 7fffffffffffffff     0  4415   2949
 ffff88005a2e5568 0000000000000082 ffff88005a2e54d8 ffffffff8028548b
 ffffffff807bb000 ffff88000d986980 ffff88005d1389c0 ffff88000d986cc0
 000000035a2e5518 0000000000000000 ffff88000d986cc0 ffff88007d0bc8a0
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80358049>] ? xfs_bmbt_insert+0xb9/0x160
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803415f5>] xfs_alloc_vextent+0x1c5/0x4f0
 [<ffffffff80350872>] xfs_bmap_btalloc+0x612/0xb10
 [<ffffffff80350d8c>] xfs_bmap_alloc+0x1c/0x40
 [<ffffffff803540ce>] xfs_bmapi+0x9ee/0x12d0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8038bdbe>] xfs_alloc_file_space+0x1ee/0x450
 [<ffffffff80390b0e>] xfs_change_file_space+0x2be/0x320
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff80396e99>] xfs_ioc_space+0xc9/0xe0
 [<ffffffff8039898d>] xfs_ioctl+0x14d/0x860
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff80396785>] xfs_file_ioctl+0x35/0x80
 [<ffffffff802cc771>] vfs_ioctl+0x31/0xa0
 [<ffffffff802cc854>] do_vfs_ioctl+0x74/0x480
 [<ffffffff802cccf9>] sys_ioctl+0x99/0xa0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  4416   2949
 ffff880061fddc58 0000000000000082 ffff880009aae8b8 0000000000000001
 ffffffff807bb000 ffff88000b76c2c0 ffff880077072600 ffff88000b76c600
 0000000309aae8b8 000000010018135a ffff88000b76c600 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S ffff880079ceeb50     0  4358   2732
 ffff880036195ce8 0000000000000082 ffff880036195ca8 ffffffff80285ee0
 ffffffff807bb000 ffff88000b03e380 ffff880014f78140 ffff88000b03e6c0
 0000000136195ce8 ffffffff8028a18d ffff88000b03e6c0 0000003800000010
Call Trace:
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff8028a18d>] ? free_pages_bulk+0x16d/0x3a0
 [<ffffffff803aed04>] ? security_ipc_permission+0x14/0x20
 [<ffffffff803a36d1>] sys_semtimedop+0x781/0x910
 [<ffffffff804bdab5>] ? skb_release_data+0x85/0xd0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802cf730>] ? d_free+0x50/0x60
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff803a386b>] sys_semop+0xb/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff880059f1ba48     0  4372   2732
 ffff880059f1ba38 0000000000000082 ffff880059f1b9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff8800190488c0 ffff880036862600 ffff880019048c00
 0000000059f1b9e8 ffffffff8024ee66 ffff880019048c00 ffff880059f1ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       R  running task        0  4374   2732
 ffff88003615fa38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff88005ecbc900 ffff88007b964540 ffff88005ecbcc40
 000000013615f9e8 ffffffff8024ee66 ffff88005ecbcc40 ffff88003615fa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  4575   2732
 ffff88005b089b28 0000000000000082 0000000000000004 ffffffff803f00b5
 ffffffff807bb000 ffff88001f3566c0 ffff880002fa8340 ffff88001f356a00
 000000005b089af8 ffffffff802b8e80 ffff88001f356a00 ffff88007f021930
Call Trace:
 [<ffffffff803f00b5>] ? memmove+0x45/0x60
 [<ffffffff802b8e80>] ? cache_flusharray+0x120/0x160
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       R  running task        0  4661   2732
 ffff880048b33a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800748b0800 ffff88007885a380 ffff8800748b0b40
 0000000148b339e8 ffffffff8024ee66 ffff8800748b0b40 ffff880048b33a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       R  running task        0  4664   2732
 ffff880007e03a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880011c72140 ffff88006a10c340 ffff880011c72480
 0000000107e039e8 ffffffff8024ee66 ffff880011c72480 ffff880007e03a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0  4665   2732
 ffff88002b345b28 0000000000000082 ffff88002b345a98 ffffffff802b6741
 ffffffff807bb000 ffff880030008940 ffff88000b064900 ffff880030008c80
 00000001804bdab5 ffff880018674338 ffff880030008c80 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S 7fffffffffffffff     0  7419   2732
 ffff88005d6ffb28 0000000000000082 ffff88005d6ffa98 ffffffff802b6741
 ffffffff807bb000 ffff880010f8c500 ffff8800488c47c0 ffff880010f8c840
 00000002804bdab5 ffff88007c9bb990 ffff880010f8c840 ffffffff802b6998
Call Trace:
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff804bd962>] ? __kfree_skb+0x42/0xa0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8025abe9>] ? prepare_to_wait+0x49/0x80
 [<ffffffff8052c5c0>] unix_stream_recvmsg+0x4e0/0x710
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804b6489>] sock_recvmsg+0x139/0x150
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff804b77ae>] sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S ffff88007d43fb50     0  7421   2732
 ffff88002e4b5ce8 0000000000000082 ffff88002e4b5ca8 ffffffff80285ee0
 ffffffff807bb000 ffff88007b85e540 ffff880014f1c040 ffff88007b85e880
 00000003365e2be0 ffff88007e1ef0d0 ffff88007b85e880 ffffe20000000000
Call Trace:
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff803aed04>] ? security_ipc_permission+0x14/0x20
 [<ffffffff803a36d1>] sys_semtimedop+0x781/0x910
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802cf730>] ? d_free+0x50/0x60
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff803a386b>] sys_semop+0xb/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880013dcba48     0  8706   2949
 ffff880013dcba38 0000000000000082 ffff880013dcb9b8 0000000000000080
 ffffffff807bb000 ffff8800183d6800 ffff8800139888c0 ffff8800183d6b40
 0000000013dcb9e8 ffffffff8024ee66 ffff8800183d6b40 ffff880013dcba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0  8712   2949
 ffff88005e9e3c58 0000000000000082 ffff8800368c8300 ffff88000103d2f0
 ffffffff807bb000 ffff88007c03e700 ffff88005d75a200 ffff88007c03ea40
 000000020103d280 ffff8800368c8300 ffff88007c03ea40 ffff88000103d280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  8713   2949
 ffff88005e9bba78 0000000000000082 411bd64d37924969 2224dc2ee0ee5fee
 ffffffff807bb000 ffff88005ece80c0 ffff88007a958700 ffff88005ece8400
 00000001f2850d30 7a3c62ab9a77f064 ffff88005ece8400 6f5ad27bb7846a8e
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0  8714   2949
 ffff880013815c58 0000000000000082 ffff88007c03e738 0000000000000001
 ffffffff807bb000 ffff880010e4c0c0 ffff88005d01a740 ffff880010e4c400
 0000000213815dd8 00000001001818d6 ffff880010e4c400 0000000000000002
Call Trace:
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880011db1a58     0  8716   2949
 ffff880011db1a48 0000000000000082 ffff880011db19a8 000000000000000b
 ffffffff807bb000 ffff88000adb40c0 ffff8800124d41c0 ffff88000adb4400
 0000000011db19f8 ffffffff8024ee66 ffff88000adb4400 ffff880011db1a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054dafe>] ? _spin_lock+0xe/0x20
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 10888   2949
 ffff880000d3fa38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88003a130700 ffff88005a238180 ffff88003a130a40
 0000000100d3f9e8 ffffffff8024ee66 ffff88003a130a40 ffff880000d3fa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 10941   2949
 ffff88006d1e1ac8 0000000000000082 ffff88006d1e1a58 ffffffff804c5515
 ffffffff807bb000 ffff8800260ae240 ffff880002f58540 ffff8800260ae580
 00000002798fe420 ffff8800369e6ab8 ffff8800260ae580 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 10949   2949
 ffff880016855a78 0000000000000082 ffff880016855b38 ffffffff8022b179
 ffffffff807bb000 ffff88006d06e3c0 ffff8800260ae240 ffff88006d06e700
 0000000016855a28 ffff880016855a28 ffff88006d06e700 0000000000000000
Call Trace:
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff80294ced>] ? zone_statistics+0x7d/0xa0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028fcd3>] ? activate_page+0x133/0x1a0
 [<ffffffff8028fda5>] ? mark_page_accessed+0x65/0x80
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11109   2949
 ffff880010b95c58 0000000000000082 ffff8800260ae278 ffff880010b95be8
 ffffffff807bb000 ffff8800655661c0 ffff88005d750640 ffff880065566500
 00000000260ae278 0000000000000001 ffff880065566500 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11113   2949
 ffff88007a6dfc58 0000000000000082 ffff88007a6dfbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88004cdde380 ffff8800774ee780 ffff88004cdde6c0
 0000000300000b16 0000000000000008 ffff88004cdde6c0 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880011f99a48     0 11029   2949
 ffff880011f99a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880002e76400 ffff88005d08c780 ffff880002e76740
 0000000111f999e8 ffffffff8024ee66 ffff880002e76740 ffff880011f99a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff802c9e5f>] ? path_walk+0xbf/0xd0
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8052b4aa>] ? unix_find_other+0x1aa/0x210
 [<ffffffff80248ca0>] ? timespec_add_safe+0xa0/0xb0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11043   2949
 ffff880010fcdac8 0000000000000082 ffff880010fcda58 ffff880037492000
 ffffffff807bb000 ffff880003af6540 ffff88002b806140 ffff880003af6880
 000000005891fa78 ffff880037559b50 ffff880003af6880 ffffffff804edb1f
Call Trace:
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80233298>] ? resched_task+0x68/0x80
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11044   2949
 ffff880003f3f798 ffff880003f3f718 ffff880003f3f718 ffff880001025280
 ffff8800688aa100 ffff8800010252f0 ffff8800688aa138 0000000000000001
 ffff880003f3f758 0000000000000096 ffff880001025280 ffff88005743a880
Call Trace:
 [<ffffffff80269539>] ? smp_call_function_mask+0x99/0x220
 [<ffffffff802695d2>] ? smp_call_function_mask+0x132/0x220
 [<ffffffff802695c3>] ? smp_call_function_mask+0x123/0x220
 [<ffffffff8028a490>] ? drain_local_pages+0x0/0x20
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8028daf8>] ? wakeup_pdflush+0x38/0x40
 [<ffffffff8029417c>] ? try_to_free_pages+0x36c/0x3b0
 [<ffffffff8028a490>] ? drain_local_pages+0x0/0x20
 [<ffffffff802696db>] ? smp_call_function+0x1b/0x20
 [<ffffffff8024968f>] ? on_each_cpu+0x1f/0x40
 [<ffffffff8028ca73>] ? __alloc_pages_internal+0x333/0x4d0
 [<ffffffff802b6d15>] ? kmem_getpages+0x85/0x190
 [<ffffffff802b6f7c>] ? fallback_alloc+0x15c/0x1f0
 [<ffffffff802b70a9>] ? ____cache_alloc_node+0x99/0x200
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b7287>] ? kmem_cache_alloc_node+0x77/0x160
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff804be557>] ? __alloc_skb+0x77/0x150
 [<ffffffff804b9797>] ? sock_alloc_send_skb+0x1c7/0x200
 [<ffffffff80236365>] ? __wake_up_sync+0x55/0x70
 [<ffffffff8052ca8b>] ? unix_stream_sendmsg+0x29b/0x3c0
 [<ffffffff804b6627>] ? sock_sendmsg+0x127/0x140
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff804b6a4a>] ? sys_sendto+0xea/0x120
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff8020c2eb>] ? system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11102   2949
 ffff880000c2dc58 0000000000000082 ffff88007f538d48 0000000000000000
 ffffffff807bb000 ffff8800031e8840 ffff88007fba0240 ffff8800031e8b80
 0000000100000001 0000000100181d39 ffff8800031e8b80 0000000000000001
Call Trace:
 [<ffffffff80236365>] ? __wake_up_sync+0x55/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff804b59c2>] ? sock_aio_write+0x172/0x190
 [<ffffffff8028f584>] ? release_pages+0x204/0x250
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11104   2949
 ffff880003e5bc58 0000000000000082 ffff880003e5bc08 ffffffff80285664
 ffffffff807bb000 ffff8800771f6440 ffff880036dee500 ffff8800771f6780
 000000018025a9b0 ffff880003e5bbe0 ffff8800771f6780 ffffffff8028548b
Call Trace:
 [<ffffffff80285664>] ? __lock_page+0x64/0x70
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff80285818>] ? find_lock_page+0x58/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11045   2949
 ffff880032e1fa38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800544e8400 ffff8800516f2900 ffff8800544e8740
 0000000032e1f9e8 ffffffff8024ee66 ffff8800544e8740 ffff880032e1fa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff802d2401>] ? touch_atime+0x31/0x140
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11047   2949
 ffff88006d0d9ac8 0000000000000082 ffff88006d0d9a58 ffffffff804c5515
 ffffffff807bb000 ffff88000b75a5c0 ffff8800183d6800 ffff88000b75a900
 000000006ed7e168 ffff8800369e6ab8 ffff88000b75a900 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11048   2949
 ffff88002f609a78 0000000000000082 8163b89dda33de04 e306d20c4b0350f8
 ffffffff807bb000 ffff880079c540c0 ffff8800544e8400 ffff880079c54400
 0000000206bfbbc2 3d23d53360b5d405 ffff880079c54400 c22b1c015ade7a4d
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005edc9a58     0 11108   2949
 ffff88005edc9a48 0000000000000082 ffff88005edc99a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88002d360300 ffff88005164e880 ffff88002d360640
 000000005edc99f8 ffffffff8024ee66 ffff88002d360640 ffff88005edc9a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11112   2949
 ffff880018d95c58 0000000000000082 ffff88000b75a5f8 ffff880018d95be8
 ffffffff807bb000 ffff8800649286c0 ffffffff806b0340 ffff880064928a00
 000000000b75a5f8 0000000100181ce0 ffff880064928a00 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff80267841>] ? do_futex+0x1/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007bd0ba48     0 11055   2949
 ffff88007bd0ba38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880048a868c0 ffff880002f10200 ffff880048a86c00
 000000017bd0b9e8 ffffffff8024ee66 ffff880048a86c00 ffff88007bd0ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11065   2949
 ffff88006bcc1ac8 0000000000000082 ffff88006bcc1a58 ffffffff804c5515
 ffffffff807bb000 ffff88003df0c940 ffff8800096e0800 ffff88003df0cc80
 0000000023231250 ffff8800369e6ab8 ffff88003df0cc80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11068   2949
 ffff88004983ba78 0000000000000082 a6c0e8b8fdb4ce67 2f870a2bbd57a4d6
 ffffffff807bb000 ffff88000b078280 ffff880048a868c0 ffff88000b0785c0
 00000002dacdb2b1 d514107143ac9825 ffff88000b0785c0 699ee8cd925b40ba
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11127   2949
 ffff88007d079c58 0000000000000082 ffff88003df0c978 0000000000000001
 ffffffff807bb000 ffff88003c838440 ffff880036dee500 ffff88003c838780
 000000023df0c978 0000000100181bfe ffff88003c838780 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11128   2949
 ffff880000c3dc58 0000000000000082 ffff880000c3dbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88005f640700 ffff880002f38940 ffff88005f640a40
 0000000300000de0 0000000000000008 ffff88005f640a40 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880014121a48     0 11105   2949
 ffff880014121a38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff880002e00900 ffff8800375fa6c0 ffff880002e00c40
 00000001141219e8 ffffffff8024ee66 ffff880002e00c40 ffff880014121a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11110   2949
 ffff880020a77ac8 0000000000000082 ffff880020a77a58 ffffffff804c5515
 ffffffff807bb000 ffff88005c0188c0 ffff88006b3b8600 ffff88005c018c00
 00000000275e1e18 ffff8800369e6ab8 ffff88005c018c00 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11111   2949
 ffff880017629a78 0000000000000082 166ce84cdf723aa4 95f68ab6f109718c
 ffffffff807bb000 ffff88005a31c780 ffff88000b75a5c0 ffff88005a31cac0
 000000012cff8e65 225a483ff8557a60 ffff88005a31cac0 895f63a78e90a28e
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11208   2949
 ffff880000d5fc58 0000000000000082 0000000200000001 ffff880000d5fbe8
 ffffffff807bb000 ffff88001f2c24c0 ffff88007d14e940 ffff88001f2c2800
 000000005c0188f8 0000000000000001 ffff88001f2c2800 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d74c>] ? unmap_region+0xec/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11209   2949
 ffff880000d6dc58 0000000000000082 ffff880000d6dbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88007e8b4400 ffff88007b5fc780 ffff88007e8b4740
 0000000300000028 0000000000000008 ffff88007e8b4740 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880059e0ba48     0 11212   2949
 ffff880059e0ba38 0000000000000082 ffff880059e0b9b8 0000000000000080
 ffffffff807bb000 ffff880003162100 ffff88007e8aa740 ffff880003162440
 0000000159e0b9e8 ffffffff8024ee66 ffff880003162440 ffff880059e0ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11214   2949
 ffff88006043fac8 0000000000000082 ffff88006043fa58 ffffffff804c5515
 ffffffff807bb000 ffff880000d16880 ffff88001fe6c380 ffff880000d16bc0
 000000006ed7e168 ffff8800369e6ab8 ffff880000d16bc0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11215   2949
 ffff8800629b1a78 0000000000000082 96133c8243369a08 7134176f0162ca69
 ffffffff807bb000 ffff8800172f2440 ffffffff806b0340 ffff8800172f2780
 00000000a8cf0c28 0000000100179e34 ffff8800172f2780 db81fbd1d5d70e55
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11300   2949
 ffff880018779c58 0000000000000082 ffff880018779c38 ffff880018779be8
 ffffffff807bb000 ffff88001fe6c380 ffff880066892540 ffff88001fe6c6c0
 0000000000d168b8 0000000000000001 ffff88001fe6c6c0 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11317   2949
 ffff88007a785c58 0000000000000082 ffff88007a785be8 ffffffff802e27c8
 ffffffff807bb000 ffff880075c643c0 ffff8800124d41c0 ffff880075c64700
 000000010000013d 0000000000000008 ffff880075c64700 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880058853a48     0 11236   2949
 ffff880058853a38 0000000000000082 ffff8800588539b8 0000000000000080
 ffffffff807bb000 ffff880018c7c5c0 ffff880003162100 ffff880018c7c900
 00000001588539e8 ffffffff8024ee66 ffff880018c7c900 ffff880058853a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11245   2949
 ffff880000d83ac8 0000000000000082 ffff880000d83a58 ffffffff804c5515
 ffffffff807bb000 ffff88000a0b8700 ffff880010cb0580 ffff88000a0b8a40
 00000001765068a8 ffff8800369e6ab8 ffff88000a0b8a40 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11246   2949
 ffff880000d33a78 0000000000000082 ffff880000d33b38 ffffffff8022b179
 ffffffff807bb000 ffff88007b4bc380 ffff88007fba0240 ffff88007b4bc6c0
 0000000100d33a28 0000000100179f7e ffff88007b4bc6c0 0000000000000000
Call Trace:
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803dafba>] ? put_io_context+0x6a/0x80
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11371   2949
 ffff880011c91c58 0000000000000082 ffff880011c91c58 ffff880011c91c58
 ffffffff807bb000 ffff880010cb0580 ffff88007f06c4c0 ffff880010cb08c0
 000000010a0b8738 0000000100181c6a ffff880010cb08c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11372   2949
 ffff88007b12bc58 0000000000000082 ffff88007b12bbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88007845e440 ffff880075708740 ffff88007845e780
 0000000000000be1 0000000000000008 ffff88007845e780 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11319   2949
 ffff88005887ba38 0000000000000082 ffff88005887b9b8 0000000000000080
 ffffffff807bb000 ffff8800674e28c0 ffff880003e8e9c0 ffff8800674e2c00
 000000015887b9e8 ffffffff8024ee66 ffff8800674e2c00 ffff88005887ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11340   2949
 ffff880008a91ac8 0000000000000082 ffff880008a91a58 ffffffff804c5515
 ffffffff807bb000 ffff880002f0e040 ffff880036862600 ffff880002f0e380
 00000003091d2420 ffff8800369e6ab8 ffff880002f0e380 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11341   2949
 ffff88001839ba78 0000000000000082 83708f22a64e5541 c3c8e4f6ebe75f9e
 ffffffff807bb000 ffff880060d64700 ffff8800674e28c0 ffff880060d64a40
 000000014d1bb02f 4c39cc0633ec494b ffff880060d64a40 f6034343770f227d
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11370   2949
 ffff88000a615c58 0000000000000082 ffff880002f0e078 ffff88000a615be8
 ffffffff807bb000 ffff880002ff6800 ffff88007fbda340 ffff880002ff6b40
 0000000202f0e078 0000000100181ce9 ffff880002ff6b40 0000000000000092
Call Trace:
 [<ffffffff8021e41a>] ? native_smp_send_reschedule+0x3a/0x50
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11373   2949
 ffff880019023c58 0000000000000082 ffff880019023be8 ffffffff802e27c8
 ffffffff807bb000 ffff88007b5fc780 ffff88002b8b2080 ffff88007b5fcac0
 0000000300000202 0000000000000008 ffff88007b5fcac0 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880064239a48     0 11374   2949
 ffff880064239a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800662e27c0 ffff880078906740 ffff8800662e2b00
 00000000642399e8 ffffffff8024ee66 ffff8800662e2b00 ffff880064239a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138c4>] ? read_tsc+0x14/0x20
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11376   2949
 ffff88002fd21ac8 0000000000000082 ffff8800547a8980 ffffffff802b7c61
 ffffffff807bb000 ffff88005d19c5c0 ffff88007f21a440 ffff88005d19c900
 000000027f803ac0 0000000000000020 ffff88005d19c900 ffff88007b53bc38
Call Trace:
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11377   2949
 ffff88005ede9a78 0000000000000082 0b0d1177015e0a0a 2e15b2eb85b30ca3
 ffffffff807bb000 ffff880043402640 ffff88007fbda340 ffff880043402980
 00000002e16bc91f 000000010017a0ab ffff880043402980 3d2743b90ff8f61d
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11444   2949
 ffff88002e5f1c58 0000000000000082 ffff88005d19c5f8 ffff88002e5f1be8
 ffffffff807bb000 ffff88007e980900 ffff880030008940 ffff88007e980c40
 000000025d19c5f8 0000000000000001 ffff88007e980c40 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11446   2949
 ffff880067cd3c58 0000000000000082 ffff880067cd3be8 ffffffff802e27c8
 ffffffff807bb000 ffff880065132680 ffff880048a40900 ffff8800651329c0
 0000000200000211 0000000000000008 ffff8800651329c0 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006758ba48     0 11398   2949
 ffff88006758ba38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880055e7c240 ffff88007e5ec780 ffff880055e7c580
 000000016758b9e8 ffffffff8024ee66 ffff880055e7c580 ffff88006758ba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bf59>] ? schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff802889dd>] ? out_of_memory+0x22d/0x2c0
 [<ffffffff8028cbc9>] ? __alloc_pages_internal+0x489/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11405   2949
 ffff880011cb3ac8 0000000000000082 ffff880011cb3a58 ffffffff804c5515
 ffffffff807bb000 ffff8800030ee300 ffff8800176a4880 ffff8800030ee640
 0000000103f817c0 ffff8800369e6ab8 ffff8800030ee640 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11406   2949
 ffff8800125efa78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff8800165a2340 ffff880055e7c240 ffff8800165a2680
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff8800165a2680 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff80287a42>] ? mempool_free_slab+0x12/0x20
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11463   2949
 ffff880010addc58 0000000000000082 ffff8800030ee338 ffff880010addbe8
 ffffffff807bb000 ffff8800176a4880 ffff880030008940 ffff8800176a4bc0
 00000001030ee338 0000000000000001 ffff8800176a4bc0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007e90d578     0 11470   2949
 ffff88007e90d568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88005b0e0280 ffff88001fa76300 ffff88005b0e05c0
 000000017e90d518 ffffffff8024ee66 ffff88005b0e05c0 ffff88007e90d578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c12b908     0 11399   2949
 ffff88007c12b8f8 0000000000000082 00000001001b4401 ffffffff8024ea20
 ffffffff807bb000 ffff8800648ea340 ffff88007b962580 ffff8800648ea680
 000000027c12b8a8 ffffffff8024ee66 ffff8800648ea680 ffff88007c12b908
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11409   2949
 ffff880079087ac8 0000000000000082 ffff88005e9dca00 ffffffff802b7c61
 ffffffff807bb000 ffff88005ecaa6c0 ffff88001fa8c180 ffff88005ecaaa00
 000000037f803ac0 0000000000000020 ffff88005ecaaa00 ffff88007b53bc38
Call Trace:
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11410   2949
 ffff880066951a78 0000000000000082 ffff880066951b38 ffffffff8022b179
 ffffffff807bb000 ffff88004c36a280 ffff8800648ea340 ffff88004c36a5c0
 000000007c098080 ffff88000103d2f0 ffff88004c36a5c0 0000000000000001
Call Trace:
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11462   2949
 ffff88007c417c58 0000000000000082 ffff88005ecaa6f8 0000000000000001
 ffffffff807bb000 ffff88000d1ea800 ffff88007e91c400 ffff88000d1eab40
 000000035ecaa6f8 0000000000000001 ffff88000d1eab40 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11468   2949
 ffff880014105c58 0000000000000082 ffff880014105be8 ffffffff802e27c8
 ffffffff807bb000 ffff8800183b4240 ffff880016842500 ffff8800183b4580
 00000000000004cb 0000000000000008 ffff8800183b4580 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880016ab7a48     0 11535   2949
 ffff880016ab7a38 0000000000000082 0000000000070309 0000000000000080
 ffffffff807bb000 ffff880003fb8600 ffff8800658503c0 ffff880003fb8940
 0000000016ab79e8 ffffffff8024ee66 ffff880003fb8940 ffff880016ab7a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80248c8c>] ? timespec_add_safe+0x8c/0xb0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11537   2949
 ffff88007a44bac8 0000000000000082 ffff88007a44ba58 ffffffff804c5515
 ffffffff807bb000 ffff880010f3c400 ffff880051702940 ffff880010f3c740
 0000000139fcbd30 ffff8800369e6ab8 ffff880010f3c740 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11538   2949
 ffff88007ad2fa78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff880000c1a940 ffff880003fb8600 ffff880000c1ac80
 0000000100000000 0000000000000000 ffff880000c1ac80 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12118   2949
 ffff88000979bc58 0000000000000082 0000000200000001 ffff88000979bbe8
 ffffffff807bb000 ffff880077d1e980 ffff880009a24600 ffff880077d1ecc0
 0000000110f3c438 0000000000000001 ffff880077d1ecc0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880077d4da58     0 12123   2949
 ffff880077d4da48 0000000000000082 ffff880077d4d9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880016b26080 ffff8800375fa6c0 ffff880016b263c0
 0000000077d4d9f8 ffffffff8024ee66 ffff880016b263c0 ffff880077d4da58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8021e41a>] ? native_smp_send_reschedule+0x3a/0x50
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880068829a48     0 11559   2949
 ffff880068829a38 0000000000000082 ffff8800688299b8 0000000000000080
 ffffffff807bb000 ffff88007af7c600 ffff88007a4ec6c0 ffff88007af7c940
 00000000688299e8 ffffffff8024ee66 ffff88007af7c940 ffff880068829a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11564   2949
 ffff880009ac7ac8 0000000000000082 ffff880009ac7a58 ffffffff804c5515
 ffffffff807bb000 ffff88000322e680 ffff88003c03c300 ffff88000322e9c0
 000000027893cf00 ffff8800369e6ab8 ffff88000322e9c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11567   2949
 ffff88002b939a78 0000000000000082 ce1f6987a7e618ac 684210709b9d5867
 ffffffff807bb000 ffff880017652040 ffff88007af7c600 ffff880017652380
 0000000195a8aac8 1e8668d5f83bb7d7 ffff880017652380 08dfed0ef1606642
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12222   2949
 ffff88005b01fc58 0000000000000082 0000000200000001 ffff88005b01fbe8
 ffffffff807bb000 ffff88003c03c300 ffff880010aea340 ffff88003c03c640
 000000020322e6b8 0000000000000001 ffff88003c03c640 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006549fa58     0 12224   2949
 ffff88006549fa48 0000000000000082 ffff88006549f9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880018294200 ffff880025ec8380 ffff880018294540
 000000016549f9f8 ffffffff8024ee66 ffff880018294540 ffff88006549fa58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8021e41a>] ? native_smp_send_reschedule+0x3a/0x50
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d5aba48     0 11560   2949
 ffff88007d5aba38 0000000000000082 ffff88007d5ab9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880020b84940 ffff88005d08c780 ffff880020b84c80
 000000017d5ab9e8 ffffffff8024ee66 ffff880020b84c80 ffff88007d5aba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80248c91>] ? timespec_add_safe+0x91/0xb0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11565   2949
 ffff88007bc4fac8 0000000000000082 ffff88007bc4fa58 ffffffff804c5515
 ffffffff807bb000 ffff880002fa8340 ffff88007881c1c0 ffff880002fa8680
 000000005406a168 ffff8800369e6ab8 ffff880002fa8680 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11568   2949
 ffff8800516bba78 0000000000000082 2c2c88c373ad51ae fe9d9b4b88b50b99
 ffffffff807bb000 ffff88002fd74900 ffff880020b84940 ffff88002fd74c40
 000000022405a156 96cc37c2b63d8601 ffff88002fd74c40 e8e42facae2b5ed8
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12265   2949
 ffff880034323c58 0000000000000082 ffff880002fa8378 ffff880034323be8
 ffffffff807bb000 ffff880010dc2080 ffff8800544b4100 ffff880010dc23c0
 0000000002fa8378 0000000000000001 ffff880010dc23c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12268   2949
 ffff88004c39fc58 0000000000000082 ffff88004c39fbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88000e6ce3c0 ffff880020b84940 ffff88000e6ce700
 0000000300000161 0000000000000008 ffff88000e6ce700 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005e987a48     0 11563   2949
 ffff88005e987a38 0000000000000082 00000000000702c9 ffffffff8028e8b8
 ffffffff807bb000 ffff88005e3fa4c0 ffff8800516f2900 ffff88005e3fa800
 000000005e9879e8 ffffffff8024ee66 ffff88005e3fa800 ffff88005e987a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80248c51>] ? timespec_add_safe+0x51/0xb0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11589   2949
 ffff88000ad73ac8 0000000000000082 ffff88000ad73a58 ffffffff804c5515
 ffffffff807bb000 ffff88007add4500 ffff88005d02c340 ffff88007add4840
 000000033c7f5b60 ffff8800369e6ab8 ffff88007add4840 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11607   2949
 ffff880022265a78 0000000000000082 ffffffff807bb000 ffff880002f00240
 ffffffff807bb000 ffff88000b752200 ffff88000b7f8700 ffff88000b752540
 0000000002f00580 ffffffff80395753 ffff88000b752540 ffff88007c0da748
Call Trace:
 [<ffffffff80395753>] ? xfs_buf_iorequest+0x43/0x90
 [<ffffffff8037c715>] ? xlog_bdstrat_cb+0x45/0x50
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880026f03a58     0 12261   2949
 ffff880026f03a48 0000000000000082 ffff880026f039a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88001dec0940 ffff8800774ee780 ffff88001dec0c80
 0000000026f039f8 ffffffff8024ee66 ffff88001dec0c80 ffff880026f03a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12266   2949
 ffff880032f8bc58 0000000000000082 ffff880032f8bc38 ffff880032f8bbe8
 ffffffff807bb000 ffff88002e4982c0 ffff88000ad46900 ffff88002e498600
 000000037add4538 0000000000000001 ffff88002e498600 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c957a48     0 11569   2949
 ffff88007c957a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005d10e8c0 ffff88005d01a740 ffff88005d10ec00
 000000007c9579e8 ffffffff8024ee66 ffff88005d10ec00 ffff88007c957a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11580   2949
 ffff88000e79fac8 0000000000000082 ffff88000e79fa58 ffffffff804c5515
 ffffffff807bb000 ffff88004209e940 ffff88002e4144c0 ffff88004209ec80
 000000034886f338 ffff8800369e6ab8 ffff88004209ec80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 11585   2949
 ffff88004c27fa78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff880002eae180 ffff88007fba0240 ffff880002eae4c0
 0000000100000000 000000010017a1b6 ffff880002eae4c0 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12270   2949
 ffff880019103c58 0000000000000082 ffff880019103be8 ffffffff802e27c8
 ffffffff807bb000 ffff88007893a380 ffff88005e930840 ffff88007893a6c0
 0000000200000560 0000000000000008 ffff88007893a6c0 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12271   2949
 ffff88003198fc58 0000000000000082 ffff88003198fc58 ffff88003198fbe8
 ffffffff807bb000 ffff88002e4144c0 ffff88007bc8e800 ffff88002e414800
 000000034209e978 0000000000000001 ffff88002e414800 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000acafa48     0 11577   2949
 ffff88000acafa38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880026ff01c0 ffff8800323248c0 ffff880026ff0500
 000000000acaf9e8 ffffffff8024ee66 ffff880026ff0500 ffff88000acafa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11613   2949
 ffff880065091ac8 0000000000000082 ffff880065091a58 ffffffff804c5515
 ffffffff807bb000 ffff88001f3f2980 ffff880048ac0500 ffff88001f3f2cc0
 0000000234b2e420 ffff8800369e6ab8 ffff88001f3f2cc0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11626   2949
 ffff88002b8ffa78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880040bce1c0 ffff880026ff01c0 ffff880040bce500
 000000006b6b6b6b 6b6b6b6b6b6b6b6b ffff880040bce500 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12302   2949
 ffff880054519c58 0000000000000082 ffff88001f3f29b8 0000000000000001
 ffffffff807bb000 ffff88001df52640 ffff880014080400 ffff88001df52980
 000000021f3f29b8 0000000000000001 ffff88001df52980 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12303   2949
 ffff880003081c58 0000000000000082 ffff880003081be8 ffffffff802e27c8
 ffffffff807bb000 ffff880076dd65c0 ffff88001fff49c0 ffff880076dd6900
 0000000100000861 0000000000000008 ffff880076dd6900 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11593   2949
 ffff88006d0f9a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff88005c4ac440 ffff8800674e28c0 ffff88005c4ac780
 000000016d0f99e8 ffffffff8024ee66 ffff88005c4ac780 ffff88006d0f9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11620   2949
 ffff8800488bfac8 0000000000000082 ffff8800488bfa58 ffffffff804c5515
 ffffffff807bb000 ffff88000a6c41c0 ffff880048ac0500 ffff88000a6c4500
 0000000109bed6d8 ffff8800369e6ab8 ffff88000a6c4500 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11622   2949
 ffff88002b819a78 0000000000000082 ffff88000103d280 0000000000000000
 ffffffff807bb000 ffff880000d66200 ffff88000a6c41c0 ffff880000d66540
 000000027f803ac0 ffff88007f803ac0 ffff880000d66540 ffffffff802b7c61
Call Trace:
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880009b27a58     0 12262   2949
 ffff880009b27a48 0000000000000082 ffff880009b279b8 ffffffff8036f419
 ffffffff807bb000 ffff88000b1a4240 ffff880025ec8380 ffff88000b1a4580
 0000000109b279f8 ffffffff8024ee66 ffff88000b1a4580 ffff880009b27a58
Call Trace:
 [<ffffffff8036f419>] ? xfs_iunlock+0x59/0xc0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12264   2949
 ffff88000d0b7c58 0000000000000082 ffff88000d0b7c58 ffff88000d0b7be8
 ffffffff807bb000 ffff8800758da680 ffff8800138d6580 ffff8800758da9c0
 000000010a6c41f8 0000000000000001 ffff8800758da9c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11604   2949
 ffff880016891a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880049912600 ffff8800662e27c0 ffff880049912940
 00000000168919e8 ffffffff8024ee66 ffff880049912940 ffff880016891a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11645   2949
 ffff8800794f7ac8 0000000000000082 ffff8800794f7a58 ffffffff804c5515
 ffffffff807bb000 ffff880025e4a980 ffff88001f3566c0 ffff880025e4acc0
 0000000006697420 ffff8800369e6ab8 ffff880025e4acc0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11646   2949
 ffff88007a5e3a78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88007d58e3c0 ffff880025e4a980 ffff88007d58e700
 0000000100000000 0000000000000000 ffff88007d58e700 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12263   2949
 ffff880077579c58 0000000000000082 ffff880025e4a9b8 ffff880077579be8
 ffffffff807bb000 ffff88005d02c340 ffff88004209e940 ffff88005d02c680
 0000000325e4a9b8 0000000000000001 ffff88005d02c680 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880013d99a58     0 12269   2949
 ffff880013d99a48 0000000000000082 ffff880013d999b8 ffffffff8036f419
 ffffffff807bb000 ffff88001902a240 ffff88000b7f8700 ffff88001902a580
 0000000013d999f8 ffffffff8024ee66 ffff88001902a580 ffff880013d99a58
Call Trace:
 [<ffffffff8036f419>] ? xfs_iunlock+0x59/0xc0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803afae7>] ? cap_file_permission+0x7/0x10
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d061a48     0 11617   2949
 ffff88007d061a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880018c0a9c0 ffff880011f6c380 ffff880018c0ad00
 000000017d0619e8 ffffffff8024ee66 ffff880018c0ad00 ffff88007d061a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000    0 11667   2949
 ffff880067c1dac8 0000000000000082 ffff880067c1da58 ffffffff804c5515
 ffffffff807bb000 ffff88000b07c340 ffff88002f0dc480 ffff88000b07c680
 0000000277f056d8 ffff8800369e6ab8 ffff88000b07c680 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11668   2949
 ffff88005e999a78 0000000000000082 ffff88005e9999d8 ffff88007bcaa470
 ffffffff807bb000 ffff88002d2b86c0 ffff880014f5e2c0 ffff88002d2b8a00
 000000035e999a38 ffffffff802afa5c ffff88002d2b8a00 ffffffff8028fb40
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff80241857>] ? __mmdrop+0x47/0x60
 [<ffffffff8028bb52>] ? free_pages+0x32/0x40
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8023e718>] ? finish_task_switch+0xa8/0xd0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12319   2949
 ffff8800545a5c58 0000000000000082 ffff8800545a5be8 ffff8800545a5be8
 ffffffff807bb000 ffff88002f0dc480 ffff880011ca6700 ffff88002f0dc7c0
 000000020b07c378 0000000000000001 ffff88002f0dc7c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880065143578     0 12321   2949
 ffff880065143568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88001ffce400 ffff880020bcc700 ffff88001ffce740
 0000000065143518 ffffffff8024ee66 ffff88001ffce740 ffff880065143578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880048883a48     0 11623   2949
 ffff880048883a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88002fd280c0 ffff8800369a4200 ffff88002fd28400
 00000001488839e8 ffffffff8024ee66 ffff88002fd28400 ffff880048883a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11662   2949
 ffff88005e871ac8 0000000000000082 ffff88005e871a58 ffffffff804c5515
 ffffffff807bb000 ffff88006d058200 ffff88000314a840 ffff88006d058540
 0000000263110e18 ffff8800369e6ab8 ffff88006d058540 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11669   2949
 ffff88007b4d1a78 0000000000000082 ffff880001031280 0000000000000000
 ffffffff807bb000 ffff88005815c300 ffff88005a220280 ffff88005815c640
 000000027c098080 ffff88000103d2f0 ffff88005815c640 0000000000000001
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12290   2949
 ffff880078ddbc58 0000000000000082 ffff88006d058238 ffff880078ddbbe8
 ffffffff807bb000 ffff88005167a540 ffff8800030b61c0 ffff88005167a880
 000000026d058238 0000000100181b58 ffff88005167a880 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12291   2949
 ffff880065539c58 0000000000000082 ffff880065539be8 ffffffff802e27c8
 ffffffff807bb000 ffff880014080400 ffff88002fd280c0 ffff880014080740
 0000000100000cbc 0000000000000008 ffff880014080740 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005b119a48     0 11635   2949
 ffff88005b119a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007b1f2600 ffff88007b962580 ffff88007b1f2940
 000000005b1199e8 ffffffff8024ee66 ffff88007b1f2940 ffff88005b119a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11670   2949
 ffff880013c83ac8 0000000000000082 ffff880013c83a58 ffffffff804c5515
 ffffffff807bb000 ffff880003a285c0 ffff880025d542c0 ffff880003a28900
 0000000321089420 ffff8800369e6ab8 ffff880003a28900 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11673   2949
 ffff88001df6da78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff880064272540 ffff8800705e0580 ffff880064272880
 0000000200000000 0000000000000000 ffff880064272880 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12324   2949
 ffff88006742fc58 0000000000000082 ffff88006742fc58 ffff88006742fbe8
 ffffffff807bb000 ffff880077d7c780 ffff88005a220280 ffff880077d7cac0
 0000000303a285f8 0000000000000001 ffff880077d7cac0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005d6c7a58     0 12340   2949
 ffff88005d6c7a48 0000000000000082 ffff88005d6c79b8 ffffffff8036f419
 ffffffff807bb000 ffff88000b7f8700 ffff880059e88400 ffff88000b7f8a40
 000000005d6c79f8 ffffffff8024ee66 ffff88000b7f8a40 ffff88005d6c7a58
Call Trace:
 [<ffffffff8036f419>] ? xfs_iunlock+0x59/0xc0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880048ba1a48     0 11681   2949
 ffff880048ba1a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88000e62e7c0 ffff88005c51c2c0 ffff88000e62eb00
 0000000048ba19e8 ffffffff8024ee66 ffff88000e62eb00 ffff880048ba1a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11724   2949
 ffff88001fe51ac8 0000000000000082 ffff88001fe51a58 ffffffff804c5515
 ffffffff807bb000 ffff8800343b0740 ffff880034326640 ffff8800343b0a80
 000000027c82f420 ffff8800369e6ab8 ffff8800343b0a80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11725   2949
 ffff880058839a78 0000000000000082 ffff880058839b38 ffff88007d9e2538
 ffffffff807bb000 ffff880011c16700 ffff8800343b0740 ffff880011c16a40
 0000000158839a38 ffffffff802afa5c ffff880011c16a40 ffffffff8028fb40
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12293   2949
 ffff88000a693c58 0000000000000082 ffff88000a693c58 ffff88000a693be8
 ffffffff807bb000 ffff880034326640 ffff88005167a540 ffff880034326980
 00000002343b0778 0000000000000001 ffff880034326980 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880002e9fa58     0 12294   2949
 ffff880002e9fa48 0000000000000082 ffff880002e9f9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff8800096e0800 ffff880025f946c0 ffff8800096e0b40
 0000000102e9f9f8 ffffffff8024ee66 ffff8800096e0b40 ffff880002e9fa58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007b033a48     0 11705   2949
 ffff88007b033a38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff88005743a880 ffff880020b84940 ffff88005743abc0
 000000017b0339e8 ffffffff8024ee66 ffff88005743abc0 ffff88007b033a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80248c43>] ? timespec_add_safe+0x43/0xb0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11743   2949
 ffff88002b8f9ac8 0000000000000082 ffff88002b8f9a58 ffffffff804c5515
 ffffffff807bb000 ffff880058186940 ffff880013d48200 ffff880058186c80
 0000000358a85250 ffff8800369e6ab8 ffff880058186c80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8054db68>] ? _spin_unlock_irqrestore+0x8/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11744   2949
 ffff880079049a78 0000000000000082 25882a15f88ec4c5 f05f7301fc7911d3
 ffffffff807bb000 ffff88000c38c980 ffff880058186940 ffff88000c38ccc0
 00000001ad8e63f8 c9fcbeb343ca0afa ffff88000c38ccc0 0e936aace03a0835
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800759e7578     0 12318   2949
 ffff8800759e7568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88001fa76300 ffff88005a272540 ffff88001fa76640
 00000001759e7518 ffffffff8024ee66 ffff88001fa76640 ffff8800759e7578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12320   2949
 ffff880013c75c58 0000000000000082 ffff880058186978 ffff880013c75be8
 ffffffff807bb000 ffff88007bc8e800 ffff88001ffe8440 ffff88007bc8eb40
 0000000358186978 0000000000000001 ffff88007bc8eb40 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880016895908     0 11733   2949
 ffff8800168958f8 0000000000000082 00000001001b43ff ffffffff8024ea20
 ffffffff807bb000 ffff88006c092840 ffff8800030466c0 ffff88006c092b80
 00000002168958a8 ffffffff8024ee66 ffff88006c092b80 ffff880016895908
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802611cf>] ? getnstimeofday+0x3f/0xe0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11810   2949
 ffff880010c5dac8 0000000000000082 ffff880010c5da58 ffffffff804c5515
 ffffffff807bb000 ffff880077d56080 ffff88000a6fa440 ffff880077d563c0
 00000000097c96d8 ffff8800369e6ab8 ffff880077d563c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11830   2949
 ffff880059e2fa78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880009a0c100 ffff8800758f8340 ffff880009a0c440
 000000036b6b6b6b 6b6b6b6b6b6b6b6b ffff880009a0c440 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80237107>] ? pick_next_task_fair+0x77/0xa0
 [<ffffffff8054b9c8>] ? thread_return+0x306/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12325   2949
 ffff88005d1dfc58 0000000000000082 ffff880077d560b8 ffff88005d1dfbe8
 ffffffff807bb000 ffff88000a6fa440 ffff88001fa76300 ffff88000a6fa780
 0000000077d560b8 0000000000000001 ffff88000a6fa780 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88000b603a58     0 12326   2949
 ffff88000b603a48 0000000000000082 ffff88000b6039a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88001fff49c0 ffff8800096e0800 ffff88001fff4d00
 000000010b6039f8 ffffffff8024ee66 ffff88001fff4d00 ffff88000b603a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11771   2949
 ffff88003612da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007a6a2180 ffff88004c3da400 ffff88007a6a24c0
 000000013612d9e8 ffffffff8024ee66 ffff88007a6a24c0 ffff88003612da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11804   2949
 ffff8800319ebac8 0000000000000082 ffff8800319eba58 ffffffff804c5515
 ffffffff807bb000 ffff8800655f8740 ffff88007b08e500 ffff8800655f8a80
 000000017d7846d8 ffff8800369e6ab8 ffff8800655f8a80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11806   2949
 ffff8800125c1a78 0000000000000082 ffff88000103d280 0000000000000000
 ffffffff807bb000 ffff8800791828c0 ffff88005440c700 ffff880079182c00
 000000017f803ac0 ffff88007f803ac0 ffff880079182c00 ffffffff802b7c61
Call Trace:
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12391   2949
 ffff880004753c58 0000000000000082 ffff8800655f8778 ffff880004753be8
 ffffffff807bb000 ffff88007d1b68c0 ffff8800658503c0 ffff88007d1b6c00
 00000001655f8778 0000000000000001 ffff88007d1b6c00 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12394   2949
 ffff88006d087c58 0000000000000082 ffff88006d087be8 ffffffff802e27c8
 ffffffff807bb000 ffff88005d472300 ffff880076dd65c0 ffff88005d472640
 0000000100000fed 0000000000000008 ffff88005d472640 ffffffff80286649

Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d575908     0 11797   2949
 ffff88007d5758f8 0000000000000082 00000001001b4401 ffffffff8024ea20
 ffffffff807bb000 ffff88005440c700 ffff8800648ea340 ffff88005440ca40
 000000027d5758a8 ffffffff8024ee66 ffff88005440ca40 ffff88007d575908
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11825   2949
 ffff880010a4dac8 0000000000000082 ffff880010a4da58 ffffffff804c5515
 ffffffff807bb000 ffff88005e8d60c0 ffff880079478100 ffff88005e8d6400
 0000000159ffd338 ffff8800369e6ab8 ffff88005e8d6400 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11838   2949
 ffff88007c053a78 0000000000000082 ffff880001025280 0000000000000000
 ffffffff807bb000 ffff88007a77a1c0 ffff88005440c700 ffff88007a77a500
 000000017c098080 ffff8800010252f0 ffff88007a77a500 0000000000000001
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800771d5578     0 12398   2949
 ffff8800771d5568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff880058118400 ffff88000ad46900 ffff880058118740
 00000001771d5518 ffffffff8024ee66 ffff880058118740 ffff8800771d5578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12399   2949
 ffff880003f05c58 0000000000000082 ffff88005e8d60f8 0000000000000001
 ffffffff807bb000 ffff880079478100 ffff880048ac0500 ffff880079478440
 000000015e8d60f8 0000000000000001 ffff880079478440 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007d94ba48     0 11827   2949
 ffff88007d94ba38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff88001724c780 ffff88002d2f0980 ffff88001724cac0
 000000017d94b9e8 ffffffff8024ee66 ffff88001724cac0 ffff88007d94ba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11854   2949
 ffff880026f9dac8 0000000000000082 ffff880026f9da58 ffffffff804c5515
 ffffffff807bb000 ffff88007e456140 ffff8800674ca800 ffff88007e456480
 0000000105fd6080 ffff8800369e6ab8 ffff88007e456480 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11855   2949
 ffff8800141f7a78 0000000000000082 ffff8800141f7b38 ffff88007d909af0
 ffffffff807bb000 ffff88000b836080 ffff88001724c780 ffff88000b8363c0
 00000001141f7a38 ffffffff802afa5c ffff88000b8363c0 ffffffff8028fb40
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12389   2949
 ffff880067467c58 0000000000000082 ffff880067467c58 ffff880067467be8
 ffffffff807bb000 ffff8800674ca800 ffff880017334380 ffff8800674cab40
 00000001016f5734 00000000000003b3 ffff8800674cab40 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006515da58     0 12395   2949
 ffff88006515da48 0000000000000082 ffff88006515d9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880000d4e140 ffff88000326c7c0 ffff880000d4e480
 000000006515d9f8 ffffffff8024ee66 ffff880000d4e480 ffff88006515da58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88001f3d5a48     0 11841   2949
 ffff88001f3d5a38 0000000000000082 00000000000702bb ffffffff8028e8b8
 ffffffff807bb000 ffff880008adc280 ffff88007e8aa740 ffff880008adc5c0
 000000001f3d59e8 ffffffff8024ee66 ffff880008adc5c0 ffff88001f3d5a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11884   2949
 ffff880020bc9ac8 0000000000000082 ffff880020bc9a58 ffffffff804c5515
 ffffffff807bb000 ffff88000b0d8480 ffff880048ac0500 ffff88000b0d87c0
 0000000110c97338 ffff8800369e6ab8 ffff88000b0d87c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11885   2949
 ffff880011e09a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880020ac0480 ffff880003266740 ffff880020ac07c0
 000000026b6b6b6b 6b6b6b6b6b6b6b6b ffff880020ac07c0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800222f9a58     0 12397   2949
 ffff8800222f9a48 0000000000000082 ffff8800222f99a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880025ec8380 ffff88001fff49c0 ffff880025ec86c0
 00000001222f99f8 ffffffff8024ee66 ffff880025ec86c0 ffff8800222f9a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12400   2949
 ffff88005ecc9c58 0000000000000082 0000000200000001 0000000000000000
 ffffffff807bb000 ffff8800138d6580 ffff88007d1b68c0 ffff8800138d68c0
 000000010b0d84b8 0000000100181bbb ffff8800138d68c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880018c0da48     0 11856   2949
 ffff880018c0da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88004cddc440 ffff8800795a8080 ffff88004cddc780
 0000000118c0d9e8 ffffffff8024ee66 ffff88004cddc780 ffff880018c0da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11897   2949
 ffff88006d199ac8 0000000000000082 ffff88006d199a58 ffffffff804c5515
 ffffffff807bb000 ffff8800705e0580 ffff880048ac0500 ffff8800705e08c0
 000000021fa6c250 ffff8800369e6ab8 ffff8800705e08c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11898   2949
 ffff880004779a78 0000000000000082 ffff8800047799d8 ffffffff8025e809
 ffffffff807bb000 ffff88006693a200 ffff88007b8e63c0 ffff88006693a540
 000000007c098080 ffff8800010252f0 ffff88006693a540 0000000000000001
Call Trace:
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007e493a58     0 12322   2949
 ffff88007e493a48 0000000000000082 ffff88007e4939a8 000000000000000b
 ffffffff807bb000 ffff8800030a6040 ffff8800662ae480 ffff8800030a6380
 000000007e4939f8 ffffffff8024ee66 ffff8800030a6380 ffff88007e493a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12323   2949
 ffff88005884bc58 0000000000000082 ffff8800705e05b8 0000000000000001
 ffffffff807bb000 ffff880034276700 ffff8800414bc040 ffff880034276a40
 00000002705e05b8 0000000000000001 ffff880034276a40 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11863   2949
 ffff88005e869a38 0000000000000082 ffff88005e8699b8 0000000000000080
 ffffffff807bb000 ffff88005c51c2c0 ffff8800168ea200 ffff88005c51c600
 000000015e8699e8 ffffffff8024ee66 ffff88005c51c600 ffff88005e869a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11909   2949
 ffff88000465bac8 0000000000000082 ffff88000465ba58 ffffffff804c5515
 ffffffff807bb000 ffff88005c1b2700 ffff880018254340 ffff88005c1b2a40
 000000011fbe1168 ffff8800369e6ab8 ffff88005c1b2a40 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11910   2949
 ffff880048b07a78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff880054588240 ffff88007c8f4440 ffff880054588580
 0000000200000000 0000000000000000 ffff880054588580 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12405   2949
 ffff88007a745c58 0000000000000082 ffff88005c1b2738 0000000000000001
 ffffffff807bb000 ffff880018254340 ffff8800758f8340 ffff880018254680
 0000000100000001 0000000100181b58 ffff880018254680 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880011c6da58     0 12406   2949
 ffff880011c6da48 0000000000000082 ffff880011c6d9a8 000000000000000b
 ffffffff807bb000 ffff8800662ae480 ffff880009a24600 ffff8800662ae7c0
 0000000011c6d9f8 ffffffff8024ee66 ffff8800662ae7c0 ffff880011c6da58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880058123a48     0 11890   2949
 ffff880058123a38 ffffffff80292f10 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff88004c214900 ffff880003e8e9c0 ffff88004c214c40
 00000001581239e8 ffffffff8024ee66 ffff88004c214c40 ffff880058123a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11936   2949
 ffff88007946bac8 0000000000000082 ffff88007946ba58 ffffffff804c5515
 ffffffff807bb000 ffff880013d48200 ffff88007c8f4440 ffff880013d48540
 000000032ca57d30 ffff8800369e6ab8 ffff880013d48540 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 11947   2949
 ffff880065527a78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88002b996740 ffff88000d85a9c0 ffff88002b996a80
 0000000100000000 0000000000000000 ffff88002b996a80 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12386   2949
 ffff88007c8b9c58 0000000000000082 ffff880013d48238 0000000000000001
 ffffffff807bb000 ffff88007c8f4440 ffff880077d7c780 ffff88007c8f4780
 0000000300000001 ffff880001019280 ffff88007c8f4780 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006697b578     0 12387   2949
 ffff88006697b568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff880020bcc700 ffff880078836940 ffff880020bcca40
 000000016697b518 ffffffff8024ee66 ffff880020bcca40 ffff88006697b578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800046b1a48     0 11924   2949
 ffff8800046b1a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005b1ba600 ffff88005ed5c240 ffff88005b1ba940
 00000001046b19e8 ffffffff8024ee66 ffff88005b1ba940 ffff8800046b1a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 11992   2949
 ffff88007d069ac8 0000000000000082 ffff88007d069a58 ffffffff804c5515
 ffffffff807bb000 ffff8800798c0380 ffff88005d750640 ffff8800798c06c0
 000000002f13d338 ffff8800369e6ab8 ffff8800798c06c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12007   2949
 ffff880065897a78 0000000000000082 ffff8800658979d8 ffff88000c0666c8
 ffffffff807bb000 ffff88006e972080 ffff88007885a380 ffff88006e9723c0
 0000000365897a38 ffffffff802afa5c ffff88006e9723c0 ffffffff8028fb40
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12390   2949
 ffff88001903bc58 0000000000000082 ffff8800798c03b8 ffff88001903bbe8
 ffffffff807bb000 ffff88003bb4c180 ffff88001724c780 ffff88003bb4c4c0
 00000000798c03b8 0000000000000001 ffff88003bb4c4c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880048aa3a58     0 12393   2949
 ffff880048aa3a48 0000000000000082 ffff880048aa39a8 000000000000000b
 ffffffff807bb000 ffff880009aea6c0 ffff880002ffa700 ffff880009aeaa00
 0000000148aa39f8 ffffffff8024ee66 ffff880009aeaa00 ffff880048aa3a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 11959   2949
 0000000000000000 0000000000000020 ffff880020a51a18 000000010000001c
 0000000000000004 0000000000000001 ffffe20000134c78 ffffe200016622f0
 ffffe200017396b8 ffffe2000059be00 ffffe2000105dbf0 ffffe20000881b98
Call Trace:
 [<ffffffff80292dd4>] ? shrink_zone+0x2a4/0x350
 [<ffffffff80294052>] ? try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12023   2949
 ffff880016adbac8 0000000000000082 ffff880016adba58 ffffffff804c5515
 ffffffff807bb000 ffff880025eb0580 ffff8800516f2900 ffff880025eb08c0
 00000002172b45f0 ffff8800369e6ab8 ffff880025eb08c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12024   2949
 ffff88007b871a78 0000000000000082 ffff88007b871b38 ffffffff8022b179
 ffffffff807bb000 ffff88006ac20280 ffff880025eb0580 ffff88006ac205c0
 000000007c098080 ffff8800010192f0 ffff88006ac205c0 0000000000000001
Call Trace:
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12385   2949
 ffff880078c7fc58 0000000000000082 ffff880078c7fc58 ffff880078c7fc58
 ffffffff807bb000 ffff88007d89a940 ffff88005ecbc900 ffff88007d89ac80
 0000000225eb05b8 0000000000000001 ffff88007d89ac80 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007b461a58     0 12402   2949
 ffff88007b461a48 0000000000000082 ffff88007b4619a8 000000000000000b
 ffffffff807bb000 ffff8800030ac1c0 ffff880009aea6c0 ffff8800030ac500
 000000017b4619f8 ffffffff8024ee66 ffff8800030ac500 ffff88007b461a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 0000000000000000     0 11991   2949
 ffff880076d09a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005164e880 ffff88005c51c2c0 ffff88005164ebc0
 0000000176d099e8 ffffffff8024ee66 ffff88005164ebc0 ffff880076d09a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12042   2949
 ffff880034353ac8 0000000000000082 ffff880034353a58 ffffffff804c5515
 ffffffff807bb000 ffff88002b850800 ffff880078836940 ffff88002b850b40
 000000011fbe1e18 ffff8800369e6ab8 ffff88002b850b40 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12048   2949
 ffff88005d12da78 0000000000000082 ffff880001025280 0000000000000000
 ffffffff807bb000 ffff880012534600 ffff8800319c8540 ffff880012534940
 000000017c098080 ffff8800010252f0 ffff880012534940 0000000000000001
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12388   2949
 ffff88002f6b1c58 0000000000000082 ffff88002b850838 ffff88002f6b1be8
 ffffffff807bb000 ffff880010aea340 ffff880034276700 ffff880010aea680
 000000022b850838 0000000000000001 ffff880010aea680 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880077479a58     0 12404   2949
 ffff880077479a48 0000000000000082 ffff8800774799a8 000000000000000b
 ffffffff807bb000 ffff88000ac36140 ffff88000adb40c0 ffff88000ac36480
 00000000774799f8 ffffffff8024ee66 ffff88000ac36480 ffff880077479a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800669c9a48     0 12008   2949
 ffff8800669c9a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88007bc06680 ffff88000d0a4440 ffff88007bc069c0
 00000000669c99e8 ffffffff8024ee66 ffff88007bc069c0 ffff8800669c9a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802611cf>] ? getnstimeofday+0x3f/0xe0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12069   2949
 ffff8800655edac8 0000000000000082 ffff8800655eda58 ffffffff804c5515
 ffffffff807bb000 ffff88006b53e500 ffff88005d750640 ffff88006b53e840
 0000000017bb3420 ffff8800369e6ab8 ffff88006b53e840 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12070   2949
 ffff88007bca3a78 0000000000000082 ffff880001019280 0000000000000000
 ffffffff807bb000 ffff88007d5c0140 ffff88000d85a9c0 ffff88007d5c0480
 000000017c0980b8 0000000000000001 ffff88007d5c0480 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12401   2949
 ffff880059e75c58 0000000000000082 ffff88006b53e538 0000000000000001
 ffffffff807bb000 ffff880077528200 ffff8800183d6800 ffff880077528540
 000000006b53e538 0000000000000001 ffff880077528540 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880036141a58     0 12403   2949
 ffff880036141a48 0000000000000082 ffff8800361419a8 000000000000000b
 ffffffff807bb000 ffff88005d750640 ffff880016b26080 ffff88005d750980
 00000000361419f8 ffffffff8024ee66 ffff88005d750980 ffff880036141a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880016b73908     0 12028   2949
 ffff880016b738f8 0000000000000082 00000001001b4400 ffffffff8024ea20
 ffffffff807bb000 ffff8800186ca200 ffff88007b962580 ffff8800186ca540
 0000000216b738a8 ffffffff8024ee66 ffff8800186ca540 ffff880016b73908
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12088   2949
 ffff88005d69dac8 0000000000000082 ffff88005d69da58 ffffffff804c5515
 ffffffff807bb000 ffff88002fdbe840 ffff8800705e0580 ffff88002fdbeb80
 000000025cc06f00 ffff8800369e6ab8 ffff88002fdbeb80 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12089   2949
 ffff880004787a78 0000000000000082 ffff880004787a08 ffffffff802afa5c
 ffffffff807bb000 ffff88000d85a9c0 ffff88002fdbe840 ffff88000d85ad00
 0000000204787a08 ffff880004787a28 ffff88000d85ad00 ffffffff80299a00
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff80299a00>] ? handle_mm_fault+0x530/0x7b0
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12392   2949
 ffff88007708dc58 0000000000000082 ffff88002fdbe878 ffff88007708dbe8
 ffffffff807bb000 ffff8800581c0380 ffff88002e4982c0 ffff8800581c06c0
 00000003275287f8 0000000100181c6e ffff8800581c06c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880010f55a58     0 12396   2949
 ffff880010f55a48 0000000000000082 ffff880010f559a8 000000000000000b
 ffffffff807bb000 ffff8800275287c0 ffff88005ec289c0 ffff880027528b00
 0000000110f559f8 ffffffff8024ee66 ffff880027528b00 ffff880010f55a58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800791bfa48     0 12115   2949
 ffff8800791bfa38 0000000000000082 ffff8800791bf9b8 0000000000000080
 ffffffff807bb000 ffff8800567b6200 ffff88006509c6c0 ffff8800567b6540
 00000001791bf9e8 ffffffff8024ee66 ffff8800567b6540 ffff8800791bfa48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12145   2949
 ffff880078c53ac8 0000000000000082 ffff880078c53a58 ffffffff804c5515
 ffffffff807bb000 ffff880000d50180 ffff880002ec4900 ffff880000d504c0
 000000032ca57d30 ffff8800369e6ab8 ffff880000d504c0 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8054db68>] ? _spin_unlock_irqrestore+0x8/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12146   2949
 ffff880048bd5a78 0000000000000082 ffff880048bd5a08 ffffffff802afa5c
 ffffffff807bb000 ffff8800460d07c0 ffff8800567b6200 ffff8800460d0b00
 0000000348bd5a08 ffff880048bd5a28 ffff8800460d0b00 ffffffff80299a00
Call Trace:
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff80299a00>] ? handle_mm_fault+0x530/0x7b0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12568   2949
 ffff88000b135c58 0000000000000082 ffff880000d501b8 0000000000000001
 ffffffff807bb000 ffff880002ec4900 ffff880067522080 ffff880002ec4c40
 0000000300d501b8 0000000000000001 ffff880002ec4c40 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880010d3fa58     0 12569   2949
 ffff880010d3fa48 0000000000000082 ffff880010d3f9a8 000000000000000b
 ffffffff807bb000 ffff88005ec289c0 ffff8800030ac1c0 ffff88005ec28d00
 0000000110d3f9f8 ffffffff8024ee66 ffff88005ec28d00 ffff880010d3fa58
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c4cb908     0 12205   2949
 ffff88007c4cb8f8 0000000000000082 ffff88007c4cba18 ffff88000103d280
 ffffffff807bb000 ffff8800124c0240 ffff88007c1c06c0 ffff8800124c0580
 000000027c4cb8a8 ffffffff8024ee66 ffff8800124c0580 ffff88007c4cb908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12212   2949
 ffff880020ac5c58 0000000000000082 ffff88007cd52de0 ffffe200008fb0d0
 ffffffff807bb000 ffff8800030f44c0 ffff880067da86c0 ffff8800030f4800
 0000000200000001 0000000000000100 ffff8800030f4800 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8023650f>] ? task_rq_lock+0x4f/0xa0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12213   2949
 ffff8800140ada78 0000000000000082 ffff8800140ad9e8 ffffffff80233d86
 ffffffff807bb000 ffff8800581680c0 ffff8800030f44c0 ffff880058168400
 000000017c0980b8 0000000000000001 ffff880058168400 ffffffff80238be4
Call Trace:
 [<ffffffff80233d86>] ? dequeue_task+0x96/0xe0
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff80289be7>] ? __rmqueue_smallest+0xf7/0x170
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12214   2949
 ffff88003c13bc58 0000000000000082 0000000000000000 ffff88003c13bbe8
 ffffffff807bb000 ffff88007d90a3c0 ffff880078836940 ffff88007d90a700
 00000003030f44f8 0000000000000001 ffff88007d90a700 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8026789b>] ? do_futex+0x5b/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880063187a58     0 12215   2949
 ffff880063187a48 0000000000000082 ffff8800631879a8 ffffffff8028d9cf
 ffffffff807bb000 ffff8800169c8040 ffff880002e1c100 ffff8800169c8380
 00000000631879f8 ffffffff8024ee66 ffff8800169c8380 ffff880063187a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       D ffff880013de5a48     0 12227   2732
 ffff880013de5a38 0000000000000082 ffff880013de59b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880067522080 ffff8800369a4200 ffff8800675223c0
 0000000113de59e8 ffffffff8024ee66 ffff8800675223c0 ffff880013de5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff88000d8ffa48     0 12408   2732
 ffff88000d8ffa38 0000000000000082 ffff88000d8ff9b8 0000000000000080
 ffffffff807bb000 ffff88007885a380 ffff8800544e8400 ffff88007885a6c0
 000000000d8ff9e8 ffffffff8024ee66 ffff88007885a6c0 ffff88000d8ffa48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff880014053a48     0 12410   2732
 ffff880014053a38 0000000000000082 0000000000070309 0000000000000080
 ffffffff807bb000 ffff8800191a40c0 ffff880067de6180 ffff8800191a4400
 00000000140539e8 ffffffff8024ee66 ffff8800191a4400 ffff880014053a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       D ffff88006d1d3a48     0 12492   2732
 ffff88006d1d3a38 0000000000000082 0000000000070309 0000000000000080
 ffffffff807bb000 ffff88005b6ac580 ffff88007e4002c0 ffff88005b6ac8c0
 000000006d1d39e8 ffffffff8024ee66 ffff88005b6ac8c0 ffff88006d1d3a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff804b77ae>] ? sys_recvfrom+0xae/0x110
 [<ffffffff8025bb53>] ? set_process_cpu_timer+0x33/0x110
 [<ffffffff8024ff6a>] ? do_sigaction+0x9a/0x1b0
 [<ffffffff8024820c>] ? do_setitimer+0x16c/0x370
 [<ffffffff8054de79>] error_exit+0x0/0x51
apache2       S 7fffffffffffffff     0 12493   2732
 ffff880007619e48 0000000000000082 ffff880007619dc8 ffffffff803ed05e
 ffffffff807bb000 ffff88005a236880 ffff8800758f8340 ffff88005a236bc0
 0000000007619dd8 ffffffff8025e809 ffff88005a236bc0 ffffffff8022b179
Call Trace:
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff802edd2b>] sys_epoll_wait+0x48b/0x550
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S ffff88007bddfb50     0 12494   2732
 ffff880017929ce8 0000000000000082 0000007f17929ca8 ffff88007f800280
 ffffffff807bb000 ffff880035392640 ffff880036862600 ffff880035392980
 0000000017929ca8 ffffffff802b6b92 ffff880035392980 ffff88007f800280
Call Trace:
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff803a34f1>] ? sys_semtimedop+0x5a1/0x910
 [<ffffffff803aed04>] ? security_ipc_permission+0x14/0x20
 [<ffffffff803a36d1>] sys_semtimedop+0x781/0x910
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff802ee525>] ? ep_ptable_queue_proc+0x35/0xb0
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802ee558>] ? ep_ptable_queue_proc+0x68/0xb0
 [<ffffffff803a386b>] sys_semop+0xb/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
apache2       S ffff88004f012b90     0 12495   2732
 ffff880078303ce8 0000000000000082 0000007f78303ca8 ffff88007f800280
 ffffffff807bb000 ffff880002f84380 ffff880076fc4700 ffff880002f846c0
 0000000078303ca8 ffffffff802b6b92 ffff880002f846c0 ffff88007f800280
Call Trace:
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff803a34f1>] ? sys_semtimedop+0x5a1/0x910
 [<ffffffff803aed04>] ? security_ipc_permission+0x14/0x20
 [<ffffffff803a36d1>] sys_semtimedop+0x781/0x910
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff802ee525>] ? ep_ptable_queue_proc+0x35/0xb0
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802ee558>] ? ep_ptable_queue_proc+0x68/0xb0
 [<ffffffff803a386b>] sys_semop+0xb/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800775cda48     0 12515   2949
 ffff8800775cda38 0000000000000082 ffff8800775cd9b8 0000000000000080
 ffffffff807bb000 ffff88001f386280 ffff8800369a4200 ffff88001f3865c0
 00000001775cd9e8 ffffffff8024ee66 ffff88001f3865c0 ffff8800775cda48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12520   2949
 ffff880026e59c58 0000000000000082 ffff8800368c8300 ffff88000103d2f0
 ffffffff807bb000 ffff88001251a100 ffff8800658503c0 ffff88001251a440
 000000010103d280 ffff8800368c8300 ffff88001251a440 ffff88000103d280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12521   2949
 ffff88002f9f5a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880002eb4180 ffff88001f386280 ffff880002eb44c0
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff880002eb44c0 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12527   2949
 ffff88005d06dc58 0000000000000082 ffff88005d06dc58 ffff88005d06dbe8
 ffffffff807bb000 ffff88003ea6c700 ffff880018c7c5c0 ffff88003ea6ca40
 000000011251a138 00000001001819c2 ffff88003ea6ca40 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff80268311>] ? sys_futex+0x1/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007c8bd578     0 12528   2949
 ffff88007c8bd568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff880075708740 ffff8800655303c0 ffff880075708a80
 000000017c8bd518 ffffffff8024ee66 ffff880075708a80 ffff88007c8bd578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800588f5a48     0 12518   2949
 ffff8800588f5a38 0000000000000082 ffff8800588f59b8 0000000000000080
 ffffffff807bb000 ffff88006509c6c0 ffff880034316540 ffff88006509ca00
 00000001588f59e8 ffffffff8024ee66 ffff88006509ca00 ffff8800588f5a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12524   2949
 ffff88005b59dc58 0000000000000082 ffff8800368c8300 ffff8800010252f0
 ffffffff807bb000 ffff8800770d0580 ffff8800368c8300 ffff8800770d08c0
 0000000101025280 ffff8800368c8300 ffff8800770d08c0 ffff880001025280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 12530   2949
 ffff88000b0f9a78 0000000000000082 0000000000000000 0000000000000000
 ffffffff807bb000 ffff88000e60c700 ffff88007f034440 ffff88000e60ca40
 0000000300000000 000000010017a8b3 ffff88000e60ca40 0000000000000000
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff80237107>] ? pick_next_task_fair+0x77/0xa0
 [<ffffffff8054b9c8>] ? thread_return+0x306/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12536   2949
 ffff88005743dc58 0000000000000082 0000000000000000 00000000ffffffff
 ffffffff807bb000 ffff88002b8908c0 ffff880037914380 ffff88002b890c00
 00000003770d05b8 0000000100180f5b ffff88002b890c00 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 7fffffffffffffff     0 12537   2949
 ffff880025e3b568 0000000000000082 ffff880025e3b558 ffff880009666740
 ffffffff807bb000 ffff880009666740 ffff8800031b66c0 ffff880009666a80
 0000000325e3b518 ffffffff8020aa95 ffff880009666a80 ffff880077025668
Call Trace:
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff803d6ed7>] ? generic_make_request+0x337/0x450
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80358049>] ? xfs_bmbt_insert+0xb9/0x160
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803415f5>] xfs_alloc_vextent+0x1c5/0x4f0
 [<ffffffff80350872>] xfs_bmap_btalloc+0x612/0xb10
 [<ffffffff80350d8c>] xfs_bmap_alloc+0x1c/0x40
 [<ffffffff803540ce>] xfs_bmapi+0x9ee/0x12d0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8038bdbe>] xfs_alloc_file_space+0x1ee/0x450
 [<ffffffff80390b0e>] xfs_change_file_space+0x2be/0x320
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff80396e99>] xfs_ioc_space+0xc9/0xe0
 [<ffffffff8039898d>] xfs_ioctl+0x14d/0x860
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff80396785>] xfs_file_ioctl+0x35/0x80
 [<ffffffff802cc771>] vfs_ioctl+0x31/0xa0
 [<ffffffff802cc854>] do_vfs_ioctl+0x74/0x480
 [<ffffffff802cccf9>] sys_ioctl+0x99/0xa0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880078149a48     0 12522   2949
 ffff880078149a38 0000000000000082 ffff8800781499b8 ffffffff8028e8b8
 ffffffff807bb000 ffff880031852500 ffff88002b806140 ffff880031852840
 00000000781499e8 ffffffff8024ee66 ffff880031852840 ffff880078149a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 12531   2949
 ffff8800794ada38 0000000000000082 0000000000070309 ffffffff8028e8b8
 ffffffff807bb000 ffff880067da86c0 ffff88006509c6c0 ffff880067da8a00
 00000001794ad9e8 ffffffff8024ee66 ffff880067da8a00 ffff8800794ada48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12533   2949
 ffff880017bb1a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88000a046600 ffff880067da86c0 ffff88000a046940
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff88000a046940 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12541   2949
 ffff88007749bc58 0000000000000082 ffff88007749bc38 ffff88007749bc38
 ffffffff807bb000 ffff88002e184540 ffff88007e890140 ffff88002e184880
 000000037749bdd8 0000000100181e12 ffff88002e184880 ffff88000314a888
Call Trace:
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002f7f1578     0 12542   2949
 ffff88002f7f1568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88006d108800 ffff880075708740 ffff88006d108b40
 000000012f7f1518 ffffffff8024ee66 ffff88006d108b40 ffff88002f7f1578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80237107>] ? pick_next_task_fair+0x77/0xa0
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 12523   2949
 ffff88002205da38 0000000000000082 0000000000070309 ffffffff8028e8b8
 ffffffff807bb000 ffff88000d0a4440 ffff88005798e9c0 ffff88000d0a4780
 000000002205d9e8 ffffffff8024ee66 ffff88000d0a4780 ffff88002205da48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 12532   2949
 ffff88006d1e3a38 0000000000000082 ffff88006d1e39b8 0000000000000080
 ffffffff807bb000 ffff88005a272540 ffff88006b3b8600 ffff88005a272880
 000000016d1e39e8 ffffffff8024ee66 ffff88005a272880 ffff88006d1e3a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12534   2949
 ffff880003a69a78 0000000000000082 227de267afa1c15a 94d6d427055ce0e4
 ffffffff807bb000 ffff88006694a140 ffff88002f148600 ffff88006694a480
 00000002a6838e33 a7349c6debe9baa8 ffff88006694a480 bb35c07656153879
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12556   2949
 ffff88001381dc58 0000000000000082 ffff88001381dc08 ffffffff80285664
 ffffffff807bb000 ffff880048914880 ffff880019160300 ffff880048914bc0
 000000025a272578 0000000100181d5c ffff880048914bc0 ffffffff80238ab8
Call Trace:
 [<ffffffff80285664>] ? __lock_page+0x64/0x70
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880026e5d578     0 12558   2949
 ffff880026e5d568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88001dffe8c0 ffff88007d97a9c0 ffff88001dffec00
 0000000126e5d518 ffffffff8024ee66 ffff88001dffec00 ffff880026e5d578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800791f3a48     0 12886   2949
 ffff8800791f3a38 0000000000000082 00000000000702e9 ffffffff8028e8b8
 ffffffff807bb000 ffff880003e8e9c0 ffff880067de6180 ffff880003e8ed00
 00000000791f39e8 ffffffff8024ee66 ffff880003e8ed00 ffff8800791f3a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff802d2401>] ? touch_atime+0x31/0x140
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12888   2949
 ffff880077d19c58 0000000000000082 ffff8800368c8300 ffff8800010252f0
 ffffffff807bb000 ffff880057638640 ffff8800368c8300 ffff880057638980
 0000000101025280 ffff8800368c8300 ffff880057638980 ffff880001025280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12889   2949
 ffff880003f21a78 0000000000000082 000000000000002a ffff88000103d280
 ffffffff807bb000 ffff8800031786c0 ffff880003e8e9c0 ffff880003178a00
 0000000303f21a38 ffffffff802373b1 ffff880003178a00 ffff88000b18c200
Call Trace:
 [<ffffffff802373b1>] ? dequeue_task_fair+0x281/0x290
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803e3185>] ? cfq_exit_single_io_context+0x55/0x70
 [<ffffffff803e31ca>] ? cfq_exit_io_context+0x2a/0x40
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 12890   2949
 ffff880014019c58 0000000000000082 0000000000000000 ffff880014019be8
 ffffffff807bb000 ffff88004190e300 ffff88007f034440 ffff88004190e640
 0000000357638678 0000000100180d18 ffff88004190e640 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88004624ba58     0 12891   2949
 ffff88004624ba48 0000000000000082 ffff88004624b9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880003a34480 ffff88000b1a4240 ffff880003a347c0
 000000014624b9f8 ffffffff8024ee66 ffff880003a347c0 ffff88004624ba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff80238c9a>] ? task_new_fair+0xaa/0xf0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88006adb7a48     0 12908   2949
 ffff88006adb7a38 0000000000000082 ffff88006adb79b8 ffffffff8028e8b8
 ffffffff807bb000 ffff88007c5ae4c0 ffff88005d10e8c0 ffff88007c5ae800
 000000006adb79e8 ffffffff8024ee66 ffff88007c5ae800 ffff88006adb7a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12928   2949
 ffff88005e937ac8 0000000000000082 ffff88005e937a58 ffffffff804c5515
 ffffffff807bb000 ffff880010dbc240 ffff880019160300 ffff880010dbc580
 000000012ca57080 ffff8800369e6ab8 ffff880010dbc580 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029f4ee>] ? do_brk+0x2ae/0x380
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12929   2949
 ffff88000a745a78 0000000000000082 ffff880001031280 0000000000000000
 ffffffff807bb000 ffff8800201427c0 ffff88007c5ae4c0 ffff880020142b00
 000000007c0980b8 0000000000000001 ffff880020142b00 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005d61da58     0 13041   2949
 ffff88005d61da48 0000000000000082 ffff88005d61d9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880032f8c500 ffff8800662ae480 ffff880032f8c840
 000000005d61d9f8 ffffffff8024ee66 ffff880032f8c840 ffff88005d61da58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803afae0>] ? cap_file_permission+0x0/0x10
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13042   2949
 ffff8800187b3c58 0000000000000082 ffff8800187b3c38 ffff8800187b3c38
 ffffffff807bb000 ffff8800588c41c0 ffff88004c3da400 ffff8800588c4500
 0000000110dbc278 0000000000000001 ffff8800588c4500 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 12924   2949
 ffff8800790f9a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800168ea200 ffff88005b1ba600 ffff8800168ea540
 00000001790f99e8 ffffffff8024ee66 ffff8800168ea540 ffff8800790f9a48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff88001d97da48     0 12935   2949
 ffff88001d97da38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff8800342b82c0 ffff88007e8aa740 ffff8800342b8600
 000000001d97d9e8 ffffffff8024ee66 ffff8800342b8600 ffff88001d97da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 12936   2949
 ffff880044e8fa78 0000000000000082 e784b055339a7361 f29faa07a00638ad
 ffffffff807bb000 ffff88001fa10300 ffffffff806b0340 ffff88001fa10640
 0000000051fc51b1 000000010017b205 ffff88001fa10640 51a3f4c7391e2abb
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12958   2949
 ffff880016a8fc58 0000000000000082 ffff8800342b82f8 0000000000000001
 ffffffff807bb000 ffff880016be6340 ffff880067de6180 ffff880016be6680
 00000001342b82f8 0000000000000001 ffff880016be6680 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880022383a58     0 12959   2949
 ffff880022383a48 0000000000000082 ffff8800223839a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880003e36200 ffff880032f8c500 ffff880003e36540
 00000000223839f8 ffffffff8024ee66 ffff880003e36540 ffff880022383a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 12930   2949
 ffff88002b83ba38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880012434880 ffff88005ed5c240 ffff880012434bc0
 000000012b83b9e8 ffffffff8024ee66 ffff880012434bc0 ffff88002b83ba48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12939   2949
 ffff880002ed7c58 0000000000000082 0000003800000038 0000000000000001
 ffffffff807bb000 ffff8800654d6300 ffff880016b26080 ffff8800654d6640
 0000000302ed7be8 0000000000000000 ffff8800654d6640 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a0576>] ? mprotect_fixup+0x2e6/0x650
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12940   2949
 ffff880002e85a78 0000000000000082 ffff880002e859d8 ffffffff8025e809
 ffffffff807bb000 ffff88007dde8180 ffff8800191a40c0 ffff88007dde84c0
 0000000002e85a28 ffffffff802857e5 ffff88007dde84c0 0000000000000000
Call Trace:
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007ad0f578     0 12946   2949
 ffff88007ad0f568 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff8800655303c0 ffff88001dffe8c0 ffff880065530700
 000000017ad0f518 ffffffff8024ee66 ffff880065530700 ffff88007ad0f578
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8029e31c>] ? vma_adjust+0xfc/0x4f0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff802a0576>] ? mprotect_fixup+0x2e6/0x650
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12947   2949
 ffff880076d13c58 0000000000000082 ffff880076d13c58 ffff880076d13c58
 ffffffff807bb000 ffff88006bd90480 ffff8800758f8340 ffff88006bd907c0
 00000000654d6338 0000000000000001 ffff88006bd907c0 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff80266357>] ? wake_futex+0x27/0x40
 [<ffffffff8026644d>] ? futex_wake+0xdd/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880002e81a48     0 12973   2949
 ffff880002e81a38 0000000000000082 ffff880002e819b8 0000000000000080
 ffffffff807bb000 ffff88002b952180 ffff88005b6ac580 ffff88002b9524c0
 0000000102e819e8 ffffffff8024ee66 ffff88002b9524c0 ffff880002e81a48
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 12987   2949
 ffff88000c2c9ac8 0000000000000082 ffff88000c2c9a58 ffffffff804c5515
 ffffffff807bb000 ffff88007881c1c0 ffff88000e6a09c0 ffff88007881c500
 00000000780b9d30 ffff8800369e6ab8 ffff88007881c500 ffffffff804edb1f
Call Trace:
 [<ffffffff804c5515>] ? dev_queue_xmit+0x105/0x570
 [<ffffffff804edb1f>] ? ip_finish_output+0x1af/0x2c0
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff804f2930>] ? tcp_poll+0x20/0x180
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff804b5b60>] ? sock_aio_read+0x180/0x190
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff802be591>] ? do_sync_read+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802ce027>] sys_poll+0x77/0x110
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 12988   2949
 ffff880079c6fa78 0000000000000082 af18039e3df1049b 6f4b41c954228bb5
 ffffffff807bb000 ffff880018c04800 ffff880067d60440 ffff880018c04b40
 000000003093b4c3 8b770c0d3e5e21a8 ffff880018c04b40 fad539f78d813ba4
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13043   2949
 ffff880077d55c58 0000000000000082 ffff88007881c1f8 0000000000000001
 ffffffff807bb000 ffff88000e6a09c0 ffff88006b53e500 ffff88000e6a0d00
 0000000000000001 ffff880001019280 ffff88000e6a0d00 0000000000000002
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80266357>] ? wake_futex+0x27/0x40
 [<ffffffff802666fc>] ? futex_requeue+0x26c/0x2c0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13049   2949
 ffff88007e96fc58 0000000000000082 ffff88007e96fbe8 ffffffff802e27c8
 ffffffff807bb000 ffff8800544b4100 ffff88000314a840 ffff8800544b4440
 0000000100000bfd 0000000000000008 ffff8800544b4440 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     R  running task        0 13198   2949
 ffff88007b07da38 0000000000000082 ffff88007b07d9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff8800139888c0 ffff880058b12340 ffff880013988c00
 000000007b07d9e8 ffffffff8024ee66 ffff880013988c00 ffff88007b07da48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     R  running task        0 13203   2949
 ffff880027543a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff880048ac0500 ffff88006b3b8600 ffff880048ac0840
 00000000275439e8 ffffffff8024ee66 ffff880048ac0840 ffff880027543a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 13204   2949
 ffff880067403a78 0000000000000082 23d17bda585bae20 e23cc6d162d8dccb
 ffffffff807bb000 ffff880009792940 ffff880077462380 ffff880009792c80
 000000013124aa7d 8eb73eb1e430e697 ffff880009792c80 fa5802ef0698f320
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff80241857>] ? __mmdrop+0x47/0x60
 [<ffffffff8028bb52>] ? free_pages+0x32/0x40
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8023e718>] ? finish_task_switch+0xa8/0xd0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13211   2949
 ffff880013d65c58 0000000000000082 ffff880013d65c08 ffffffff80285664
 ffffffff807bb000 ffff880002f58540 ffff88002e184540 ffff880002f58880
 000000038025a9b0 0000000100181df5 ffff880002f58880 ffffffff8028548b
Call Trace:
 [<ffffffff80285664>] ? __lock_page+0x64/0x70
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff80285818>] ? find_lock_page+0x58/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8029d790>] ? unmap_region+0x130/0x150
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13220   2949
 ffff880017babc58 0000000000000082 ffff880017babbe8 ffffffff802e27c8
 ffffffff807bb000 ffff8800414bc040 ffff880002f58540 ffff8800414bc380
 0000000300000e8e 0000000000000008 ffff8800414bc380 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005c411908     0 13281   2949
 ffff88005c4118f8 0000000000000082 ffff88005c411878 ffff88000103d280
 ffffffff807bb000 ffff880017b6e080 ffff88001fa8c180 ffff880017b6e3c0
 000000025c4118a8 ffffffff8024ee66 ffff880017b6e3c0 ffff88005c411908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff8800047a3a48     0 13284   2949
 ffff8800047a3a38 0000000000000082 00000000000702bb 0000000000000080
 ffffffff807bb000 ffff8800488c47c0 ffff880019160300 ffff8800488c4b00
 00000000047a39e8 ffffffff8024ee66 ffff8800488c4b00 ffff8800047a3a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff804b81a2>] ? sock_common_recvmsg+0x32/0x50
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 13285   2949
 ffff88002e4fba78 0000000000000082 5c83bad368d45a7f 07cc4f480cdccccf
 ffffffff807bb000 ffff880036972740 ffff88007a958700 ffff880036972a80
 0000000205fcd59b 0b1febcb15f7a4ca ffff880036972a80 a94ef05b53ce9db0
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff803ec989>] ? rb_erase+0x1d9/0x350
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13289   2949
 ffff88007b553c58 0000000000000082 ffff8800488c47f8 ffff88007b553be8
 ffffffff807bb000 ffff880020b46180 ffff88000ad46900 ffff880020b464c0
 00000003488c47f8 0000000100181d5b ffff880020b464c0 ffffffff8028548b
Call Trace:
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13298   2949
 ffff880063c5dc58 0000000000000082 ffff880063c5dbe8 ffffffff802e27c8
 ffffffff807bb000 ffff88000b18c200 ffff88005798e9c0 ffff88000b18c540
 00000001000006e5 0000000000000008 ffff88000b18c540 ffffffff80286649
Call Trace:
 [<ffffffff802e27c8>] ? generic_write_end+0x88/0x90
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bf566>] ? generic_file_llseek+0x56/0x70
 [<ffffffff802bdf45>] ? vfs_llseek+0x35/0x40
 [<ffffffff802be072>] ? sys_lseek+0x52/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880017b27a48     0 13283   2949
 ffff880017b27a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88005a238180 ffff8800168ea200 ffff88005a2384c0
 0000000000000000 ffffffff8024ee66 ffff88005a2384c0 ffff880017b27a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     D ffff880078d0b908     0 13292   2949
 ffff880078d0b8f8 0000000000000082 ffff880078d0b878 ffff88000103d280
 ffffffff807bb000 ffff88001fa8c180 ffff8800186ca200 ffff88001fa8c4c0
 0000000278d0b8a8 ffffffff8024ee66 ffff88001fa8c4c0 ffff880078d0b908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bf239>] ? vfs_read+0x129/0x180
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 13293   2949
 ffff880059f39a78 0000000000000082 ffff880059f39a48 ffffffff8028a18d
 ffffffff807bb000 ffff880058b06780 ffff880077072600 ffff880058b06ac0
 000000010058dfc0 ffff88007fb725c8 ffff880058b06ac0 0000000000000000
Call Trace:
 [<ffffffff8028a18d>] ? free_pages_bulk+0x16d/0x3a0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802d2f4f>] ? destroy_inode+0x4f/0x60
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13296   2949
 ffff880058945c58 0000000000000082 ffff880058945bb8 ffffffff8023b5ad
 ffffffff807bb000 ffff880002eaa4c0 ffff88007a8207c0 ffff880002eaa800
 0000000058945be8 ffffffff8025a9e1 ffff880002eaa800 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8025a9e1>] ? wake_bit_function+0x31/0x40
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff80296b05>] ? sys_madvise+0xb5/0x620
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88005ec3ba58     0 13297   2949
 ffff88005ec3ba48 0000000000000082 ffff88005ec3b9a8 ffffffff8028d9cf
 ffffffff807bb000 ffff880002ffa700 ffff88005ec289c0 ffff880002ffaa40
 000000015ec3b9f8 ffffffff8024ee66 ffff880002ffaa40 ffff88005ec3ba58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88007bccf838     0 13286   2949
 ffff88007bccf828 0000000000000082 ffffe20000ef8f00 0000000000000000
 ffffffff807bb000 ffff880016ac2940 ffff8800124c0240 ffff880016ac2c80
 000000027bccf7d8 ffffffff8024ee66 ffff880016ac2c80 ffff88007bccf838
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80292454>] ? shrink_active_list+0x3c4/0x470
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e1a4>] throttle_vm_writeout+0x94/0xb0
 [<ffffffff80292ddd>] shrink_zone+0x2ad/0x350
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S ffffffff80560200     0 13290   2949
 ffff88006d151c58 0000000000000082 ffff8800368c8300 ffff8800010192f0
 ffffffff807bb000 ffff88001ffb07c0 ffff88007fba0240 ffff88001ffb0b00
 0000000101019280 0000000100181329 ffff88001ffb0b00 ffff880001019280
Call Trace:
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a0576>] ? mprotect_fixup+0x2e6/0x650
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13291   2949
 ffff88005d7a1a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff88007d9241c0 ffff880077072600 ffff88007d924500
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff88007d924500 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028c823>] ? __alloc_pages_internal+0xe3/0x4d0
 [<ffffffff802afa5c>] ? alloc_page_vma+0x6c/0x200
 [<ffffffff8028fb40>] ? lru_cache_add_lru+0x20/0x50
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff802a3094>] ? page_add_new_anon_rmap+0x44/0x60
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S ffffffff80560200     0 13294   2949
 ffff88006089dc58 0000000000000082 ffff88001ffb07f8 0000000000000001
 ffffffff807bb000 ffff880017ab8880 ffff88007fba0240 ffff880017ab8bc0
 000000011ffb07f8 0000000100181318 ffff880017ab8bc0 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 7fffffffffffffff     0 13295   2949
 ffff8800166ff568 0000000000000082 ffff8800166ff558 ffff88005c5fc300
 ffffffff807bb000 ffff88005c5fc300 ffff880014f78140 ffff88005c5fc640
 00000003166ff518 ffffffff8020aa95 ffff88005c5fc640 ffff88005d4dc998
Call Trace:
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff803d6ed7>] ? generic_make_request+0x337/0x450
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80358049>] ? xfs_bmbt_insert+0xb9/0x160
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803415f5>] xfs_alloc_vextent+0x1c5/0x4f0
 [<ffffffff80350872>] xfs_bmap_btalloc+0x612/0xb10
 [<ffffffff80350d8c>] xfs_bmap_alloc+0x1c/0x40
 [<ffffffff803540ce>] xfs_bmapi+0x9ee/0x12d0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8038bdbe>] xfs_alloc_file_space+0x1ee/0x450
 [<ffffffff80390b0e>] xfs_change_file_space+0x2be/0x320
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff80396e99>] xfs_ioc_space+0xc9/0xe0
 [<ffffffff8039898d>] xfs_ioctl+0x14d/0x860
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff80396785>] xfs_file_ioctl+0x35/0x80
 [<ffffffff802cc771>] vfs_ioctl+0x31/0xa0
 [<ffffffff802cc854>] do_vfs_ioctl+0x74/0x480
 [<ffffffff802cccf9>] sys_ioctl+0x99/0xa0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff8800030f9788     0 13301   2949
 ffff8800030f9778 0000000000000082 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007c80c140 ffff88001dffe8c0 ffff88007c80c480
 00000001030f9728 ffffffff8024ee66 ffff88007c80c480 ffff8800030f9788
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359e8e>] xfs_btree_read_bufs+0x4e/0x70
 [<ffffffff80342a09>] xfs_alloc_lookup+0x109/0x410
 [<ffffffff80342d27>] xfs_alloc_lookup_le+0x17/0x20
 [<ffffffff8033f44b>] xfs_free_ag_extent+0x6b/0x6e0
 [<ffffffff8034140c>] xfs_free_extent+0xac/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff80390722>] xfs_setattr+0xb02/0xc30
 [<ffffffff80399d38>] xfs_vn_setattr+0x18/0x20
 [<ffffffff802d3f9a>] notify_change+0x19a/0x360
 [<ffffffff802bd5c3>] do_truncate+0x63/0x90
 [<ffffffff802c254e>] ? sys_newfstat+0x2e/0x40
 [<ffffffff802bd6d2>] sys_ftruncate+0xe2/0x130
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13303   2949
 ffff88007a657c58 0000000000000082 ffff8800368c8300 ffff8800010252f0
 ffffffff807bb000 ffff88007d8e6840 ffff88001ffce400 ffff88007d8e6b80
 0000000201025280 ffff8800368c8300 ffff88007d8e6b80 ffff880001025280
Call Trace:
 [<ffffffff8023aadf>] ? check_preempt_wakeup+0x12f/0x1c0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80294b59>] ? __inc_zone_page_state+0x29/0x30
 [<ffffffff80299aa3>] ? handle_mm_fault+0x5d3/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8020aa95>] ? __switch_to+0x275/0x400
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13307   2949
 ffff88005814fa78 0000000000000082 fd674b83af679546 2322ee93dc40d885
 ffffffff807bb000 ffff880010bb4480 ffff88005e912600 ffff880010bb47c0
 0000000129315bdc 029865fb6558b0fb ffff880010bb47c0 fd41963604c65021
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13308   2949
 ffff880061e99c58 0000000000000082 ffff880061e99c58 ffff880061e99c58
 ffffffff807bb000 ffff88005d0d46c0 ffff88005d08c780 ffff88005d0d4a00
 000000037d8e6878 000000010018163d ffff88005d0d4a00 ffffffff80238ab8
Call Trace:
 [<ffffffff80238ab8>] ? enqueue_task_fair+0x198/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802a66a5>] ? free_pages_and_swap_cache+0x85/0xb0
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D 7fffffffffffffff     0 13315   2949
 ffff880003217568 0000000000000082 0000000000100000 ffff88003796e720
 ffffffff807bb000 ffff88005e810840 ffff880009666740 ffff88005e810b80
 00000003ffffffff ffff8800343ba998 ffff88005e810b80 ffff88001911f8a0
Call Trace:
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803415f5>] xfs_alloc_vextent+0x1c5/0x4f0
 [<ffffffff80350872>] xfs_bmap_btalloc+0x612/0xb10
 [<ffffffff80350d8c>] xfs_bmap_alloc+0x1c/0x40
 [<ffffffff803540ce>] xfs_bmapi+0x9ee/0x12d0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8038bdbe>] xfs_alloc_file_space+0x1ee/0x450
 [<ffffffff80390b0e>] xfs_change_file_space+0x2be/0x320
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802cae0d>] ? user_path_at+0x8d/0xb0
 [<ffffffff80396e99>] xfs_ioc_space+0xc9/0xe0
 [<ffffffff8039898d>] xfs_ioctl+0x14d/0x860
 [<ffffffff802d6bba>] ? mntput_no_expire+0x2a/0x140
 [<ffffffff80396785>] xfs_file_ioctl+0x35/0x80
 [<ffffffff802cc771>] vfs_ioctl+0x31/0xa0
 [<ffffffff802cc854>] do_vfs_ioctl+0x74/0x480
 [<ffffffff802cccf9>] sys_ioctl+0x99/0xa0
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff88002d21ba48     0 13304   2949
 ffff88002d21ba38 0000000000000082 ffff88002d21b9b8 ffffffff8028e8b8
 ffffffff807bb000 ffff88001770c840 ffff880012434880 ffff88001770cb80
 000000002d21b9e8 ffffffff8024ee66 ffff88001770cb80 ffff88002d21ba48
Call Trace:
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
v3krecord     S 0000000000000000     0 13313   2949
 ffff88000323bc58 0000000000000082 ffff88000323bbb8 ffffffff8023b5ad
 ffffffff807bb000 ffff88005e912600 ffff880067d60440 ffff88005e912940
 000000000323bbe8 ffffffff8025a9e1 ffff88005e912940 ffffffff8023428a
Call Trace:
 [<ffffffff8023b5ad>] ? default_wake_function+0xd/0x10
 [<ffffffff8025a9e1>] ? wake_bit_function+0x31/0x40
 [<ffffffff8023428a>] ? __wake_up_common+0x5a/0x90
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802c616d>] ? pipe_write+0x2fd/0x620
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff802bef7c>] ? vfs_write+0x12c/0x190
 [<ffffffff802bf108>] ? sys_write+0x88/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13314   2949
 ffff8800183d3a78 0000000000000082 6b6b6b6b6b6b6b6b 6b6b6b6b6b6b6b6b
 ffffffff807bb000 ffff880058806800 ffff88001770c840 ffff880058806b40
 000000016b6b6b6b 6b6b6b6b6b6b6b6b ffff880058806b40 6b6b6b6b6b6b6b6b
Call Trace:
 [<ffffffff8054c6fd>] schedule_hrtimeout_range+0x10d/0x130
 [<ffffffff8025ad29>] ? add_wait_queue+0x49/0x60
 [<ffffffff802cee3d>] ? __pollwait+0x7d/0x110
 [<ffffffff8052a280>] ? unix_poll+0x20/0xc0
 [<ffffffff802cdc97>] do_sys_poll+0x317/0x4b0
 [<ffffffff802cedc0>] ? __pollwait+0x0/0x110
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff80285ee0>] ? filemap_fault+0x240/0x440
 [<ffffffff802857b2>] ? unlock_page+0x22/0x30
 [<ffffffff802977a4>] ? __do_fault+0x1f4/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff8025e809>] ? up_read+0x9/0x10
 [<ffffffff8022b179>] ? do_page_fault+0x2f9/0x960
 [<ffffffff802cde79>] sys_ppoll+0x49/0x180
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     D ffff880077185a58     0 13389   2949
 ffff880077185a48 0000000000000082 ffff8800771859a8 ffffffff8028d9cf
 ffffffff807bb000 ffff88000a7142c0 ffff880011d94080 ffff88000a714600
 00000000771859f8 ffffffff8024ee66 ffff88000a714600 ffff880077185a58
Call Trace:
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028e2ff>] balance_dirty_pages_ratelimited_nr+0x13f/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802bf510>] ? generic_file_llseek+0x0/0x70
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
v3krecord     S 0000000000000000     0 13391   2949
 ffff88000b1cdc58 0000000000000082 ffff88000b1cdc38 ffff88000b1cdbe8
 ffffffff807bb000 ffff88007bcc4240 ffff88000b1a4240 ffff88007bcc4580
 000000005e912638 0000000000000001 ffff88007bcc4580 ffffffff80238be4
Call Trace:
 [<ffffffff80238be4>] ? enqueue_task_fair+0x2c4/0x2d0
 [<ffffffff8026620e>] futex_wait+0x3ce/0x4a0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802678fc>] do_futex+0xbc/0xad0
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff802683d6>] sys_futex+0xc6/0x170
 [<ffffffff8020d729>] ? do_device_not_available+0x9/0x10
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
pdflush       D ffff880058b15890     0 14928      2
 ffff880058b15880 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88007d97a9c0 ffff880058118400 ffff88007d97ad00
 0000000158b15830 ffffffff8024ee66 ffff88007d97ad00 ffff880058b15890
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8028e8b8>] ? pdflush_operation+0x88/0xb0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff802363ce>] ? __wake_up+0x4e/0x70
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e0e0>] background_writeout+0xb0/0xe0
 [<ffffffff8028e754>] pdflush+0x144/0x220
 [<ffffffff8028e030>] ? background_writeout+0x0/0xe0
 [<ffffffff8028e610>] ? pdflush+0x0/0x220
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
rm            D ffff88007dd71a48     0 15371   2845
 ffff88007dd71a38 0000000000000082 00000000000702e9 0000000000000080
 ffffffff807bb000 ffff88002d2f0980 ffff880011f20980 ffff88002d2f0cc0
 000000017dd719e8 ffffffff8024ee66 ffff88002d2f0cc0 ffff88007dd71a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802ca52e>] ? do_unlinkat+0x5e/0x1d0
 [<ffffffff802ca52e>] ? do_unlinkat+0x5e/0x1d0
 [<ffffffff8054de79>] error_exit+0x0/0x51
rm            D ffff880003045908     0 15448   2845
 ffff8800030458f8 0000000000000082 0000000000000000 ffff88000103d280
 ffffffff807bb000 ffff880002eb61c0 ffff88007b962580 ffff880002eb6500
 00000002030458a8 ffffffff8024ee66 ffff880002eb6500 ffff880003045908
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff80233ce0>] ? enqueue_task+0x50/0x60
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff802ca52e>] ? do_unlinkat+0x5e/0x1d0
 [<ffffffff802ca52e>] ? do_unlinkat+0x5e/0x1d0
 [<ffffffff8054de79>] error_exit+0x0/0x51
rm            D 7fffffffffffffff     0 15524   2845
 ffff880010ed5908 0000000000000082 0000000200000001 ffff88007d0460e8
 ffffffff807bb000 ffff88007ad3a3c0 ffff88007f21a440 ffff88007ad3a700
 0000000210ed58c8 ffffffff803d69cc ffff88007ad3a700 ffff88007c5e71a0
Call Trace:
 [<ffffffff803d69cc>] ? blk_unplug+0x5c/0x70
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff8033f732>] ? xfs_free_ag_extent+0x352/0x6e0
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff803413ee>] xfs_free_extent+0x8e/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
rm            D 7fffffffffffffff     0 15530   2845
 ffff88001de21908 0000000000000082 ffff88000103d280 ffff8800659cc998
 ffffffff807bb000 ffff88002d27c700 ffff880037914380 ffff88002d27ca40
 000000031de21948 ffffffff8054b6ff ffff88002d27ca40 ffff880013955a78
Call Trace:
 [<ffffffff8054b6ff>] ? thread_return+0x3d/0x64e
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802857e5>] ? find_lock_page+0x25/0x70
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff803413ee>] xfs_free_extent+0x8e/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
rm            D ffff88007b111798     0 15593   2845
 ffff88007b111788 0000000000000082 0000000000000282 ffff880067d93300
 ffffffff807bb000 ffff88005aa722c0 ffff88005c4ac440 ffff88005aa72600
 000000017b111738 ffffffff8024ee66 ffff88005aa72600 ffff88007b111798
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff80359e8e>] xfs_btree_read_bufs+0x4e/0x70
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8035a252>] ? xfs_btree_del_cursor+0x62/0x70
 [<ffffffff80342a09>] xfs_alloc_lookup+0x109/0x410
 [<ffffffff80342d64>] xfs_alloc_lookup_eq+0x14/0x20
 [<ffffffff8033f62c>] xfs_free_ag_extent+0x24c/0x6e0
 [<ffffffff8034140c>] xfs_free_extent+0xac/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
rm            D 7fffffffffffffff     0 15663   2845
 ffff8800068cb908 0000000000000082 0000000100000001 ffff88006424f308
 ffffffff807bb000 ffff8800030e8900 ffff8800688aa100 ffff8800030e8c40
 00000001068cb8c8 ffffffff803d69cc ffff8800030e8c40 ffff88007705e4d0
Call Trace:
 [<ffffffff803d69cc>] ? blk_unplug+0x5c/0x70
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff8033f732>] ? xfs_free_ag_extent+0x352/0x6e0
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff803ed05e>] ? __up_read+0x8e/0xb0
 [<ffffffff803413ee>] xfs_free_extent+0x8e/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
rm            D 7fffffffffffffff     0 15666   2845
 ffff880002fb1908 0000000000000082 7fffffffffffffff ffff8800775e23c0
 ffffffff807bb000 ffff8800031b66c0 ffff88007d934540 ffff8800031b6a00
 00000000775e23c0 ffffffff80391637 ffff8800031b6a00 ffffffff802b6b92
Call Trace:
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8038970b>] ? xfs_trans_log_buf+0x8b/0xa0
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff803413ee>] xfs_free_extent+0x8e/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
pdflush       D ffff880064349890     0 15818      2
 ffff880064349880 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff880078836940 ffff880058118400 ffff880078836c80
 0000000164349830 ffffffff8024ee66 ffff880078836c80 ffff880064349890
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e0e0>] background_writeout+0xb0/0xe0
 [<ffffffff8028e754>] pdflush+0x144/0x220
 [<ffffffff8028e030>] ? background_writeout+0x0/0xe0
 [<ffffffff8028e610>] ? pdflush+0x0/0x220
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
ipmitool      D ffff8800080b1a48     0 15898   2819
 ffff8800080b1a38 0000000000000082 00000000000702db 0000000000000080
 ffffffff807bb000 ffff880002f8a900 ffff880011c72140 ffff880002f8ac40
 00000001080b19e8 ffffffff8024ee66 ffff880002f8ac40 ffff8800080b1a48
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054bf59>] schedule_timeout_uninterruptible+0x19/0x20
 [<ffffffff8028caaa>] __alloc_pages_internal+0x36a/0x4d0
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80469859>] ? handle_send_req+0xd9/0x130
 [<ffffffff80466da0>] ? free_recv_msg+0x10/0x20
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff802cc7c4>] ? vfs_ioctl+0x84/0xa0
 [<ffffffff802cc854>] ? do_vfs_ioctl+0x74/0x480
 [<ffffffff8054de79>] error_exit+0x0/0x51
pdflush       D ffff880068807890     0 15899      2
 ffff880068807880 0000000000000046 0000000000000286 ffff880067d93300
 ffffffff807bb000 ffff88000314a840 ffff8800655303c0 ffff88000314ab80
 0000000168807830 ffffffff8024ee66 ffff88000314ab80 ffff880068807890
Call Trace:
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8028ca35>] __alloc_pages_internal+0x2f5/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802861e3>] find_or_create_page+0x43/0xa0
 [<ffffffff80395144>] _xfs_buf_lookup_pages+0x134/0x340
 [<ffffffff80395f83>] xfs_buf_get_flags+0x73/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a18>] xfs_trans_read_buf+0x188/0x360
 [<ffffffff80372d0e>] xfs_imap_to_bp+0x4e/0x120
 [<ffffffff80372ef7>] xfs_itobp+0x67/0x100
 [<ffffffff80373134>] xfs_iflush+0x1a4/0x350
 [<ffffffff8025e829>] ? down_read_trylock+0x9/0x10
 [<ffffffff8038cbcf>] xfs_inode_flush+0xbf/0xf0
 [<ffffffff8039bd39>] xfs_fs_write_inode+0x29/0x70
 [<ffffffff802dca45>] __writeback_single_inode+0x335/0x4c0
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e0e0>] background_writeout+0xb0/0xe0
 [<ffffffff8028e754>] pdflush+0x144/0x220
 [<ffffffff8028e030>] ? background_writeout+0x0/0xe0
 [<ffffffff8028e610>] ? pdflush+0x0/0x220
 [<ffffffff8025a599>] kthread+0x49/0x90
 [<ffffffff8020d1d9>] child_rip+0xa/0x11
 [<ffffffff8025a550>] ? kthread+0x0/0x90
 [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
rm            D 7fffffffffffffff     0 15900   2845
 ffff8800581b9908 0000000000000082 7fffffffffffffff ffff880010d31080
 ffffffff807bb000 ffff88000320c780 ffff88002e05c500 ffff88000320cac0
 0000000210d31080 ffffffff80391637 ffff88000320cac0 ffffffff802b6b92
Call Trace:
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff803d69cc>] ? blk_unplug+0x5c/0x70
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff8054bf05>] schedule_timeout+0xb5/0xf0
 [<ffffffff8038970b>] ? xfs_trans_log_buf+0x8b/0xa0
 [<ffffffff8054caba>] __down+0x6a/0xb0
 [<ffffffff8025f076>] down+0x46/0x50
 [<ffffffff80394913>] xfs_buf_lock+0x43/0x50
 [<ffffffff80395e05>] _xfs_buf_find+0x145/0x250
 [<ffffffff80395f70>] xfs_buf_get_flags+0x60/0x180
 [<ffffffff803960a6>] xfs_buf_read_flags+0x16/0xb0
 [<ffffffff80389a69>] xfs_trans_read_buf+0x1d9/0x360
 [<ffffffff8033f1f0>] xfs_alloc_read_agf+0x80/0x1e0
 [<ffffffff803412cf>] xfs_alloc_fix_freelist+0x3ff/0x490
 [<ffffffff80391637>] ? kmem_zone_alloc+0x97/0xe0
 [<ffffffff802b6b92>] ? cache_alloc_debugcheck_after+0x172/0x270
 [<ffffffff8054d8ec>] ? __down_read+0x1c/0xba
 [<ffffffff802b83ab>] ? kmem_cache_alloc+0xcb/0x190
 [<ffffffff803413ee>] xfs_free_extent+0x8e/0xd0
 [<ffffffff80351346>] xfs_bmap_finish+0x156/0x1a0
 [<ffffffff803740e7>] xfs_itruncate_finish+0x137/0x340
 [<ffffffff8038f496>] xfs_inactive+0x386/0x4b0
 [<ffffffff802cf3c4>] ? d_rehash+0x34/0x50
 [<ffffffff8039b9e6>] xfs_fs_clear_inode+0xc6/0x120
 [<ffffffff802d2d48>] clear_inode+0x58/0x100
 [<ffffffff802d359e>] generic_delete_inode+0x10e/0x140
 [<ffffffff802d3655>] generic_drop_inode+0x85/0x210
 [<ffffffff802d256d>] iput+0x5d/0x70
 [<ffffffff802ca5eb>] do_unlinkat+0x11b/0x1d0
 [<ffffffff802ca7fd>] sys_unlinkat+0x1d/0x40
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b
sleep         D ffff880000d39908     0 15970   3066
 ffff880000d398f8 0000000000000082 00000001001b43ff ffffffff8024ea20
 ffffffff807bb000 ffff8800030466c0 ffff88007b962580 ffff880003046a00
 0000000200d398a8 ffffffff8024ee66 ffff880003046a00 ffff880000d39908
Call Trace:
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8024ee66>] ? lock_timer_base+0x36/0x70
 [<ffffffff8024f05f>] ? __mod_timer+0xaf/0xd0
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8054bece>] schedule_timeout+0x7e/0xf0
 [<ffffffff8024ea20>] ? process_timeout+0x0/0x10
 [<ffffffff8054af27>] __sched_text_start+0x37/0x50
 [<ffffffff80295c3c>] congestion_wait+0x6c/0x90
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802940fd>] try_to_free_pages+0x2ed/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8025a9b0>] ? wake_bit_function+0x0/0x40
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025e0df>] ? hrtimer_try_to_cancel+0x3f/0x80
 [<ffffffff8025e13a>] ? hrtimer_cancel+0x1a/0x30
 [<ffffffff8054c770>] ? do_nanosleep+0x40/0xc0
 [<ffffffff8025e393>] ? hrtimer_nanosleep+0xa3/0x120
 [<ffffffff8025dad0>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8054de79>] error_exit+0x0/0x51
Sched Debug Version: v0.07, 2.6.28.10-v3500-1 #1
now at 7626765.740753 msecs
  .sysctl_sched_latency                    : 60.000000
  .sysctl_sched_min_granularity            : 12.000000
  .sysctl_sched_wakeup_granularity         : 15.000000
  .sysctl_sched_child_runs_first           : 0.000001
  .sysctl_sched_features                   : 24191

cpu#0, 2493.725 MHz
  .nr_running                    : 0
  .load                          : 6242
  .nr_switches                   : 58047129
  .nr_load_updates               : 1581284
  .nr_uninterruptible            : -5965
  .jiffies                       : 4296799012
  .next_balance                  : 4296.799015
  .curr->pid                     : 11827
  .clock                         : 7626890.544399
  .cpu_load[0]                   : 0
  .cpu_load[1]                   : 3121
  .cpu_load[2]                   : 877
  .cpu_load[3]                   : 471
  .cpu_load[4]                   : 314
  .yld_exp_empty                 : 0
  .yld_act_empty                 : 0
  .yld_both_empty                : 0
  .yld_count                     : 950
  .sched_switch                  : 0
  .sched_count                   : 92951825
  .sched_goidle                  : 3678468
  .ttwu_count                    : 52547303
  .ttwu_local                    : 7000088
  .bkl_count                     : 1862

cfs_rq[0]:
  .exec_clock                    : 2557979.670118
  .MIN_vruntime                  : 2790427521.534577
  .min_vruntime                  : 2790427529.670815
  .max_vruntime                  : 2790427529.670815
  .spread                        : 8.136238
  .spread0                       : 0.000000
  .nr_running                    : 1
  .load                          : 9363
  .nr_spread_over                : 11914050

rt_rq[0]:
  .rt_nr_running                 : 0
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
         kswapd0   267 2790427515.084496    729865   115 2790427515.473090     69210.885943   6825994.591214

cpu#1, 2493.725 MHz
  .nr_running                    : 0
  .load                          : 26835
  .nr_switches                   : 25211255
  .nr_load_updates               : 1449005
  .nr_uninterruptible            : 6239
  .jiffies                       : 4296799099
  .next_balance                  : 4296.799099
  .curr->pid                     : 15818
  .clock                         : 7627238.805762
  .cpu_load[0]                   : 6242
  .cpu_load[1]                   : 8069
  .cpu_load[2]                   : 8529
  .cpu_load[3]                   : 9298
  .cpu_load[4]                   : 8957
  .yld_exp_empty                 : 0
  .yld_act_empty                 : 0
  .yld_both_empty                : 0
  .yld_count                     : 1137
  .sched_switch                  : 0
  .sched_count                   : 44534056
  .sched_goidle                  : 2473867
  .ttwu_count                    : 21111160
  .ttwu_local                    : 8076075
  .bkl_count                     : 2626

cfs_rq[1]:
  .exec_clock                    : 2530324.005430
  .MIN_vruntime                  : 4570057628.759580
  .min_vruntime                  : 4570057648.438939
  .max_vruntime                  : 4570057628.759580
  .spread                        : 0.000000
  .spread0                       : 1779630079.191190
  .nr_running                    : 43
  .load                          : 0
  .nr_spread_over                : 8713931

rt_rq[1]:
  .rt_nr_running                 : 0
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------

cpu#2, 2493.725 MHz
  .nr_running                    : 4
  .load                          : 184788
  .nr_switches                   : 12447088
  .nr_load_updates               : 1473584
  .nr_uninterruptible            : -4959
  .jiffies                       : 4296799363
  .next_balance                  : 4296.754201
  .curr->pid                     : 11959
  .clock                         : 7628292.017838
  .cpu_load[0]                   : 24640
  .cpu_load[1]                   : 24665
  .cpu_load[2]                   : 25042
  .cpu_load[3]                   : 24835
  .cpu_load[4]                   : 24130
  .yld_exp_empty                 : 0
  .yld_act_empty                 : 0
  .yld_both_empty                : 0
  .yld_count                     : 2132
  .sched_switch                  : 0
  .sched_count                   : 19146452
  .sched_goidle                  : 2291163
  .ttwu_count                    : 8763982
  .ttwu_local                    : 5026881
  .bkl_count                     : 3318

cfs_rq[2]:
  .exec_clock                    : 2312657.234063
  .MIN_vruntime                  : 2930559440.542941
  .min_vruntime                  : 2930559460.228939
  .max_vruntime                  : 2930559460.763815
  .spread                        : 20.220874
  .spread0                       : 140131878.585329
  .nr_running                    : 3
  .load                          : 7266
  .nr_spread_over                : 2399703

rt_rq[2]:
  .rt_nr_running                 : 1
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
     migration/2     9       -14.157958     18799     0       -14.157958        59.655064         0.000000
        events/2    17 2930559440.542941    872426   115 2930559440.542941      3087.530728   6661968.797556
      xfsdatad/2   279 2930559460.763815    165601   115 2930559460.763815     33405.155069   6901381.541632
R      v3krecord 11959 2930568251.816191     20415   120 2930568251.816191     20305.282111    374273.834691

cpu#3, 2493.725 MHz
  .nr_running                    : 4
  .load                          : 184788
  .nr_switches                   : 14509558
  .nr_load_updates               : 1701903
  .nr_uninterruptible            : 4858
  .jiffies                       : 4296799466
  .next_balance                  : 4296.799511
  .curr->pid                     : 11044
  .clock                         : 7628701.500632
  .cpu_load[0]                   : 184788
  .cpu_load[1]                   : 184788
  .cpu_load[2]                   : 184788
  .cpu_load[3]                   : 184788
  .cpu_load[4]                   : 184788
  .yld_exp_empty                 : 0
  .yld_act_empty                 : 0
  .yld_both_empty                : 0
  .yld_count                     : 1829
  .sched_switch                  : 0
  .sched_count                   : 49134998
  .sched_goidle                  : 2216545
  .ttwu_count                    : 10545825
  .ttwu_local                    : 4922459
  .bkl_count                     : 1775

cfs_rq[3]:
  .exec_clock                    : 2625312.323578
  .MIN_vruntime                  : 4437052342.015185
  .min_vruntime                  : 4437052361.701183
  .max_vruntime                  : 4437052342.015185
  .spread                        : 0.000000
  .spread0                       : 1646624764.722207
  .nr_running                    : 3
  .load                          : 7266
  .nr_spread_over                : 14145456

rt_rq[3]:
  .rt_nr_running                 : 1
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
      watchdog/3    14        -7.608472        10     0        -7.608472         0.027042       476.023649
        events/3    18 4437052342.015185    147103   115 4437052342.015185       590.587449   7183582.873644
      xfsdatad/3   280 4437052342.015185    161824   115 4437052342.015185     56237.074219   6696015.105972
R      v3krecord 11044 4437232621.684592     30001   120 4437233109.684438    204618.760050    316303.011281


INFO: task v3krecord:23498 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
v3krecord     D 0000000000000002     0 23498   2949
 ffff880018369568 0000000000000082 ffff880018369508 ffffffffa028b602
 ffffffff807bb000 ffff88001ffe8440 ffff8800662ae480 ffff88001ffe8780
 0000000200000001 ffff880011e12d68 ffff88001ffe8780 ffff880011e128a0
Call Trace:
 [<ffffffffa028b602>] ? __map_bio+0x42/0x160 [dm_mod]
 [<ffffffffa028c309>] ? __split_bio+0xe9/0x4a0 [dm_mod]
 [<ffffffff8054d95d>] __down_read+0x8d/0xba
 [<ffffffff8054c879>] down_read+0x9/0x10
 [<ffffffff8036f5d5>] xfs_ilock+0x55/0xa0
 [<ffffffff8036f63e>] xfs_ilock_map_shared+0x1e/0x50
 [<ffffffff80377955>] xfs_iomap+0x1a5/0x300
 [<ffffffffa028d07d>] ? dm_merge_bvec+0xbd/0x120 [dm_mod]
 [<ffffffff803d705e>] ? submit_bio+0x6e/0xf0
 [<ffffffff80392786>] xfs_map_blocks+0x36/0x90
 [<ffffffff803931c1>] xfs_page_state_convert+0x291/0x760
 [<ffffffff803ebb90>] ? radix_tree_gang_lookup_tag_slot+0xc0/0xe0
 [<ffffffff80393998>] xfs_vm_writepage+0x68/0x110
 [<ffffffff8028cc22>] __writepage+0x12/0x50
 [<ffffffff8028d777>] write_cache_pages+0x227/0x460
 [<ffffffff8028cc10>] ? __writepage+0x0/0x50
 [<ffffffff8028d9cf>] generic_writepages+0x1f/0x30
 [<ffffffff803938f4>] xfs_vm_writepages+0x54/0x70
 [<ffffffff8028da08>] do_writepages+0x28/0x50
 [<ffffffff802dc7b0>] __writeback_single_inode+0xa0/0x4c0
 [<ffffffff8028548b>] ? find_get_page+0x1b/0xb0
 [<ffffffff802dd0e9>] generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] xfs_write+0x6a3/0x9a0
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff80396883>] xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] sys_write+0x50/0x90
 [<ffffffff8020c2eb>] system_call_fastpath+0x16/0x1b

v3krecord: page allocation failure. order:0, mode:0x20
Pid: 12518, comm: v3krecord Not tainted 2.6.28.10-v3500-1 #1
Call Trace:
 <IRQ>  [<ffffffff8028cb0e>] __alloc_pages_internal+0x3ce/0x4d0
 [<ffffffff802b6d15>] kmem_getpages+0x85/0x190
 [<ffffffff802b6f7c>] fallback_alloc+0x15c/0x1f0
 [<ffffffff802b70a9>] ____cache_alloc_node+0x99/0x200
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b7287>] kmem_cache_alloc_node+0x77/0x160
 [<ffffffff802b7c61>] __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff804be557>] __alloc_skb+0x77/0x150
 [<ffffffff804bf0f3>] __netdev_alloc_skb+0x33/0x60
 [<ffffffffa00711e7>] bnx2_poll_work+0x907/0x12c0 [bnx2]
 [<ffffffffa0071cd1>] bnx2_poll+0x51/0x260 [bnx2]
 [<ffffffff804c2ff9>] net_rx_action+0x99/0x1c0
 [<ffffffff80249c14>] __do_softirq+0x94/0x160
 [<ffffffff8020d53c>] call_softirq+0x1c/0x30
 [<ffffffff8020ee65>] do_softirq+0x45/0x80
 [<ffffffff802498ed>] irq_exit+0x8d/0xa0
 [<ffffffff8020f109>] do_IRQ+0xc9/0x110
 [<ffffffff8020c7f6>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8054db68>] ? _spin_unlock_irqrestore+0x8/0x10
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff8023b5d0>] ? wake_up_process+0x10/0x20
 [<ffffffff80393c27>] ? xfsbufd_wakeup+0x57/0x70
 [<ffffffff80292f10>] ? shrink_slab+0x90/0x180
 [<ffffffff80294076>] ? try_to_free_pages+0x266/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  30
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
Active_anon:306629 active_file:27 inactive_anon:102279
 inactive_file:50561 unevictable:3 dirty:694 writeback:50580 unstable:0
 free:2512 slab:36464 mapped:1 pagetables:9577 bounce:0
Node 0 DMA free:7992kB min:24kB low:28kB high:36kB active_anon:100kB inactive_anon:128kB active_file:0kB inactive_file:808kB unevictable:0kB present:9000kB pages_scanned:1668 all_unreclaimable? yes
lowmem_reserve[]: 0 2003 2003 2003
Node 0 DMA32 free:2056kB min:5712kB low:7140kB high:8568kB active_anon:1226416kB inactive_anon:408988kB active_file:108kB inactive_file:201436kB unevictable:12kB present:2052092kB pages_scanned:113384981 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 40*4kB 23*8kB 14*16kB 10*32kB 7*64kB 4*128kB 4*256kB 2*512kB 2*1024kB 1*2048kB 0*4096kB = 7992kB
Node 0 DMA32: 0*4kB 7*8kB 7*16kB 3*32kB 4*64kB 4*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2056kB
209346 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524231 pages RAM
8897 pages reserved
88840 pages shared
457970 pages non-shared
v3krecord: page allocation failure. order:0, mode:0x20
Pid: 12518, comm: v3krecord Not tainted 2.6.28.10-v3500-1 #1
Call Trace:
 <IRQ>  [<ffffffff8028cb0e>] __alloc_pages_internal+0x3ce/0x4d0
 [<ffffffff802b6d15>] kmem_getpages+0x85/0x190
 [<ffffffff802b6f7c>] fallback_alloc+0x15c/0x1f0
 [<ffffffff802b70a9>] ____cache_alloc_node+0x99/0x200
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b7287>] kmem_cache_alloc_node+0x77/0x160
 [<ffffffff802b7c61>] __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff804be557>] __alloc_skb+0x77/0x150
 [<ffffffff804bf0f3>] __netdev_alloc_skb+0x33/0x60
 [<ffffffffa00711e7>] bnx2_poll_work+0x907/0x12c0 [bnx2]
 [<ffffffffa0071cd1>] bnx2_poll+0x51/0x260 [bnx2]
 [<ffffffff804c2ff9>] net_rx_action+0x99/0x1c0
 [<ffffffff80249c14>] __do_softirq+0x94/0x160
 [<ffffffff8020d53c>] call_softirq+0x1c/0x30
 [<ffffffff8020ee65>] do_softirq+0x45/0x80
 [<ffffffff802498ed>] irq_exit+0x8d/0xa0
 [<ffffffff8020f109>] do_IRQ+0xc9/0x110
 [<ffffffff8020c7f6>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8054db68>] ? _spin_unlock_irqrestore+0x8/0x10
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff8023b5d0>] ? wake_up_process+0x10/0x20
 [<ffffffff80393c27>] ? xfsbufd_wakeup+0x57/0x70
 [<ffffffff80292f10>] ? shrink_slab+0x90/0x180
 [<ffffffff80294076>] ? try_to_free_pages+0x266/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  30
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
Active_anon:306629 active_file:27 inactive_anon:102279
 inactive_file:50561 unevictable:3 dirty:694 writeback:50580 unstable:0
 free:2512 slab:36464 mapped:1 pagetables:9577 bounce:0
Node 0 DMA free:7992kB min:24kB low:28kB high:36kB active_anon:100kB inactive_anon:128kB active_file:0kB inactive_file:808kB unevictable:0kB present:9000kB pages_scanned:1668 all_unreclaimable? yes
lowmem_reserve[]: 0 2003 2003 2003
Node 0 DMA32 free:2056kB min:5712kB low:7140kB high:8568kB active_anon:1226416kB inactive_anon:408988kB active_file:108kB inactive_file:201436kB unevictable:12kB present:2052092kB pages_scanned:113384981 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 40*4kB 23*8kB 14*16kB 10*32kB 7*64kB 4*128kB 4*256kB 2*512kB 2*1024kB 1*2048kB 0*4096kB = 7992kB
Node 0 DMA32: 0*4kB 7*8kB 7*16kB 3*32kB 4*64kB 4*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2056kB
209346 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524231 pages RAM
8897 pages reserved
88840 pages shared
457970 pages non-shared
v3krecord: page allocation failure. order:0, mode:0x20
Pid: 12518, comm: v3krecord Not tainted 2.6.28.10-v3500-1 #1
Call Trace:
 <IRQ>  [<ffffffff8028cb0e>] __alloc_pages_internal+0x3ce/0x4d0
 [<ffffffff802b6d15>] kmem_getpages+0x85/0x190
 [<ffffffff802b6f7c>] fallback_alloc+0x15c/0x1f0
 [<ffffffff802b70a9>] ____cache_alloc_node+0x99/0x200
 [<ffffffff802b7c61>] ? __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff802b7287>] kmem_cache_alloc_node+0x77/0x160
 [<ffffffff802b7c61>] __kmalloc_node_track_caller+0x51/0x80
 [<ffffffff804be557>] __alloc_skb+0x77/0x150
 [<ffffffff804bf0f3>] __netdev_alloc_skb+0x33/0x60
 [<ffffffffa00711e7>] bnx2_poll_work+0x907/0x12c0 [bnx2]
 [<ffffffffa0071cd1>] bnx2_poll+0x51/0x260 [bnx2]
 [<ffffffff804c2ff9>] net_rx_action+0x99/0x1c0
 [<ffffffff80249c14>] __do_softirq+0x94/0x160
 [<ffffffff8020d53c>] call_softirq+0x1c/0x30
 [<ffffffff8020ee65>] do_softirq+0x45/0x80
 [<ffffffff802498ed>] irq_exit+0x8d/0xa0
 [<ffffffff8020f109>] do_IRQ+0xc9/0x110
 [<ffffffff8020c7f6>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8054db68>] ? _spin_unlock_irqrestore+0x8/0x10
 [<ffffffff8023b426>] ? try_to_wake_up+0x106/0x280
 [<ffffffff8023b5d0>] ? wake_up_process+0x10/0x20
 [<ffffffff80393c27>] ? xfsbufd_wakeup+0x57/0x70
 [<ffffffff80292f10>] ? shrink_slab+0x90/0x180
 [<ffffffff80294076>] ? try_to_free_pages+0x266/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] ? __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] ? alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] ? __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] ? __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] ? do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] ? filemap_fault+0x33a/0x440
 [<ffffffff80297600>] ? __do_fault+0x50/0x450
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] ? do_page_fault+0x2d7/0x960
 [<ffffffff802b6741>] ? kfree_debugcheck+0x11/0x30
 [<ffffffff802b6998>] ? cache_free_debugcheck+0x238/0x2c0
 [<ffffffff8029d80c>] ? remove_vma+0x5c/0x80
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] ? error_exit+0x0/0x51
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  30
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
Active_anon:306629 active_file:27 inactive_anon:102279
 inactive_file:50561 unevictable:3 dirty:694 writeback:50580 unstable:0
 free:2512 slab:36464 mapped:1 pagetables:9577 bounce:0
Node 0 DMA free:7992kB min:24kB low:28kB high:36kB active_anon:100kB inactive_anon:128kB active_file:0kB inactive_file:808kB unevictable:0kB present:9000kB pages_scanned:1668 all_unreclaimable? yes
lowmem_reserve[]: 0 2003 2003 2003
Node 0 DMA32 free:2056kB min:5712kB low:7140kB high:8568kB active_anon:1226416kB inactive_anon:408988kB active_file:108kB inactive_file:201436kB unevictable:12kB present:2052092kB pages_scanned:113384981 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 40*4kB 23*8kB 14*16kB 10*32kB 7*64kB 4*128kB 4*256kB 2*512kB 2*1024kB 1*2048kB 0*4096kB = 7992kB
Node 0 DMA32: 0*4kB 7*8kB 7*16kB 3*32kB 4*64kB 4*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 2056kB
209346 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524231 pages RAM
8897 pages reserved
88840 pages shared
457970 pages non-shared

SysRq : Show backtrace of all active CPUs
CPU2:
CPU 2:
Modules linked in: sha256_generic dm_crypt dm_mod aes_x86_64 aes_generic cbc hid_cherry video output button ac battery ipv6 bridge stp llc sd_mod usbhid hid ses enclosure sg ide_pci_generic piix ide_core usb_storage ata_piix ata_generic aacraid mptsas mptscsih libata mptbase scsi_transport_sas ehci_hcd bnx2 zlib_inflate uhci_hcd scsi_mod thermal processor fan thermal_sys
Pid: 11733, comm: v3krecord Not tainted 2.6.28.10-v3500-1 #1
RIP: 0010:[<ffffffff80292384>]  [<ffffffff80292384>] shrink_active_list+0x2f4/0x470
RSP: 0000:ffff880016895678  EFLAGS: 00000283
RAX: 0000000000000000 RBX: ffff8800168957b8 RCX: 000000000000001c
RDX: 000000000000001c RSI: 0000000000000001 RDI: ffff880000001700
RBP: ffff8800168957b8 R08: ffff88007fb725b8 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff802a1d93
R13: ffff8800168955f8 R14: ffffffff802a1ea6 R15: ffff880016895618
FS:  00007f38271aa770(0000) GS:ffff88007fb670a0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fd8b973b4be CR3: 000000002224f000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 [<ffffffff80292374>] ? shrink_active_list+0x2e4/0x470
 [<ffffffff80292a55>] shrink_list+0x555/0x630
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff80292d8b>] shrink_zone+0x25b/0x350
 [<ffffffff80294052>] try_to_free_pages+0x242/0x3b0
 [<ffffffff80290b50>] ? isolate_pages_global+0x0/0x250
 [<ffffffff8028c957>] __alloc_pages_internal+0x217/0x4d0
 [<ffffffff802af976>] alloc_pages_current+0x76/0xf0
 [<ffffffff802858bb>] __page_cache_alloc+0xb/0x10
 [<ffffffff8028ea8a>] __do_page_cache_readahead+0xca/0x200
 [<ffffffff8023b5a0>] ? default_wake_function+0x0/0x10
 [<ffffffff8028ec1e>] do_page_cache_readahead+0x5e/0x90
 [<ffffffff80285fda>] filemap_fault+0x33a/0x440
 [<ffffffff80297600>] __do_fault+0x50/0x450
 [<ffffffff80299688>] handle_mm_fault+0x1b8/0x7b0
 [<ffffffff8022b157>] do_page_fault+0x2d7/0x960
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802611cf>] ? getnstimeofday+0x3f/0xe0
 [<ffffffff802138b9>] ? read_tsc+0x9/0x20
 [<ffffffff802611e9>] ? getnstimeofday+0x59/0xe0
 [<ffffffff8025e519>] ? ktime_get_ts+0x59/0x60
 [<ffffffff802cd8c0>] ? poll_select_set_timeout+0x80/0x90
 [<ffffffff8054de79>] error_exit+0x0/0x51
CPU3:
 ffff88007f03ff08 0000000000000046 ffff8800790a9238 0000000000000003
 ffff88002d2f9b58 ffff88002d2f9b58 ffff88007f03ff48 ffffffff8020fea7
 ffff88007f03ff68 ffffffff8045de2f ffffffff807bfa30 ffff8800790a9210
Call Trace:
 <IRQ>  [<ffffffff8020fea7>] ? show_stack+0x17/0x20
 [<ffffffff8045de2f>] ? showacpu+0x4f/0x60
 [<ffffffff8026981c>] ? generic_smp_call_function_interrupt+0x4c/0x100
 [<ffffffff8021e4ef>] ? smp_call_function_interrupt+0x1f/0x30
 [<ffffffff8020ce3b>] ? call_function_interrupt+0x6b/0x70
 <EOI>  [<ffffffff8054dafe>] ? _spin_lock+0xe/0x20
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff803938da>] ? xfs_vm_writepages+0x3a/0x70
 [<ffffffff8028da08>] ? do_writepages+0x28/0x50
 [<ffffffff802dc7b0>] ? __writeback_single_inode+0xa0/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] ? generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] ? writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] ? balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] ? xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] ? xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] ? do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] ? vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] ? sys_write+0x50/0x90
 [<ffffffff8020c2eb>] ? system_call_fastpath+0x16/0x1b
CPU1:
 ffff88007fba7f08 0000000000000046 ffff8800790a9238 0000000000000001
 ffff88006257e5d8 ffff88005d61db58 ffff88007fba7f48 ffffffff8020fea7
 ffff88007fba7f68 ffffffff8045de2f ffffffff807bfa30 ffff8800790a9210
Call Trace:
 <IRQ>  [<ffffffff8020fea7>] ? show_stack+0x17/0x20
 [<ffffffff8045de2f>] ? showacpu+0x4f/0x60
 [<ffffffff8026981c>] ? generic_smp_call_function_interrupt+0x4c/0x100
 [<ffffffff8021e4ef>] ? smp_call_function_interrupt+0x1f/0x30
 [<ffffffff8020ce3b>] ? call_function_interrupt+0x6b/0x70
 <EOI>  [<ffffffff8054db06>] ? _spin_lock+0x16/0x20
 [<ffffffff802dc804>] ? __writeback_single_inode+0xf4/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] ? generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] ? writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] ? balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] ? xfs_write+0x6a3/0x9a0
 [<ffffffff802663e1>] ? futex_wake+0x71/0x120
 [<ffffffff80396883>] ? xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] ? do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803afae0>] ? cap_file_permission+0x0/0x10
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] ? vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] ? sys_write+0x50/0x90
 [<ffffffff8020c2eb>] ? system_call_fastpath+0x16/0x1b
CPU0:
 ffffffff807c8f08 0000000000000046 ffff8800790a9238 0000000000000000
 0000000000000000 000000000000000e ffffffff807c8f48 ffffffff8020fea7
 ffffffff807c8f68 ffffffff8045de2f ffffffff807bfa30 ffff8800790a9210
Call Trace:
 <IRQ>  [<ffffffff8020fea7>] ? show_stack+0x17/0x20
 [<ffffffff8045de2f>] ? showacpu+0x4f/0x60
 [<ffffffff8026981c>] ? generic_smp_call_function_interrupt+0x4c/0x100
 [<ffffffff8021e4ef>] ? smp_call_function_interrupt+0x1f/0x30
 [<ffffffff8020ce3b>] ? call_function_interrupt+0x6b/0x70
 <EOI>  [<ffffffff803eba3b>] ? __lookup_tag+0x8b/0x120
 [<ffffffff803ebb90>] ? radix_tree_gang_lookup_tag_slot+0xc0/0xe0
 [<ffffffff8028519a>] ? find_get_pages_tag+0x4a/0x120
 [<ffffffff8028f0f2>] ? pagevec_lookup_tag+0x22/0x30
 [<ffffffff8028d681>] ? write_cache_pages+0x131/0x460
 [<ffffffff8028cc10>] ? __writepage+0x0/0x50
 [<ffffffff802362fa>] ? complete+0x4a/0x60
 [<ffffffff8028d9cf>] ? generic_writepages+0x1f/0x30
 [<ffffffff803938f4>] ? xfs_vm_writepages+0x54/0x70
 [<ffffffff8028da08>] ? do_writepages+0x28/0x50
 [<ffffffff802dc7b0>] ? __writeback_single_inode+0xa0/0x4c0
 [<ffffffff8024ef2a>] ? del_timer_sync+0x1a/0x30
 [<ffffffff802dd0e9>] ? generic_sync_sb_inodes+0x2d9/0x4b0
 [<ffffffff802dd47e>] ? writeback_inodes+0x4e/0xf0
 [<ffffffff8028e3e0>] ? balance_dirty_pages_ratelimited_nr+0x220/0x330
 [<ffffffff80286649>] ? generic_file_buffered_write+0x1b9/0x310
 [<ffffffff8039ab93>] ? xfs_write+0x6a3/0x9a0
 [<ffffffff80299688>] ? handle_mm_fault+0x1b8/0x7b0
 [<ffffffff80396883>] ? xfs_file_aio_write+0x53/0x60
 [<ffffffff802be451>] ? do_sync_write+0xf1/0x140
 [<ffffffff8025a970>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff803ae8a1>] ? security_file_permission+0x11/0x20
 [<ffffffff802bef1b>] ? vfs_write+0xcb/0x190
 [<ffffffff802bf0d0>] ? sys_write+0x50/0x90
 [<ffffffff8020c2eb>] ? system_call_fastpath+0x16/0x1b

--Boundary-00=_CoD2KDw3DDl7SWJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 99D238D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 12:07:40 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303228009.3171.18.camel@mulgrave.site>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	 <20110418100131.GD8925@tiehlicka.suse.cz>
	 <20110418135637.5baac204.akpm@linux-foundation.org>
	 <20110419111004.GE21689@tiehlicka.suse.cz>
	 <1303228009.3171.18.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 11:07:33 -0500
Message-ID: <1303229253.3171.19.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org

On Tue, 2011-04-19 at 10:46 -0500, James Bottomley wrote:
> On Tue, 2011-04-19 at 13:10 +0200, Michal Hocko wrote:
> > On Mon 18-04-11 13:56:37, Andrew Morton wrote:
> > > On Mon, 18 Apr 2011 12:01:31 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > Currently we have expand_upwards exported while expand_downwards is
> > > > accessible only via expand_stack or expand_stack_downwards.
> > > > 
> > > > check_stack_guard_page is a nice example of the asymmetry. It uses
> > > > expand_stack for VM_GROWSDOWN while expand_upwards is called for
> > > > VM_GROWSUP case.
> > > > 
> > > > Let's clean this up by exporting both functions and make those name
> > > > consistent. Let's use expand_stack_{upwards,downwards} so that we are
> > > > explicit about stack manipulation in the name. expand_stack_downwards
> > > > has to be defined for both CONFIG_STACK_GROWS{UP,DOWN} because
> > > > get_arg_page calls the downwards version in the early process
> > > > initialization phase for growsup configuration.
> > > 
> > > Has this patch been tested on any stack-grows-upwards architecture?
> > 
> > The only one I can find in the tree is parisc and I do not have access
> > to any such machine. Maybe someone on the list (CCed) can help with
> > testing the patch bellow? Nevertheless, the patch doesn't change growsup
> > case. It just renames functions and exports growsdown.
> 
> It compiles OK, but crashes on boot in fsck.  The crash is definitely mm
> but looks to be a slab problem (it's a null deref on a spinlock in
> add_partial(), which seems unrelated to this patch).
> 
> [   15.628000] sd 1:0:2:0: [sdc] Attached SCSI disk
> done.
> [   16.632000] EXT3-fs: barriers not enabled
> [   16.640000] kjournald starting.  Commit interval 5 seconds
> [   16.640000] EXT3-fs (sda3): mounted filesystem with ordered data mode
> Begin: Running /scripts/local-bottom ... done.
> done.
> Begin: Running /scripts/init-bottom ... done.
> INIT: version 2.88 booting
> Setting hostname to 'ion'...done.
> Starting the hotplug events dispatcher: udevd[   22.008000] udev[211]: starting version 164
> .
> Synthesizing the initial hotplug events...done.
> Waiting for /dev to be fully populated...done.
> Activating swap:swapon on /dev/sda2
> swapon: /dev/sda2: found swap signature: version 1, page-size 4, same byte order
> swapon: /dev/sda2: pagesize=4096, swapsize=1028157440, devsize=1028160000
> [   28.780000] Adding 1004056k swap on /dev/sda2.  Priority:-1 extents:1 across:1004056k 
> .
> Will now check root file system:fsck from util-linux-ng 2.17.2
> [/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a -C0 /dev/sda3 
> /dev/sda3 has been mounted 37 times without being checked, check forced.
> [  257.192000] Backtrace:===========                                \ 42.8%   
> [  257.192000]  [<0000000040214f78>] add_partial+0x28/0x98
> [  257.192000]  [<0000000040217ff8>] __slab_free+0x1d0/0x1d8
> [  257.192000]  [<000000004021825c>] kmem_cache_free+0xc4/0x128
> [  257.192000]  [<00000000401fd1a4>] remove_vma+0x8c/0xc0
> [  257.192000]  [<00000000401fd3a8>] exit_mmap+0x1d0/0x220
> [  257.192000]  [<0000000040156514>] mmput+0xd4/0x200
> [  257.192000]  [<000000004015c7b8>] exit_mm+0x100/0x2c0
> [  257.192000]  [<000000004015ef40>] do_exit+0x778/0x9d8
> [  257.192000]  [<000000004015f1ec>] do_group_exit+0x4c/0xe0
> [  257.192000]  [<000000004015f298>] sys_exit_group+0x18/0x28
> [  257.192000]  [<0000000040106034>] syscall_exit+0x0/0x14
> [  257.192000] 
> [  257.192000] 
> [  257.192000] Kernel Fault: Code=26 regs=00000040bf1807d0 (Addr=0000000000000000)
> [  257.192000] 
> [  257.192000]      YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
> [  257.192000] PSW: 00001000000001001111000000001110 Not tainted
> [  257.192000] r00-03  000000ff0804f00e 0000000040769e40 0000000040214f78 0000000000000000
> [  257.192000] r04-07  0000000040746e40 0000000000000001 0000004080ded370 0000000000000001
> [  257.192000] r08-11  0000000040654150 0000000000000000 0000000000000001 0000000000000001
> [  257.192000] r12-15  0000000000000000 00000000ffffffff 0000000000000024 0000000000000000
> [  257.192000] r16-19  00000000fb4ead9c 00000000fb4eac54 0000000000000000 0000000000000000
> [  257.192000] r20-23  000000000800000e 0000000000000001 000000007bbb7180 00000000401fd1a4
> [  257.192000] r24-27  0000000000000001 0000004080ded370 0000000000000000 0000000040746e40
> [  257.192000] r28-31  000000007ec0a908 00000040bf1807a0 00000040bf1807d0 0000000000000016
> [  257.192000] sr00-03  00000000002d9000 0000000000000000 0000000000000000 00000000002d9000
> [  257.192000] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  257.192000] 
> [  257.192000] IASQ: 0000000000000000 0000000000000000 IAOQ: 000000004011bbc0 000000004011bbc4
> [  257.192000]  IIR: 0f4015dc    ISR: 0000000000000000  IOR: 0000000000000000
> [  257.192000]  CPU:        0   CR30: 00000040bf180000 CR31: fffffff0f0e098e0
> [  257.192000]  ORIG_R28: 0000000040769e40
> [  257.192000]  IAOQ[0]: _raw_spin_lock+0x0/0x20
> [  257.192000]  IAOQ[1]: _raw_spin_lock+0x4/0x20
> [  257.192000]  RP(r2): add_partial+0x28/0x98
> [  257.192000] Backtrace:
> [  257.192000]  [<0000000040214f78>] add_partial+0x28/0x98
> [  257.192000]  [<0000000040217ff8>] __slab_free+0x1d0/0x1d8
> [  257.192000]  [<000000004021825c>] kmem_cache_free+0xc4/0x128
> [  257.192000]  [<00000000401fd1a4>] remove_vma+0x8c/0xc0
> [  257.192000]  [<00000000401fd3a8>] exit_mmap+0x1d0/0x220
> [  257.192000]  [<0000000040156514>] mmput+0xd4/0x200
> [  257.192000]  [<000000004015c7b8>] exit_mm+0x100/0x2c0
> [  257.192000]  [<000000004015ef40>] do_exit+0x778/0x9d8
> [  257.192000]  [<000000004015f1ec>] do_group_exit+0x4c/0xe0
> [  257.192000]  [<000000004015f298>] sys_exit_group+0x18/0x28
> [  257.192000]  [<0000000040106034>] syscall_exit+0x0/0x14
> [  257.192000] 
> [  257.192000] Kernel panic - not syncing: Kernel Fault
> [  257.192000] Backtrace:
> [  257.192000]  [<000000004011f984>] show_stack+0x14/0x20
> [  257.192000]  [<000000004011f9a8>] dump_stack+0x18/0x28
> [  257.192000]  [<000000004015946c>] panic+0xd4/0x368
> [  257.192000]  [<0000000040120024>] parisc_terminate+0x14c/0x170
> [  257.192000]  [<000000004012059c>] handle_interruption+0x2ac/0x8f8
> [  257.192000]  [<000000004011bbc0>] _raw_spin_lock+0x0/0x20
> [  257.192000] 
> [  257.192000] Rebooting in 5 seconds..
> 
> It seems to be a random intermittent mm crash because the next reboot
> crashed with the same trace but after the fsck had completed and the
> third came up to the login prompt.

I should add that this crash is with CONFIG_SLUB ... do you want me to
retry with CONFIG_SLAB?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC69C8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:05:29 -0400 (EDT)
Received: by vxk20 with SMTP id 20so6925014vxk.14
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 10:05:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303228009.3171.18.camel@mulgrave.site>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	<20110418100131.GD8925@tiehlicka.suse.cz>
	<20110418135637.5baac204.akpm@linux-foundation.org>
	<20110419111004.GE21689@tiehlicka.suse.cz>
	<1303228009.3171.18.camel@mulgrave.site>
Date: Tue, 19 Apr 2011 20:05:27 +0300
Message-ID: <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Tue, Apr 19, 2011 at 6:46 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> It compiles OK, but crashes on boot in fsck. =A0The crash is definitely m=
m
> but looks to be a slab problem (it's a null deref on a spinlock in
> add_partial(), which seems unrelated to this patch).
>
> [ =A0 15.628000] sd 1:0:2:0: [sdc] Attached SCSI disk
> done.
> [ =A0 16.632000] EXT3-fs: barriers not enabled
> [ =A0 16.640000] kjournald starting. =A0Commit interval 5 seconds
> [ =A0 16.640000] EXT3-fs (sda3): mounted filesystem with ordered data mod=
e
> Begin: Running /scripts/local-bottom ... done.
> done.
> Begin: Running /scripts/init-bottom ... done.
> INIT: version 2.88 booting
> Setting hostname to 'ion'...done.
> Starting the hotplug events dispatcher: udevd[ =A0 22.008000] udev[211]: =
starting version 164
> .
> Synthesizing the initial hotplug events...done.
> Waiting for /dev to be fully populated...done.
> Activating swap:swapon on /dev/sda2
> swapon: /dev/sda2: found swap signature: version 1, page-size 4, same byt=
e order
> swapon: /dev/sda2: pagesize=3D4096, swapsize=3D1028157440, devsize=3D1028=
160000
> [ =A0 28.780000] Adding 1004056k swap on /dev/sda2. =A0Priority:-1 extent=
s:1 across:1004056k
> .
> Will now check root file system:fsck from util-linux-ng 2.17.2
> [/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a -C0 /dev/sda3
> /dev/sda3 has been mounted 37 times without being checked, check forced.
> [ =A0257.192000] Backtrace:=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\ 42.8%
> [ =A0257.192000] =A0[<0000000040214f78>] add_partial+0x28/0x98
> [ =A0257.192000] =A0[<0000000040217ff8>] __slab_free+0x1d0/0x1d8
> [ =A0257.192000] =A0[<000000004021825c>] kmem_cache_free+0xc4/0x128
> [ =A0257.192000] =A0[<00000000401fd1a4>] remove_vma+0x8c/0xc0
> [ =A0257.192000] =A0[<00000000401fd3a8>] exit_mmap+0x1d0/0x220
> [ =A0257.192000] =A0[<0000000040156514>] mmput+0xd4/0x200
> [ =A0257.192000] =A0[<000000004015c7b8>] exit_mm+0x100/0x2c0
> [ =A0257.192000] =A0[<000000004015ef40>] do_exit+0x778/0x9d8
> [ =A0257.192000] =A0[<000000004015f1ec>] do_group_exit+0x4c/0xe0
> [ =A0257.192000] =A0[<000000004015f298>] sys_exit_group+0x18/0x28
> [ =A0257.192000] =A0[<0000000040106034>] syscall_exit+0x0/0x14
> [ =A0257.192000]
> [ =A0257.192000]
> [ =A0257.192000] Kernel Fault: Code=3D26 regs=3D00000040bf1807d0 (Addr=3D=
0000000000000000)
> [ =A0257.192000]
> [ =A0257.192000] =A0 =A0 =A0YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
> [ =A0257.192000] PSW: 00001000000001001111000000001110 Not tainted
> [ =A0257.192000] r00-03 =A0000000ff0804f00e 0000000040769e40 000000004021=
4f78 0000000000000000
> [ =A0257.192000] r04-07 =A00000000040746e40 0000000000000001 0000004080de=
d370 0000000000000001
> [ =A0257.192000] r08-11 =A00000000040654150 0000000000000000 000000000000=
0001 0000000000000001
> [ =A0257.192000] r12-15 =A00000000000000000 00000000ffffffff 000000000000=
0024 0000000000000000
> [ =A0257.192000] r16-19 =A000000000fb4ead9c 00000000fb4eac54 000000000000=
0000 0000000000000000
> [ =A0257.192000] r20-23 =A0000000000800000e 0000000000000001 000000007bbb=
7180 00000000401fd1a4
> [ =A0257.192000] r24-27 =A00000000000000001 0000004080ded370 000000000000=
0000 0000000040746e40
> [ =A0257.192000] r28-31 =A0000000007ec0a908 00000040bf1807a0 00000040bf18=
07d0 0000000000000016
> [ =A0257.192000] sr00-03 =A000000000002d9000 0000000000000000 00000000000=
00000 00000000002d9000
> [ =A0257.192000] sr04-07 =A00000000000000000 0000000000000000 00000000000=
00000 0000000000000000
> [ =A0257.192000]
> [ =A0257.192000] IASQ: 0000000000000000 0000000000000000 IAOQ: 0000000040=
11bbc0 000000004011bbc4
> [ =A0257.192000] =A0IIR: 0f4015dc =A0 =A0ISR: 0000000000000000 =A0IOR: 00=
00000000000000
> [ =A0257.192000] =A0CPU: =A0 =A0 =A0 =A00 =A0 CR30: 00000040bf180000 CR31=
: fffffff0f0e098e0
> [ =A0257.192000] =A0ORIG_R28: 0000000040769e40
> [ =A0257.192000] =A0IAOQ[0]: _raw_spin_lock+0x0/0x20
> [ =A0257.192000] =A0IAOQ[1]: _raw_spin_lock+0x4/0x20
> [ =A0257.192000] =A0RP(r2): add_partial+0x28/0x98
> [ =A0257.192000] Backtrace:
> [ =A0257.192000] =A0[<0000000040214f78>] add_partial+0x28/0x98
> [ =A0257.192000] =A0[<0000000040217ff8>] __slab_free+0x1d0/0x1d8
> [ =A0257.192000] =A0[<000000004021825c>] kmem_cache_free+0xc4/0x128
> [ =A0257.192000] =A0[<00000000401fd1a4>] remove_vma+0x8c/0xc0
> [ =A0257.192000] =A0[<00000000401fd3a8>] exit_mmap+0x1d0/0x220
> [ =A0257.192000] =A0[<0000000040156514>] mmput+0xd4/0x200
> [ =A0257.192000] =A0[<000000004015c7b8>] exit_mm+0x100/0x2c0
> [ =A0257.192000] =A0[<000000004015ef40>] do_exit+0x778/0x9d8
> [ =A0257.192000] =A0[<000000004015f1ec>] do_group_exit+0x4c/0xe0
> [ =A0257.192000] =A0[<000000004015f298>] sys_exit_group+0x18/0x28
> [ =A0257.192000] =A0[<0000000040106034>] syscall_exit+0x0/0x14
> [ =A0257.192000]
> [ =A0257.192000] Kernel panic - not syncing: Kernel Fault
> [ =A0257.192000] Backtrace:
> [ =A0257.192000] =A0[<000000004011f984>] show_stack+0x14/0x20
> [ =A0257.192000] =A0[<000000004011f9a8>] dump_stack+0x18/0x28
> [ =A0257.192000] =A0[<000000004015946c>] panic+0xd4/0x368
> [ =A0257.192000] =A0[<0000000040120024>] parisc_terminate+0x14c/0x170
> [ =A0257.192000] =A0[<000000004012059c>] handle_interruption+0x2ac/0x8f8
> [ =A0257.192000] =A0[<000000004011bbc0>] _raw_spin_lock+0x0/0x20
> [ =A0257.192000]
> [ =A0257.192000] Rebooting in 5 seconds..
>
> It seems to be a random intermittent mm crash because the next reboot
> crashed with the same trace but after the fsck had completed and the
> third came up to the login prompt.

Looks like a genuine SLUB problem on parisc. Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

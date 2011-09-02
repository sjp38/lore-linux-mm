Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 816FE6B016A
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 07:19:41 -0400 (EDT)
From: Christian Casteyde <casteyde.christian@free.fr>
Subject: Re: [Bug 42202] New: Caught 64-bit read from uninitialized memory in kmem_cache_alloc
Date: Fri, 2 Sep 2011 13:19:50 +0200
References: <bug-42202-27@https.bugzilla.kernel.org/> <20110901125045.aba23d9f.akpm@linux-foundation.org>
In-Reply-To: <20110901125045.aba23d9f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201109021319.51382.casteyde.christian@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Vegard Nossum <vegardno@ifi.uio.no>

I indeed use SLUB allocator.=20
I didn't managed to get the same call stack (no page fault) after rebooting=
,=20
but I'm wondering if it's a dup of=20
https://bugzilla.kernel.org/show_bug.cgi?id=3D36512

In this case this may not be a regression.
CC

Le jeudi 1 septembre 2011 21:50:45, Andrew Morton a =E9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>=20
> On Thu, 1 Sep 2011 17:15:00 GMT
>=20
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42202
> >=20
> >            Summary: Caught 64-bit read from uninitialized memory in
> >           =20
> >                     kmem_cache_alloc
>=20
> I'm really struggling with this one.
>=20
> >            Product: Memory Management
> >            Version: 2.5
> >    =20
> >     Kernel Version: 3.1-rc4
> >    =20
> >           Platform: All
> >        =20
> >         OS/Version: Linux
> >        =20
> >               Tree: Mainline
> >            =20
> >             Status: NEW
> >          =20
> >           Severity: normal
> >           Priority: P1
> >         =20
> >          Component: Page Allocator
> >        =20
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: casteyde.christian@free.fr
> >         Regression: Yes
> >=20
> > Acer Aspire 7750G
> > Core i7 in 64bits mode
> > Slackware64 13.37
> > kmemcheck configured
> >=20
> > Since 3.1-rc4, I have the following warning at boot:
> >=20
> > udev[1745]: renamed network interface eth0 to eth1
> > udev[1699]: renamed network interface wlan0-eth0 to eth0
> > WARNING: kmemcheck: Caught 64-bit read from uninitialized memory
> > (ffff8801c11865d0)
> > 000110000000adde000220000000addee06d18c10188ffff403d27c20188ffff
> >=20
> >  f f f f f f f f f f f f f f f f u u u u u u u u u u u u u u u u
> > =20
> >                                  ^
> >=20
> > Pid: 1700, comm: udevd Tainted: G        W   3.1.0-rc4 #13 Acer Aspire
> > 7750G/JE70_HR
> > RIP: 0010:[<ffffffff8111aea6>]  [<ffffffff8111aea6>]
> > kmem_cache_alloc+0x66/0x120
> > RSP: 0018:ffff8801c2103b38  EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: ffff8801c23f6d10 RCX: 0000000000062720
> > RDX: 0000000000062718 RSI: 00000000001d43a0 RDI: 00000000000000d0
> > RBP: ffff8801c2103b68 R08: ffff8801c2109300 R09: 0000000000000001
> > R10: ffff8801c2109300 R11: 0000000000000000 R12: ffff8801c11865d0
> > R13: ffff8801c7414400 R14: 00000000000000d0 R15: ffffffff8110519f
> > FS:  00007fec4c108720(0000) GS:ffff8801c7800000(0000)
> > knlGS:0000000000000000 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: ffff8801c604a0b0 CR3: 00000001c20f9000 CR4: 00000000000406f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> >=20
> >  [<ffffffff8110519f>] anon_vma_prepare+0x5f/0x190
> >  [<ffffffff810fb0b6>] handle_pte_fault+0x576/0x790
> >  [<ffffffff810fc5ff>] handle_mm_fault+0x11f/0x1c0
> >  [<ffffffff810575d2>] do_page_fault+0x142/0x490
> >  [<ffffffff817db57f>] page_fault+0x1f/0x30
> >  [<ffffffff811858a0>] sysfs_read_file+0xf0/0x1a0
> >  [<ffffffff8112166a>] vfs_read+0xaa/0x160
> >  [<ffffffff81121768>] sys_read+0x48/0x90
> >  [<ffffffff817dbabb>] system_call_fastpath+0x16/0x1b
> >  [<ffffffffffffffff>] 0xffffffffffffffff
> >=20
> > Adding 2097148k swap on /dev/sda1.  Priority:-1 extents:1 across:209714=
8k
> > EXT4-fs (sda2): re-mounted. Opts: (null)
> >=20
> > I do not know if it occurs with previous rc of 3.1, but I don't have it
> > with 3.0.
>=20
> It seems to be saying that the read occurred within kmem_cache_alloc().
>=20
> Or is the stack trace off-by-one, and the read is occurring in
> anon_vma_prepare()?
>=20
> Could you please take a look at the very nice
> Documentation/kmemcheck.txt and use the info in there to work out the
> exact file and line where the read is occurring?  The "addr2line"
> operation.
>=20
> I'm having trojuble working out if your kernel is using slab or slub.
> This happens to me quite often.  Pekka, perhaps we should add this info
> to the "Pid: 1700, comm: udevd Tainted: G W 3.1.0-rc4 #13 Acer Aspire"
> line.  Or remove a few of our sl*b implementations...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

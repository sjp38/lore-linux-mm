Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0CB026B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:13:54 -0400 (EDT)
Message-ID: <1340838807.10063.90.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 01:13:27 +0200
In-Reply-To: <1340838154.10063.86.camel@twins>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 01:02 +0200, Peter Zijlstra wrote:
> On Wed, 2012-06-27 at 15:26 -0700, Linus Torvalds wrote:
> > On Wed, Jun 27, 2012 at 2:15 PM, Peter Zijlstra <a.p.zijlstra@chello.nl=
> wrote:
> > > This originated from s390 which does something similar and would allo=
w
> > > s390 to use the generic TLB flushing code.
> > >
> > > The idea is to flush the mm wide cache and tlb a priory and not bothe=
r
> > > with multiple flushes if the batching isn't large enough.
> > >
> > > This can be safely done since there cannot be any concurrency on this
> > > mm, its either after the process died (exit) or in the middle of
> > > execve where the thread switched to the new mm.
> >=20
> > I think we actually *used* to do the final TLB flush from within the
> > context of the process that died. That doesn't seem to ever be the
> > case any more, but it does worry me a bit. Maybe a
> >=20
> >    VM_BUG_ON(current->active_mm =3D=3D mm);
> >=20
> > or something for the fullmm case?
>=20
> OK, added it and am rebooting the test box..

That triggered.. is this a problem though, at this point userspace is
very dead so it shouldn't matter, right?

Will have to properly think about it tomorrow, its been 1am, brain is
mostly sleeping already.

------------[ cut here ]------------
kernel BUG at /home/root/src/linux-2.6/mm/memory.c:221!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in:
CPU 13=20
Pid: 132, comm: modprobe Not tainted 3.5.0-rc4-01507-g912ca15-dirty #180 Su=
permicro X8DTN/X8DTN
RIP: 0010:[<ffffffff811511bf>]  [<ffffffff811511bf>] tlb_gather_mmu+0x9f/0x=
b0
RSP: 0018:ffff880235b2bd78  EFLAGS: 00010246
RAX: ffff880235b18000 RBX: ffff880235b2bdc0 RCX: ffff880235b18000
RDX: 0000000000000000 RSI: 0000000000000100 RDI: 0000000000000000
RBP: ffff880235b2bd98 R08: 0000000000000018 R09: 0000000000000004
R10: ffffffff81eedfc0 R11: 0000000000000084 R12: ffff8804356b8000
R13: 0000000000000001 R14: ffff880235b185f0 R15: ffff880235b18000
FS:  0000000000000000(0000) GS:ffff880237ce0000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000038ce8ae150 CR3: 0000000436ad6000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 132, threadinfo ffff880235b2a000, task ffff880235b18=
000)
Stack:
 ffff880235b2bd98 0000000000000000 ffff8804356b8000 ffff8804356b8060
 ffff880235b2be38 ffffffff8115ad38 ffff880235b2be38 ffff880235b4e000
 ffff880235b4e630 ffff8804356b8000 0000000100000000 ffff880235b2bdd8
Call Trace:
 [<ffffffff8115ad38>] exit_mmap+0x98/0x150
 [<ffffffff810bf98e>] ? exit_numa+0xae/0xe0
 [<ffffffff81078b74>] mmput+0x84/0x120
 [<ffffffff81080ce8>] exit_mm+0x108/0x130
 [<ffffffff81081388>] do_exit+0x678/0x950
 [<ffffffff811a3ad6>] ? alloc_fd+0xd6/0x120
 [<ffffffff811791c0>] ? kmem_cache_free+0x20/0x130
 [<ffffffff810819af>] do_group_exit+0x3f/0xa0
 [<ffffffff81081a27>] sys_exit_group+0x17/0x20
 [<ffffffff81980ed2>] system_call_fastpath+0x16/0x1b
Code: 10 74 1a 65 48 8b 04 25 80 ba 00 00 4c 3b a0 90 02 00 00 74 16 4c 89 =
e7 e8 5f 39 f2 ff 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 <0f> 0b 66 66 6=
6 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5=20
RIP  [<ffffffff811511bf>] tlb_gather_mmu+0x9f/0xb0
 RSP <ffff880235b2bd78>
---[ end trace f99f121b09c974f8 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

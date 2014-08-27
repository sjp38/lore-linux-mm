Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id C1FBD6B0039
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:26:29 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id w7so674336lbi.16
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:26:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rx10si1040488lbb.76.2014.08.27.08.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 08:26:27 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:26:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140827152622.GC12424@suse.de>
References: <53DD5F20.8010507@oracle.com>
 <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
 <20140805144439.GW10819@suse.de>
 <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
 <53E17F06.30401@oracle.com>
 <53E989FB.5000904@oracle.com>
 <53FD4D9F.6050500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53FD4D9F.6050500@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Tue, Aug 26, 2014 at 11:16:47PM -0400, Sasha Levin wrote:
> On 08/11/2014 11:28 PM, Sasha Levin wrote:
> > On 08/05/2014 09:04 PM, Sasha Levin wrote:
> >> > Thanks Hugh, Mel. I've added both patches to my local tree and will update tomorrow
> >> > with the weather.
> >> > 
> >> > Also:
> >> > 
> >> > On 08/05/2014 08:42 PM, Hugh Dickins wrote:
> >>> >> One thing I did wonder, though: at first I was reassured by the
> >>> >> VM_BUG_ON(!pte_present(pte)) you add to pte_mknuma(); but then thought
> >>> >> it would be better as VM_BUG_ON(!(val & _PAGE_PRESENT)), being stronger
> >>> >> - asserting that indeed we do not put NUMA hints on PROT_NONE areas.
> >>> >> (But I have not tested, perhaps such a VM_BUG_ON would actually fire.)
> >> > 
> >> > I've added VM_BUG_ON(!(val & _PAGE_PRESENT)) in just as a curiosity, I'll
> >> > update how that one looks as well.
> > Sorry for the rather long delay.
> > 
> > The patch looks fine, the issue didn't reproduce.
> > 
> > The added VM_BUG_ON didn't trigger either, so maybe we should consider adding
> > it in.
> 
> It took a while, but I've managed to hit that VM_BUG_ON:
> 
> [  707.975456] kernel BUG at include/asm-generic/pgtable.h:724!
> [  707.977147] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  707.978974] Dumping ftrace buffer:
> [  707.980110]    (ftrace buffer empty)
> [  707.981221] Modules linked in:
> [  707.982312] CPU: 18 PID: 9488 Comm: trinity-c538 Not tainted 3.17.0-rc2-next-20140826-sasha-00031-gc48c9ac-dirty #1079
> [  707.982801] task: ffff880165e28000 ti: ffff880165e30000 task.ti: ffff880165e30000
> [  707.982801] RIP: 0010:[<ffffffffb42e3dda>]  [<ffffffffb42e3dda>] change_protection_range+0x94a/0x970
> [  707.982801] RSP: 0018:ffff880165e33d98  EFLAGS: 00010246
> [  707.982801] RAX: 000000009d340902 RBX: ffff880511204a08 RCX: 0000000000000100
> [  707.982801] RDX: 000000009d340902 RSI: 0000000041741000 RDI: 000000009d340902
> [  707.982801] RBP: ffff880165e33e88 R08: ffff880708a23c00 R09: 0000000000b52000
> [  707.982801] R10: 0000000000001e01 R11: 0000000000000008 R12: 0000000041751000
> [  707.982801] R13: 00000000000000f7 R14: 000000009d340902 R15: 0000000041741000
> [  707.982801] FS:  00007f358a9aa700(0000) GS:ffff88071c600000(0000) knlGS:0000000000000000
> [  707.982801] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  707.982801] CR2: 00007f3586b69490 CR3: 0000000165d88000 CR4: 00000000000006a0
> [  707.982801] Stack:
> [  707.982801]  ffff8804db88d058 0000000000000000 ffff88070fb17cf0 0000000000000000
> [  707.982801]  ffff880165d88000 0000000000000000 ffff8801686a5000 000000004163e000
> [  707.982801]  ffff8801686a5000 0000000000000001 0000000000000025 0000000041750fff
> [  707.982801] Call Trace:
> [  707.982801]  [<ffffffffb42e3e14>] change_protection+0x14/0x30
> [  707.982801]  [<ffffffffb42fda3b>] change_prot_numa+0x1b/0x40
> [  707.982801]  [<ffffffffb41ad766>] task_numa_work+0x1f6/0x330
> [  707.982801]  [<ffffffffb41937c4>] task_work_run+0xc4/0xf0
> [  707.982801]  [<ffffffffb40712e7>] do_notify_resume+0x97/0xb0
> [  707.982801]  [<ffffffffb74fd6ea>] int_signal+0x12/0x17
> [  707.982801] Code: e8 2c 84 21 03 e9 72 ff ff ff 0f 1f 80 00 00 00 00 0f 0b 48 8b 7d a8 4c 89 f2 4c 89 fe e8 9f 7b 03 00 e9 47 f9 ff ff 0f 0b 0f 0b <0f> 0b 0f 0b 48 8b b5 70 ff ff ff 4c 89 ea 48 89 c7 e8 10 d5 01
> [  707.982801] RIP  [<ffffffffb42e3dda>] change_protection_range+0x94a/0x970
> [  707.982801]  RSP <ffff880165e33d98>
> 

The tests to reach here are

pte_present     any of  _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_NUMA
pte_numa        only    _PAGE_NUMA out of _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_NUMA
VM_BUG_ON	not set _PAGE_PRESENT

To trigger the bug the PTE bits must then be _PAGE_PROTNONE | _PAGE_NUMA. The
NUMA PTE scanner is skipping PROT_NONE VMAs so it should be "impossible"
for it to be set there. The mmap_sem is held for read during scans so
the protections should not be altering underneath us and the PTL is held
against parallel faults.

That leaves setting prot_none leaveing _PAGE_NUMA behind. Potentially
that's an issue due to

/* Set of bits not changed in pte_modify */
#define _PAGE_CHG_MASK  (PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT | \
                         _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY | \
                         _PAGE_SOFT_DIRTY | _PAGE_NUMA)

The _PAGE_NUMA bit is not cleared as removing it potentially leaves the
PTE in an unexpected state due to a "present" PTE marked for NUMA hinting
fault becoming non-present. Instead there is this check in change_pte_range()
to move PTEs to a known state before changing protections

                                if (pte_numa(ptent))
                                        ptent = pte_mknonnuma(ptent);
                                ptent = pte_modify(ptent, newprot);

So right now, I'm not seeing what path gets us to this inconsistent
state. Sasha, how long does it typically take to trigger this? Are you
using any particular switches for trinity that would trigger the bug
faster?

This untested patch might help pinpoint the source of the corruption
early though it's x86 only

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 281870f..ffea570 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -723,6 +723,9 @@ static inline pte_t pte_mknuma(pte_t pte)
 
 	VM_BUG_ON(!(val & _PAGE_PRESENT));
 
+	/* debugging only, specific to x86 */
+	VM_BUG_ON(val & _PAGE_PROTNONE);
+
 	val &= ~_PAGE_PRESENT;
 	val |= _PAGE_NUMA;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

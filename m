From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm:  kernel BUG at mm/huge_memory.c:1371!
Date: Thu, 10 Apr 2014 13:37:27 +0300
Message-ID: <20140410103727.GA24354@node.dhcp.inet.fi>
References: <5307D74C.5070002@oracle.com>
 <20140221235145.GA18046@node.dhcp.inet.fi>
 <5307F90C.9060602@oracle.com>
 <5310C56C.60709@oracle.com>
 <53446261.9070903@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53446261.9070903@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Tue, Apr 08, 2014 at 04:56:01PM -0400, Sasha Levin wrote:
> On 02/28/2014 12:20 PM, Sasha Levin wrote:
> > On 02/21/2014 08:10 PM, Sasha Levin wrote:
> >> On 02/21/2014 06:51 PM, Kirill A. Shutemov wrote:
> >>> On Fri, Feb 21, 2014 at 05:46:36PM -0500, Sasha Levin wrote:
> >>>> >Hi all,
> >>>> >
> >>>> >While fuzzing with trinity inside a KVM tools guest running latest -next
> >>>> >kernel I've stumbled on the following (now with pretty line numbers!) spew:
> >>>> >
> >>>> >[  746.125099] kernel BUG at mm/huge_memory.c:1371!
> >>> It "VM_BUG_ON_PAGE(!PageHead(page), page);", correct?
> >>> I don't see dump_page() output.
> >>
> >> Right. However, I'm not seeing the dump_page() output in the log.
> >>
> >> I see that dump_page() has been modified not long ago, I'm looking into it.
> > 
> > Alright, here we go:
> > 
> > [ 3323.062742] page:ffffea00080f0000 count:3 mapcount:0 mapping:ffff8802292ee0e1 index:0x7fa2e6800
> > [ 3323.065978] page flags: 0x16fffff80090018(uptodate|dirty|swapcache|swapbacked)
> > [ 3323.068535] ------------[ cut here ]------------
> > [ 3323.069669] kernel BUG at mm/huge_memory.c:1371!
> > [ 3323.070961] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [ 3323.071028] Dumping ftrace buffer:
> > [ 3323.071028]    (ftrace buffer empty)
> > [ 3323.071028] Modules linked in:
> > [ 3323.071028] CPU: 101 PID: 48284 Comm: trinity-c101 Tainted: G        W 3.14.0-rc4-next-20140228-sasha-00011-g4077c67 #25
> > [ 3323.071028] task: ffff8800c2718000 ti: ffff8800c26ec000 task.ti: ffff8800c26ec000
> > [ 3323.071028] RIP: 0010:[<ffffffff812c083a>]  [<ffffffff812c083a>] zap_huge_pmd+0x17a/0x200
> > [ 3323.071028] RSP: 0018:ffff8800c26edc78  EFLAGS: 00010246
> > [ 3323.071028] RAX: ffff88022febc000 RBX: ffff8800c26edde8 RCX: 0000000000000040
> > [ 3323.071028] RDX: 0000000000000000 RSI: ffff8800c2718cc0 RDI: 000000000203c000
> > [ 3323.071028] RBP: ffff8800c26edcb8 R08: 0000000000000000 R09: 0000000000000000
> > [ 3323.071028] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0008b9e240
> > [ 3323.071028] R13: ffffea00080f0000 R14: 00007fa2e6800000 R15: 00007fa2ffffffff
> > [ 3323.071028] FS:  00007fa31e1b8700(0000) GS:ffff880230600000(0000) knlGS:0000000000000000
> > [ 3323.071028] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 3323.071028] CR2: 00007fa31e1e8990 CR3: 0000000005c25000 CR4: 00000000000006e0
> > [ 3323.071028] DR0: 0000000000698000 DR1: 0000000000698000 DR2: 0000000000698000
> > [ 3323.071028] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> > [ 3323.071028] Stack:
> > [ 3323.071028]  00000000000004de ffff88022e2139d0 ffff8800c26edcb8 ffff88021b7ef9a0
> > [ 3323.071028]  00007fa2e6800000 00007fa300000000 ffff8800c26edde8 00007fa2ffffffff
> > [ 3323.071028]  ffff8800c26edd48 ffffffff812800c6 ffffea0008454540 00007fa2e6a00000
> > [ 3323.071028] Call Trace:
> > [ 3323.071028]  [<ffffffff812800c6>] unmap_page_range+0x2c6/0x410
> > [ 3323.071028]  [<ffffffff81280301>] unmap_single_vma+0xf1/0x110
> > [ 3323.071028]  [<ffffffff81280381>] unmap_vmas+0x61/0xa0
> > [ 3323.071028]  [<ffffffff812875e0>] exit_mmap+0xd0/0x170
> > [ 3323.071028]  [<ffffffff811387a7>] mmput+0x77/0xe0
> > [ 3323.071028]  [<ffffffff8113c80d>] exit_mm+0x18d/0x1a0
> > [ 3323.071028]  [<ffffffff811ecea5>] ? acct_collect+0x175/0x1b0
> > [ 3323.071028]  [<ffffffff8113ec1a>] do_exit+0x26a/0x510
> > [ 3323.071028]  [<ffffffff8113ef61>] do_group_exit+0xa1/0xe0
> > [ 3323.071028]  [<ffffffff8113efb2>] SyS_exit_group+0x12/0x20
> > [ 3323.071028]  [<ffffffff8439f720>] tracesys+0xdd/0xe2
> > [ 3323.071028] Code: 00 eb fe 66 0f 1f 44 00 00 48 8b 03 f0 48 81 80 60 03 00 00 00 fe ff ff 49 8b 45 00 f6 c4 40 75 18 31 f6 4c 89 ef e8 f6 1f f9 ff <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 48 8b 03 f0 48 ff 48
> > [ 3323.071028] RIP  [<ffffffff812c083a>] zap_huge_pmd+0x17a/0x200
> > [ 3323.071028]  RSP <ffff8800c26edc78>
> 
> This is still happening in -next. Anything else I can provide that'll be useful?

I don't know... :(

One theory I have is that the root cause of the bug is the same as with
mm/huge_memory.c:1829 bug. If the compound page has been split but we miss
the vma where PMD should be split, then we could see the effect. It could
happend due anon_vma_interval_tree_foreach() vs.
anon_vma_interval_tree_insert() race or something else.

-- 
 Kirill A. Shutemov

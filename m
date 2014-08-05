Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B180E6B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 10:51:50 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so1137427wgg.7
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 07:51:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jd16si5084622wic.83.2014.08.05.07.44.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 07:45:15 -0700 (PDT)
Date: Tue, 5 Aug 2014 15:44:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140805144439.GW10819@suse.de>
References: <53DD5F20.8010507@oracle.com>
 <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="XvKFcGCOAo53UbWW"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>


--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Mon, Aug 04, 2014 at 04:40:38AM -0700, Hugh Dickins wrote:
> On Sat, 2 Aug 2014, Sasha Levin wrote:
> 
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> > kernel, I've stumbled on the following spew:
> > 
> > [ 2957.087977] BUG: unable to handle kernel paging request at ffffea0003480008
> > [ 2957.088008] IP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
> > [ 2957.088024] PGD 7fffc6067 PUD 7fffc5067 PMD 0
> > [ 2957.088041] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [ 2957.088087] Dumping ftrace buffer:
> > [ 2957.088266]    (ftrace buffer empty)
> > [ 2957.088279] Modules linked in:
> > [ 2957.088293] CPU: 2 PID: 15417 Comm: trinity-c200 Not tainted 3.16.0-rc7-next-20140801-sasha-00047-gd6ce559 #990
> > [ 2957.088301] task: ffff8807a8c50000 ti: ffff880739fb4000 task.ti: ffff880739fb4000
> > [ 2957.088320] RIP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
> > [ 2957.088328] RSP: 0018:ffff880739fb7c58  EFLAGS: 00010246
> > [ 2957.088336] RAX: 0000000000000000 RBX: ffff880eb2bdbed8 RCX: dfff971b42800000
> > [ 2957.088343] RDX: 1ffff100e73f6fc4 RSI: 00007f00e85db000 RDI: ffffea0003480008
> > [ 2957.088350] RBP: ffff880739fb7d58 R08: 0000000000000001 R09: 0000000000b6e000
> > [ 2957.088357] R10: 0000000000000000 R11: 0000000000000001 R12: ffffea0003480000
> > [ 2957.088365] R13: 00000000d2000700 R14: 00007f00e85dc000 R15: 00007f00e85db000
> > [ 2957.088374] FS:  00007f00e85d8700(0000) GS:ffff88177fa00000(0000) knlGS:0000000000000000
> > [ 2957.088381] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [ 2957.088387] CR2: ffffea0003480008 CR3: 00000007a802a000 CR4: 00000000000006a0
> > [ 2957.088406] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [ 2957.088413] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> > [ 2957.088416] Stack:
> > [ 2957.088432]  ffff88171726d570 0000000000000010 0000000000000008 00000000d2000730
> > [ 2957.088450]  0000000019d00250 00007f00e85dc000 ffff880f9d311900 ffff880739fb7e20
> > [ 2957.088466]  ffff8807a8c507a0 ffff8807a8c50000 ffff8807a75fe000 ffff8807ceaa7a10
> > [ 2957.088469] Call Trace:
> > [ 2957.088490] unmap_single_vma (mm/memory.c:1348)
> > [ 2957.088505] unmap_vmas (mm/memory.c:1375 (discriminator 3))
> > [ 2957.088520] unmap_region (mm/mmap.c:2386 (discriminator 4))
> > [ 2957.088542] ? vma_rb_erase (mm/mmap.c:454 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:493)
> > [ 2957.088559] ? vmacache_update (mm/vmacache.c:61)
> > [ 2957.088572] do_munmap (mm/mmap.c:2581)
> > [ 2957.088583] vm_munmap (mm/mmap.c:2596)
> > [ 2957.088595] SyS_munmap (mm/mmap.c:2601)
> > [ 2957.088616] tracesys (arch/x86/kernel/entry_64.S:541)
> > [ 2957.088770] Code: ff ff e8 f9 5f 07 00 48 8b 45 90 80 48 18 01 4d 85 e4 0f 84 8b fe ff ff 45 84 ed 0f 85 fc 03 00 00 49 8d 7c 24 08 e8 b5 67 07 00 <41> f6 44 24 08 01 0f 84 29 02 00 00 83 6d c8 01 4c 89 e7 e8 bd
> > All code
> > ========
> >    0:	ff                   	(bad)
> >    1:	ff e8                	ljmpq  *<internal disassembler error>
> >    3:	f9                   	stc
> >    4:	5f                   	pop    %rdi
> >    5:	07                   	(bad)
> >    6:	00 48 8b             	add    %cl,-0x75(%rax)
> >    9:	45 90                	rex.RB xchg %eax,%r8d
> >    b:	80 48 18 01          	orb    $0x1,0x18(%rax)
> >    f:	4d 85 e4             	test   %r12,%r12
> >   12:	0f 84 8b fe ff ff    	je     0xfffffffffffffea3
> >   18:	45 84 ed             	test   %r13b,%r13b
> >   1b:	0f 85 fc 03 00 00    	jne    0x41d
> >   21:	49 8d 7c 24 08       	lea    0x8(%r12),%rdi
> >   26:	e8 b5 67 07 00       	callq  0x767e0
> >   2b:*	41 f6 44 24 08 01    	testb  $0x1,0x8(%r12)		<-- trapping instruction
> >   31:	0f 84 29 02 00 00    	je     0x260
> >   37:	83 6d c8 01          	subl   $0x1,-0x38(%rbp)
> >   3b:	4c 89 e7             	mov    %r12,%rdi
> >   3e:	e8                   	.byte 0xe8
> >   3f:	bd                   	.byte 0xbd
> 
> This differs in which functions got inlined (unmap_page_range showing up
> in place of zap_pte_range), but this is the same "if (PageAnon(page))"
> that Sasha reported in the "hang in shmem_fallocate" thread on June 26th.
> 
> I can see what it is now, and here is most of a patch (which I don't
> expect to satisfy Trinity yet); at this point I think I had better
> hand it over to Mel, to complete or to discard.
> 
> [INCOMPLETE PATCH] x86,mm: fix pte_special versus pte_numa
> 
> Sasha Levin has shown oopses on ffffea0003480048 and ffffea0003480008
> at mm/memory.c:1132, running Trinity on different 3.16-rc-next kernels:
> where zap_pte_range() checks page->mapping to see if PageAnon(page).
> 
> Those addresses fit struct pages for pfns d2001 and d2000, and in each
> dump a register or a stack slot showed d2001730 or d2000730: pte flags
> 0x730 are PCD ACCESSED PROTNONE SPECIAL IOMAP; and Sasha's e820 map has
> a hole between cfffffff and 100000000, which would need special access.
> 
> Commit c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on
> the PMD and PTE levels") has broken vm_normal_page(): a PROTNONE SPECIAL
> pte no longer passes the pte_special() test, so zap_pte_range() goes on
> to try to access a non-existent struct page.
> 

:(

> Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
> to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).
> 
> It's unclear why c46a7c817e66 added pte_numa() test to vm_normal_page(),
> and moved its is_zero_pfn() test from slow to fast path: I suspect both
> were papering over PROT_NONE issues seen with inadequate pte_special().
> Revert vm_normal_page() to how it was before, relying on pte_special().
> 

Rather than answering directly I updated your changelog

    Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
    to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).

    A hint that this was a problem was that c46a7c817e66 added pte_numa()
    test to vm_normal_page(), and moved its is_zero_pfn() test from slow to
    fast path: This was papering over a pte_special() snag when the zero
    page was encountered during zap. This patch reverts vm_normal_page()
    to how it was before, relying on pte_special().

> I find it confusing, that the only example of ARCH_USES_NUMA_PROT_NONE
> no longer uses PROTNONE for NUMA, but SPECIAL instead: update the
> asm-generic comment a little, but that config option remains unhelpful.
> 

ARCH_USES_NUMA_PROT_NONE should have been sent to the farm at the same time
as that patch and by rights unified with the powerpc helpers. With the new
_PAGE_NUMA bit, there is no reason they should have different implementations
of pte_numa and related functions. Unfortunately unifying them is a little
problematic due to differences in fundamental types. It could be done with
#defines but I'm attaching a preliminary prototype to illustrate the issue.

> But more seriously, I think this patch is incomplete: aren't there
> other places which need to be handling PROTNONE along with PRESENT?
> For example, pte_mknuma() clears _PAGE_PRESENT and sets _PAGE_NUMA,
> but on a PROT_NONE area, I think that will now make it pte_special()?
> So it ought to clear _PAGE_PROTNONE too.  Or maybe we can never
> pte_mknuma() on a PROT_NONE area - there would be no point?
> 

We are depending on the fact that inaccessible VMAs are skipped by the
NUMA hinting scanner.

> Around here I began to wonder if it was just a mistake to have deserted
> the PROTNONE for NUMA model: I know Linus had a strong reaction against
> it, and I've never delved into its drawbacks myself; but bringing yet
> another (SPECIAL) flag into the game is not an obvious improvement.
> Should we just revert c46a7c817e66, or would that be a mistake?
> 

It's replacing one type of complexity with another. The downside is that
_PAGE_NUMA == _PAGE_PROTNONE puts subtle traps all over the core for
powerpc to fall foul of.

I'm attaching a preliminary pair of patches. The first which deals with
ARCH_USES_NUMA_PROT_NONE and the second which is yours with a revised
changelog. I'm adding Aneesh to the cc to look at the powerpc portion of
the first patch.

-- 
Mel Gorman
SUSE Labs

--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=0001


--XvKFcGCOAo53UbWW--

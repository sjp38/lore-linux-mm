Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0EE6B039F
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 13:43:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p20so149041759pgd.21
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 10:43:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b23si14879789pgn.323.2017.04.03.10.43.26
        for <linux-mm@kvack.org>;
        Mon, 03 Apr 2017 10:43:27 -0700 (PDT)
Date: Mon, 3 Apr 2017 18:43:04 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Bad page state splats on arm64, v4.11-rc{3,4}
Message-ID: <20170403174304.GH18905@leverpostej>
References: <20170331175845.GE6488@leverpostej>
 <20170403105629.GB18905@leverpostej>
 <20170403113751.GD5706@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403113751.GD5706@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, catalin.marinas@arm.com, punit.agrawal@arm.com

On Mon, Apr 03, 2017 at 12:37:51PM +0100, Will Deacon wrote:
> On Mon, Apr 03, 2017 at 11:56:29AM +0100, Mark Rutland wrote:
> > On Fri, Mar 31, 2017 at 06:58:45PM +0100, Mark Rutland wrote:
> > > Hi,
> > > 
> > > I'm seeing intermittent bad page state splats on arm64 with 4.11-rc3 and
> > > v4.11-rc4. I have not tested earlier kernels, or other architectures.
> > > 
> > > So far, it looks like the flags are always bad in the same
> > > way:
> > > 
> > > 	bad because of flags: 0x80(waiters)
> > > 
> > > ... though I don't know if that's definitely the case for splat 4, the
> > > BUG at mm/page_alloc.c:800.
> > > 
> > > I see this in QEMU VMs launched by Syzkaller, triggering once every few
> > > hours. So far, I have not been able to reproduce the issue in any other
> > > way (including using syz-repro).
> > 
> > It looks like this may be an issue with the arm64 HUGETLB code.
> > 
> > I wasn't able to trigger the issue over the weekend on a kernel with
> > HUGETLBFS disabled. There are known issues with our handling of
> > contiguous entries, and this might be an artefact of that.
> 
> After chatting with Punit, it looks like this might be because the GUP
> code doesn't handle huge ptes (which we create using the contiguous hint),
> so follow_page_pte ends up with one of those and goes wrong. In particular,
> the migration code will certainly do the wrong thing.
> 
> I'll probably revert the contiguous support (again) if testing indicates
> that it makes this issue disappear.

FWIW, with contiguous support reverted, I've just seen the issue; splat below.

Regardless, I'm testing with 4K page, and I'm not overriding the hugepage size
at boot time. So the only hugepage size registered should be 2M, IIUC.

Thanks,
Mark.

BUG: Bad page state in process syz-executor0  pfn:77200
page:ffff7e0000dc8000 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x4fffc00000000080(waiters)
raw: 4fffc00000000080 0000000000000000 0000000000000000 00000000ffffffff
raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
page dumped because: PAGE_FLAGS_CHECK_AT_PREP flag set
bad because of flags: 0x80(waiters)
Modules linked in:
CPU: 3 PID: 1317 Comm: syz-executor0 Not tainted 4.11.0-rc4-00002-g34b0849 #3
Hardware name: linux,dummy-virt (DT)
Call trace:
[<ffff200008094778>] dump_backtrace+0x0/0x538 arch/arm64/kernel/traps.c:73
[<ffff200008094cd0>] show_stack+0x20/0x30 arch/arm64/kernel/traps.c:228
[<ffff200008c18328>] __dump_stack lib/dump_stack.c:16 [inline]
[<ffff200008c18328>] dump_stack+0x120/0x188 lib/dump_stack.c:52
[<ffff200008432c38>] bad_page+0x1d8/0x2e8 mm/page_alloc.c:555
[<ffff200008433048>] check_new_page_bad+0xf8/0x200 mm/page_alloc.c:1682
[<ffff20000843f4e0>] check_new_pcp mm/page_alloc.c:1694 [inline]
[<ffff20000843f4e0>] __rmqueue_pcplist mm/page_alloc.c:2668 [inline]
[<ffff20000843f4e0>] rmqueue_pcplist+0x768/0xde0 mm/page_alloc.c:2686
[<ffff200008443ab8>] rmqueue mm/page_alloc.c:2708 [inline]
[<ffff200008443ab8>] get_page_from_freelist+0xdb0/0x2298 mm/page_alloc.c:3046
[<ffff200008445f8c>] __alloc_pages_nodemask+0x1f4/0x1b10 mm/page_alloc.c:3965
[<ffff200008562624>] alloc_pages_current+0x144/0x4d8 mm/mempolicy.c:2069
[<ffff2000085210a8>] alloc_pages include/linux/gfp.h:462 [inline]
[<ffff2000085210a8>] __vmalloc_area_node mm/vmalloc.c:1690 [inline]
[<ffff2000085210a8>] __vmalloc_node_range+0x3b8/0x7c0 mm/vmalloc.c:1751
[<ffff200008521584>] __vmalloc_node mm/vmalloc.c:1794 [inline]
[<ffff200008521584>] vmalloc_user+0x5c/0x140 mm/vmalloc.c:1857
[<ffff2000083b3de0>] kcov_mmap+0x38/0x1a8 kernel/kcov.c:150
[<ffff2000085028b8>] call_mmap include/linux/fs.h:1738 [inline]
[<ffff2000085028b8>] mmap_region+0x800/0x1060 mm/mmap.c:1675
[<ffff200008503814>] do_mmap+0x6fc/0x930 mm/mmap.c:1453
[<ffff20000849b8cc>] do_mmap_pgoff include/linux/mm.h:2121 [inline]
[<ffff20000849b8cc>] vm_mmap_pgoff+0x164/0x1b0 mm/util.c:309
[<ffff2000084fb304>] SYSC_mmap_pgoff mm/mmap.c:1503 [inline]
[<ffff2000084fb304>] SyS_mmap_pgoff+0x2cc/0x818 mm/mmap.c:1461
[<ffff200008092fe0>] sys_mmap+0x58/0x80 arch/arm64/kernel/sys.c:37
[<ffff200008084770>] el0_svc_naked+0x24/0x28
Disabling lock debugging due to kernel taint
hrtimer: interrupt took 14253464 ns

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id CE0E26B00CE
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 09:49:29 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so146163obc.4
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 06:49:29 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l10si32559435oep.3.2014.11.14.06.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 06:49:28 -0800 (PST)
Message-ID: <5466142C.60100@oracle.com>
Date: Fri, 14 Nov 2014 09:39:40 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: freeing mlocked page
References: <545C4A36.9050702@oracle.com>
In-Reply-To: <545C4A36.9050702@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 11/06/2014 11:27 PM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:
> 
> [ 1441.564471] BUG: Bad page state in process trinity-c612  pfn:12593a
> [ 1441.564476] page:ffffea0006e175c0 count:0 mapcount:0 mapping:          (null) index:
> 0x49
> [ 1441.564488] flags: 0xafffff8028000c(referenced|uptodate|swapbacked|mlocked)
> [ 1441.564491] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> [ 1441.564493] bad because of flags:
> [ 1441.564498] flags: 0x200000(mlocked)
> [ 1441.564503] Modules linked in:
> [ 1441.564511] CPU: 2 PID: 11657 Comm: trinity-c612 Not tainted 3.18.0-rc3-next-20141106-sasha-00054-g09b7ccf-dirty #1447
> [ 1441.564519]  0000000000000000 0000000000000000 1ffffffff3b44e48 ffff8805c969b868
> [ 1441.564526]  ffffffff9c085024 0000000000000000 ffffea0006e175c0 ffff8805c969b898
> [ 1441.564532]  ffffffff925fd0a1 ffffea0006e17628 dfffe90000000000 0000000000000000
> [ 1441.564534] Call Trace:
> [ 1441.568496] dump_stack (lib/dump_stack.c:52)
> [ 1441.568516] bad_page (mm/page_alloc.c:338)
> [ 1441.568523] free_pages_prepare (mm/page_alloc.c:649 mm/page_alloc.c:755)
> [ 1441.568531] free_hot_cold_page (mm/page_alloc.c:1436)
> [ 1441.568541] free_hot_cold_page_list (mm/page_alloc.c:1482 (discriminator 3))
> [ 1441.568555] release_pages (mm/swap.c:961)
> [ 1441.568566] __pagevec_release (include/linux/pagevec.h:44 mm/swap.c:978)
> [ 1441.568579] shmem_undo_range (include/linux/pagevec.h:69 mm/shmem.c:451)
> [ 1441.568591] shmem_truncate_range (mm/shmem.c:546)
> [ 1441.568599] shmem_fallocate (include/linux/spinlock.h:309 mm/shmem.c:2092)
> [ 1441.568612] ? __sb_start_write (fs/super.c:1208)
> [ 1441.568622] ? __sb_start_write (fs/super.c:1208)
> [ 1441.568633] do_fallocate (fs/open.c:297)
> [ 1441.568648] SyS_madvise (mm/madvise.c:332 mm/madvise.c:381 mm/madvise.c:531 mm/madvise.c:462)
> [ 1441.568660] ? syscall_trace_enter_phase1 (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1486)
> [ 1441.568672] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
> 
> I'm slightly confused here, because the page is mapcount==0, not LOCKED but still MLOCKED...

So I got this as well:

[ 1026.988043] BUG: Bad page state in process trinity-c374  pfn:23f70
[ 1026.989684] page:ffffea0000b3d300 count:0 mapcount:0 mapping:          (null) index:0x5b
[ 1026.991151] flags: 0x1fffff8028000c(referenced|uptodate|swapbacked|mlocked)
[ 1026.992410] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[ 1026.993479] bad because of flags:
[ 1026.994125] flags: 0x200000(mlocked)
[ 1026.994816] Modules linked in:
[ 1026.995378] CPU: 7 PID: 7879 Comm: trinity-c374 Not tainted 3.18.0-rc4-next-20141113-sasha-00047-gd1763ce-dirty #1455
[ 1026.996123] FAULT_INJECTION: forcing a failure.
[ 1026.996123] name failslab, interval 100, probability 30, space 0, times -1
[ 1026.999050]  0000000000000000 0000000000000000 0000000000b3d300 ffff88061295bbd8
[ 1027.000676]  ffffffff92f71097 0000000000000000 ffffea0000b3d300 ffff88061295bc08
[ 1027.002020]  ffffffff8197ef7a ffffea0000b3d300 ffffffff942dd148 dfffe90000000000
[ 1027.003359] Call Trace:
[ 1027.003831] dump_stack (lib/dump_stack.c:52)
[ 1027.004725] bad_page (mm/page_alloc.c:338)
[ 1027.005623] free_pages_prepare (mm/page_alloc.c:657 mm/page_alloc.c:763)
[ 1027.006761] free_hot_cold_page (mm/page_alloc.c:1438)
[ 1027.007772] ? __page_cache_release (mm/swap.c:66)
[ 1027.008815] put_page (mm/swap.c:270)
[ 1027.009665] page_cache_pipe_buf_release (fs/splice.c:93)
[ 1027.010888] __splice_from_pipe (fs/splice.c:784 fs/splice.c:886)
[ 1027.011917] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3734)
[ 1027.012856] ? pipe_lock (fs/pipe.c:69)
[ 1027.013728] ? write_pipe_buf (fs/splice.c:1534)
[ 1027.014756] vmsplice_to_user (fs/splice.c:1574)
[ 1027.015725] ? rcu_read_lock_held (kernel/rcu/update.c:169)
[ 1027.016757] ? __fget_light (include/linux/fdtable.h:80 fs/file.c:684)
[ 1027.017782] SyS_vmsplice (fs/splice.c:1656 fs/splice.c:1639)
[ 1027.018863] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)

Which makes me suspect I blamed shmem for nothing.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

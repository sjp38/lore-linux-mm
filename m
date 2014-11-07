Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C2109800CA
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 23:27:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2747480pab.0
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 20:27:56 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nz9si7889316pbb.86.2014.11.06.20.27.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 20:27:55 -0800 (PST)
Message-ID: <545C4A36.9050702@oracle.com>
Date: Thu, 06 Nov 2014 23:27:34 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: shmem: freeing mlocked page
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 1441.564471] BUG: Bad page state in process trinity-c612  pfn:12593a
[ 1441.564476] page:ffffea0006e175c0 count:0 mapcount:0 mapping:          (null) index:
0x49
[ 1441.564488] flags: 0xafffff8028000c(referenced|uptodate|swapbacked|mlocked)
[ 1441.564491] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[ 1441.564493] bad because of flags:
[ 1441.564498] flags: 0x200000(mlocked)
[ 1441.564503] Modules linked in:
[ 1441.564511] CPU: 2 PID: 11657 Comm: trinity-c612 Not tainted 3.18.0-rc3-next-20141106-sasha-00054-g09b7ccf-dirty #1447
[ 1441.564519]  0000000000000000 0000000000000000 1ffffffff3b44e48 ffff8805c969b868
[ 1441.564526]  ffffffff9c085024 0000000000000000 ffffea0006e175c0 ffff8805c969b898
[ 1441.564532]  ffffffff925fd0a1 ffffea0006e17628 dfffe90000000000 0000000000000000
[ 1441.564534] Call Trace:
[ 1441.568496] dump_stack (lib/dump_stack.c:52)
[ 1441.568516] bad_page (mm/page_alloc.c:338)
[ 1441.568523] free_pages_prepare (mm/page_alloc.c:649 mm/page_alloc.c:755)
[ 1441.568531] free_hot_cold_page (mm/page_alloc.c:1436)
[ 1441.568541] free_hot_cold_page_list (mm/page_alloc.c:1482 (discriminator 3))
[ 1441.568555] release_pages (mm/swap.c:961)
[ 1441.568566] __pagevec_release (include/linux/pagevec.h:44 mm/swap.c:978)
[ 1441.568579] shmem_undo_range (include/linux/pagevec.h:69 mm/shmem.c:451)
[ 1441.568591] shmem_truncate_range (mm/shmem.c:546)
[ 1441.568599] shmem_fallocate (include/linux/spinlock.h:309 mm/shmem.c:2092)
[ 1441.568612] ? __sb_start_write (fs/super.c:1208)
[ 1441.568622] ? __sb_start_write (fs/super.c:1208)
[ 1441.568633] do_fallocate (fs/open.c:297)
[ 1441.568648] SyS_madvise (mm/madvise.c:332 mm/madvise.c:381 mm/madvise.c:531 mm/madvise.c:462)
[ 1441.568660] ? syscall_trace_enter_phase1 (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1486)
[ 1441.568672] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)

I'm slightly confused here, because the page is mapcount==0, not LOCKED but still MLOCKED...

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

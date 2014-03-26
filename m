Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7440F6B0038
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:13:36 -0400 (EDT)
Received: by mail-yh0-f45.google.com with SMTP id a41so2198458yho.32
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:13:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l53si23743723yhh.132.2014.03.26.08.13.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 08:13:35 -0700 (PDT)
Message-ID: <5332EE97.4050604@oracle.com>
Date: Wed, 26 Mar 2014 11:13:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: BUG: Bad page state in process ksmd
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following.

Out of curiosity, is there a reason not to do bad flag checks when actually
setting flag? Obviously it'll be slower but it'll be easier catching these
issues.

[ 3926.683948] BUG: Bad page state in process ksmd  pfn:5a6246
[ 3926.689336] page:ffffea0016989180 count:0 mapcount:0 mapping:          (null) index:
[ 3926.696507] page flags: 0x56fffff8028001c(referenced|uptodate|dirty|swapbacked|mlock
[ 3926.709201] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[ 3926.711216] bad because of flags:
[ 3926.712136] page flags: 0x200000(mlocked)
[ 3926.713574] Modules linked in:
[ 3926.714466] CPU: 26 PID: 3864 Comm: ksmd Tainted: G        W     3.14.0-rc7-next-201
[ 3926.720942]  ffffffff85688060 ffff8806ec7abc38 ffffffff844bd702 0000000000002fa0
[ 3926.728107]  ffffea0016989180 ffff8806ec7abc68 ffffffff844b158f 000fffff80000000
[ 3926.730563]  0000000000000000 000fffff80000000 ffffffff85688060 ffff8806ec7abcb8
[ 3926.737653] Call Trace:
[ 3926.738347]  dump_stack (lib/dump_stack.c:52)
[ 3926.739841]  bad_page (arch/x86/include/asm/atomic.h:38 include/linux/mm.h:432 mm/page_alloc.c:339)
[ 3926.741296]  free_pages_prepare (mm/page_alloc.c:644 mm/page_alloc.c:738)
[ 3926.742818]  free_hot_cold_page (mm/page_alloc.c:1371)
[ 3926.749425]  __put_single_page (mm/swap.c:71)
[ 3926.751074]  put_page (mm/swap.c:237)
[ 3926.752398]  ksm_do_scan (mm/ksm.c:1480 mm/ksm.c:1704)
[ 3926.753957]  ksm_scan_thread (mm/ksm.c:1723)
[ 3926.755940]  ? bit_waitqueue (kernel/sched/wait.c:291)
[ 3926.758644]  ? ksm_do_scan (mm/ksm.c:1715)
[ 3926.760420]  kthread (kernel/kthread.c:219)
[ 3926.761605]  ? kthread_create_on_node (kernel/kthread.c:185)
[ 3926.763149]  ret_from_fork (arch/x86/kernel/entry_64.S:555)
[ 3926.764323]  ? kthread_create_on_node (kernel/kthread.c:185)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

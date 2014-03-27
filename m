Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5856B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:22:30 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so3503936pde.38
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:22:30 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id xj10si1732856pab.450.2014.03.27.08.22.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 08:22:29 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3631432pbb.33
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:22:29 -0700 (PDT)
Date: Thu, 27 Mar 2014 08:21:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG: Bad page state in process ksmd
In-Reply-To: <5332EE97.4050604@oracle.com>
Message-ID: <alpine.LSU.2.11.1403270806340.4269@eggly.anvils>
References: <5332EE97.4050604@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 26 Mar 2014, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following.
> 
> Out of curiosity, is there a reason not to do bad flag checks when actually
> setting flag? Obviously it'll be slower but it'll be easier catching these
> issues.o

I don't see how it would help here.

> 
> [ 3926.683948] BUG: Bad page state in process ksmd  pfn:5a6246
> [ 3926.689336] page:ffffea0016989180 count:0 mapcount:0 mapping:
> (null) index:
> [ 3926.696507] page flags:
> 0x56fffff8028001c(referenced|uptodate|dirty|swapbacked|mlock
> [ 3926.709201] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> [ 3926.711216] bad because of flags:
> [ 3926.712136] page flags: 0x200000(mlocked)
> [ 3926.713574] Modules linked in:
> [ 3926.714466] CPU: 26 PID: 3864 Comm: ksmd Tainted: G        W
> 3.14.0-rc7-next-201
> [ 3926.720942]  ffffffff85688060 ffff8806ec7abc38 ffffffff844bd702
> 0000000000002fa0
> [ 3926.728107]  ffffea0016989180 ffff8806ec7abc68 ffffffff844b158f
> 000fffff80000000
> [ 3926.730563]  0000000000000000 000fffff80000000 ffffffff85688060
> ffff8806ec7abcb8
> [ 3926.737653] Call Trace:
> [ 3926.738347]  dump_stack (lib/dump_stack.c:52)
> [ 3926.739841]  bad_page (arch/x86/include/asm/atomic.h:38
> include/linux/mm.h:432 mm/page_alloc.c:339)
> [ 3926.741296]  free_pages_prepare (mm/page_alloc.c:644 mm/page_alloc.c:738)
> [ 3926.742818]  free_hot_cold_page (mm/page_alloc.c:1371)
> [ 3926.749425]  __put_single_page (mm/swap.c:71)
> [ 3926.751074]  put_page (mm/swap.c:237)
> [ 3926.752398]  ksm_do_scan (mm/ksm.c:1480 mm/ksm.c:1704)
> [ 3926.753957]  ksm_scan_thread (mm/ksm.c:1723)
> [ 3926.755940]  ? bit_waitqueue (kernel/sched/wait.c:291)
> [ 3926.758644]  ? ksm_do_scan (mm/ksm.c:1715)
> [ 3926.760420]  kthread (kernel/kthread.c:219)
> [ 3926.761605]  ? kthread_create_on_node (kernel/kthread.c:185)
> [ 3926.763149]  ret_from_fork (arch/x86/kernel/entry_64.S:555)
> [ 3926.764323]  ? kthread_create_on_node (kernel/kthread.c:185)

I've thought about this some, and slept on it, but don't yet see
how it comes about.  I'll have to come back to it later.

Was it a one-off, or do you find it fairly easy to reproduce?

If the latter, it would be interesting to know if it comes from
recent changes or not.  mm/mlock.c does appear to have been under
continuous revision for several releases (but barely changed in next).

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id E67486B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 17:51:44 -0400 (EDT)
Received: by obbeb7 with SMTP id eb7so60280429obb.3
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 14:51:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id uv7si10996034obc.93.2015.04.25.14.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Apr 2015 14:51:44 -0700 (PDT)
Message-ID: <553C0C65.6010401@oracle.com>
Date: Sat, 25 Apr 2015 17:51:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: free large amount of 0-order pages in workqueue
References: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>	<20150331153127.2eb8cc2f04c742dde7a8c96c@linux-foundation.org>	<551B222E.4000009@oracle.com> <20150331155455.dd725010cec78112cd549c5b@linux-foundation.org>
In-Reply-To: <20150331155455.dd725010cec78112cd549c5b@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, open@kvack.org, list@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 03/31/2015 06:54 PM, Andrew Morton wrote:
>> [ 2896.340953] trinity-c6      R  running task    27040  6561   9144 0x10000006
>> > [ 2896.342673]  ffff8802e72576a8 ffff8802e7257758 ffffffffabfdd628 003c5e36ef1674fa
>> > [ 2896.344267]  ffff8801533e1588 ffff8801533e1560 ffff8802d3963778 ffff8802ad220000
>> > [ 2896.345824]  ffff8802d3963000 0000000000000000 ffff8802e7250000 ffffed005ce4a002
>> > [ 2896.347286] Call Trace:
>> > [ 2896.347784] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
>> > [ 2896.348977] preempt_schedule_common (./arch/x86/include/asm/preempt.h:77 (discriminator 1) kernel/sched/core.c:2867 (discriminator 1))
>> > [ 2896.350279] preempt_schedule (kernel/sched/core.c:2893)
>> > [ 2896.351349] ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
>> > [ 2896.353782] __debug_check_no_obj_freed (lib/debugobjects.c:713)
>> > [ 2896.360001] debug_check_no_obj_freed (lib/debugobjects.c:727)
>> > [ 2896.361574] free_pages_prepare (mm/page_alloc.c:823)
>> > [ 2896.362657] free_hot_cold_page (mm/page_alloc.c:1550)
>> > [ 2896.363735] free_hot_cold_page_list (mm/page_alloc.c:1596 (discriminator 3))
>> > [ 2896.364846] release_pages (mm/swap.c:935)
>> > [ 2896.367979] __pagevec_release (include/linux/pagevec.h:44 mm/swap.c:1013)
>> > [ 2896.369149] shmem_undo_range (include/linux/pagevec.h:69 mm/shmem.c:446)
>> > [ 2896.377070] shmem_truncate_range (mm/shmem.c:541)
>> > [ 2896.378450] shmem_setattr (mm/shmem.c:577)
>> > [ 2896.379556] notify_change (fs/attr.c:270)
>> > [ 2896.382804] do_truncate (fs/open.c:62)
>> > [ 2896.387739] do_sys_ftruncate.constprop.4 (fs/open.c:191)
>> > [ 2896.389450] SyS_ftruncate (fs/open.c:199)
>> > [ 2896.390879] tracesys_phase2 (arch/x86/kernel/entry_64.S:340)
> OK, so shmem_undo_range() is full of cond_resched()s but it's holding
> i_mutex for too long.  Hugh, fix your junk!

Ping on this one? It's causing lockups on all kernels...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

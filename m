Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 582666B006E
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 09:21:06 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so54989066pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 06:21:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ke8si2871879pad.190.2015.04.01.06.21.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 06:21:04 -0700 (PDT)
Message-ID: <551BF0B4.2060309@oracle.com>
Date: Wed, 01 Apr 2015 09:20:52 -0400
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
> On Tue, 31 Mar 2015 18:39:42 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>>
>>> Stick a cond_resched() in __vunmap() ;)
>>
>> If only it was that simple :)
>>
>> Not only it get called in atomic context, 
> 
> Drat.  Who's calling vfree() from non-interrupt, atomic context for
> vast regions?

I have to admit that I don't have a clue. Michal and I discussed it at LSF/MM, and
he mentioned in his mail on the subject:

On 03/17/2015 04:58 AM, Michal Hocko wrote:
> Hmm, just looked into the git log and it seems that there are/were
> some callers of vfree with spinlock held (e.g. 9265f1d0c759 (GFS2:
> gfs2_dir_get_hash_table(): avoiding deferred vfree() is easy here...))
> and who knows how many others like that we have so cond_resched here is
> no-no.

>> but the problem is not just the
>> thread locking up, it's also lock dependency which causes other processes
>> to lock up. This is the example I've mentioned in the commit log with shmem.
>>
>> We have one random process crying about being stuck for two minutes:
>>
>> [ 2885.711517] INFO: task trinity-c5:7071 blocked for more than 120 seconds.
>> [ 2885.714534]       Not tainted 4.0.0-rc6-next-20150331-sasha-00036-g29ef5d2 #2108
>> [ 2885.717519] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> [ 2885.719472] trinity-c5      D ffff88011604fc18 26704  7071   9144 0x10000004
>> [ 2885.721271]  ffff88011604fc18 ffff880127bb3d80 0000000000000001 0000000000000000
>> [ 2885.722842]  ffff8801291e1588 ffff8801291e1560 ffff880127bb3008 ffff8801f9218000
>> [ 2885.724431]  ffff880127bb3000 ffff88011604fbf8 ffff880116048000 ffffed0022c09002
>> [ 2885.726088] Call Trace:
>> [ 2885.726612] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
>> [ 2885.727523] schedule_preempt_disabled (kernel/sched/core.c:2859)
>> [ 2885.728639] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
>> [ 2885.736019] chown_common (fs/open.c:595)
>> [ 2885.745761] SyS_fchown (fs/open.c:663 fs/open.c:650)
>> [ 2885.746714] tracesys_phase2 (arch/x86/kernel/entry_64.S:340)
>> [ 2885.747758] 2 locks held by trinity-c5/7071:
>> [ 2885.748545] #0: (sb_writers#10){.+.+.+}, at: mnt_want_write_file (fs/namespace.c:445)
>> [ 2885.751407] #1: (&sb->s_type->i_mutex_key#15){+.+.+.}, at: chown_common (fs/open.c:595)
>> [ 2885.755143] Mutex: counter: -1 owner: trinity-c6
>>
>> While shmem is work tirelessly to free up it's pages:
>>
>> [ 2896.340953] trinity-c6      R  running task    27040  6561   9144 0x10000006
>> [ 2896.342673]  ffff8802e72576a8 ffff8802e7257758 ffffffffabfdd628 003c5e36ef1674fa
>> [ 2896.344267]  ffff8801533e1588 ffff8801533e1560 ffff8802d3963778 ffff8802ad220000
>> [ 2896.345824]  ffff8802d3963000 0000000000000000 ffff8802e7250000 ffffed005ce4a002
>> [ 2896.347286] Call Trace:
>> [ 2896.347784] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
>> [ 2896.348977] preempt_schedule_common (./arch/x86/include/asm/preempt.h:77 (discriminator 1) kernel/sched/core.c:2867 (discriminator 1))
>> [ 2896.350279] preempt_schedule (kernel/sched/core.c:2893)
>> [ 2896.351349] ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
>> [ 2896.353782] __debug_check_no_obj_freed (lib/debugobjects.c:713)
>> [ 2896.360001] debug_check_no_obj_freed (lib/debugobjects.c:727)
>> [ 2896.361574] free_pages_prepare (mm/page_alloc.c:823)
>> [ 2896.362657] free_hot_cold_page (mm/page_alloc.c:1550)
>> [ 2896.363735] free_hot_cold_page_list (mm/page_alloc.c:1596 (discriminator 3))
>> [ 2896.364846] release_pages (mm/swap.c:935)
>> [ 2896.367979] __pagevec_release (include/linux/pagevec.h:44 mm/swap.c:1013)
>> [ 2896.369149] shmem_undo_range (include/linux/pagevec.h:69 mm/shmem.c:446)
>> [ 2896.377070] shmem_truncate_range (mm/shmem.c:541)
>> [ 2896.378450] shmem_setattr (mm/shmem.c:577)
>> [ 2896.379556] notify_change (fs/attr.c:270)
>> [ 2896.382804] do_truncate (fs/open.c:62)
>> [ 2896.387739] do_sys_ftruncate.constprop.4 (fs/open.c:191)
>> [ 2896.389450] SyS_ftruncate (fs/open.c:199)
>> [ 2896.390879] tracesys_phase2 (arch/x86/kernel/entry_64.S:340)
> 
> OK, so shmem_undo_range() is full of cond_resched()s but it's holding
> i_mutex for too long.  Hugh, fix your junk!
> 
> Rather than mucking with the core page allocator I really do think it
> would be better to bodge the offending callers for this problem.
> 
> And/or maybe extend the softlockup timeout when crazy debug options are
> selected.  You're the only person who this will hurt ;)

2 minutes is too little, but I'm hitting (unrelated) things like the
lru_add_drain_all() hang even with a 20 minute timer. At some point it
just stops fuzzing and turns into an attempt to deal with freeing large
chunks of memory :/


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

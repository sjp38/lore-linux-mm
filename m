Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA5876B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 05:39:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so18572733wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 02:39:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si422845wrw.52.2017.02.06.02.39.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 02:39:20 -0800 (PST)
Date: Mon, 6 Feb 2017 11:39:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170206103918.GD3097@dhcp22.suse.cz>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145548.GC19325@dhcp22.suse.cz>
 <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, peterz@infradead.org
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Sun 05-02-17 19:43:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> I got same warning with ext4. Maybe we need to check carefully.
> 
> [  511.215743] =====================================================
> [  511.218003] WARNING: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected
> [  511.220031] 4.10.0-rc6-next-20170202+ #500 Not tainted
> [  511.221689] -----------------------------------------------------
> [  511.223579] a.out/49302 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
> [  511.225533]  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff810a1477>] get_online_cpus+0x37/0x80
> [  511.227795] 
> [  511.227795] and this task is already holding:
> [  511.230082]  (jbd2_handle){++++-.}, at: [<ffffffff813a8be7>] start_this_handle+0x1a7/0x590
> [  511.232592] which would create a new lock dependency:
> [  511.234192]  (jbd2_handle){++++-.} -> (cpu_hotplug.dep_map){++++++}
> [  511.235966] 
> [  511.235966] but this new dependency connects a RECLAIM_FS-irq-safe lock:
> [  511.238563]  (jbd2_handle){++++-.}
> [  511.238564] 
> [  511.238564] ... which became RECLAIM_FS-irq-safe at:
> [  511.242078]   
> [  511.242084] [<ffffffff811089db>] __lock_acquire+0x34b/0x1640
> [  511.244495] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
> [  511.246697] [<ffffffff813b3525>] jbd2_log_wait_commit+0x55/0x1d0
[...]
> [  511.276216] to a RECLAIM_FS-irq-unsafe lock:
> [  511.278128]  (cpu_hotplug.dep_map){++++++}
> [  511.278130] 
> [  511.278130] ... which became RECLAIM_FS-irq-unsafe at:
> [  511.281809] ...
> [  511.281811]   
> [  511.282598] [<ffffffff81108141>] mark_held_locks+0x71/0x90
> [  511.284854] [<ffffffff8110ab6f>] lockdep_trace_alloc+0x6f/0xd0
> [  511.287218] [<ffffffff812744c8>] kmem_cache_alloc_node_trace+0x48/0x3b0
> [  511.289755] [<ffffffff810cfa65>] __smpboot_create_thread.part.2+0x35/0xf0
> [  511.292329] [<ffffffff810d0026>] smpboot_create_threads+0x66/0x90
[...]
> [  511.317867] other info that might help us debug this:
> [  511.317867] 
> [  511.320920]  Possible interrupt unsafe locking scenario:
> [  511.320920] 
> [  511.323218]        CPU0                    CPU1
> [  511.324622]        ----                    ----
> [  511.325973]   lock(cpu_hotplug.dep_map);
> [  511.327246]                                local_irq_disable();
> [  511.328870]                                lock(jbd2_handle);
> [  511.330483]                                lock(cpu_hotplug.dep_map);
> [  511.332259]   <Interrupt>
> [  511.333187]     lock(jbd2_handle);

Peter, is there any way how to tell the lockdep that this is in fact
reclaim safe? The direct reclaim only does the trylock and backs off so
we cannot deadlock here.

Or am I misinterpreting the trace?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

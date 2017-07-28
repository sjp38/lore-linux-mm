Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF59F6B0511
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:31:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f69so126475264ioe.10
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:31:02 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i126si17840348iof.95.2017.07.28.02.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 02:31:02 -0700 (PDT)
Date: Fri, 28 Jul 2017 11:30:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of
 cpusets_enabled()
Message-ID: <20170728093047.ykgbufjj74xa5x3r@hirez.programming.kicks-ass.net>
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
 <20170727164608.12701-1-dmitriyz@waymo.com>
 <41954034-9de1-de8e-f915-51a4b0334f98@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41954034-9de1-de8e-f915-51a4b0334f98@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dima Zavin <dmitriyz@waymo.com>, Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri, Jul 28, 2017 at 09:45:16AM +0200, Vlastimil Babka wrote:
> [+CC PeterZ]
> 
> On 07/27/2017 06:46 PM, Dima Zavin wrote:
> > In codepaths that use the begin/retry interface for reading
> > mems_allowed_seq with irqs disabled, there exists a race condition that
> > stalls the patch process after only modifying a subset of the
> > static_branch call sites.
> > 
> > This problem manifested itself as a dead lock in the slub
> > allocator, inside get_any_partial. The loop reads
> > mems_allowed_seq value (via read_mems_allowed_begin),
> > performs the defrag operation, and then verifies the consistency
> > of mem_allowed via the read_mems_allowed_retry and the cookie
> > returned by xxx_begin. The issue here is that both begin and retry
> > first check if cpusets are enabled via cpusets_enabled() static branch.
> > This branch can be rewritted dynamically (via cpuset_inc) if a new
> > cpuset is created. The x86 jump label code fully synchronizes across
> > all CPUs for every entry it rewrites. If it rewrites only one of the
> > callsites (specifically the one in read_mems_allowed_retry) and then
> > waits for the smp_call_function(do_sync_core) to complete while a CPU is
> > inside the begin/retry section with IRQs off and the mems_allowed value
> > is changed, we can hang. This is because begin() will always return 0
> > (since it wasn't patched yet) while retry() will test the 0 against
> > the actual value of the seq counter.
> 
> Hm I wonder if there are other static branch users potentially having
> similar problem. Then it would be best to fix this at static branch
> level. Any idea, Peter? An inelegant solution would be to have indicate
> static_branch_(un)likely() callsites ordering for the patching. I.e.
> here we would make sure that read_mems_allowed_begin() callsites are
> patched before read_mems_allowed_retry() when enabling the static key,
> and the opposite order when disabling the static key.

I'm not aware of any other sure ordering requirements. But you can
manually create this order by using 2 static keys. Then flip them in the
desired order.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

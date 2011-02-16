Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 241938D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 09:45:03 -0500 (EST)
Date: Wed, 16 Feb 2011 15:44:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
 insufficient progress if !__GFP_REPEAT
Message-ID: <20110216144432.GZ5935@random.random>
References: <20110209164656.GA1063@csn.ul.ie>
 <20110209182846.GN3347@random.random>
 <20110210102109.GB17873@csn.ul.ie>
 <20110210124838.GU3347@random.random>
 <20110210133323.GH17873@csn.ul.ie>
 <20110210141447.GW3347@random.random>
 <20110210145813.GK17873@csn.ul.ie>
 <20110216095048.GA4473@csn.ul.ie>
 <20110216101301.GT5935@random.random>
 <20110216112232.GC4473@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110216112232.GC4473@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 16, 2011 at 11:22:32AM +0000, Mel Gorman wrote:
> Out of curiousity, what are you measuring the latency of and how? I used
> a combination of the function_graph ftrace analyser and the mm_page_alloc
> tracepoint myself to avoid any additional patching and it was easier than
> cobbling together something with kprobes. A perl script configures ftrace
> and then parses the contents of trace_pipe - crude but does the job without
> patching the kernel.

It's some complex benchmark that is measuring the latency from
userland, I think latency is measured from clients (not the server
running compaction).

> How big are the discrepancies?

Latency in msec/op goes up from 1.1 to 5.4 starting from half the peak
load. But then latency stays flat with compaction, eventually the peak
load latency is similar. It just goes immediately from 1.1 to 5.4 in
the middle and it's slightly higher even for the light load runs.

> No idea.

I guess it's very hard to tell unless we try. I just nuked the
bulk_latency for the jumbo frames and forced the driver to always
stay in low_latency mode (in NAPI ->poll method of the driver), just
in case it's not compaction to blame but a side effect of compaction
providing jumbo frames much more frequently to the driver.

> Can I have your ack on the patch then? Even if it doesn't resolve the

Sure, I acked it explicitly in separate email ;).

> jumbo frame problems, it's in the right direction. Measuring how it
> currently behaves and what direction should be taken may be something
> still worth discussing at LSF/MM.

Agreed!

> > One issue with compaction for jumbo frames, is the potentially very
> > long loop, for the scan in isolated_migratepages.
> 
> Yes, the scanner is poor. The scanner for free pages is potentially just
> as bad. I prototyped some designs that should have been faster but they
> didn't make any significant difference so they got discarded.

But the scanner for free pages a nr_scanned countdown and breaks the
loop way sooner. Also most of the >order allocations must have a
fallback so scanning everything for succeeding order 0 is much more
obviously safe than scanning everything to provide an order 2
allocation, if the order 0 allocation could be provided immediately
without scanning anything. It's not a trivial problem when we deal
with short lived allocations. Also the throughput is equal or a little
higher (not necessarily related to compaction though), the latency is
the real measurable regression.

> This surprises me. In my own tests at least, the compaction stuff was
> way down in the profile and I wouldn't have expected scanning to take so
> long as to require a cond_resched. I was depending on the cond_resched()
> in migrate_pages() to yield the processor as necessary.

If migrate_pages runs often likely won't need to scan too many pages
in the first place. I think cond_resched is good idea in that
loop considering the current possible worst case.

This is the profiling. This is with basically 2.6.37 compaction code
so only enabled for THP sized allocations and not for order <=
PAGE_ALLOC_COSTLY_ORDER and not for kswapd.

Samples          % of Total       Cum. Samples     Cum. % of Total   module:function
-------------------------------------------------------------------------------------------------
177786           6.178            177786           6.178             sunrpc:svc_recv
128779           4.475            306565           10.654            sunrpc:svc_xprt_enqueue
80786            2.807            387351           13.462            vmlinux:__d_lookup
62272            2.164            449623           15.626            ext4:ext4_htree_store_dirent
55896            1.942            505519           17.569            jbd2:journal_clean_one_cp_list
43868            1.524            549387           19.093            vmlinux:task_rq_lock
43572            1.514            592959           20.608            vmlinux:kfree
37620            1.307            630579           21.915            vmlinux:mwait_idle
36169            1.257            666748           23.172            vmlinux:schedule
34037            1.182            700785           24.355            e1000:e1000_clean
31945            1.110            732730           25.465            vmlinux:find_busiest_group
31491            1.094            764221           26.560            qla2xxx:qla24xx_intr_handler
30681            1.066            794902           27.626            vmlinux:_atomic_dec_and_lock 
7425             0.258            xxxxxx           xxxxxx            vmlinux:get_page_from_freelist

This is with 2.6.38 compaction code enabled for all !order in both
direct compaction and kswapd (it includes async compaction/migrate and
the preferred pageblock selection in !cc->sync mode). It basically
only doesn't include the should_continue_reclaim loop as that could
only potentially increase the latency even further so I skipped it for
now (I'll add it later with your __GFP_RECLAIM new patch).

Samples          % of Total       Cum. Samples     Cum. % of Total   module:function
-------------------------------------------------------------------------------------------------
1182928          17.358           1182928          17.358            vmlinux:get_page_from_freelist
657802           9.652            1840730          27.011            vmlinux:free_pcppages_bulk
579976           8.510            2420706          35.522            sunrpc:svc_xprt_enqueue
508953           7.468            2929659          42.991            sunrpc:svc_recv
490538           7.198            3420197          50.189            vmlinux:compaction_alloc
188620           2.767            3608817          52.957            vmlinux:tg_shares_up
97527            1.431            3706344          54.388            vmlinux:__d_lookup
85670            1.257            3792014          55.646            jbd2:journal_clean_one_cp_list
71738            1.052            3863752          56.698            vmlinux:mutex_spin_on_owner
71037            1.042            3934789          57.741            vmlinux:kfree

Basically it was my patch that enabled compaction for all order sized
allocations and in kswapd as well that started this but I think I only
exposed the problem and if the jumbo frame would have order 4 instead
of order 1/2/3, it'd happen regardless of my patch. Later I'm also
going to check if it's the kswapd invocation that causes the problem
(so trying with only direct compaction) but I doubt it'll help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

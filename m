Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D3FC96B0072
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 05:12:02 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so14099592wgh.32
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 02:12:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ao10si15733827wjc.83.2014.12.15.02.12.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 02:12:01 -0800 (PST)
Message-ID: <548EB3EF.2060803@suse.cz>
Date: Mon, 15 Dec 2014 11:11:59 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] memory compaction and anti-fragmentation
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>

Hi,

this topic still looks like far from a solved problem. It's also a natural
complement to the topics of THP and CMA.

When we discussed compaction last LSF/MM [1] we noted presence of bugs, and
overhead. Both was improved since, but still today we find quite old bugs, deal
with reports of excessive overhead, and the success rates are also still not great.

So here's a list of compaction subtopics/questions that I think could be discussed.

- As it turns out, surprising behavior can still show up in compaction code, and
often we don't have a good idea about what it's really doing. I've been using
ad-hoc (and ugly) tracepoints locally for specific issues, Joonsoo has recently
posted more polished set of tracepoints. Is this enough, or do we need more
tracepoints or vmstat entries? What about postprocessing of the traces, should
there be shared tools?

- For testing, which benchmarks to use? I (and others) have been relying on
stress-highalloc from mmtests, but I'm aware it's quite artificial, and results
could thus be potentially misleading. Is there anything better representative,
but doesn't need hours to run for a single data point?

- How to better decide when to try compaction and for how long? Is the deferred
compaction mechanism enough? Given how we've reduced the amount of synchronous
compaction compared to asynchronous, it's possible that deferred compaction is
not triggered enough. For asynchronous compaction we currently quit when we
detect lock contention or need_resched(). We have briefly discussed on linux-mm
with David Rientjes whether this makes sense and if instead there shouldn't be a
limit on the number of scanned pages per invocation? User or automatically
tunable perhaps?

- Can we improve coordination between direct reclaim and compaction? Both rely
mostly on watermark checks and estimation of fragmentation to decide whether to
reclaim or compact. Within compaction itself, the checks were found to be
inconsistent due to important parameters (alloc_flags and classzone_idx) not
available, which should now be fixed. But they are still missing in the reclaim
vs compaction decisions. This could be a problem in near-full-memory situations.
Can we also do something about parallel activity changing the conditions during
the compaction? E.g. we decide we have enough free memory to try compaction, but
then another process allocates it...

- Is the fundamental compaction algorithm sufficient? Migration scanner starts
at the zone beginning, free scanner at the zone end. Testing shows that with
memory nearly full, they always meet somewhere around the middle of the zone.
But that means the migration scanner never sees the second half of the zone, and
won't migrate movable pages from unmovable pageblocks, which impacts
fragmentation avoidance. Should we try to somehow move the scanner starting
points around the zone so all pageblocks get the same share of migrate scanner
on average?

Complementary to compaction is the fragmentation avoidance mechanism, which
Joonsoo and I are now also looking at. It's of course a heuristic and cannot be
perfect, unless it could predict the future. But can we do better to prevent
long-term unmovable allocations from polluting more pageblocks than needed?

- Should we perhaps sometimes decide that it's better to try migrating movable
pages out of current unmovable pageblocks, than placing an unmovable allocation
to movable pageblock?

- Would it be useful to introduce another migratetype e.g. MIXED, to mark
pageblocks where unmovable allocations occured, but didn't steal enough free
pages to change pageblock migratetype to unmovable? The idea is that further
stealing would prefer MIXED pageblocks before polluting another clean movable
pageblocks.

In case anyone's interested in more details, I've also written about the work
done on this topic (mostly from my perspective) during the last year, for our
SUSE Labs conference this September [2].

Vlastimil

[1] http://lwn.net/Articles/591998/
[2] http://labs.suse.cz/vbabka/compaction.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19EA36B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 06:25:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so13605689lfe.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:25:34 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id l4si12753100wmf.56.2016.07.28.03.25.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jul 2016 03:25:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 08F4F993D7
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 10:25:31 +0000 (UTC)
Date: Thu, 28 Jul 2016 11:25:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160728102513.GA2799@techsingularity.net>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
 <20160728054947.GL12670@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160728054947.GL12670@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tony Jones <tonyj@suse.de>, Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Thu, Jul 28, 2016 at 03:49:47PM +1000, Dave Chinner wrote:
> Seems you're all missing the obvious.
> 
> Add a tracepoint for a shrinker callback that includes a "name"
> field, have the shrinker callback fill it out appropriately. e.g
> in the superblock shrinker:
> 
> 	trace_shrinker_callback(shrinker, shrink_control, sb->s_type->name);
> 

That misses capturing the latency of the call unless there is a begin/end
tracepoint. I was aware of the function graph tracer but I don't know how
to convince that to give the following information;

1. The length of time spent in a given function
2. The tracepoint information that might explain why the stall occurred

Take the compaction tracepoint for example

        trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
                                cc->free_pfn, end_pfn, sync);

	...

	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
                                cc->free_pfn, end_pfn, sync, ret);

The function graph tracer can say that X time is compact_zone() but it
cannot distinguish between a short time spent in that function because
compaction_suitable == false or compaction simply finished quickly.  While
the cc struct parameters could be extracted, end_pfn is much harder to figure
out because a user would have to parse zoneinfo to figure it out and even
*that* would only work if there are no overlapping nodes. Extracting sync
would require making assumptions about the implementation of compact_zone()
that could change.

> And now you know exactly what shrinker is being run.
> 

Sure and it's a good suggestion but does not say how long the shrinker
was running.

My understanding was the point of the tracepoints was to get detailed
information on points where the kernel is known to stall for long periods
of time. I don't actually know how to convince the function graph tracer
to get that type of information. Maybe it's possible and I just haven't
tried recently enough.

It potentially duration could be inferred from using a return probe on
the function but that requires that the function the tracepoint is running
is is known by the tool, has not been inlined and that there are no retry
loops that hit the begin tracepoint.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

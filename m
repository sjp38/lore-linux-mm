Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEB196B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:37:43 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x63so4955502wmf.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:37:43 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id h1si2676423edc.286.2017.11.23.05.37.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 05:37:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 2ED7CB925C
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 13:37:42 +0000 (GMT)
Date: Thu, 23 Nov 2017 13:36:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: peter.enderborg@sony.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu, Nov 23, 2017 at 01:25:30PM +0100, Michal Hocko wrote:
> On Thu 23-11-17 11:43:36, peter.enderborg@sony.com wrote:
> > From: Peter Enderborg <peter.enderborg@sony.com>
> > 
> > The warning of slow allocation has been removed, this is
> > a other way to fetch that information. But you need
> > to enable the trace. The exit function also returns
> > information about the number of retries, how long
> > it was stalled and failure reason if that happened.
> 
> I think this is just too excessive. We already have a tracepoint for the
> allocation exit. All we need is an entry to have a base to compare with.
> Another usecase would be to measure allocation latency. Information you
> are adding can be (partially) covered by existing tracepoints.
> 

You can gather that by simply adding a probe to __alloc_pages_slowpath
(like what perf probe does) and matching the trigger with the existing
mm_page_alloc points. This is a bit approximate because you would need
to filter mm_page_alloc hits that do not have a corresponding hit with
__alloc_pages_slowpath but that is easy.

With that probe, it's trivial to use systemtap to track the latencies between
those points on a per-processes basis and then only do a dump_stack from
systemtap for the ones that are above a particular threshold. This can all
be done without introducing state-tracking code into the page allocator
that is active regardless of whether the tracepoint is in use. It also
has the benefit of working with many older kernels.

If systemtap is not an option then use ftrace directly to gather the
information from userspace. It can be done via trace_pipe with some overhead
or on a per-cpu basis like what trace-cmd does. It's important to note
that even *if* the tracepoints were introduced that it would be necessary
to have something gather the information and report it in a sensible fashion.

That probe+mm_page_alloc can tell you the frequency of allocation
attempts that take a long time but not the why. Compaction and direct
reclaim latencies can be checked via existing tracepoints and in the case
of compaction, detailed information can also be gathered from existing
tracepoints. Detailed information on why direct reclaim stalled can be
harder but the biggest one is checking if reclaim stalls due to congestion
and again, tracepoints already exist for that.

I'm not convinced that a new tracepoint is needed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

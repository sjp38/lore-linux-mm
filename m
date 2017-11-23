Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85F146B0253
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:09:51 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o60so12210239wrc.14
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:09:51 -0800 (PST)
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id a54si1854102edc.11.2017.11.23.07.09.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 07:09:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id EEC83B909D
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 15:09:49 +0000 (GMT)
Date: Thu, 23 Nov 2017 15:09:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123150949.ccca6mvcwp74v4iy@techsingularity.net>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
 <20171123140127.7z5z6awj2ti6lozh@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171123140127.7z5z6awj2ti6lozh@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: peter.enderborg@sony.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu, Nov 23, 2017 at 03:01:27PM +0100, Michal Hocko wrote:
> On Thu 23-11-17 13:36:29, Mel Gorman wrote:
> > On Thu, Nov 23, 2017 at 01:25:30PM +0100, Michal Hocko wrote:
> > > On Thu 23-11-17 11:43:36, peter.enderborg@sony.com wrote:
> > > > From: Peter Enderborg <peter.enderborg@sony.com>
> > > > 
> > > > The warning of slow allocation has been removed, this is
> > > > a other way to fetch that information. But you need
> > > > to enable the trace. The exit function also returns
> > > > information about the number of retries, how long
> > > > it was stalled and failure reason if that happened.
> > > 
> > > I think this is just too excessive. We already have a tracepoint for the
> > > allocation exit. All we need is an entry to have a base to compare with.
> > > Another usecase would be to measure allocation latency. Information you
> > > are adding can be (partially) covered by existing tracepoints.
> > > 
> > 
> > You can gather that by simply adding a probe to __alloc_pages_slowpath
> > (like what perf probe does) and matching the trigger with the existing
> > mm_page_alloc points.
> 
> I am not sure adding a probe on a production system will fly in many
> cases.

Not sure why not considering that the final mechanism is very similar.

> A static tracepoint would be much easier in that case.

Sure, but if it's only really latencies that are a concern then a probe
would do the job without backports. 

> But I
> agree there are other means to accomplish the same thing. My main point
> was to have an easy out-of-the-box way to check latencies. But that is
> not something I would really insist on.
> 

An entry tracepoint is enough for just latencies by punting the analysis
to userspace and state tracking to either systemtap or userspace. If
userspace then it would need to never malloc once analysis starts and be
mlocked.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

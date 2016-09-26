Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4E13280266
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:12:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so75516876wmg.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:12:04 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id o2si5858664wjc.37.2016.09.26.01.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 01:12:03 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 133so12821518wmq.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:12:03 -0700 (PDT)
Date: Mon, 26 Sep 2016 10:12:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160926081200.GB27030@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <57E56789.1070205@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E56789.1070205@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri 23-09-16 10:34:01, Dave Hansen wrote:
> On 09/23/2016 01:15 AM, Michal Hocko wrote:
> > +	/* Make sure we know about allocations which stall for too long */
> > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> > +				order, gfp_mask, &gfp_mask);
> > +		stall_timeout += 10 * HZ;
> > +		dump_stack();
> > +	}
> 
> This would make an awesome tracepoint.  There's probably still plenty of
> value to having it in dmesg, but the configurability of tracepoints is
> hard to beat.

Currently we only have trace_mm_page_alloc in __alloc_pages_nodemask. I
think we want to add another one to mark the beginning of the allocation
so that we can track allocation latencies per allocation context and
ideally drop them down into sources - congestion waits, reclaim path,
slab reclaim etc. Janani Ravichandran is working on a script to do that
http://lkml.kernel.org/r/20160911222411.GA2854@janani-Inspiron-3521

But this sounds a bit orthogonal to my proposal here because I would
really like to warn unconditionally when an allocation stalls for
unreasonably long. Tracepoints are not an ideal tool for that because
you have to start collecting tracing output before this situations
happen. Moreover in my experience I often had to replace my local
debugging trace_printks by regular printks because the prior ones just
got lost under a heavy memory pressure.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

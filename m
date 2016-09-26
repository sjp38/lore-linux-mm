Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C91CD280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:13:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so75471839wmc.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:13:16 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d5si4299019wjw.79.2016.09.26.01.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 01:13:15 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 133so12825934wmq.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:13:15 -0700 (PDT)
Date: Mon, 26 Sep 2016 10:13:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160926081314.GC27030@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <57E56789.1070205@intel.com>
 <31729f1f-c0da-29e4-5777-69446daab122@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31729f1f-c0da-29e4-5777-69446daab122@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Sat 24-09-16 23:19:04, Balbir Singh wrote:
> 
> 
> On 24/09/16 03:34, Dave Hansen wrote:
> > On 09/23/2016 01:15 AM, Michal Hocko wrote:
> >> +	/* Make sure we know about allocations which stall for too long */
> >> +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> >> +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> >> +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> >> +				order, gfp_mask, &gfp_mask);
> >> +		stall_timeout += 10 * HZ;
> >> +		dump_stack();
> >> +	}
> > 
> > This would make an awesome tracepoint.  There's probably still plenty of
> > value to having it in dmesg, but the configurability of tracepoints is
> > hard to beat.
> 
> An awesome tracepoint and a great place to trigger other tracepoints. With stall timeout
> increasing every time, do we only care about the first instance when we exceeded stall_timeout?
> Do we debug just that instance?

I am not sure I understand you here. The stall_timeout is increased to
see whether the situation is permanent of ephemeral. This is similar to
RCU lockup reports.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

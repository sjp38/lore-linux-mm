Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5256B041A
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 13:11:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g10so22262618wrg.5
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 10:11:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 36si9654846wrp.148.2017.03.09.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 10:11:38 -0800 (PST)
Date: Thu, 9 Mar 2017 13:05:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170309180540.GA8678@cmpxchg.org>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1488916356.6405.4.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> It only does this to some extent.  If reclaim made
> no progress, for example due to immediately bailing
> out because the number of already isolated pages is
> too high (due to many parallel reclaimers), the code
> could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> test without ever looking at the number of reclaimable
> pages.

Hm, there is no early return there, actually. We bump the loop counter
every time it happens, but then *do* look at the reclaimable pages.

> Could that create problems if we have many concurrent
> reclaimers?

With increased concurrency, the likelihood of OOM will go up if we
remove the unlimited wait for isolated pages, that much is true.

I'm not sure that's a bad thing, however, because we want the OOM
killer to be predictable and timely. So a reasonable wait time in
between 0 and forever before an allocating thread gives up under
extreme concurrency makes sense to me.

> It may be OK, I just do not understand all the implications.
> 
> I like the general direction your patch takes the code in,
> but I would like to understand it better...

I feel the same way. The throttling logic doesn't seem to be very well
thought out at the moment, making it hard to reason about what happens
in certain scenarios.

In that sense, this patch isn't really an overall improvement to the
way things work. It patches a hole that seems to be exploitable only
from an artificial OOM torture test, at the risk of regressing high
concurrency workloads that may or may not be artificial.

Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
behind this patch. Can we think about a general model to deal with
allocation concurrency? Unlimited parallel direct reclaim is kinda
bonkers in the first place. How about checking for excessive isolation
counts from the page allocator and putting allocations on a waitqueue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

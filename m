Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id EE1D76B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 14:42:33 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so85471925wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 11:42:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m66si14775040wma.102.2016.02.19.11.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 11:42:32 -0800 (PST)
Date: Fri, 19 Feb 2016 14:41:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160219194128.GA17342@cmpxchg.org>
References: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
 <1455826543.15821.64.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455826543.15821.64.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Feb 18, 2016 at 03:15:43PM -0500, Rik van Riel wrote:
> On Thu, 2016-02-18 at 11:41 -0500, Johannes Weiner wrote:
> > In machines with 140G of memory and enterprise flash storage, we have
> > seen read and write bursts routinely exceed the kswapd watermarks and
> > cause thundering herds in direct reclaim. Unfortunately, the only way
> > to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> > the system's emergency reserves - which is entirely unrelated to the
> > system's latency requirements. In order to get kswapd to maintain a
> > 250M buffer of free memory, the emergency reserves need to be set to
> > 1G. That is a lot of memory wasted for no good reason.
> > 
> > On the other hand, it's reasonable to assume that allocation bursts
> > and overall allocation concurrency scale with memory capacity, so it
> > makes sense to make kswapd aggressiveness a function of that as well.
> > 
> > Change the kswapd watermark scale factor from the currently fixed 25%
> > of the tunable emergency reserve to a tunable 0.001% of memory.
> > 
> > On a 140G machine, this raises the default watermark steps - the
> > distance between min and low, and low and high - from 16M to 143M.
> 
> This is an excellent idea for a large system,
> but your patch reduces the gap between watermarks
> on small systems.
> 
> On an 8GB zone, your patch halves the gap between
> the watermarks, and on smaller systems it would be
> even worse.

You're right, I'll address that in v2.

> Would it make sense to keep using the old calculation
> on small systems, when the result of the old calculation
> exceeds that of the new calculation?
> 
> Using the max of the two calculations could prevent
> the issue you are trying to prevent on large systems,
> from happening on smaller systems.

Yes, I think enforcing a reasonable minimum this way makes sense.

Thanks Rik.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

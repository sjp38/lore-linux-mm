Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5026B0254
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:46:59 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so23576644wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:46:59 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id k5si45189228wma.35.2016.02.24.02.46.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 02:46:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id E00E598F3A
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:46:57 +0000 (UTC)
Date: Wed, 24 Feb 2016 10:46:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Message-ID: <20160224104656.GT2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <20160223200416.GA27563@cmpxchg.org>
 <20160223201932.GN2854@techsingularity.net>
 <20160223205915.GA10744@cmpxchg.org>
 <20160223215859.GO2854@techsingularity.net>
 <20160224001201.GA2120@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160224001201.GA2120@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 04:12:01PM -0800, Johannes Weiner wrote:
> > > > > If reclaim can't guarantee a balanced zone utilization then the
> > > > > allocator has to keep doing it. :(
> > > > 
> > > > That's the key issue - the main reason balanced zone utilisation is
> > > > necessary is because we reclaim on a per-zone basis and we must avoid
> > > > page aging anomalies. If we balance such that one eligible zone is above
> > > > the watermark then it's less of a concern.
> > > 
> > > Yes, but only if there can't be extended reclaim stretches that prefer
> > > the pages of a single zone. Yet it looks like this is still possible.
> > 
> > And that is a problem if a workload is dominated by allocations
> > requiring the lower zones. If that is the common case then it's a bust
> > and fair zone allocation policy is still required. That removes one
> > motivation from the series as it leaves some fatness in the page
> > allocator paths.
> 
> With your above explanations, I'm now much more confident this series
> is doing the right thing. Thanks.
> 
> The uncertainty over low-zone allocation floods is real, but what is
> also unsettling is that, where the fair zone code used to shield us
> from kswapd changes, we now open ourselves up to subtle aging bugs,
> which are no longer detectable via the zone placement statistics. And
> we have changed kswapd around quite extensively in the recent past.
> 
> A good metric for aging distortion might be able to mitigate both
> these things. Something to keep an eye on when making changes to
> kswapd, or when analyzing performance problems with a workload.
> 
> What I have in mind is per-classzone counters of reclaim work. If we
> had exact numbers on how much zone-restricted reclaim is being done
> relative to unrestricted scans, we could know how severely the aging
> process is being distorted under any given workload. That would allow
> us to validate these changes here, future kswapd and allocator
> changes, and help us identify problematic workloads.
> 

Ok, that makes me think that I should keep the per-zone pgscan figures
even if they are based on node LRU reclaim because we'll know what the
per-zone scan activity is. We already know how many pages get skipped
when reclaiming for lower zones.

> And maybe we can change the now useless pgalloc_ stats from counting
> zone placement to counting allocation requests by classzone.

I can't convince myself about this one way or the other.

> We could
> then again correlate the number of requests to the amount of work
> done. A high amount of restricted reclaim on behalf of mostly Normal
> allocation requests would detect the bug I described above, e.g. And
> we could generally tell how expensive restricted allocations are in
> the new node-LRUs.
> 

I keep thinking the skip statistics gives us similar data -- it does
not tell us how many restricted allocations that resulted in reclaim was
but we do get an idea of the amount of work caused.

I'll think about it some more and see what I come up with.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

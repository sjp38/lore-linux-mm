Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 159436B49B7
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:51:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id k58so11176958eda.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:51:16 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id g7-v6si743571ejl.130.2018.11.27.09.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 09:51:13 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 842A0986C7
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 17:51:13 +0000 (UTC)
Date: Tue, 27 Nov 2018 17:51:11 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm: Stall movable allocations until kswapd
 progresses during serious external fragmentation event
Message-ID: <20181127175111.GT23260@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-6-mgorman@techsingularity.net>
 <e0867205-e5f1-b007-5dc7-bb4655f6e5c1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e0867205-e5f1-b007-5dc7-bb4655f6e5c1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Nov 27, 2018 at 02:20:30PM +0100, Vlastimil Babka wrote:
> > This patch has a marginal rate on fragmentation rates as it's rare for
> > the stall logic to actually trigger but the small stalls can be enough for
> > kswapd to catch up. How much that helps is variable but probably worthwhile
> > for long-term allocation success rates. It is possible to eliminate
> > fragmentation events entirely with tuning due to this patch although that
> > would require careful evaluation to determine if it's worthwhile.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> The gains here are relatively smaller and noisier than for the previous
> patches.

Indeed, in an earlier illogical version then it had a bigger impact but
that was due to buggy side-effects.

> Also I'm afraid that once antifrag loses against the ultimate
> adversary workload (see the "Caching/buffers become useless after some
> time" thread), then this might result in adding stalls to a workload
> that has no other options but to allocate movable pages from partially
> filled unmovable blocks, because that's simply the majority of
> pageblocks in the system, and the stalls can't help the situation. If
> that proves to be true, we could revert, but then there's the new
> user-visible tunable... and that all makes it harder for me to decide
> about this patch :) If only we could find out early while this is in
> linux-mm/linux-next...
> 

I think in the event it has to revert that it would be ok for the tuning
to disappear at the same time. There are occasions where a particular
tuning has side-effects that make it harder to remove the interface but
in this case, the tuning is directly related to the patch itself.

That said, stalling behaviour has been problematic so if we want to play
it safe then I do not mind this patch being dropped until there is a
definite benefit from it as the bulk of the series benefit is from the
first 4 patches.

-- 
Mel Gorman
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA2126B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:22:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 143so2766895wmu.5
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:22:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 96si5976684wrk.320.2017.07.20.06.22.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:22:27 -0700 (PDT)
Date: Thu, 20 Jul 2017 15:22:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170720132225.GI9058@dhcp22.suse.cz>
References: <20170710074842.23175-1-mhocko@kernel.org>
 <alpine.LSU.2.11.1707191823190.2445@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1707191823190.2445@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-07-17 18:54:40, Hugh Dickins wrote:
[...]
> You probably won't welcome getting into alternatives at this late stage;
> but after hacking around it one way or another because of its pointless
> lockups, I lost patience with that too_many_isolated() loop a few months
> back (on realizing the enormous number of pages that may be isolated via
> migrate_pages(2)), and we've been running nicely since with something like:
> 
> 	bool got_mutex = false;
> 
> 	if (unlikely(too_many_isolated(pgdat, file, sc))) {
> 		if (mutex_lock_killable(&pgdat->too_many_isolated))
> 			return SWAP_CLUSTER_MAX;
> 		got_mutex = true;
> 	}
> 	...
> 	if (got_mutex)
> 		mutex_unlock(&pgdat->too_many_isolated);
> 
> Using a mutex to provide the intended throttling, without an infinite
> loop or an arbitrary delay; and without having to worry (as we often did)
> about whether those numbers in too_many_isolated() are really appropriate.
> No premature OOMs complained of yet.
> 
> But that was on a different kernel, and there I did have to make sure
> that PF_MEMALLOC always prevented us from nesting: I'm not certain of
> that in the current kernel (but do remember Johannes changing the memcg
> end to make it use PF_MEMALLOC too).  I offer the preview above, to see
> if you're interested in that alternative: if you are, then I'll go ahead
> and make it into an actual patch against v4.13-rc.

I would rather get rid of any additional locking here and my ultimate
goal is to make throttling at the page allocator layer rather than
inside the reclaim.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

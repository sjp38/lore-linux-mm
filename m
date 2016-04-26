Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A00E86B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 12:29:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so15612984wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:29:32 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id jk2si30798466wjd.134.2016.04.26.09.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 09:29:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 069BA1C1B1C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:29:30 +0100 (IST)
Date: Tue, 26 Apr 2016 17:29:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 15/28] mm, page_alloc: Move might_sleep_if check to the
 allocator slowpath
Message-ID: <20160426162928.GE2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
 <571F7002.5030602@suse.cz>
 <20160426145006.GD2858@techsingularity.net>
 <571F8645.6060503@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <571F8645.6060503@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2016 at 05:16:21PM +0200, Vlastimil Babka wrote:
> On 04/26/2016 04:50 PM, Mel Gorman wrote:
> >On Tue, Apr 26, 2016 at 03:41:22PM +0200, Vlastimil Babka wrote:
> >>On 04/15/2016 11:07 AM, Mel Gorman wrote:
> >>>There is a debugging check for callers that specify __GFP_DIRECT_RECLAIM
> >>>from a context that cannot sleep. Triggering this is almost certainly
> >>>a bug but it's also overhead in the fast path.
> >>
> >>For CONFIG_DEBUG_ATOMIC_SLEEP, enabling is asking for the overhead. But for
> >>CONFIG_PREEMPT_VOLUNTARY which turns it into _cond_resched(), I guess it's
> >>not.
> >>
> >
> >Either way, it struck me as odd. It does depend on the config and it's
> >marginal so if there is a problem then I can drop it.
> 
> What I tried to say is that it makes sense, but it's perhaps non-obvious :)
> 
> >>>Move the check to the slow
> >>>path. It'll be harder to trigger as it'll only be checked when watermarks
> >>>are depleted but it'll also only be checked in a path that can sleep.
> >>
> >>Hmm what about zone_reclaim_mode=1, should the check be also duplicated to
> >>that part of get_page_from_freelist()?
> >>
> >
> >zone_reclaim has a !gfpflags_allow_blocking() check, does not call
> >cond_resched() before that check so it does not fall into an accidental
> >sleep path. I'm not seeing why the check is necessary there.
> 
> Hmm I thought the primary purpose of this might_sleep_if() is to catch those
> (via the DEBUG_ATOMIC_SLEEP) that do pass __GFP_DIRECT_RECLAIM (which means
> gfpflags_allow_blocking() will be true and zone_reclaim will proceed),

It proceeds but fails immediately so what I'm failing to see is why
moving the check increases risk. I wanted to remove the check from the
path where the problem it's catching cannot happen. It does mean the
debugging check is made less frequently but it's still useful. If you
feel the safety is preferred then I'll drop the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

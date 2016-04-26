Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2CA06B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:50:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so13435550wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:50:10 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id f85si3668708wmi.89.2016.04.26.07.50.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:50:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id C75A91C15B4
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:50:07 +0100 (IST)
Date: Tue, 26 Apr 2016 15:50:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 15/28] mm, page_alloc: Move might_sleep_if check to the
 allocator slowpath
Message-ID: <20160426145006.GD2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
 <571F7002.5030602@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <571F7002.5030602@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2016 at 03:41:22PM +0200, Vlastimil Babka wrote:
> On 04/15/2016 11:07 AM, Mel Gorman wrote:
> >There is a debugging check for callers that specify __GFP_DIRECT_RECLAIM
> >from a context that cannot sleep. Triggering this is almost certainly
> >a bug but it's also overhead in the fast path.
> 
> For CONFIG_DEBUG_ATOMIC_SLEEP, enabling is asking for the overhead. But for
> CONFIG_PREEMPT_VOLUNTARY which turns it into _cond_resched(), I guess it's
> not.
> 

Either way, it struck me as odd. It does depend on the config and it's
marginal so if there is a problem then I can drop it.

> >Move the check to the slow
> >path. It'll be harder to trigger as it'll only be checked when watermarks
> >are depleted but it'll also only be checked in a path that can sleep.
> 
> Hmm what about zone_reclaim_mode=1, should the check be also duplicated to
> that part of get_page_from_freelist()?
> 

zone_reclaim has a !gfpflags_allow_blocking() check, does not call
cond_resched() before that check so it does not fall into an accidental
sleep path. I'm not seeing why the check is necessary there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

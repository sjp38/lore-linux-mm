Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 170916B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:46:47 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id a140so13633480wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:46:47 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m136si18494474wmb.94.2016.04.11.06.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 06:46:45 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a140so21417733wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:46:45 -0700 (PDT)
Date: Mon, 11 Apr 2016 15:46:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/11] mm, compaction: distinguish between full and
 partial COMPACT_COMPLETE
Message-ID: <20160411134633.GJ23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-7-git-send-email-mhocko@kernel.org>
 <570B9432.9090600@suse.cz>
 <20160411124653.GG23157@dhcp22.suse.cz>
 <570B9E50.9040000@suse.cz>
 <20160411132745.GH23157@dhcp22.suse.cz>
 <570BA9BD.2030404@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570BA9BD.2030404@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-04-16 15:42:21, Vlastimil Babka wrote:
> On 04/11/2016 03:27 PM, Michal Hocko wrote:
> >On Mon 11-04-16 14:53:36, Vlastimil Babka wrote:
> >>On 04/11/2016 02:46 PM, Michal Hocko wrote:
> >>
> >>The racy part is negligible but I didn't realize the sync/async migrate
> >>scanner part until now. So yeah, free_pfn could have got to middle of zone
> >>when it was in the async mode. But that also means that the async mode
> >>recently used up all free pages in the second half of the zone. WRT free
> >>pages isolation, async mode is not trying less than sync, so it shouldn't be
> >>a considerable missed opportunity if we don't rescan the it, though.
> >
> >I am not really sure I understand. The primary intention of this patch
> >is to distinguish where we have scanned basically whole zones from cases
> >where a new scan started off previous mark and so it was just unlucky to
> >see only tiny bit of the zone where we would clearly give up too early.
> >FWIU this shouldn't be the case if we start scanning from the beginning
> >of the zone even if we raced on the other end of the zone because the
> >missed part would be negligible. Is that understanding correct?
> 
> Yes, it should be less unlucky than seeing a tiny bit of the zone. Just
> wanted to point out that you might still not see the whole zone in one
> compaction attempt. E.g. async compaction is first, advances the free
> scanner and caches its position when it bails out due to being contended.
> Then direct reclaim frees some pages behind the cached position. Sync
> compaction attempts starts migration scanner from start_pfn, but picks up
> the cached free scanner pfn. The result is missing some free pages and the
> scanners meeting somewhat earlier than they otherwise would. Probably not
> critical even for OOM decisions, as that's also racy anyway.

OK, I see now. I agree this shouldn't be critical and thanks for the
clarification.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

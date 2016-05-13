Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5F036B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:15:42 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id tb5so29531979lbb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:15:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id uw10si22362582wjc.242.2016.05.13.07.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:15:41 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so3978830wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:15:41 -0700 (PDT)
Date: Fri, 13 May 2016 16:15:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160513141539.GR20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-13-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:36:02, Vlastimil Babka wrote:
> During reclaim/compaction loop, compaction priority can be increased by the
> should_compact_retry() function, but the current code is not optimal for
> several reasons:
> 
> - priority is only increased when compaction_failed() is true, which means
>   that compaction has scanned the whole zone. This may not happen even after
>   multiple attempts with the lower priority due to parallel activity, so we
>   might needlessly struggle on the lower priority.

OK, I can see that this can be changed if we have a guarantee that at
least one full round is guaranteed. Which seems to be the case for the
lowest priority.

> 
> - should_compact_retry() is only called when should_reclaim_retry() returns
>   false. This means that compaction priority cannot get increased as long
>   as reclaim makes sufficient progress. Theoretically, reclaim should stop
>   retrying for high-order allocations as long as the high-order page doesn't
>   exist but due to races, this may result in spurious retries when the
>   high-order page momentarily does exist.

This is intentional behavior and I would like to preserve it if it is
possible. For higher order pages should_reclaim_retry retries as long
as there are some eligible high order pages present which are just hidden
by the watermark check. So this is mostly to get us over watermarks to
start carrying about fragmentation. If we race there then nothing really
terrible should happen and we should eventually converge to a terminal
state.

Does this make sense to you?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

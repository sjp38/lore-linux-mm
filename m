Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7B2D6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:53:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so61349184wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:53:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si14195556wmd.62.2016.04.28.01.53.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 01:53:19 -0700 (PDT)
Subject: Re: [PATCH 09/14] mm: use compaction feedback for thp backoff
 conditions
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-10-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5721CF7E.9020106@suse.cz>
Date: Thu, 28 Apr 2016 10:53:18 +0200
MIME-Version: 1.0
In-Reply-To: <1461181647-8039-10-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/20/2016 09:47 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> THP requests skip the direct reclaim if the compaction is either
> deferred or contended to reduce stalls which wouldn't help the
> allocation success anyway. These checks are ignoring other potential
> feedback modes which we have available now.
>
> It clearly doesn't make much sense to go and reclaim few pages if the
> previous compaction has failed.
>
> We can also simplify the check by using compaction_withdrawn which
> checks for both COMPACT_CONTENDED and COMPACT_DEFERRED. This check
> is however covering more reasons why the compaction was withdrawn.
> None of them should be a problem for the THP case though.
>
> It is safe to back of if we see COMPACT_SKIPPED because that means
> that compaction_suitable failed and a single round of the reclaim is
> unlikely to make any difference here. We would have to be close to
> the low watermark to reclaim enough and even then there is no guarantee
> that the compaction would make any progress while the direct reclaim
> would have caused the stall.
>
> COMPACT_PARTIAL_SKIPPED is slightly different because that means that we
> have only seen a part of the zone so a retry would make some sense. But
> it would be a compaction retry not a reclaim retry to perform. We are
> not doing that and that might indeed lead to situations where THP fails
> but this should happen only rarely and it would be really hard to
> measure.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

THP's don't compact by default in page fault path anymore, so we don't 
need to restrict them even more. And hopefully we'll replace the 
is_thp_gfp_mask() hack with something better soon, so this might be just 
extra code churn. But I don't feel strongly enough to nack it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

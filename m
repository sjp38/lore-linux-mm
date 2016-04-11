Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0C76B0263
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:24:07 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id n3so100009098wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:24:07 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jr1si28324495wjb.156.2016.04.11.04.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:24:06 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l6so20491357wml.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:24:06 -0700 (PDT)
Date: Mon, 11 Apr 2016 13:24:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 05/11] mm, compaction: distinguish COMPACT_DEFERRED from
 COMPACT_SKIPPED
Message-ID: <20160411112404.GE23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-6-git-send-email-mhocko@kernel.org>
 <570B843C.8050608@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570B843C.8050608@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-04-16 13:02:20, Vlastimil Babka wrote:
> On 04/05/2016 01:25 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >try_to_compact_pages can currently return COMPACT_SKIPPED even when the
> >compaction is defered for some zone just because zone DMA is skipped
> >in 99% of cases due to watermark checks. This makes COMPACT_DEFERRED
> >basically unusable for the page allocator as a feedback mechanism.
> >
> >Make sure we distinguish those two states properly and switch their
> >ordering in the enum. This would mean that the COMPACT_SKIPPED will be
> >returned only when all eligible zones are skipped.
> >
> >This shouldn't introduce any functional change.
> 
> Hmm, really? __alloc_pages_direct_compact() does distinguish
> COMPACT_DEFERRED, and sets *deferred compaction, so ultimately this is some
> change for THP allocations?

Hmm, you are right. In cases where we would return COMPACTION_SKIPED
even though there is a zone which would really like to tell us
COMPACT_DEFERRED then we would previously did __alloc_pages_direct_reclaim
and then bail out for THP which do not have __GFP_REPEAT while now we
would recognize DEFERRED and bail out without the direct reclaim. So
there is a functional change. Adnrew, could you drop the sentence about
no functional change and replace it by the following?

"
As a result COMPACT_DEFERRED handling for THP in __alloc_pages_slowpath
will be more precise and we would bail out rather than reclaim.
"

> Also there's no mention of COMPACT_INACTIVE in the changelog (which indeed
> isn't functional change, but might surprise somebody).
> 
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Patch itself is OK.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

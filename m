Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDC906B0260
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:39:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so70664806lfg.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 05:39:06 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id xy10si587961wjc.159.2016.04.28.05.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 05:39:05 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so23004769wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 05:39:05 -0700 (PDT)
Date: Thu, 28 Apr 2016 14:39:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
Message-ID: <20160428123904.GH31489@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-15-git-send-email-mhocko@kernel.org>
 <5721D0EA.3020205@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5721D0EA.3020205@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 28-04-16 10:59:22, Vlastimil Babka wrote:
> On 04/20/2016 09:47 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >"mm: consider compaction feedback also for costly allocation" has
> >removed the upper bound for the reclaim/compaction retries based on the
> >number of reclaimed pages for costly orders. While this is desirable
> >the patch did miss a mis interaction between reclaim, compaction and the
> >retry logic.
> 
> Hmm perhaps reversing the order of patches 13 and 14 would be a bit safer
> wrt future bisections then? Add compaction_zonelist_suitable() first with
> the reasoning, and then immediately use it in the other patch.

Hmm, I do not think the risk is high. This would require the allocate
GFP_REPEAT large orders to the last drop which is not usual. I found the
ordering more logical to argue about because this patch will be mostly
noop for costly orders without 13 and !costly allocations retry
endlessly anyway. So I would prefer this ordering even though there is
a window where an extreme load can lockup. I do not expect people
shooting their head during bisection.

[...]
> >
> >[vbabka@suse.cz: fix classzone_idx vs. high_zoneidx usage in
> >compaction_zonelist_suitable]
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
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

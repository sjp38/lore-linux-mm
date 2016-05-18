Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68F0B6B0253
	for <linux-mm@kvack.org>; Wed, 18 May 2016 09:50:08 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ga2so24088644lbc.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 06:50:08 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id f5si10541494wjt.204.2016.05.18.06.50.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 06:50:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 54A9998D81
	for <linux-mm@kvack.org>; Wed, 18 May 2016 13:50:06 +0000 (UTC)
Date: Wed, 18 May 2016 14:50:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
Message-ID: <20160518135004.GE2527@techsingularity.net>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
 <20160516092505.GE23146@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160516092505.GE23146@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, May 16, 2016 at 11:25:05AM +0200, Michal Hocko wrote:
> On Tue 10-05-16 09:36:03, Vlastimil Babka wrote:
> > Compaction has been using watermark checks when deciding whether it was
> > successful, and whether compaction is at all suitable. There are few problems
> > with these checks.
> > 
> > - __compact_finished() uses low watermark in a check that has to pass if
> >   the direct compaction is to finish and allocation should succeed. This is
> >   too pessimistic, as the allocation will typically use min watermark. It
> >   may happen that during compaction, we drop below the low watermark (due to
> >   parallel activity), but still form the target high-order page. By checking
> >   against low watermark, we might needlessly continue compaction. After this
> >   patch, the check uses direct compactor's alloc_flags to determine the
> >   watermark, which is effectively the min watermark.
> 
> OK, this makes some sense. It would be great if we could have at least
> some clarification why the low wmark has been used previously. Probably
> Mel can remember?
> 

Two reasons -- it was a very rough estimate of whether enough pages are free
for compaction to have any chance. Secondly, it was to minimise the risk
that compaction would isolate so many pages that the zone was completely
depleted. This was a concern during the initial prototype of compaction.

> > - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
> >   to decide if there's enough free memory to perform compaction. This check
> 
> And this was a real head scratcher when I started looking into the
> compaction recently. Why do we need to be above low watermark to even
> start compaction. Compaction uses additional memory only for a short
> period of time and then releases the already migrated pages.
> 

Simply minimising the risk that compaction would deplete the entire
zone. Sure, it hands pages back shortly afterwards. At the time of the
initial prototype, page migration was severely broken and the system was
constantly crashing. The cautious checks were left in place after page
migration was fixed as there wasn't a compelling reason to remove them
at the time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

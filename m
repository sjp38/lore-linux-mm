Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DECE6B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:27:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a17so15384555wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:27:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x9si10784486wjp.55.2016.05.18.07.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 07:27:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so13291813wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:27:55 -0700 (PDT)
Date: Wed, 18 May 2016 16:27:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
Message-ID: <20160518142753.GJ21654@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
 <20160516092505.GE23146@dhcp22.suse.cz>
 <20160518135004.GE2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518135004.GE2527@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed 18-05-16 14:50:04, Mel Gorman wrote:
> On Mon, May 16, 2016 at 11:25:05AM +0200, Michal Hocko wrote:
> > On Tue 10-05-16 09:36:03, Vlastimil Babka wrote:
> > > Compaction has been using watermark checks when deciding whether it was
> > > successful, and whether compaction is at all suitable. There are few problems
> > > with these checks.
> > > 
> > > - __compact_finished() uses low watermark in a check that has to pass if
> > >   the direct compaction is to finish and allocation should succeed. This is
> > >   too pessimistic, as the allocation will typically use min watermark. It
> > >   may happen that during compaction, we drop below the low watermark (due to
> > >   parallel activity), but still form the target high-order page. By checking
> > >   against low watermark, we might needlessly continue compaction. After this
> > >   patch, the check uses direct compactor's alloc_flags to determine the
> > >   watermark, which is effectively the min watermark.
> > 
> > OK, this makes some sense. It would be great if we could have at least
> > some clarification why the low wmark has been used previously. Probably
> > Mel can remember?
> > 
> 
> Two reasons -- it was a very rough estimate of whether enough pages are free
> for compaction to have any chance. Secondly, it was to minimise the risk
> that compaction would isolate so many pages that the zone was completely
> depleted. This was a concern during the initial prototype of compaction.
> 
> > > - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
> > >   to decide if there's enough free memory to perform compaction. This check
> > 
> > And this was a real head scratcher when I started looking into the
> > compaction recently. Why do we need to be above low watermark to even
> > start compaction. Compaction uses additional memory only for a short
> > period of time and then releases the already migrated pages.
> > 
> 
> Simply minimising the risk that compaction would deplete the entire
> zone. Sure, it hands pages back shortly afterwards. At the time of the
> initial prototype, page migration was severely broken and the system was
> constantly crashing. The cautious checks were left in place after page
> migration was fixed as there wasn't a compelling reason to remove them
> at the time.

OK, then moving to min_wmark + bias from low_wmark should work, right?
This would at least remove the discrepancy between the reclaim and
compaction thresholds to some degree. Which is good IMHO.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

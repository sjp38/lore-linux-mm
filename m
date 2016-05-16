Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3FA6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 08:30:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so42250936wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 05:30:56 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id k62si19841997wmf.79.2016.05.16.05.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 05:30:54 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id g17so133520914wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 05:30:54 -0700 (PDT)
Date: Mon, 16 May 2016 14:30:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
Message-ID: <20160516123053.GI23146@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
 <20160516092505.GE23146@dhcp22.suse.cz>
 <573997DE.6010109@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573997DE.6010109@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 16-05-16 11:50:22, Vlastimil Babka wrote:
> On 05/16/2016 11:25 AM, Michal Hocko wrote:
> > On Tue 10-05-16 09:36:03, Vlastimil Babka wrote:
> > > Compaction has been using watermark checks when deciding whether it was
> > > successful, and whether compaction is at all suitable. There are few problems
> > > with these checks.
> > > 
> > > - __compact_finished() uses low watermark in a check that has to pass if
> > >    the direct compaction is to finish and allocation should succeed. This is
> > >    too pessimistic, as the allocation will typically use min watermark. It
> > >    may happen that during compaction, we drop below the low watermark (due to
> > >    parallel activity), but still form the target high-order page. By checking
> > >    against low watermark, we might needlessly continue compaction. After this
> > >    patch, the check uses direct compactor's alloc_flags to determine the
> > >    watermark, which is effectively the min watermark.
> > 
> > OK, this makes some sense. It would be great if we could have at least
> > some clarification why the low wmark has been used previously. Probably
> > Mel can remember?
> > 
> > > - __compaction_suitable has the same issue in the check whether the allocation
> > >    is already supposed to succeed and we don't need to compact. Fix it the same
> > >    way.
> > > 
> > > - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
> > >    to decide if there's enough free memory to perform compaction. This check
> > 
> > And this was a real head scratcher when I started looking into the
> > compaction recently. Why do we need to be above low watermark to even
> > start compaction.
> 
> Hmm, above you said you're fine with low wmark (maybe after clarification).
> I don't know why it was used, can only guess.

Yes I can imagine this would be a good backoff for costly orders without
__GFP_REPEAT.

> > Compaction uses additional memory only for a short
> > period of time and then releases the already migrated pages.
> 
> As for the 2 << order gap. I can imagine that e.g. order-5 compaction (32
> pages) isolates 20 pages for migration and starts looking for free pages. It
> collects 19 free pages and then reaches an order-4 free page. Splitting that
> page to collect it would result in 19+16=35 pages isolated, thus exceed the
> 1 << order gap, and fail. With 2 << order gap, chances of this happening are
> reduced.

OK, fair enough but that sounds like a case which is not worth optimize
and introduce a subtle code for.

[...]

> > > - __isolate_free_page uses low watermark check to decide if free page can be
> > >    isolated. It also doesn't use ALLOC_CMA, so add it for the same reasons.
> > 
> > Why do we check the watermark at all? What would happen if this obscure
> > if (!is_migrate_isolate(mt)) was gone? I remember I put some tracing
> > there and it never hit for me even when I was testing close to OOM
> > conditions. Maybe an earlier check bailed out but this code path looks
> > really obscure so it should either deserve a large fat comment or to
> > die.
> 
> The check is there so that compaction doesn't exhaust memory below reserves
> during its work, just like any other non-privileged allocation.

Hmm. OK this is a fair point. I would expect that the reclaim preceeding
the compaction would compensate for the temporarily used memory but it
is true that a) we might be in the optimistic async compaction which
happens _before_ the reclaim and b) the reclaim might be not effective
enough so some throttling is indeed appropriate.

I guess you do not want to rely on throttling only at the beginning of
the compaction because it would be too racy, which would be true. So I
guess it would be indeed safer to check for the watermark both when we
attempt to compact and when we isolate free pages. Can we at least use a
common helper so that we know that those checks are done same way?
 
 Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

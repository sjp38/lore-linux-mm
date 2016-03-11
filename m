Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id A29D06B0255
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:06:50 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so17310160wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:06:50 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id k188si2626861wmd.53.2016.03.11.05.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 05:06:49 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id p65so2345203wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:06:49 -0800 (PST)
Date: Fri, 11 Mar 2016 14:06:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
Message-ID: <20160311130647.GO27701@dhcp22.suse.cz>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
 <20160309111109.GG27018@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603110354360.7920@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603110354360.7920@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 11-03-16 04:17:30, Hugh Dickins wrote:
> On Wed, 9 Mar 2016, Michal Hocko wrote:
> > Joonsoo has pointed out that this attempt is still not sufficient
> > becasuse we might have invoked only a single compaction round which
> > is might be not enough. I fully agree with that. Here is my take on
> > that. It is again based on the number of retries loop.
> > 
> > I was also playing with an idea of doing something similar to the
> > reclaim retry logic:
> > 	if (order) {
> > 		if (compaction_made_progress(compact_result)
> > 			no_compact_progress = 0;
> > 		else if (compaction_failed(compact_result)
> > 			no_compact_progress++;
> > 	}
> > but it is compaction_failed() part which is not really
> > straightforward to define. Is it COMPACT_NO_SUITABLE_PAGE
> > resp. COMPACT_NOT_SUITABLE_ZONE sufficient? compact_finished and
> > compaction_suitable however hide this from compaction users so it
> > seems like we can never see it.
> > 
> > Maybe we can update the feedback mechanism from the compaction but
> > retries count seems reasonably easy to understand and pragmatic. If
> > we cannot form a order page after we tried for N times then it really
> > doesn't make much sense to continue and we are oom for this order. I am
> > holding my breath to hear from Hugh on this, though.
> 
> Never a wise strategy.  But I just got around to it tonight.
> 
> I do believe you've nailed it with this patch!  Thank you!

That's a great news! Thanks for testing.

> I've applied 1/3, 2/3 and this (ah, it became the missing 3/3 later on)
> on top of 4.5.0-rc5-mm1 (I think there have been a couple of mmotms since,
> but I've not got to them yet): so far it is looking good on all machines.
> 
> After a quick go with the simple make -j20 in tmpfs, which survived
> a cycle on the laptop, I've switched back to my original tougher load,
> and that's going well so far: no sign of any OOMs.  But I've interrupted
> on the laptop to report back to you now, then I'll leave it running
> overnight.

OK, let's wait for the rest of the tests but I find it really optimistic
considering how easily you could trigger the issue previously. Anyway
I hope for your Tested-by after you are reasonably confident your loads
are behaving well.

[...]
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index b167801187e7..7d028ccf440a 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -61,6 +61,12 @@ extern void compaction_defer_reset(struct zone *zone, int order,
> >  				bool alloc_success);
> >  extern bool compaction_restarting(struct zone *zone, int order);
> >  
> > +static inline bool compaction_made_progress(enum compact_result result)
> > +{
> > +	return (compact_result > COMPACT_SKIPPED &&
> > +				compact_result < COMPACT_NO_SUITABLE_PAGE)
> 
> That line didn't build at all:
> 
>         return result > COMPACT_SKIPPED && result < COMPACT_NO_SUITABLE_PAGE;

those last minute changes... Sorry about that. Fixed.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

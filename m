Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E74BB6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:21:56 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so109426913wml.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:21:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 82si19344544wmu.80.2016.03.14.09.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 09:21:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l68so16189415wml.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:21:55 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:21:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
Message-ID: <20160314162153.GD11400@dhcp22.suse.cz>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
 <20160309111109.GG27018@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603110354360.7920@eggly.anvils>
 <20160311130647.GO27701@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603111058510.26840@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603111058510.26840@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 11-03-16 11:08:05, Hugh Dickins wrote:
> On Fri, 11 Mar 2016, Michal Hocko wrote:
> > On Fri 11-03-16 04:17:30, Hugh Dickins wrote:
> > > On Wed, 9 Mar 2016, Michal Hocko wrote:
> > > > Joonsoo has pointed out that this attempt is still not sufficient
> > > > becasuse we might have invoked only a single compaction round which
> > > > is might be not enough. I fully agree with that. Here is my take on
> > > > that. It is again based on the number of retries loop.
> > > > 
> > > > I was also playing with an idea of doing something similar to the
> > > > reclaim retry logic:
> > > > 	if (order) {
> > > > 		if (compaction_made_progress(compact_result)
> > > > 			no_compact_progress = 0;
> > > > 		else if (compaction_failed(compact_result)
> > > > 			no_compact_progress++;
> > > > 	}
> > > > but it is compaction_failed() part which is not really
> > > > straightforward to define. Is it COMPACT_NO_SUITABLE_PAGE
> > > > resp. COMPACT_NOT_SUITABLE_ZONE sufficient? compact_finished and
> > > > compaction_suitable however hide this from compaction users so it
> > > > seems like we can never see it.
> > > > 
> > > > Maybe we can update the feedback mechanism from the compaction but
> > > > retries count seems reasonably easy to understand and pragmatic. If
> > > > we cannot form a order page after we tried for N times then it really
> > > > doesn't make much sense to continue and we are oom for this order. I am
> > > > holding my breath to hear from Hugh on this, though.
> > > 
> > > Never a wise strategy.  But I just got around to it tonight.
> > > 
> > > I do believe you've nailed it with this patch!  Thank you!
> > 
> > That's a great news! Thanks for testing.
> > 
> > > I've applied 1/3, 2/3 and this (ah, it became the missing 3/3 later on)
> > > on top of 4.5.0-rc5-mm1 (I think there have been a couple of mmotms since,
> > > but I've not got to them yet): so far it is looking good on all machines.
> > > 
> > > After a quick go with the simple make -j20 in tmpfs, which survived
> > > a cycle on the laptop, I've switched back to my original tougher load,
> > > and that's going well so far: no sign of any OOMs.  But I've interrupted
> > > on the laptop to report back to you now, then I'll leave it running
> > > overnight.
> > 
> > OK, let's wait for the rest of the tests but I find it really optimistic
> > considering how easily you could trigger the issue previously. Anyway
> > I hope for your Tested-by after you are reasonably confident your loads
> > are behaving well.
> 
> Three have been stably running load for between 6 and 7 hours now,
> no problems, looking very good:
> 
> Tested-by: Hugh Dickins <hughd@google.com>

Thanks!

> I'll be interested to see how my huge tmpfs loads fare with the rework,
> but I'm not quite ready to try that today; and any issue there (I've no
> reason to suppose that there will be) can be a separate investigation
> for me to make at some future date.  It was this order=2 regression
> that was holding me back, and I've now no objection to your patches
> (though nobody should imagine that I've actually studied them).

I still have some work on top pending and I do not want to rush these
changes and target this for 4.7. 4.6 is just too close and I would hate
to push some last minute changes. I think oom_reaper would be large
enough for 4.6 in this area. 

I will post the full series after rc1. Andrew feel free to drop it from
the mmotm tree for now. I would prefer they got all reviewed together
rather than a larger number of fixups.

Thanks Hugh for your testing. I wish I could depend on it less but I've
not been able to reproduce not matter how much I tried.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

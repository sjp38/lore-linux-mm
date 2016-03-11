Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 844526B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:08:14 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so106096897pad.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 11:08:14 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id bx6si15562644pad.6.2016.03.11.11.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 11:08:13 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id tt10so106743581pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 11:08:13 -0800 (PST)
Date: Fri, 11 Mar 2016 11:08:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
In-Reply-To: <20160311130647.GO27701@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1603111058510.26840@eggly.anvils>
References: <20160307160838.GB5028@dhcp22.suse.cz> <1457444565-10524-1-git-send-email-mhocko@kernel.org> <1457444565-10524-4-git-send-email-mhocko@kernel.org> <20160309111109.GG27018@dhcp22.suse.cz> <alpine.LSU.2.11.1603110354360.7920@eggly.anvils>
 <20160311130647.GO27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 11 Mar 2016, Michal Hocko wrote:
> On Fri 11-03-16 04:17:30, Hugh Dickins wrote:
> > On Wed, 9 Mar 2016, Michal Hocko wrote:
> > > Joonsoo has pointed out that this attempt is still not sufficient
> > > becasuse we might have invoked only a single compaction round which
> > > is might be not enough. I fully agree with that. Here is my take on
> > > that. It is again based on the number of retries loop.
> > > 
> > > I was also playing with an idea of doing something similar to the
> > > reclaim retry logic:
> > > 	if (order) {
> > > 		if (compaction_made_progress(compact_result)
> > > 			no_compact_progress = 0;
> > > 		else if (compaction_failed(compact_result)
> > > 			no_compact_progress++;
> > > 	}
> > > but it is compaction_failed() part which is not really
> > > straightforward to define. Is it COMPACT_NO_SUITABLE_PAGE
> > > resp. COMPACT_NOT_SUITABLE_ZONE sufficient? compact_finished and
> > > compaction_suitable however hide this from compaction users so it
> > > seems like we can never see it.
> > > 
> > > Maybe we can update the feedback mechanism from the compaction but
> > > retries count seems reasonably easy to understand and pragmatic. If
> > > we cannot form a order page after we tried for N times then it really
> > > doesn't make much sense to continue and we are oom for this order. I am
> > > holding my breath to hear from Hugh on this, though.
> > 
> > Never a wise strategy.  But I just got around to it tonight.
> > 
> > I do believe you've nailed it with this patch!  Thank you!
> 
> That's a great news! Thanks for testing.
> 
> > I've applied 1/3, 2/3 and this (ah, it became the missing 3/3 later on)
> > on top of 4.5.0-rc5-mm1 (I think there have been a couple of mmotms since,
> > but I've not got to them yet): so far it is looking good on all machines.
> > 
> > After a quick go with the simple make -j20 in tmpfs, which survived
> > a cycle on the laptop, I've switched back to my original tougher load,
> > and that's going well so far: no sign of any OOMs.  But I've interrupted
> > on the laptop to report back to you now, then I'll leave it running
> > overnight.
> 
> OK, let's wait for the rest of the tests but I find it really optimistic
> considering how easily you could trigger the issue previously. Anyway
> I hope for your Tested-by after you are reasonably confident your loads
> are behaving well.

Three have been stably running load for between 6 and 7 hours now,
no problems, looking very good:

Tested-by: Hugh Dickins <hughd@google.com>

I'll be interested to see how my huge tmpfs loads fare with the rework,
but I'm not quite ready to try that today; and any issue there (I've no
reason to suppose that there will be) can be a separate investigation
for me to make at some future date.  It was this order=2 regression
that was holding me back, and I've now no objection to your patches
(though nobody should imagine that I've actually studied them).

Thank you, Michal.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

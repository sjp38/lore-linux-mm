Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 000806B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 00:22:29 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so71733661pad.0
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 21:22:29 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id yv4si793126pab.119.2016.03.06.21.22.28
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 21:22:29 -0800 (PST)
Date: Mon, 7 Mar 2016 14:23:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160307052305.GA25517@js1304-P5Q-DELUXE>
References: <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
 <20160303152514.GG26202@dhcp22.suse.cz>
 <20160304052327.GA13022@js1304-P5Q-DELUXE>
 <20160304151558.GF31257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160304151558.GF31257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Mar 04, 2016 at 04:15:58PM +0100, Michal Hocko wrote:
> On Fri 04-03-16 14:23:27, Joonsoo Kim wrote:
> > On Thu, Mar 03, 2016 at 04:25:15PM +0100, Michal Hocko wrote:
> > > On Thu 03-03-16 23:10:09, Joonsoo Kim wrote:
> > > > 2016-03-03 18:26 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> [...]
> > > > >> I guess that usual case for high order allocation failure has enough freepage.
> > > > >
> > > > > Not sure I understand you mean here but I wouldn't be surprised if high
> > > > > order failed even with enough free pages. And that is exactly why I am
> > > > > claiming that reclaiming more pages is no free ticket to high order
> > > > > pages.
> > > > 
> > > > I didn't say that it's free ticket. OOM kill would be the most expensive ticket
> > > > that we have. Why do you want to kill something?
> > > 
> > > Because all the attempts so far have failed and we should rather not
> > > retry endlessly. With the band-aid we know we will retry
> > > MAX_RECLAIM_RETRIES at most. So compaction had that many attempts to
> > > resolve the situation along with the same amount of reclaim rounds to
> > > help and get over watermarks.
> > > 
> > > > It also doesn't guarantee to make high order pages. It is just another
> > > > way of reclaiming memory. What is the difference between plain reclaim
> > > > and OOM kill? Why do we use OOM kill in this case?
> > > 
> > > What is our alternative other than keep looping endlessly?
> > 
> > Loop as long as free memory or estimated available memory (free +
> > reclaimable) increases. This means that we did some progress. And,
> > they will not grow forever because we have just limited reclaimable
> > memory and limited memory. You can reset no_progress_loops = 0 when
> > those metric increases than before.
> 
> Hmm, why is this any better than taking the feedback from the reclaim
> (did_some_progress)?

My suggestion could be only applied to high order case. In this case,
free page and reclaimable page is already sufficient and parallel
free page consumer would re-generate reclaimable page endlessly so
positive did_some_progress will be returned endlessy. We need to stop
retry at some point so we need some metric that ensures finite retry
in any case.

>  
> > With this bound, we can do our best to try to solve this unpleasant
> > situation before OOM.
> > 
> > Unconditional 16 looping and then OOM kill really doesn't make any
> > sense, because it doesn't mean that we already do our best.
> 
> 16 is not really that important. We can change that if that doesn't
> sounds sufficient. But please note that each reclaim round means
> that we have scanned all eligible LRUs to find and reclaim something
> and asked direct compaction to prepare a high order page.
> This sounds like "do our best" to me.

AFAIK, each reclaim round doesn't reclaim all reclaimable page. It has
a limit to reclaim. It looks not our best to me and N retry only
multipies that limit N times. It also doesn't look like our best to
me and will lead to premature OOM kill.

> Now it seems that we need more changes at least in the compaction area
> because the code doesn't seem to fit the nature of !costly allocation
> requests. I am also not satisfied with the fixed MAX_RECLAIM_RETRIES for
> high order pages, I would much rather see some feedback mechanism which
> would measurable and evaluated in some way but is this really necessary
> for the initial version?

I don't know. My analysis is just based on my guess and background knowledge,
not practical usecase, so I'm not sure it is necessary for the initial
version or not. It's up to you.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

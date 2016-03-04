Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id BF7296B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 10:16:01 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so39336287wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:16:01 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h130si4446386wmh.7.2016.03.04.07.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 07:16:00 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id p65so4638435wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:16:00 -0800 (PST)
Date: Fri, 4 Mar 2016 16:15:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304151558.GF31257@dhcp22.suse.cz>
References: <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
 <20160303152514.GG26202@dhcp22.suse.cz>
 <20160304052327.GA13022@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160304052327.GA13022@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri 04-03-16 14:23:27, Joonsoo Kim wrote:
> On Thu, Mar 03, 2016 at 04:25:15PM +0100, Michal Hocko wrote:
> > On Thu 03-03-16 23:10:09, Joonsoo Kim wrote:
> > > 2016-03-03 18:26 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
[...]
> > > >> I guess that usual case for high order allocation failure has enough freepage.
> > > >
> > > > Not sure I understand you mean here but I wouldn't be surprised if high
> > > > order failed even with enough free pages. And that is exactly why I am
> > > > claiming that reclaiming more pages is no free ticket to high order
> > > > pages.
> > > 
> > > I didn't say that it's free ticket. OOM kill would be the most expensive ticket
> > > that we have. Why do you want to kill something?
> > 
> > Because all the attempts so far have failed and we should rather not
> > retry endlessly. With the band-aid we know we will retry
> > MAX_RECLAIM_RETRIES at most. So compaction had that many attempts to
> > resolve the situation along with the same amount of reclaim rounds to
> > help and get over watermarks.
> > 
> > > It also doesn't guarantee to make high order pages. It is just another
> > > way of reclaiming memory. What is the difference between plain reclaim
> > > and OOM kill? Why do we use OOM kill in this case?
> > 
> > What is our alternative other than keep looping endlessly?
> 
> Loop as long as free memory or estimated available memory (free +
> reclaimable) increases. This means that we did some progress. And,
> they will not grow forever because we have just limited reclaimable
> memory and limited memory. You can reset no_progress_loops = 0 when
> those metric increases than before.

Hmm, why is this any better than taking the feedback from the reclaim
(did_some_progress)?
 
> With this bound, we can do our best to try to solve this unpleasant
> situation before OOM.
> 
> Unconditional 16 looping and then OOM kill really doesn't make any
> sense, because it doesn't mean that we already do our best.

16 is not really that important. We can change that if that doesn't
sounds sufficient. But please note that each reclaim round means
that we have scanned all eligible LRUs to find and reclaim something
and asked direct compaction to prepare a high order page.
This sounds like "do our best" to me.

Now it seems that we need more changes at least in the compaction area
because the code doesn't seem to fit the nature of !costly allocation
requests. I am also not satisfied with the fixed MAX_RECLAIM_RETRIES for
high order pages, I would much rather see some feedback mechanism which
would measurable and evaluated in some way but is this really necessary
for the initial version?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

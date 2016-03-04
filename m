Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id CE89C6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 02:10:31 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id y8so5110833igp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 23:10:31 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id ga4si2450586igd.34.2016.03.03.23.10.30
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 23:10:31 -0800 (PST)
Date: Fri, 4 Mar 2016 16:10:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304071053.GB13317@js1304-P5Q-DELUXE>
References: <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
 <56D85D38.1060404@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D85D38.1060404@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Mar 03, 2016 at 04:50:16PM +0100, Vlastimil Babka wrote:
> On 03/03/2016 03:10 PM, Joonsoo Kim wrote:
> > 
> >> [...]
> >>>>> At least, reset no_progress_loops when did_some_progress. High
> >>>>> order allocation up to PAGE_ALLOC_COSTLY_ORDER is as important
> >>>>> as order 0. And, reclaim something would increase probability of
> >>>>> compaction success.
> >>>>
> >>>> This is something I still do not understand. Why would reclaiming
> >>>> random order-0 pages help compaction? Could you clarify this please?
> >>>
> >>> I just can tell simple version. Please check the link from me on another reply.
> >>> Compaction could scan more range of memory if we have more freepage.
> >>> This is due to algorithm limitation. Anyway, so, reclaiming random
> >>> order-0 pages helps compaction.
> >>
> >> I will have a look at that code but this just doesn't make any sense.
> >> The compaction should be reshuffling pages, this shouldn't be a function
> >> of free memory.
> > 
> > Please refer the link I mentioned before. There is a reason why more free
> > memory would help compaction success. Compaction doesn't work
> > like as random reshuffling. It has an algorithm to reduce system overall
> > fragmentation so there is limitation.
> 
> I proposed another way to get better results from direct compaction -
> don't scan for free pages but get them directly from freelists:
> 
> https://lkml.org/lkml/2015/12/3/60
> 

I think that major problem of this approach is that there is no way
to prevent other parallel compacting thread from taking freepage on
targetted aligned block. So, if there are parallel compaction requestors,
they would disturb each others. However, it would not be a problem for order
up to PAGE_ALLOC_COSTLY_ORDER which would be finished so soon.

In fact, for quick allocation, migration scanner is also unnecessary.
There would be a lot of pageblock we cannot do migration. Scanning
all of them in this situation is unnecessary and costly. Moreover, scanning
only half of zone due to limitation of compaction algorithm also looks
not good. Instead, we can get base page on lru list and migrate
neighborhood pages. I named this idea as "lumpy compaction" but didn't
try it. If we only focus on quick allocation, this would be a better way.
Any thought?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

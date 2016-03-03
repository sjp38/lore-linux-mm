Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E356C6B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:26:31 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so38562185wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:26:31 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id e3si49296754wjn.27.2016.03.03.08.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 08:26:30 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id 1so4953178wmg.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:26:30 -0800 (PST)
Date: Thu, 3 Mar 2016 17:26:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160303162628.GI26202@dhcp22.suse.cz>
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
Cc: Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu 03-03-16 16:50:16, Vlastimil Babka wrote:
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

Yes this makes perfect sense to me (with my limited experience in
this area so I might be missing some obvious problems this would
introduce). The direct compaction for !costly orders is something
we should better satisfy immediately. I would just object that this
shouldn't be reduced to ASYNC compaction requests only. SYNC* modes are
even a more desperate call (at least that is my understanding) for the
page and we should treat them the appropriately.

> But your redesign would be useful too for kcompactd/khugepaged keeping
> overall fragmentation low.

kcompactd can handle and should focus on the long term goals.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

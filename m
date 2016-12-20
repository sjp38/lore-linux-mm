Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C73F6B0323
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:35:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so25371212wme.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 06:35:05 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id lm8si22874362wjb.234.2016.12.20.06.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 06:35:04 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id j10so27938256wjb.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 06:35:04 -0800 (PST)
Date: Tue, 20 Dec 2016 15:35:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
Message-ID: <20161220143501.GI3769@dhcp22.suse.cz>
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220091814.GC3769@dhcp22.suse.cz>
 <20161220131040.f5ga5426dduh3mhu@techsingularity.net>
 <20161220132643.GG3769@dhcp22.suse.cz>
 <20161220142845.drbedcibjcggdxk7@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220142845.drbedcibjcggdxk7@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>

On Tue 20-12-16 14:28:45, Mel Gorman wrote:
> On Tue, Dec 20, 2016 at 02:26:43PM +0100, Michal Hocko wrote:
> > On Tue 20-12-16 13:10:40, Mel Gorman wrote:
> > > On Tue, Dec 20, 2016 at 10:18:14AM +0100, Michal Hocko wrote:
> > > > On Mon 12-12-16 13:59:07, Jia He wrote:
> > > > > In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
> > > > > zone_statistics"), it reconstructed codes to reduce the branch miss rate.
> > > > > Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
> > > > >  z->node would not be equal to preferred_zone->node. That seems to be
> > > > > incorrect.
> > > > 
> > > > I am sorry but I have hard time following the changelog. It is clear
> > > > that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
> > > > but it is not really clear when such thing happens. You are adding
> > > > preferred_zone->node check. preferred_zone is the first zone in the
> > > > requested zonelist. So for the most allocations it is a node from the
> > > > local node. But if something request an explicit numa node (without
> > > > __GFP_OTHER_NODE which would be the majority I suspect) then we could
> > > > indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
> > > > referenced patch indeed caused an unintended change of accounting AFAIU.
> > > > 
> > > 
> > > This is a similar concern to what I had. If the preferred zone, which is
> > > the first valid usable zone, is not a "hit" for the statistics then I
> > > don't know what "hit" is meant to mean.
> > 
> > But the first valid usable zone is defined based on the requested numa
> > node. Unless the requested node is memoryless then we should have a hit,
> > no?
> > 
> 
> Should be. If the local node is memoryless then there would be a difference
> between hit and whether it's local or not but that to me is a little
> useless. A local vs remote page allocated has a specific meaning and
> consequence. It's hard to see how hit can be meaningfully interpreted if
> there are memoryless nodes. I don't have a strong objection to the patch
> so I didn't nak it, I'm just not convinced it matters.

So what do you think about
http://lkml.kernel.org/r/20161220091814.GC3769@dhcp22.suse.cz

I think that we should get rid of __GFP_OTHER_NODE thingy. It is just
one off thing and the gfp space it rather precious.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

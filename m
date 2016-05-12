Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 333426B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 01:19:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gw7so91554668pac.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 22:19:09 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s138si4422041pfs.165.2016.05.11.22.19.07
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 22:19:08 -0700 (PDT)
Date: Thu, 12 May 2016 14:19:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160512051913.GA13185@js1304-P5Q-DELUXE>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
 <20160510094347.GH23576@dhcp22.suse.cz>
 <20160512022334.GA8215@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512022334.GA8215@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 12, 2016 at 11:23:34AM +0900, Joonsoo Kim wrote:
> On Tue, May 10, 2016 at 11:43:48AM +0200, Michal Hocko wrote:
> > On Tue 10-05-16 15:41:04, Joonsoo Kim wrote:
> > > 2016-05-05 3:16 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > > > On Wed 04-05-16 23:32:31, Joonsoo Kim wrote:
> > > >> 2016-05-04 17:47 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > [...]
> > > >> > progress. What is the usual reason to disable compaction in the first
> > > >> > place?
> > > >>
> > > >> I don't disable it. But, who knows who disable compaction? It's been *not*
> > > >> a long time that CONFIG_COMPACTION is default enable. Maybe, 3 years?
> > > >
> > > > I would really like to hear about real life usecase before we go and
> > > > cripple otherwise deterministic algorithms. It might be very well
> > > > possible that those configurations simply do not have problems with high
> > > > order allocations because they are too specific.
> > 
> > Sorry for insisting but I would really like to hear some answer for
> > this, please.
> 
> I don't know. Who knows? How you can make sure that? And, I don't like
> below fixup. Theoretically, it could retry forever.
> 
> > 
> > [...]
> > > >> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > >> > index 2e7e26c5d3ba..f48b9e9b1869 100644
> > > >> > --- a/mm/page_alloc.c
> > > >> > +++ b/mm/page_alloc.c
> > > >> > @@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> > > >> >                      enum migrate_mode *migrate_mode,
> > > >> >                      int compaction_retries)
> > > >> >  {
> > > >> > +       struct zone *zone;
> > > >> > +       struct zoneref *z;
> > > >> > +
> > > >> > +       if (order > PAGE_ALLOC_COSTLY_ORDER)
> > > >> > +               return false;
> > > >> > +
> > > >> > +       /*
> > > >> > +        * There are setups with compaction disabled which would prefer to loop
> > > >> > +        * inside the allocator rather than hit the oom killer prematurely. Let's
> > > >> > +        * give them a good hope and keep retrying while the order-0 watermarks
> > > >> > +        * are OK.
> > > >> > +        */
> > > >> > +       for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> > > >> > +                                       ac->nodemask) {
> > > >> > +               if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> > > >> > +                                       ac->high_zoneidx, alloc_flags))
> > > >> > +                       return true;
> > > >> > +       }
> > > >> >         return false;
> > [...]
> > > My benchmark is too specific so I make another one. It does very
> > > simple things.
> > > 
> > > 1) Run the system with 256 MB memory and 2 GB swap
> > > 2) Run memory-hogger which takes (anonymous memory) 256 MB
> > > 3) Make 1000 new processes by fork (It will take 16 MB order-2 pages)
> > > 
> > > You can do it yourself with above instructions.
> > > 
> > > On current upstream kernel without CONFIG_COMPACTION, OOM doesn't happen.
> > > On next-20160509 kernel without CONFIG_COMPACTION, OOM happens when
> > > roughly *500* processes forked.
> > > 
> > > With CONFIG_COMPACTION, OOM doesn't happen on any kernel.
> > 
> > Does the patch I have posted helped?
> 
> I guess that it will help but please do it by yourself. It's simple.
> 
> > > Other kernels doesn't trigger OOM even if I make 10000 new processes.
> > 
> > Is this an usual load on !CONFIG_COMPACTION configurations?
> 
> I don't know. User-space developer doesn't take care about kernel
> configuration and it seems that fork 500 times when memory is full is
> not a corner case to me.
> 
> > > This example is very intuitive and reasonable. I think that it's not
> > > artificial.  It has enough swap space so OOM should not happen.
> > 
> > I am not really convinced this is true actually. You can have an
> > arbitrary amount of the swap space yet it still won't help you
> > because more reclaimed memory simply doesn't imply a more continuous
> > memory. This is a fundamental problem. So I think that relying on
> > !CONFIG_COMPACTION for heavy fork (or other high order) loads simply
> > never works reliably.
> 
> I think that you don't understand how powerful the reclaim and
> compaction are. In the system with large disk swap, what compaction can do
> is also possible for reclaim. Reclaim can do more.
> 
> Think about following examples.
> 
> _: free
> U: used(unmovable)
> M: used(migratable and reclaimable)
> 
> _MUU _U_U MMMM MMMM
> 
> With compaction (assume theoretically best algorithm),
> just 3 contiguous region can be made like as following:
> 
> MMUU MUMU ___M MMMM
> 
> With reclaim, we can make 8 contiguous region.
> 
> __UU _U_U ____ ____
> 
> Reclaim can be easily affected by thrashing but it is fundamentally
> more powerful than compaction.

Hmm... I uses wrong example here because if there is enough freepage,
compaction using theoretically best algorithm can make enoguh
contiguous region. We ensure that by watermark check so it has no
problem like as above. Anyway, you can see that reclaim has at least
enough power to make high order page. That's what I'd like to express
by using this example.

> 
> Even, there are not migratable but reclaimable pages and it could weak
> power of the compaction.

This is still true and one of limitation of compaction.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

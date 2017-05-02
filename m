Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 848FA6B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 09:32:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n198so1873264wmg.9
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:32:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s110si15613992wrc.179.2017.05.02.06.32.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 06:32:33 -0700 (PDT)
Date: Tue, 2 May 2017 15:32:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170502133229.GK14593@dhcp22.suse.cz>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502040129.GA27335@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue 02-05-17 13:01:32, Joonsoo Kim wrote:
> On Thu, Apr 27, 2017 at 05:06:36PM +0200, Michal Hocko wrote:
[...]
> > I see this point and I agree that using a specific zone might be a
> > _nicer_ solution in the end but you have to consider another aspects as
> > well. The main one I am worried about is a long term maintainability.
> > We are really out of page flags and consuming one for a rather specific
> > usecase is not good. Look at ZONE_DMA. I am pretty sure that almost
> > no sane HW needs 16MB zone anymore, yet we have hard time to get rid
> > of it and so we have that memory laying around unused all the time
> > and blocking one page flag bit. CMA falls into a similar category
> > AFAIU. I wouldn't be all that surprised if a future HW will not need CMA
> > allocations in few years, yet we will have to fight to get rid of it
> > like we do with ZONE_DMA. And not only that. We will also have to fight
> > finding page flags for other more general usecases in the meantime.
> 
> This maintenance problem is inherent. This problem exists even if we
> uses MIGRATETYPE approach. We cannot remove many hooks for CMA if a
> future HW will not need CMA allocation in few years. The only
> difference is that one takes single zone bit only for CMA user and the
> other approach takes many hooks that we need to take care about it all
> the time.

And I consider this a big difference. Because while hooks are not nice
they will affect CMA users (in a sense of bugs/performance etc.). While
an additional bit consumed will affect potential future and more generic
features.

[...]
> > I believe that the overhead in the hot path is not such a big deal. We
> > have means to make it 0 when CMA is not used by jumplabels. I assume
> > that the vast majority of systems will not use CMA. Those systems which
> > use CMA should be able to cope with some slight overhead IMHO.
> 
> Please don't underestimate number of CMA user. Most of android device
> uses CMA. So, there would be more devices using CMA than the server
> not using CMA. They also have a right to experience the best performance.

This is not a fair comparison, though. Android development model is much
more faster and tend to not care about future maintainability at all. I
do not know about any android device that would run on a clean vanilla
kernel because vendors simply do not care enough (or have time) to put
the code into a proper shape to upstream it. I understand that this
model might work quite well for rapidly changing and moving mobile or
IoT segment but it is not the greatest fit to motivate the core kernel
subsystem development. We are not in the drivers space!

[...]
> > This looks like a nice clean up. Those ifdefs are ugly as hell. One
> > could argue that some of that could be cleaned up by simply adding some
> > helpers (with a jump label to reduce the overhead), though. But is this
> > really strong enough reason to bring the whole zone in? I am not really
> > convinced to be honest.
> 
> Please don't underestimate the benefit of this patchset.
> I have said that we need *more* hooks to fix all the problems.
> 
> And, please think that this code removal is not only code removal but
> also concept removal. With this removing, we don't need to consider
> ALLOC_CMA for alloc_flags when calling zone_watermark_ok(). There are
> many bugs on it and it still remains. We don't need to consider
> pageblock migratetype when handling pageblock migratetype. We don't
> need to take a great care about calculating the number of CMA
> freepages.

And all this can be isolated to CMA specific hooks with mostly minimum
impact to most users. I hear you saying that zone approach is more natural
and I would agree if we wouldn't have to care about the number of zones.

> > [...]
> > 
> > > > Please do _not_ take this as a NAK from me. At least not at this time. I
> > > > am still trying to understand all the consequences but my intuition
> > > > tells me that building on top of highmem like approach will turn out to
> > > > be problematic in future (as we have already seen with the highmem and
> > > > movable zones) so this needs a very prudent consideration.
> > > 
> > > I can understand that you are prudent to this issue. However, it takes more
> > > than two years and many people already expressed that ZONE approach is the
> > > way to go.
> > 
> > I can see a single Acked-by and one Reviewed-by. It would be much more
> > convincing to see much larger support. Do not take me wrong I am not
> > trying to undermine the feedback so far but we should be clear about one
> > thing. CMA is mostly motivated by the industry which tries to overcome
> > HW limitations which can change in future very easily. I would rather
> > see good enough solution for something like that than a nicer solution
> > which is pushing additional burden on more general usecases.
> 
> First of all, current MIGRATETYPE approach isn't good enough to me.
> They caused too many problems and there are many remanining problems.
> It will causes maintenance issue for a long time.
> 
> And, although good enough solution can be better than nicer solution
> in some cases, it looks like current situation isn't that case.
> There is a single reason, saving page flag bit, to support good enough
> solution.
> 
> I'd like to ask reversly. Is this a enough reason to make CMA user to
> suffer from bugs?

No, but I haven't heard any single argument that those bugs are
impossible to fix with the current approach. They might be harder to fix
but if I can chose between harder for CMA and harder for other more
generic HW independent features I will go for the first one. And do not
take me wrong, I have nothing against CMA as such. It solves a real life
problem. I just believe it doesn't deserve to consume a new bit in page
flags because that is just too scarce resource.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

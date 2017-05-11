Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 395D26B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 05:13:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c15so4926173wmd.14
        for <linux-mm@kvack.org>; Thu, 11 May 2017 02:13:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si8255wmi.38.2017.05.11.02.13.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 02:13:07 -0700 (PDT)
Date: Thu, 11 May 2017 11:13:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170511091304.GH26782@dhcp22.suse.cz>
References: <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
 <20170502133229.GK14593@dhcp22.suse.cz>
 <20170511021240.GA22319@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170511021240.GA22319@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Thu 11-05-17 11:12:43, Joonsoo Kim wrote:
> Sorry for the late response. I was on a vacation.
> 
> On Tue, May 02, 2017 at 03:32:29PM +0200, Michal Hocko wrote:
> > On Tue 02-05-17 13:01:32, Joonsoo Kim wrote:
> > > On Thu, Apr 27, 2017 at 05:06:36PM +0200, Michal Hocko wrote:
> > [...]
> > > > I see this point and I agree that using a specific zone might be a
> > > > _nicer_ solution in the end but you have to consider another aspects as
> > > > well. The main one I am worried about is a long term maintainability.
> > > > We are really out of page flags and consuming one for a rather specific
> > > > usecase is not good. Look at ZONE_DMA. I am pretty sure that almost
> > > > no sane HW needs 16MB zone anymore, yet we have hard time to get rid
> > > > of it and so we have that memory laying around unused all the time
> > > > and blocking one page flag bit. CMA falls into a similar category
> > > > AFAIU. I wouldn't be all that surprised if a future HW will not need CMA
> > > > allocations in few years, yet we will have to fight to get rid of it
> > > > like we do with ZONE_DMA. And not only that. We will also have to fight
> > > > finding page flags for other more general usecases in the meantime.
> > > 
> > > This maintenance problem is inherent. This problem exists even if we
> > > uses MIGRATETYPE approach. We cannot remove many hooks for CMA if a
> > > future HW will not need CMA allocation in few years. The only
> > > difference is that one takes single zone bit only for CMA user and the
> > > other approach takes many hooks that we need to take care about it all
> > > the time.
> > 
> > And I consider this a big difference. Because while hooks are not nice
> > they will affect CMA users (in a sense of bugs/performance etc.). While
> > an additional bit consumed will affect potential future and more generic
> > features.
> 
> Because these hooks are so tricky and are spread on many places,
> bugs about these hooks can be made by *non-CMA* user and they hurt
> *CMA* user. These hooks could also delay non-CMA user's development speed
> since there are many hooks about CMA and understanding how CMA is managed
> is rather difficult.

Than make those hooks easier to maintain. Seriously this is a
non-argument.

[...]

> > And all this can be isolated to CMA specific hooks with mostly minimum
> > impact to most users. I hear you saying that zone approach is more natural
> > and I would agree if we wouldn't have to care about the number of zones.
> 
> I attach a solution about one more bit in page flags although I don't
> agree with your opinion that additional bit is no-go approach. Just
> note that we have already used three bits for zone encoding in some
> configuration due to ZONE_DEVICE.

I am absolutely not happy about ZONE_DEVICE but there is _no_ other
viable solution right now. I know that people behind this are still
considering struct page over direct pfn usage but they are not in the
same situation as CMA which _can_ work without additional zone.

If you _really_ insist on using zone for CMA then reuse ZONE_MOVABLE.
I absolutely miss why do you push a specialized zone so hard.

[...]
> > No, but I haven't heard any single argument that those bugs are
> > impossible to fix with the current approach. They might be harder to fix
> > but if I can chose between harder for CMA and harder for other more
> > generic HW independent features I will go for the first one. And do not
> > take me wrong, I have nothing against CMA as such. It solves a real life
> > problem. I just believe it doesn't deserve to consume a new bit in page
> > flags because that is just too scarce resource.
> 
> As I mentioned above, I think that maintenance overhead due to CMA
> deserves to consume a new bit in page flags. It also provide us
> extendability to introduce more zones in the future.
> 
> Anyway, this value-judgement is subjective so I guess that we
> cannot agree with each other. To solve your concern,
> I make following solution. Please let me know your opinion about this.
> This patch can be applied on top of my ZONE_CMA series.

I don not think this makes situation any easier or more acceptable for
merging.

But I feel we are looping without much progress. So let me NAK this
until it is _proven_ that the current code is unfixable nor ZONE_MOVABLE
can be reused
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

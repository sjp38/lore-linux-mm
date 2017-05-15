Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7566B0038
	for <linux-mm@kvack.org>; Sun, 14 May 2017 23:57:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q125so102207877pgq.8
        for <linux-mm@kvack.org>; Sun, 14 May 2017 20:57:27 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id 70si9686399pfp.320.2017.05.14.20.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 May 2017 20:57:26 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id e193so56028866pfh.0
        for <linux-mm@kvack.org>; Sun, 14 May 2017 20:57:26 -0700 (PDT)
Date: Mon, 15 May 2017 12:57:15 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170515035712.GA11257@js1304-desktop>
References: <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
 <20170502133229.GK14593@dhcp22.suse.cz>
 <20170511021240.GA22319@js1304-desktop>
 <20170511091304.GH26782@dhcp22.suse.cz>
 <20170512020046.GA5538@js1304-desktop>
 <20170512063815.GC6803@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170512063815.GC6803@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Fri, May 12, 2017 at 08:38:15AM +0200, Michal Hocko wrote:
> On Fri 12-05-17 11:00:48, Joonsoo Kim wrote:
> > On Thu, May 11, 2017 at 11:13:04AM +0200, Michal Hocko wrote:
> > > On Thu 11-05-17 11:12:43, Joonsoo Kim wrote:
> > > > Sorry for the late response. I was on a vacation.
> > > > 
> > > > On Tue, May 02, 2017 at 03:32:29PM +0200, Michal Hocko wrote:
> > > > > On Tue 02-05-17 13:01:32, Joonsoo Kim wrote:
> > > > > > On Thu, Apr 27, 2017 at 05:06:36PM +0200, Michal Hocko wrote:
> > > > > [...]
> > > > > > > I see this point and I agree that using a specific zone might be a
> > > > > > > _nicer_ solution in the end but you have to consider another aspects as
> > > > > > > well. The main one I am worried about is a long term maintainability.
> > > > > > > We are really out of page flags and consuming one for a rather specific
> > > > > > > usecase is not good. Look at ZONE_DMA. I am pretty sure that almost
> > > > > > > no sane HW needs 16MB zone anymore, yet we have hard time to get rid
> > > > > > > of it and so we have that memory laying around unused all the time
> > > > > > > and blocking one page flag bit. CMA falls into a similar category
> > > > > > > AFAIU. I wouldn't be all that surprised if a future HW will not need CMA
> > > > > > > allocations in few years, yet we will have to fight to get rid of it
> > > > > > > like we do with ZONE_DMA. And not only that. We will also have to fight
> > > > > > > finding page flags for other more general usecases in the meantime.
> > > > > > 
> > > > > > This maintenance problem is inherent. This problem exists even if we
> > > > > > uses MIGRATETYPE approach. We cannot remove many hooks for CMA if a
> > > > > > future HW will not need CMA allocation in few years. The only
> > > > > > difference is that one takes single zone bit only for CMA user and the
> > > > > > other approach takes many hooks that we need to take care about it all
> > > > > > the time.
> > > > > 
> > > > > And I consider this a big difference. Because while hooks are not nice
> > > > > they will affect CMA users (in a sense of bugs/performance etc.). While
> > > > > an additional bit consumed will affect potential future and more generic
> > > > > features.
> > > > 
> > > > Because these hooks are so tricky and are spread on many places,
> > > > bugs about these hooks can be made by *non-CMA* user and they hurt
> > > > *CMA* user. These hooks could also delay non-CMA user's development speed
> > > > since there are many hooks about CMA and understanding how CMA is managed
> > > > is rather difficult.
> > > 
> > > Than make those hooks easier to maintain. Seriously this is a
> > > non-argument.
> > 
> > I can't understand what you said here. 
> 
> I wanted to say that you can make those hooks so non-intrusive that
> nobody outside of the CMA has to even care that CMA exists.

I guess that current code is the result of such effort and it would be
intrusive.

> 
> > With zone approach, someone who
> > isn't related to CMA don't need to understand how CMA is managed.
> > 
> > > 
> > > [...]
> > > 
> > > > > And all this can be isolated to CMA specific hooks with mostly minimum
> > > > > impact to most users. I hear you saying that zone approach is more natural
> > > > > and I would agree if we wouldn't have to care about the number of zones.
> > > > 
> > > > I attach a solution about one more bit in page flags although I don't
> > > > agree with your opinion that additional bit is no-go approach. Just
> > > > note that we have already used three bits for zone encoding in some
> > > > configuration due to ZONE_DEVICE.
> > > 
> > > I am absolutely not happy about ZONE_DEVICE but there is _no_ other
> > > viable solution right now. I know that people behind this are still
> > > considering struct page over direct pfn usage but they are not in the
> > > same situation as CMA which _can_ work without additional zone.
> > 
> > IIUC, ZONE_DEVICE can reuse the other zone and migratetype.
> 
> They are not going to migrate anything or define any allocation fallback
> policy because those pages are outside of the page allocator completely.
> And that is why a zone approach is a reasonable approach. There are
> probably other ways and I will certainly push going that way.

I have a different opinion but it's not a main issue here so I don't
argue anymore.

> [...]
> 
> > > If you _really_ insist on using zone for CMA then reuse ZONE_MOVABLE.
> > > I absolutely miss why do you push a specialized zone so hard.
> > 
> > As I said before, there is no fundamental issue to reuse ZONE_MOVABLE.
> > I just don't want to reuse it because they have a different
> > characteristic. In MM subsystem context, their characteristic is the same.
> > However, CMA memory should be used for the device in runtime so more
> > allocation guarantee is needed. See the offline_pages() in
> > mm/memory_hotplug.c. They can bear in 120 sec to offline the
> > memory but CMA memory can't.
> 
> This is just an implementation detail. Pinned pages in the CMA ranges
> should be easilly checked. Moreover memory hotplug cares only about
> hotplugable memory and placing CMA ranges there could be seen as a
> configuration bug.

I just wanted to say that there is a difference and I'm worry about
that it would cause the unexpected problem in the future. We can
easily distinguish them by adding another explicit check but I don't
think that this is the best.

> > And, this is a design issue. I don't want to talk about why should we
> > pursuit the good design. Originally, ZONE exists to manage different
> > type of memory. Migratetype is not for that purpose. Using separate
> > zone fits the original purpose. Mixing them would be a bad design and
> > we would esaily encounter the unexpected problem in the future.
> 
> As I've said earlier. Abusing ZONE_MOVABLE is not ideal either. I would
> rather keep the status quo and fix the cluttered code and make it easier
> to follow. But if you absolutely insist that a specialized zone is
> necessary then ZONE_MOVABLE a) already exists and we do not need to
> consume another bit b) most of the CMA zone characteristics overlap
> with MOVABLE. So it is the least painful zone to use with the current
> restrictions we have.

I also think that using ZONE_MOVALBE for CMA memory is a good
candidate to consider. I will consider it more deeply.

> > > [...]
> > > > > No, but I haven't heard any single argument that those bugs are
> > > > > impossible to fix with the current approach. They might be harder to fix
> > > > > but if I can chose between harder for CMA and harder for other more
> > > > > generic HW independent features I will go for the first one. And do not
> > > > > take me wrong, I have nothing against CMA as such. It solves a real life
> > > > > problem. I just believe it doesn't deserve to consume a new bit in page
> > > > > flags because that is just too scarce resource.
> > > > 
> > > > As I mentioned above, I think that maintenance overhead due to CMA
> > > > deserves to consume a new bit in page flags. It also provide us
> > > > extendability to introduce more zones in the future.
> > > > 
> > > > Anyway, this value-judgement is subjective so I guess that we
> > > > cannot agree with each other. To solve your concern,
> > > > I make following solution. Please let me know your opinion about this.
> > > > This patch can be applied on top of my ZONE_CMA series.
> > > 
> > > I don not think this makes situation any easier or more acceptable for
> > > merging.
> > 
> > Please say the reason. This implementation don't use additional bit in
> > page flags that you concerned about. And, there is no performance
> > regression at least in my simple test.
> 
> I really do not want to question your "simple test" but page_zonenum is
> used in many performance sensitive paths and proving it doesn't regress
> would require testing many different workload. Are you going to do that?

In fact, I don't think that we need to take care about this
performance problem seriously. The reasons are that:

1. Currently, there is a usable bit in the page flags.
2. Even if others consume one usable bit, there still exists spare bit
in 64b kernel. And, for 32b kernel, the number of the zone can be five
if both, ZONE_CMA and ZONE_HIGHMEM, are used. And, using ZONE_HIGHMEM
in 32b system is out of the trend.
3. Even if we fall into the latter category, I can optimize it not to
regress if both the zone, ZONE_MOVABLE and ZONE_CMA, aren't used
simultaneously with two zone bits in page flags. However, using both
zones is not usual case.
4. This performance problem only affects CMA users and there is also a
benefit due to removal of many hooks in MM subsystem so net result would
not be worse.

So, I think that performance would be better in most of cases. It
would be magianlly worse in rare cases and they could bear with it. Do
you still think that using ZONE_MOVABLE for CMA memory is
necessary rather than separate zone, ZONE_CMA?

> > > But I feel we are looping without much progress. So let me NAK this
> > > until it is _proven_ that the current code is unfixable nor ZONE_MOVABLE
> > > can be reused
> > 
> > I want to open all the possibilty so could you check that ZONE_MOVABLE
> > can be overlapped with other zones? IIRC, your rework doesn't allow
> > it.
> 
> My rework keeps the status quo, which is based on the assumption that
> zones cannot overlap. A longer term plan is that this restriction is
> removed. As I've said earlier overlapping zones is an interesting
> concept which is definitely worth pursuing.

Okay. We did a lot of discussion so it's better to summarise it.

1. ZONE_CMA might be a nicer solution than MIGRATETYPE.
2. Additional bit in page flags would cause another kind of
maintenance problem so it's better to avoid it as much as possible.
3. Abusing ZONE_MOVABLE looks better than introducing ZONE_CMA since
it doesn't need additional bit in page flag.
4. (Not-yet-finished) If ZONE_CMA doesn't need extra bit in page
flags with hacky magic and it has no performance regression,
??? (it's okay to use separate zone for CMA?)

If you clarify your opinion on forth argument, I will try to think the
best approach with considering these arguements.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

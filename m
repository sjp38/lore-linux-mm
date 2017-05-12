Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30E736B02EE
	for <linux-mm@kvack.org>; Thu, 11 May 2017 22:01:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d11so36425365pgn.9
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:01:01 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 144si1772242pfa.118.2017.05.11.19.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 19:01:00 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u187so5641175pgb.1
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:01:00 -0700 (PDT)
Date: Fri, 12 May 2017 11:00:48 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170512020046.GA5538@js1304-desktop>
References: <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
 <20170502133229.GK14593@dhcp22.suse.cz>
 <20170511021240.GA22319@js1304-desktop>
 <20170511091304.GH26782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170511091304.GH26782@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Thu, May 11, 2017 at 11:13:04AM +0200, Michal Hocko wrote:
> On Thu 11-05-17 11:12:43, Joonsoo Kim wrote:
> > Sorry for the late response. I was on a vacation.
> > 
> > On Tue, May 02, 2017 at 03:32:29PM +0200, Michal Hocko wrote:
> > > On Tue 02-05-17 13:01:32, Joonsoo Kim wrote:
> > > > On Thu, Apr 27, 2017 at 05:06:36PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > I see this point and I agree that using a specific zone might be a
> > > > > _nicer_ solution in the end but you have to consider another aspects as
> > > > > well. The main one I am worried about is a long term maintainability.
> > > > > We are really out of page flags and consuming one for a rather specific
> > > > > usecase is not good. Look at ZONE_DMA. I am pretty sure that almost
> > > > > no sane HW needs 16MB zone anymore, yet we have hard time to get rid
> > > > > of it and so we have that memory laying around unused all the time
> > > > > and blocking one page flag bit. CMA falls into a similar category
> > > > > AFAIU. I wouldn't be all that surprised if a future HW will not need CMA
> > > > > allocations in few years, yet we will have to fight to get rid of it
> > > > > like we do with ZONE_DMA. And not only that. We will also have to fight
> > > > > finding page flags for other more general usecases in the meantime.
> > > > 
> > > > This maintenance problem is inherent. This problem exists even if we
> > > > uses MIGRATETYPE approach. We cannot remove many hooks for CMA if a
> > > > future HW will not need CMA allocation in few years. The only
> > > > difference is that one takes single zone bit only for CMA user and the
> > > > other approach takes many hooks that we need to take care about it all
> > > > the time.
> > > 
> > > And I consider this a big difference. Because while hooks are not nice
> > > they will affect CMA users (in a sense of bugs/performance etc.). While
> > > an additional bit consumed will affect potential future and more generic
> > > features.
> > 
> > Because these hooks are so tricky and are spread on many places,
> > bugs about these hooks can be made by *non-CMA* user and they hurt
> > *CMA* user. These hooks could also delay non-CMA user's development speed
> > since there are many hooks about CMA and understanding how CMA is managed
> > is rather difficult.
> 
> Than make those hooks easier to maintain. Seriously this is a
> non-argument.

I can't understand what you said here. With zone approach, someone who
isn't related to CMA don't need to understand how CMA is managed.

> 
> [...]
> 
> > > And all this can be isolated to CMA specific hooks with mostly minimum
> > > impact to most users. I hear you saying that zone approach is more natural
> > > and I would agree if we wouldn't have to care about the number of zones.
> > 
> > I attach a solution about one more bit in page flags although I don't
> > agree with your opinion that additional bit is no-go approach. Just
> > note that we have already used three bits for zone encoding in some
> > configuration due to ZONE_DEVICE.
> 
> I am absolutely not happy about ZONE_DEVICE but there is _no_ other
> viable solution right now. I know that people behind this are still
> considering struct page over direct pfn usage but they are not in the
> same situation as CMA which _can_ work without additional zone.

IIUC, ZONE_DEVICE can reuse the other zone and migratetype. What
they need is just struct page and separate zone is not necessarily needed.
The other thing that they want is to distinguish if the page is for
the ZONE_DEVICE memory or not so it can use similar approach with CMA.

IMHO, there is almost nothing that _cannot_ work in S/W world. What we
need to consider is just trade-off. So, please don't say impossibility
again.

> 
> If you _really_ insist on using zone for CMA then reuse ZONE_MOVABLE.
> I absolutely miss why do you push a specialized zone so hard.

As I said before, there is no fundamental issue to reuse ZONE_MOVABLE.
I just don't want to reuse it because they have a different
characteristic. In MM subsystem context, their characteristic is the same.
However, CMA memory should be used for the device in runtime so more
allocation guarantee is needed. See the offline_pages() in
mm/memory_hotplug.c. They can bear in 120 sec to offline the
memory but CMA memory can't.

And, this is a design issue. I don't want to talk about why should we
pursuit the good design. Originally, ZONE exists to manage different
type of memory. Migratetype is not for that purpose. Using separate
zone fits the original purpose. Mixing them would be a bad design and
we would esaily encounter the unexpected problem in the future.

> 
> [...]
> > > No, but I haven't heard any single argument that those bugs are
> > > impossible to fix with the current approach. They might be harder to fix
> > > but if I can chose between harder for CMA and harder for other more
> > > generic HW independent features I will go for the first one. And do not
> > > take me wrong, I have nothing against CMA as such. It solves a real life
> > > problem. I just believe it doesn't deserve to consume a new bit in page
> > > flags because that is just too scarce resource.
> > 
> > As I mentioned above, I think that maintenance overhead due to CMA
> > deserves to consume a new bit in page flags. It also provide us
> > extendability to introduce more zones in the future.
> > 
> > Anyway, this value-judgement is subjective so I guess that we
> > cannot agree with each other. To solve your concern,
> > I make following solution. Please let me know your opinion about this.
> > This patch can be applied on top of my ZONE_CMA series.
> 
> I don not think this makes situation any easier or more acceptable for
> merging.

Please say the reason. This implementation don't use additional bit in
page flags that you concerned about. And, there is no performance
regression at least in my simple test.

> But I feel we are looping without much progress. So let me NAK this
> until it is _proven_ that the current code is unfixable nor ZONE_MOVABLE
> can be reused

I want to open all the possibilty so could you check that ZONE_MOVABLE
can be overlapped with other zones? IIRC, your rework doesn't allow
it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

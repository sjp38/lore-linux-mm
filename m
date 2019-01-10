Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43F408E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 23:39:43 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so6850082pfi.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 20:39:43 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id a2si7581315pfb.166.2019.01.09.20.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 20:39:41 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Jan 2019 10:09:40 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
In-Reply-To: <fa89d216da811e97428ad155770bcca5eddecc37.camel@linux.intel.com>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <7c81c8bc741819e87e9a2a39a8b1b6d2f8d3423a.camel@linux.intel.com>
 <fdc656df7c54819f60d9a1682c84b14f@codeaurora.org>
 <fa89d216da811e97428ad155770bcca5eddecc37.camel@linux.intel.com>
Message-ID: <210ea658c3bdd074febbe90b19e88615@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2019-01-09 21:39, Alexander Duyck wrote:
> On Wed, 2019-01-09 at 11:51 +0530, Arun KS wrote:
>> On 2019-01-09 03:47, Alexander Duyck wrote:
>> > On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
>> > > When freeing pages are done with higher order, time spent on
>> > > coalescing
>> > > pages by buddy allocator can be reduced.  With section size of 256MB,
>> > > hot
>> > > add latency of a single section shows improvement from 50-60 ms to
>> > > less
>> > > than 1 ms, hence improving the hot add latency by 60 times.  Modify
>> > > external providers of online callback to align with the change.
>> > >
>> > > Signed-off-by: Arun KS <arunks@codeaurora.org>
>> > > Acked-by: Michal Hocko <mhocko@suse.com>
>> > > Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> >
>> > Sorry, ended up encountering a couple more things that have me a bit
>> > confused.
>> >
>> > [...]
>> >
>> > > diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
>> > > index 5301fef..211f3fe 100644
>> > > --- a/drivers/hv/hv_balloon.c
>> > > +++ b/drivers/hv/hv_balloon.c
>> > > @@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start,
>> > > unsigned long size,
>> > >  	}
>> > >  }
>> > >
>> > > -static void hv_online_page(struct page *pg)
>> > > +static int hv_online_page(struct page *pg, unsigned int order)
>> > >  {
>> > >  	struct hv_hotadd_state *has;
>> > >  	unsigned long flags;
>> > > @@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
>> > >  		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
>> > >  			continue;
>> > >
>> > > -		hv_page_online_one(has, pg);
>> > > +		hv_bring_pgs_online(has, pfn, (1UL << order));
>> > >  		break;
>> > >  	}
>> > >  	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
>> > > +
>> > > +	return 0;
>> > >  }
>> > >
>> > >  static int pfn_covered(unsigned long start_pfn, unsigned long
>> > > pfn_cnt)
>> >
>> > So the question I have is why was a return value added to these
>> > functions? They were previously void types and now they are int. What
>> > is the return value expected other than 0?
>> 
>> Earlier with returning a void there was now way for an arch code to
>> denying onlining of this particular page. By using an int as return
>> type, we can implement this. In one of the boards I was using, there 
>> are
>> some pages which should not be onlined because they are used for other
>> purposes(like secure trust zone or hypervisor).
> 
> So where is the code using that? I don't see any functions in the
> kernel that are returning anything other than 0. Maybe you should hold
> off on changing the return type and make that a separate patch to be
> enabled when you add the new functions that can return non-zero values.
> 
> That way if someone wants to backport this they are just getting the
> bits needed to enable the improved hot-plug times without adding the
> extra overhead for changing the return type.

The implementation was in our downstream code. I thought this might be 
useful for someone else in similar situations.
Considering the above mentioned reasons, I ll remove changing the return 
type.

Regards,
Arun

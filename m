Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 492FB6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:12:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n126so5353505wma.7
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:12:47 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id d200si6734330wmd.238.2017.12.22.08.12.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 08:12:46 -0800 (PST)
Received: from mail-it0-f72.google.com ([209.85.214.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <seth.forshee@canonical.com>)
	id 1eSPwD-0000VC-IU
	for linux-mm@kvack.org; Fri, 22 Dec 2017 16:12:45 +0000
Received: by mail-it0-f72.google.com with SMTP id c33so11022958itf.8
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:12:45 -0800 (PST)
Date: Fri, 22 Dec 2017 10:12:40 -0600
From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20171222161240.GA25425@ubuntu-xps13>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
 <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
 <20171201142327.GA16952@ubuntu-xps13>
 <20171218145320.GO16951@dhcp22.suse.cz>
 <20171222144925.GR4831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222144925.GR4831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 22, 2017 at 03:49:25PM +0100, Michal Hocko wrote:
> On Mon 18-12-17 15:53:20, Michal Hocko wrote:
> > On Fri 01-12-17 08:23:27, Seth Forshee wrote:
> > > On Mon, Sep 25, 2017 at 02:58:25PM +0200, Michal Hocko wrote:
> > > > On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> > [...]
> > > > > It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
> > > > > and the problem still occurs there. It's pointing to the call to
> > > > > __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
> > > > > get to via wp_page_copy -> cow_user_page -> copy_user_highpage.
> > > > 
> > > > Hmm, this is interesting. That would mean that we have successfully
> > > > mapped the destination page but its memory is still not accessible.
> > > > 
> > > > Right now I do not see how the patch you have bisected to could make any
> > > > difference because it only postponed the onlining to be independent but
> > > > your config simply onlines automatically so there shouldn't be any
> > > > semantic change. Maybe there is some sort of off-by-one or something.
> > > > 
> > > > I will try to investigate some more. Do you think it would be possible
> > > > to configure kdump on your system and provide me with the vmcore in some
> > > > way?
> > > 
> > > Sorry, I got busy with other stuff and this kind of fell off my radar.
> > > It came to my attention again recently though.
> > 
> > Apology on my side. This has completely fall of my radar.
> > 
> > > I was looking through the hotplug rework changes, and I noticed that
> > > 32-bit x86 previously was using ZONE_HIGHMEM as a default but after the
> > > rework it doesn't look like it's possible for memory to be associated
> > > with ZONE_HIGHMEM when onlining. So I made the change below against 4.14
> > > and am now no longer seeing the oopses.
> > 
> > Thanks a lot for debugging! Do I read the above correctly that the
> > current code simply returns ZONE_NORMAL and maps an unrelated pfn into
> > this zone and that leads to later blowups? Could you attach the fresh
> > boot dmesg output please?
> > 
> > > I'm sure this isn't the correct fix, but I think it does confirm that
> > > the problem is that the memory should be associated with ZONE_HIGHMEM
> > > but is not.
> > 
> > 
> > Yes, the fix is not quite right. HIGHMEM is not a _kernel_ memory
> > zone. The kernel cannot access that memory directly. It is essentially a
> > movable zone from the hotplug API POV. We simply do not have any way to
> > tell into which zone we want to online this memory range in.
> > Unfortunately both zones _can_ be present. It would require an explicit
> > configuration (movable_node and a NUMA hoptlugable nodes running in 32b
> > or and movable memory configured explicitly on the kernel command line).
> > 
> > The below patch is not really complete but I would rather start simple.
> > Maybe we do not even have to care as most 32b users will never use both
> > zones at the same time. I've placed a warning to learn about those.
> > 
> > Does this pass your testing?
> 
> Any chances to test this?

Yes, I should get to testing it soon. I'm working through a backlog of
things I need to get done and this just hasn't quite made it to the top.

> > ---
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 262bfd26baf9..18fec18bdb60 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -855,12 +855,29 @@ static struct zone *default_kernel_zone_for_pfn(int nid, unsigned long start_pfn
> >  	return &pgdat->node_zones[ZONE_NORMAL];
> >  }
> >  
> > +static struct zone *default_movable_zone_for_pfn(int nid)
> > +{
> > +	/*
> > +	 * Please note that 32b HIGHMEM systems might have 2 movable zones
> > +	 * actually so we have to check for both. This is rather ugly hack
> > +	 * to enforce using Highmem on those systems but we do not have a
> > +	 * good user API to tell into which movable zone we should online.
> > +	 * WARN if we have a movable zone which is not highmem.
> > +	 */
> > +#ifdef CONFIG_HIGHMEM
> > +	WARN_ON_ONCE(!zone_movable_is_highmem());
> > +	return &NODE_DATA(nid)->node_zones[ZONE_HIGHMEM];
> > +#else
> > +	return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > +#endif
> > +}
> > +
> >  static inline struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
> >  		unsigned long nr_pages)
> >  {
> >  	struct zone *kernel_zone = default_kernel_zone_for_pfn(nid, start_pfn,
> >  			nr_pages);
> > -	struct zone *movable_zone = &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > +	struct zone *movable_zone = default_movable_zone_for_pfn(nid);
> >  	bool in_kernel = zone_intersects(kernel_zone, start_pfn, nr_pages);
> >  	bool in_movable = zone_intersects(movable_zone, start_pfn, nr_pages);
> >  
> > @@ -886,7 +903,7 @@ struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
> >  		return default_kernel_zone_for_pfn(nid, start_pfn, nr_pages);
> >  
> >  	if (online_type == MMOP_ONLINE_MOVABLE)
> > -		return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> > +		return default_movable_zone_for_pfn(nid);
> >  
> >  	return default_zone_for_pfn(nid, start_pfn, nr_pages);
> >  }
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

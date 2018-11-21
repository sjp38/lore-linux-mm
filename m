Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E31ED6B2520
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:24:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so2604035edb.22
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:24:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si9644617edy.160.2018.11.21.00.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 00:24:31 -0800 (PST)
Message-ID: <1542788654.2940.14.camel@suse.de>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
From: osalvador <osalvador@suse.de>
Date: Wed, 21 Nov 2018 09:24:14 +0100
In-Reply-To: <20181121025231.ggk7zgq53nmqsqds@master>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
	 <20181120073141.GY22247@dhcp22.suse.cz>
	 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
	 <20181121025231.ggk7zgq53nmqsqds@master>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, 2018-11-21 at 02:52 +0000, Wei Yang wrote:
> On Tue, Nov 20, 2018 at 08:58:11AM +0100, osalvador@suse.de wrote:
> > > On the other hand I would like to see the global lock to go away
> > > because
> > > it causes scalability issues and I would like to change it to a
> > > range
> > > lock. This would make this race possible.
> > > 
> > > That being said this is more of a preparatory work than a fix.
> > > One could
> > > argue that pgdat resize lock is abused here but I am not
> > > convinced a
> > > dedicated lock is much better. We do take this lock already and
> > > spanning
> > > its scope seems reasonable. An update to the documentation is
> > > due.
> > 
> > Would not make more sense to move it within the pgdat lock
> > in move_pfn_range_to_zone?
> > The call from free_area_init_core is safe as we are single-thread
> > there.
> > 
> 
> Agree. This would be better.
> 
> > And if we want to move towards a range locking, I even think it
> > would be more
> > consistent if we move it within the zone's span lock (which is
> > already
> > wrapped with a pgdat lock).
> > 
> 
> I lost a little here, just want to confirm with you.
> 
> Instead of call pgdat_resize_lock() around
> init_currently_empty_zone()
> in move_pfn_range_to_zone(), we move init_currently_empty_zone()
> before
> resize_zone_range()?
> 
> This sounds reasonable.

Yeah.
spanned pages are being touched in:

- shrink_pgdat_span
- resize_zone_range
- init_currently_emty_zone

The first two are already protected by the span lock.

In init_currently_empty_zone, we also touch zone_start_pfn, which is
part of the spanned pages (beginning), so I think it makes sense to
also protect it with the span lock.
We just call init_currently_empty_zone in case the zone is empty, so
the race should be not existent to be honest.

But I just think it is more consistent, and since moving it under
spanlock would imply to also have it under pgdat lock, which was the
main point of this, I think we do not have anything to lose.

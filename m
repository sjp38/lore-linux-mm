Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3302C6B06DE
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:45:48 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d11-v6so1070199plo.17
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:45:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w32-v6sor7522293pgl.74.2018.11.09.02.45.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 02:45:47 -0800 (PST)
Date: Fri, 9 Nov 2018 21:45:41 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
Message-ID: <20181109104541.GE9042@350D>
References: <20181106095524.14629-1-mhocko@kernel.org>
 <20181106203518.GC9042@350D>
 <20181107073548.GU27423@dhcp22.suse.cz>
 <20181107125324.GD9042@350D>
 <20181107130655.GE27423@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107130655.GE27423@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 07, 2018 at 02:06:55PM +0100, Michal Hocko wrote:
> On Wed 07-11-18 23:53:24, Balbir Singh wrote:
> > On Wed, Nov 07, 2018 at 08:35:48AM +0100, Michal Hocko wrote:
> > > On Wed 07-11-18 07:35:18, Balbir Singh wrote:
> [...]
> > > > The check seems to be quite aggressive and in a loop that iterates
> > > > pages, but has nothing to do with the page, did you mean to make
> > > > the check
> > > > 
> > > > zone_idx(page_zone(page)) == ZONE_MOVABLE
> > > 
> > > Does it make any difference? Can we actually encounter a page from a
> > > different zone here?
> > > 
> > 
> > Just to avoid page state related issues, do we want to go ahead
> > with the migration if zone_idx(page_zone(page)) != ZONE_MOVABLE.
> 
> Could you be more specific what kind of state related issues you have in
> mind?
> 

I was wondering if page_zone() is setup correctly, but it's setup
upfront, so I don't think that is ever an issue.

> > > > it also skips all checks for pinned pages and other checks
> > > 
> > > Yes, this is intentional and the comment tries to explain why. I wish we
> > > could be add a more specific checks for movable pages - e.g. detect long
> > > term pins that would prevent migration - but we do not have any facility
> > > for that. Please note that the worst case of a false positive is a
> > > repeated migration failure and user has a way to break out of migration
> > > by a signal.
> > >
> > 
> > Basically isolate_pages() will fail as opposed to hotplug failing upfront.
> > The basic assertion this patch makes is that all ZONE_MOVABLE pages that
> > are not reserved are hotpluggable.
> 
> Yes, that is correct.
>

I wonder if it is easier to catch a __SetPageReserved() on ZONE_MOVABLE memory
at set time, the downside is that we never know if that memory will ever be
hot(un)plugged. The patch itself, I think is OK

Acked-by: Balbir Singh <bsingharora@gmail.com>

Balbir Singh.

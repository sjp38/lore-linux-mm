Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id B60CC6B3F9A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:28:52 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id t133so17158983iof.20
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:28:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y42sor21543724ita.24.2018.11.25.18.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 18:28:51 -0800 (PST)
MIME-Version: 1.0
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz> <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master> <20181121071549.GG12932@dhcp22.suse.cz>
In-Reply-To: <20181121071549.GG12932@dhcp22.suse.cz>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Mon, 26 Nov 2018 10:28:40 +0800
Message-ID: <CADZGycYghU=_vXR759mwFhvV=7KKu3z3h1FyWb4OeEMeOY5isg@mail.gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Nov 21, 2018 at 3:15 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Wed 21-11-18 02:52:31, Wei Yang wrote:
> > On Tue, Nov 20, 2018 at 08:58:11AM +0100, osalvador@suse.de wrote:
> > >> On the other hand I would like to see the global lock to go away because
> > >> it causes scalability issues and I would like to change it to a range
> > >> lock. This would make this race possible.
> > >>
> > >> That being said this is more of a preparatory work than a fix. One could
> > >> argue that pgdat resize lock is abused here but I am not convinced a
> > >> dedicated lock is much better. We do take this lock already and spanning
> > >> its scope seems reasonable. An update to the documentation is due.
> > >
> > >Would not make more sense to move it within the pgdat lock
> > >in move_pfn_range_to_zone?
> > >The call from free_area_init_core is safe as we are single-thread there.
> > >
> >
> > Agree. This would be better.
> >
> > >And if we want to move towards a range locking, I even think it would be more
> > >consistent if we move it within the zone's span lock (which is already
> > >wrapped with a pgdat lock).
> > >
> >
> > I lost a little here, just want to confirm with you.
> >
> > Instead of call pgdat_resize_lock() around init_currently_empty_zone()
> > in move_pfn_range_to_zone(), we move init_currently_empty_zone() before
> > resize_zone_range()?
> >
> > This sounds reasonable.
>
> Btw. resolving the existing TODO would be nice as well, now that you are
> looking that direction...
>

Michal,

I took a look at commit f1dd2cd13c4b ("mm, memory_hotplug: do not
associate hotadded memory to zones until online"), and try to understand
this TODO.

The reason to acquire these lock is before this commit, the memory is
associated with zone at physical adding phase, while after this commit,
this is delayed to logical online stage.

But I get some difficulty to understand this TODO. You want to get rid of
these lock? While these locks seem necessary to protect those data of
pgdat/zone. Would you mind sharing more on this statement?

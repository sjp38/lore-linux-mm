Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20F016B0260
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:25:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so15902402wmf.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:25:40 -0800 (PST)
Received: from mail-wj0-f177.google.com (mail-wj0-f177.google.com. [209.85.210.177])
        by mx.google.com with ESMTPS id t10si7003767wmb.0.2016.12.05.01.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 01:25:38 -0800 (PST)
Received: by mail-wj0-f177.google.com with SMTP id tg4so28873174wjb.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:25:38 -0800 (PST)
Date: Mon, 5 Dec 2016 10:25:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silly question about dethrottling
Message-ID: <20161205092536.GE30758@dhcp22.suse.cz>
References: <CAGDaZ_r3-DxOEsGdE2y1UsS_-=UR-Qc0CsouGtcCgoXY3kVotQ@mail.gmail.com>
 <20161205070519.GA30765@dhcp22.suse.cz>
 <CAGDaZ_oXcWVVAugGetVV2qBR9kJ-=VKKn8A0ErT-0vXOAZ6NTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_oXcWVVAugGetVV2qBR9kJ-=VKKn8A0ErT-0vXOAZ6NTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Mon 05-12-16 01:15:39, Raymond Jennings wrote:
> On Sun, Dec 4, 2016 at 11:05 PM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Sun 04-12-16 13:56:54, Raymond Jennings wrote:
> > > I have an application that is generating HUGE amounts of dirty data.
> > > Multiple GiB worth, and I'd like to allow it to fill at least half of my
> > > RAM.
> >
> > Could you be more specific why and what kind of problem you are trying
> > to solve?
> >
> > > I already have /proc/sys/vm/dirty_ratio pegged at 80 and the background
> > one
> > > pegged at 50.  RAM is 32GiB.
> >
> > There is also dirty_bytes alternative which is an absolute numer.
> >
> 
> How does this compare to setting dirty_ratio to a high percentage?

Well, dirty_bytes is an absolute number when to start to throttle while
ratio is relative to node_dirtyable_memory

> > > it appears to be butting heads with clean memory.  How do I tell my
> > system
> > > to prefer using RAM to soak up writes instead of caching?
> >
> > I am not sure I understand. Could you be more specific about what is the
> > actual problem? Is it possible that your dirty data is already being
> > flushed and that is wy you see a clean cache?
> >
> 
> What I'm wanting is for my writing process not to get throttled, even when
> the dirty memory it starts creating starts hogging memory the system would
> rather use for cache.

Then you can configure dirty_background_{bytes,ratio} to start flushing
dirty data sooner. Having a lot of dirty data in the system just asks
for troubles elsewhere as it would take a lot of time to sync that to
the backing store. That means that many unrelated processes might get
stuck on sync etc. for an unconfortably large amount of time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA3E66B000D
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:55:53 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t17-v6so5220955ply.13
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 04:55:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7-v6si7693109plk.391.2018.06.15.04.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jun 2018 04:55:52 -0700 (PDT)
Date: Fri, 15 Jun 2018 13:55:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180615115547.GH24039@dhcp22.suse.cz>
References: <1528790608-19557-1-git-send-email-jing.xia@unisoc.com>
 <20180612212007.GA22717@redhat.com>
 <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com>
 <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com>
 <20180614073153.GB9371@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615073201.GB24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 15-06-18 07:35:07, Mikulas Patocka wrote:
> 
> 
> On Fri, 15 Jun 2018, Michal Hocko wrote:
> 
> > On Thu 14-06-18 14:34:06, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Thu, 14 Jun 2018, Michal Hocko wrote:
> > > 
> > > > On Thu 14-06-18 15:18:58, jing xia wrote:
> > > > [...]
> > > > > PID: 22920  TASK: ffffffc0120f1a00  CPU: 1   COMMAND: "kworker/u8:2"
> > > > >  #0 [ffffffc0282af3d0] __switch_to at ffffff8008085e48
> > > > >  #1 [ffffffc0282af3f0] __schedule at ffffff8008850cc8
> > > > >  #2 [ffffffc0282af450] schedule at ffffff8008850f4c
> > > > >  #3 [ffffffc0282af470] schedule_timeout at ffffff8008853a0c
> > > > >  #4 [ffffffc0282af520] schedule_timeout_uninterruptible at ffffff8008853aa8
> > > > >  #5 [ffffffc0282af530] wait_iff_congested at ffffff8008181b40
> > > > 
> > > > This trace doesn't provide the full picture unfortunately. Waiting in
> > > > the direct reclaim means that the underlying bdi is congested. The real
> > > > question is why it doesn't flush IO in time.
> > > 
> > > I pointed this out two years ago and you just refused to fix it:
> > > http://lkml.iu.edu/hypermail/linux/kernel/1608.1/04507.html
> > 
> > Let me be evil again and let me quote the old discussion:
> > : > I agree that mempool_alloc should _primarily_ sleep on their own
> > : > throttling mechanism. I am not questioning that. I am just saying that
> > : > the page allocator has its own throttling which it relies on and that
> > : > cannot be just ignored because that might have other undesirable side
> > : > effects. So if the right approach is really to never throttle certain
> > : > requests then we have to bail out from a congested nodes/zones as soon
> > : > as the congestion is detected.
> > : >
> > : > Now, I would like to see that something like that is _really_ necessary.
> > :
> > : Currently, it is not a problem - device mapper reports the device as
> > : congested only if the underlying physical disks are congested.
> > :
> > : But once we change it so that device mapper reports congested state on its
> > : own (when it has too many bios in progress), this starts being a problem.
> > 
> > So has this changed since then? If yes then we can think of a proper
> > solution but that would require to actually describe why we see the
> > congestion, why it does help to wait on the caller rather than the
> > allocator etc...
> 
> Device mapper doesn't report congested state - but something else does 
> (perhaps the user inserted a cheap slow usb stick or sdcard?). And device 
> mapper is just a victim of that.

Maybe yes and that would require some more debugging to find out,
analyze and think of a proper solution.

> Why should device mapper sleep because some other random block device is 
> congested?

Well, the direct reclaim is a way to throttle memory allocations. There
is no real concept on who is asking for the memory. If you do not want
to get blocked then use GFP_NOWAIT.

> > Throwing statements like ...
> > 
> > > I'm sure you'll come up with another creative excuse why GFP_NORETRY 
> > > allocations need incur deliberate 100ms delays in block device drivers.
> > 
> > ... is not really productive. I've tried to explain why I am not _sure_ what
> > possible side effects such a change might have and your hand waving
> > didn't really convince me. MD is not the only user of the page
> > allocator...
> > 
> > E.g. why has 41c73a49df31 ("dm bufio: drop the lock when doing GFP_NOIO
> > allocation") even added GFP_NOIO request in the first place when you
> > keep retrying and sleep yourself?
> 
> Because mempool uses it. Mempool uses allocations with "GFP_NOIO | 
> __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN". An so dm-bufio uses 
> these flags too. dm-bufio is just a big mempool.

This doesn't answer my question though. Somebody else is doing it is not
an explanation. Prior to your 41c73a49df31 there was no GFP_NOIO
allocation AFAICS. So why do you really need it now? Why cannot you
simply keep retrying GFP_NOWAIT with your own throttling?

Note that I am not trying to say that 41c73a49df31, I am merely trying
to understand why this blocking allocation is done in the first place.
 
> If you argue that these flags are incorrect - then fix mempool_alloc.

AFAICS there is no report about mempool_alloc stalling here. Maybe this
is the same class of problem, honestly, I dunno. And I've already said
that stalling __GFP_NORETRY might be a good way around that but that
needs much more consideration and existing users examination. I am not
aware anybody has done that. Doing changes like that based on a single
user is certainly risky.
-- 
Michal Hocko
SUSE Labs

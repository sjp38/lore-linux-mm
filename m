Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 30FDA6B008C
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:23:27 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id n12so1486642wgh.1
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:23:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si35367072wjq.185.2015.02.18.06.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 06:23:25 -0800 (PST)
Date: Wed, 18 Feb 2015 15:23:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
Message-ID: <20150218142322.GD4680@dhcp22.suse.cz>
References: <CALYGNiP-CKYsVzLpUdUWM3ftfg1vPvKWQvbegXVLoNovtNWS6Q@mail.gmail.com>
 <131740628.109294.1423821136530.JavaMail.yahoo@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <131740628.109294.1423821136530.JavaMail.yahoo@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cheng Rk <crquan@ymail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 13-02-15 09:52:16, Cheng Rk wrote:
> 
> 
> On Thursday, February 12, 2015 11:34 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> 
> >>
> >> -bash-4.2$ sudo losetup -a
> >> /dev/loop0: [0005]:16512 (/dev/dm-2)
> >> -bash-4.2$ free -m
> >>                 total          used         free      shared       buffers     cached
> >> Mem:             48094         46081         2012          40         40324       2085
> >> -/+ buffers/cache:              3671       44422
> >> Swap:             8191             5         8186
> >>
> >>
> >> I've tried sysctl mm.vfs_cache_pressure=10000 but that seems working to Cached
> >> memory, I wonder is there another sysctl for reclaming Buffers?
> 
> > AFAIK "Buffers" is just a page-cache of block devices.
> > From reclaimer's point of view they have no difference from file page-cache.
> 
> > Could you post oom-killer log, there should be a lot of numbers
> > describing memory state.
> 
> 
> in this case, 40GB memory got stuck in Buffers, and 90+% of them are
> reclaimable (can be verified by vm.drop_caches manual reclaim) if
> Buffers are treated same as Cached, why mm.vfs_cache_pressure=10000
> (or even I tried up to 1,000,000) can't get Buffers reclaimed early?

As per Documentation/sysctl/vm.txt the knob doesn't affect the page
cache reclaim but rather inode vs. dentry reclaim.

> I have some oom-killer msgs but were with older kernels, after set
> vm.overcommit_memory=2, it simply returns -ENOMEM, unable to spawn any
> new container, why doesn't it even try to reclaim some memory from
> those 40GB Buffers,

overcommit_memory controls behavior of the _virtual_ memory
reservations. OVERCOMMIT_NEVER (2) means that even virtual memory cannot
be overcommit outside of the configured value (RAM + swap basically -
see Documentation/vm/overcommit-accounting for more information). So
your application most probably consumes a lot of virtual memory (mmaps
etc.) and that is why it gets ENOMEM.

OOM report would tell us what was the memory state at the time when you
were short of memory and why the cache (buffers in your case) were not
reclaimed properly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

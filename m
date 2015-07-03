Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A76AF280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 09:02:21 -0400 (EDT)
Received: by wiga1 with SMTP id a1so177530414wig.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 06:02:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv2si14461839wjb.30.2015.07.03.06.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 06:02:19 -0700 (PDT)
Date: Fri, 3 Jul 2015 15:02:13 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 41/51] writeback: make wakeup_flusher_threads() handle
 multiple bdi_writeback's
Message-ID: <20150703130213.GM23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-42-git-send-email-tj@kernel.org>
 <20150701081528.GB7252@quack.suse.cz>
 <20150702023706.GK26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702023706.GK26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 22:37:06, Tejun Heo wrote:
> Hello,
> 
> On Wed, Jul 01, 2015 at 10:15:28AM +0200, Jan Kara wrote:
> > I was looking at who uses wakeup_flusher_threads(). There are two usecases:
> > 
> > 1) sync() - we want to writeback everything
> > 2) We want to relieve memory pressure by cleaning and subsequently
> >    reclaiming pages.
> > 
> > Neither of these cares about number of pages too much if you write enough.
> 
> What's enough tho?  Saying "yeah let's try about 1000 pages" is one
> thing and "let's try about 1000 pages on each of 100 cgroups" is a
> quite different operation.  Given the nature of "let's try to write
> some", I'd venture to say that writing somewhat less is an a lot
> better behavior than possibly trying to write out possibly huge amount
> given that the amount of fluctuation such behaviors may cause
> system-wide and how non-obvious the reasons for such fluctuations
> would be.
> 
> > So similarly as we don't split the passed nr_pages argument among bdis, I
> 
> bdi's are bound by actual hardware.  wb's aren't.  This is a purely
> logical construct and there can be a lot of them.  Again, trying to
> write 1024 pages on each of 100 devices and trying to write 1024 * 100
> pages to single device are quite different.

OK, I agree with your device vs logical construct argument. However when
splitting pages based on avg throughput each cgroup generates, we know
nothing about actual amount of dirty pages in each cgroup so we may end up
writing much fewer pages than we originally wanted since a cgroup which was
assigned a big chunk needn't have many pages available. So your algorithm
is basically bound to undershoot the requested number of pages in some
cases...

Another concern is that if we have two cgroups with same amount of dirty
pages but cgroup A has them randomly scattered (and thus have much lower
bandwidth) and cgroup B has them in a sequential fashion (thus with higher
bandwidth), you end up cleaning (and subsequently reclaiming) more from
cgroup B. That may be good for immediate memory pressure but could be
considered unfair by the cgroup owner.

Maybe it would be better to split number of pages to write based on
fraction of dirty pages each cgroup has in the bdi?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

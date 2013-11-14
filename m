Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B417C6B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 11:21:15 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so2194468pdj.9
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 08:21:15 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id ru9si28072324pbc.198.2013.11.14.08.21.13
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 08:21:14 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id va2so2449964obc.9
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 08:21:12 -0800 (PST)
Date: Thu, 14 Nov 2013 10:21:03 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
Message-ID: <20131114162103.GA4370@cerebellum.variantweb.net>
References: <20131107070451.GA10645@bbox>
 <20131112154137.GA3330@gmail.com>
 <alpine.LNX.2.00.1311131811030.1120@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1311131811030.1120@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, riel@redhat.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Luigi Semenzato <semenzato@google.com>

On Wed, Nov 13, 2013 at 08:00:34PM -0800, Hugh Dickins wrote:
> On Wed, 13 Nov 2013, Minchan Kim wrote:
> > On Thu, Nov 07, 2013 at 04:04:51PM +0900, Minchan Kim wrote:
> > > On Wed, Nov 06, 2013 at 07:05:11PM -0800, Greg KH wrote:
> > > > On Wed, Nov 06, 2013 at 03:46:19PM -0800, Nitin Gupta wrote:
> > > >  > I'm getting really tired of them hanging around in here for many years
> > > > > > now...
> > > > > >
> > > > > 
> > > > > Minchan has tried many times to promote zram out of staging. This was
> > > > > his most recent attempt:
> > > > > 
> > > > > https://lkml.org/lkml/2013/8/21/54
> ...
> > 
> > Hello Andrew,
> > 
> > I'd like to listen your opinion.
> > 
> > The zram promotion trial started since Aug 2012 and I already have get many
> > Acked/Reviewed feedback and positive feedback from Rik and Bob in this thread.
> > (ex, Jens Axboe[1], Konrad Rzeszutek Wilk[2], Nitin Gupta[3], Pekka Enberg[4])
> > In Linuxcon, Hugh gave positive feedback about zram(Hugh, If I misunderstood,
> > please correct me!). And there are lots of users already in embedded industry
> > ex, (most of TV in the world, Chromebook, CyanogenMod, Android Kitkat.)
> > They are not idiot. Zram is really effective for embedded world.
> 
> Sorry for taking so long to respond, Minchan: no, you do not misrepresent
> me at all.  Promotion of zram and zsmalloc from staging is way overdue:
> they long ago proved their worth, look tidy, and have an active maintainer.
> 
> Putting them into drivers/staging was always a mistake, and I quite
> understand Greg's impatience with them by now; but please let's move
> them to where they belong instead of removing them.
> 
> I would not have lent support to zswap if I'd thought that was going to
> block zram.  And I was not the only one surprised when zswap replaced its
> use of zsmalloc by zbud: we had rather expected a zbud option to be added,
> and I still assume that zsmalloc support will be added back to zswap later.

Yes, it is still the plan to reintroduce zsmalloc as an option (possibly
_the_ option) for zswap.

An idea being tossed around is making zswap writethrough instead of
delayed writeback.

Doing this would be mean that zswap would no longer reduce swap out
traffic, but would continue to reduce swap in latency by reading out of
the compressed cache instead of the swap device.

For that loss, we gain a benefit: the compressed pages in the cache are
clean, meaning we can reclaim them at any time with no writeback
cost.  This addresses Mel's initial concern (the one that led to zswap
moving to zbud) about writeback latency when the zswap pool is full.

If there is no writeback cost for reclaiming space in the compressed
pool, then we can use higher density packing like zsmalloc.

Making zswap writethough would also make the difference between zswap
and zram, both in terms of operation and application, more apparent,
demonstrating the need for both.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA6946B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:17:05 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g8so28381039ioi.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:17:05 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id e7si48649696ioa.127.2016.11.30.10.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Nov 2016 10:17:05 -0800 (PST)
Date: Wed, 30 Nov 2016 10:16:53 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161130181653.g2hujqqu2fu2unjj@merlins.org>
References: <20161118164643.g7ttuzgsj74d6fbz@merlins.org>
 <20161118184915.j6dlazbgminxnxzx@merlins.org>
 <b6c3daab-d990-e873-4d0f-0f0afe2259b1@coly.li>
 <alpine.LRH.2.11.1611291255350.1914@mail.ewheeler.net>
 <20161130164646.d6ejlv72hzellddd@merlins.org>
 <20161130171814.3yrqzzoocg3kz4ki@merlins.org>
 <6303e492-62f8-cbcc-4536-81350f2e9a86@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6303e492-62f8-cbcc-4536-81350f2e9a86@gmail.com>
Subject: Re: btrfs flooding the I/O subsystem and hanging the machine, with
 bcache cache turned off
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Cc: Btrfs BTRFS <linux-btrfs@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, torvalds@linux-foundation.org

+folks from linux-mm thread for your suggestion

On Wed, Nov 30, 2016 at 01:00:45PM -0500, Austin S. Hemmelgarn wrote:
> > swraid5 < bcache < dmcrypt < btrfs
> > 
> > Copying with btrfs send/receive causes massive hangs on the system.
> > Please see this explanation from Linus on why the workaround was
> > suggested:
> > https://lkml.org/lkml/2016/11/29/667
> And Linux' assessment is absolutely correct (at least, the general
> assessment is, I have no idea about btrfs_start_shared_extent, but I'm more
> than willing to bet he's correct that that's the culprit).

> > All of this mostly went away with Linus' suggestion:
> > echo 2 > /proc/sys/vm/dirty_ratio
> > echo 1 > /proc/sys/vm/dirty_background_ratio
> > 
> > But that's hiding the symptom which I think is that btrfs is piling up too many I/O
> > requests during btrfs send/receive and btrfs scrub (probably balance too) and not
> > looking at resulting impact to system health.

> I see pretty much identical behavior using any number of other storage
> configurations on a USB 2.0 flash drive connected to a system with 16GB of
> RAM with the default dirty ratios because it's trying to cache up to 3.2GB
> of data for writeback.  While BTRFS is doing highly sub-optimal things here,
> the ancient default writeback ratios are just as much a culprit.  I would
> suggest that get changed to 200MB or 20% of RAM, whichever is smaller, which
> would give overall almost identical behavior to x86-32, which in turn works
> reasonably well for most cases.  I sadly don't have the time, patience, or
> expertise to write up such a patch myself though.

Dear linux-mm folks, is that something you could consider (changing the
dirty_ratio defaults) given that it affects at least bcache and btrfs
(with or without bcache)?

By the way, on the 200MB max suggestion, when I had 2 and 1% (or 480MB
and 240MB on my 24GB system), this was enough to make btrfs behave
sanely, but only if I had bcache turned off.
With bcache enabled, those values were just enough so that bcache didn't
crash my system, but not enough that prevent undesirable behaviour
(things hanging, 100+ bcache kworkers piled up, and more). However, the
copy did succeed, despite the relative impact on the system, so it's
better than nothing :)
But the impact from bcache probably goes beyond what btrfs is
responsible for, so I have a separate thread on the bcache list:
http://marc.info/?l=linux-bcache&m=148052441423532&w=2
http://marc.info/?l=linux-bcache&m=148052620524162&w=2

On the plus side, btrfs did ok with 0 visible impact to my system with
those 480 and 240MB dirty ratio values.

Thanks for your reply, Austin.
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

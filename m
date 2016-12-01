Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A407280260
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:49:56 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so39697208wjb.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:49:56 -0800 (PST)
Received: from mail-wj0-f175.google.com (mail-wj0-f175.google.com. [209.85.210.175])
        by mx.google.com with ESMTPS id z80si1167150wmd.57.2016.12.01.07.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:49:55 -0800 (PST)
Received: by mail-wj0-f175.google.com with SMTP id v7so208157680wjy.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:49:54 -0800 (PST)
Date: Thu, 1 Dec 2016 16:49:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: btrfs flooding the I/O subsystem and hanging the machine, with
 bcache cache turned off
Message-ID: <20161201154952.GC20966@dhcp22.suse.cz>
References: <20161118164643.g7ttuzgsj74d6fbz@merlins.org>
 <20161118184915.j6dlazbgminxnxzx@merlins.org>
 <b6c3daab-d990-e873-4d0f-0f0afe2259b1@coly.li>
 <alpine.LRH.2.11.1611291255350.1914@mail.ewheeler.net>
 <20161130164646.d6ejlv72hzellddd@merlins.org>
 <20161130171814.3yrqzzoocg3kz4ki@merlins.org>
 <6303e492-62f8-cbcc-4536-81350f2e9a86@gmail.com>
 <20161130181653.g2hujqqu2fu2unjj@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130181653.g2hujqqu2fu2unjj@merlins.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Btrfs BTRFS <linux-btrfs@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, torvalds@linux-foundation.org

On Wed 30-11-16 10:16:53, Marc MERLIN wrote:
> +folks from linux-mm thread for your suggestion
> 
> On Wed, Nov 30, 2016 at 01:00:45PM -0500, Austin S. Hemmelgarn wrote:
> > > swraid5 < bcache < dmcrypt < btrfs
> > > 
> > > Copying with btrfs send/receive causes massive hangs on the system.
> > > Please see this explanation from Linus on why the workaround was
> > > suggested:
> > > https://lkml.org/lkml/2016/11/29/667
> > And Linux' assessment is absolutely correct (at least, the general
> > assessment is, I have no idea about btrfs_start_shared_extent, but I'm more
> > than willing to bet he's correct that that's the culprit).
> 
> > > All of this mostly went away with Linus' suggestion:
> > > echo 2 > /proc/sys/vm/dirty_ratio
> > > echo 1 > /proc/sys/vm/dirty_background_ratio
> > > 
> > > But that's hiding the symptom which I think is that btrfs is piling up too many I/O
> > > requests during btrfs send/receive and btrfs scrub (probably balance too) and not
> > > looking at resulting impact to system health.
> 
> > I see pretty much identical behavior using any number of other storage
> > configurations on a USB 2.0 flash drive connected to a system with 16GB of
> > RAM with the default dirty ratios because it's trying to cache up to 3.2GB
> > of data for writeback.  While BTRFS is doing highly sub-optimal things here,
> > the ancient default writeback ratios are just as much a culprit.  I would
> > suggest that get changed to 200MB or 20% of RAM, whichever is smaller, which
> > would give overall almost identical behavior to x86-32, which in turn works
> > reasonably well for most cases.  I sadly don't have the time, patience, or
> > expertise to write up such a patch myself though.
> 
> Dear linux-mm folks, is that something you could consider (changing the
> dirty_ratio defaults) given that it affects at least bcache and btrfs
> (with or without bcache)?

As much as the dirty_*ratio defaults a major PITA this is not something
that would be _easy_ to change without high risks of regressions. This
topic has been discussed many times with many good ideas, nothing really
materialized from them though :/

To be honest I really do hate dirty_*ratio and have seen many issues on
very large machines and always suggested to use dirty_bytes instead but
a particular value has always been a challenge to get right. It has
always been very workload specific.

That being said this is something more for IO people than MM IMHO.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

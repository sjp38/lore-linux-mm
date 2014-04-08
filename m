Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EBAE86B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 19:26:48 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so1703110wgh.20
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 16:26:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si1852882wix.2.2014.04.08.16.26.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 16:26:46 -0700 (PDT)
Date: Wed, 9 Apr 2014 00:26:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
Message-ID: <20140408232642.GR7292@suse.de>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
 <5343A494.9070707@suse.cz>
 <alpine.DEB.2.10.1404080914280.8782@nuc>
 <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com>
 <alpine.DEB.2.10.1404081752390.16708@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1404081752390.16708@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robert Haas <robertmhaas@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On Tue, Apr 08, 2014 at 05:58:21PM -0500, Christoph Lameter wrote:
> On Tue, 8 Apr 2014, Robert Haas wrote:
> 
> > Well, as Josh quite rightly said, the hit from accessing remote memory
> > is never going to be as large as the hit from disk.  If and when there
> > is a machine where remote memory is more expensive to access than
> > disk, that's a good argument for zone_reclaim_mode.  But I don't
> > believe that's anywhere close to being true today, even on an 8-socket
> > machine with an SSD.
> 
> I am nost sure how disk figures into this?
> 

It's a matter of perspective. For those that are running file servers,
databases and the like they don't see the remote accesses, they see their
page cache getting reclaimed but not all of those users understand why
because they are not NUMA aware. This is why they are seeing the cost of
zone_reclaim_mode to be IO-related.

I think pretty much 100% of the bug reports I've seen related to
zone_reclaim_mode were due to IO-intensive workloads and the user not
recognising why page cache was getting reclaimed aggressively.

> The tradeoff is zone reclaim vs. the aggregate performance
> degradation of the remote memory accesses. That depends on the
> cacheability of the app and the scale of memory accesses.
> 

For HPC, yes.

> The reason that zone reclaim is on by default is that off node accesses
> are a big performance hit on large scale NUMA systems (like ScaleMP and
> SGI). Zone reclaim was written *because* those system experienced severe
> performance degradation.
> 

Yes, this is understood. However, those same people already know how to use
cpusets, NUMA bindings and how tune their workload to partition it into
the nodes. From a NUMA perspective they are relatively sophisticated and
know how and when to set zone_reclaim_mode. At least on any bug report I've
seen related to these really large machines, they were already using cpusets.

This is why I think think the default for zone_reclaim should now be off
because it helps the common case.

> On the tightly coupled 4 and 8 node systems there does not seem to
> be a benefit from what I hear.
> 
> > Now, perhaps the fear is that if we access that remote memory
> > *repeatedly* the aggregate cost will exceed what it would have cost to
> > fault that page into the local node just once.  But it takes a lot of
> > accesses for that to be true, and most of the time you won't get them.
> >  Even if you do, I bet many workloads will prefer even performance
> > across all the accesses over a very slow first access followed by
> > slightly faster subsequent accesses.
> 
> Many HPC workloads prefer the opposite.
> 

And they know how to tune accordingly.

> > In an ideal world, the kernel would put the hottest pages on the local
> > node and the less-hot pages on remote nodes, moving pages around as
> > the workload shifts.  In practice, that's probably pretty hard.
> > Fortunately, it's not nearly as important as making sure we don't
> > unnecessarily hit the disk, which is infinitely slower than any memory
> > bank.
> 
> Shifting pages involves similar tradeoffs as zone reclaim vs. remote
> allocations.

In practice it really is hard for the kernel to do this
automatically. Automatic NUMA balancing will help if the data is mapped but
not if it's buffered read/writes because there is no hinting information
available right now. At some point we may need to tackle IO locality but
it'll take time for users to get experience with automatic balancing as
it is before taking further steps. That's an aside to the current discussion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

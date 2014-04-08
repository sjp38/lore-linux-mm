Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 53E4F6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 18:58:26 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so1684558pad.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 15:58:25 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id w4si1742779paa.34.2014.04.08.15.58.25
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 15:58:25 -0700 (PDT)
Date: Tue, 8 Apr 2014 17:58:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
In-Reply-To: <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1404081752390.16708@nuc>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <5343A494.9070707@suse.cz> <alpine.DEB.2.10.1404080914280.8782@nuc> <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Haas <robertmhaas@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On Tue, 8 Apr 2014, Robert Haas wrote:

> Well, as Josh quite rightly said, the hit from accessing remote memory
> is never going to be as large as the hit from disk.  If and when there
> is a machine where remote memory is more expensive to access than
> disk, that's a good argument for zone_reclaim_mode.  But I don't
> believe that's anywhere close to being true today, even on an 8-socket
> machine with an SSD.

I am nost sure how disk figures into this?

The tradeoff is zone reclaim vs. the aggregate performance
degradation of the remote memory accesses. That depends on the
cacheability of the app and the scale of memory accesses.

The reason that zone reclaim is on by default is that off node accesses
are a big performance hit on large scale NUMA systems (like ScaleMP and
SGI). Zone reclaim was written *because* those system experienced severe
performance degradation.

On the tightly coupled 4 and 8 node systems there does not seem to
be a benefit from what I hear.

> Now, perhaps the fear is that if we access that remote memory
> *repeatedly* the aggregate cost will exceed what it would have cost to
> fault that page into the local node just once.  But it takes a lot of
> accesses for that to be true, and most of the time you won't get them.
>  Even if you do, I bet many workloads will prefer even performance
> across all the accesses over a very slow first access followed by
> slightly faster subsequent accesses.

Many HPC workloads prefer the opposite.

> In an ideal world, the kernel would put the hottest pages on the local
> node and the less-hot pages on remote nodes, moving pages around as
> the workload shifts.  In practice, that's probably pretty hard.
> Fortunately, it's not nearly as important as making sure we don't
> unnecessarily hit the disk, which is infinitely slower than any memory
> bank.

Shifting pages involves similar tradeoffs as zone reclaim vs. remote
allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCE826B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 15:08:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x8-v6so10976195pln.9
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 12:08:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t19-v6si1104528plo.102.2018.04.03.12.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 12:08:02 -0700 (PDT)
Date: Tue, 3 Apr 2018 12:07:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Message-ID: <20180403190759.GB6779@bombadil.infradead.org>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403133115.GA5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Buddy Lumpkin <buddy.lumpkin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, akpm@linux-foundation.org

On Tue, Apr 03, 2018 at 03:31:15PM +0200, Michal Hocko wrote:
> On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
> > The presence of direct reclaims 10 years ago was a fairly reliable
> > indicator that too much was being asked of a Linux system. Kswapd was
> > likely wasting time scanning pages that were ineligible for eviction.
> > Adding RAM or reducing the working set size would usually make the problem
> > go away. Since then hardware has evolved to bring a new struggle for
> > kswapd. Storage speeds have increased by orders of magnitude while CPU
> > clock speeds stayed the same or even slowed down in exchange for more
> > cores per package. This presents a throughput problem for a single
> > threaded kswapd that will get worse with each generation of new hardware.
> 
> AFAIR we used to scale the number of kswapd workers many years ago. It
> just turned out to be not all that great. We have a kswapd reclaim
> window for quite some time and that can allow to tune how much proactive
> kswapd should be.
> 
> Also please note that the direct reclaim is a way to throttle overly
> aggressive memory consumers. The more we do in the background context
> the easier for them it will be to allocate faster. So I am not really
> sure that more background threads will solve the underlying problem. It
> is just a matter of memory hogs tunning to end in the very same
> situtation AFAICS. Moreover the more they are going to allocate the more
> less CPU time will _other_ (non-allocating) task get.
> 
> > Test Details
> 
> I will have to study this more to comment.
> 
> [...]
> > By increasing the number of kswapd threads, throughput increased by ~50%
> > while kernel mode CPU utilization decreased or stayed the same, likely due
> > to a decrease in the number of parallel tasks at any given time doing page
> > replacement.
> 
> Well, isn't that just an effect of more work being done on behalf of
> other workload that might run along with your tests (and which doesn't
> really need to allocate a lot of memory)? In other words how
> does the patch behaves with a non-artificial mixed workloads?
> 
> Please note that I am not saying that we absolutely have to stick with the
> current single-thread-per-node implementation but I would really like to
> see more background on why we should be allowing heavy memory hogs to
> allocate faster or how to prevent that. I would be also very interested
> to see how to scale the number of threads based on how CPUs are utilized
> by other workloads.

Yes, very much this.  If you have a single-threaded workload which is
using the entirety of memory and would like to use even more, then it
makes sense to use as many CPUs as necessary getting memory out of its
way.  If you have N CPUs and N-1 threads happily occupying themselves in
their own reasonably-sized working sets with one monster process trying
to use as much RAM as possible, then I'd be pretty unimpressed to see
the N-1 well-behaved threads preempted by kswapd.

My biggest problem with the patch-as-presented is that it's yet one more
thing for admins to get wrong.  We should spawn more threads automatically
if system conditions are right to do that.

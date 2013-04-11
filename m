Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 74F576B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 05:10:48 -0400 (EDT)
Date: Thu, 11 Apr 2013 10:10:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
Message-ID: <20130411091044.GG3710@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com>
 <20130410141445.GD3710@suse.de>
 <alpine.DEB.2.02.1304101524120.7738@dtop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304101524120.7738@dtop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dormando <dormando@rydia.net>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 10, 2013 at 03:28:32PM -0700, dormando wrote:
> > On Tue, Apr 09, 2013 at 05:27:18PM +0000, Christoph Lameter wrote:
> > > One additional measure that may be useful is to make kswapd prefer one
> > > specific processor on a socket. Two benefits arise from that:
> > >
> > > 1. Better use of cpu caches and therefore higher speed, less
> > > serialization.
> > >
> >
> > Considering the volume of pages that kswapd can scan when it's active
> > I would expect that it trashes its cache anyway. The L1 cache would be
> > flushed after scanning struct pages for just a few MB of memory.
> >
> > > 2. Reduction of the disturbances to one processor.
> > >
> >
> > I've never checked it but I would have expected kswapd to stay on the
> > same processor for significant periods of time. Have you experienced
> > problems where kswapd bounces around on CPUs within a node causing
> > workload disruption?
> 
> When kswapd shares the same CPU as our main process it causes a measurable
> drop in response time (graphs show tiny spikes at the same time memory is
> freed). Would be nice to be able to ensure it runs on a different core
> than our latency sensitive processes at least. We can pin processes to
> subsets of cores but I don't think there's a way to keep kswapd from
> waking up on any of them?

I've never tried it myself but does the following work?

taskset -p MASK `pidof kswapd`

where MASK is a cpumask describing what CPUs kswapd can run on?
Obviously care should be taken to ensure that you bind kswapd to a CPU
running on the node kswapd cares about.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

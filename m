Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C3DE06B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:13:21 -0400 (EDT)
Received: by mail-ea0-f171.google.com with SMTP id b15so947683eae.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:13:19 -0700 (PDT)
Date: Thu, 11 Apr 2013 22:13:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
Message-ID: <20130411201316.GB15238@dhcp22.suse.cz>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com>
 <20130410141445.GD3710@suse.de>
 <alpine.DEB.2.02.1304101524120.7738@dtop>
 <20130411091044.GG3710@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411091044.GG3710@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: dormando <dormando@rydia.net>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, Satoru Moriya <satoru.moriya@hds.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 11-04-13 10:10:44, Mel Gorman wrote:
> On Wed, Apr 10, 2013 at 03:28:32PM -0700, dormando wrote:
> > > On Tue, Apr 09, 2013 at 05:27:18PM +0000, Christoph Lameter wrote:
> > > > One additional measure that may be useful is to make kswapd prefer one
> > > > specific processor on a socket. Two benefits arise from that:
> > > >
> > > > 1. Better use of cpu caches and therefore higher speed, less
> > > > serialization.
> > > >
> > >
> > > Considering the volume of pages that kswapd can scan when it's active
> > > I would expect that it trashes its cache anyway. The L1 cache would be
> > > flushed after scanning struct pages for just a few MB of memory.
> > >
> > > > 2. Reduction of the disturbances to one processor.
> > > >
> > >
> > > I've never checked it but I would have expected kswapd to stay on the
> > > same processor for significant periods of time. Have you experienced
> > > problems where kswapd bounces around on CPUs within a node causing
> > > workload disruption?
> > 
> > When kswapd shares the same CPU as our main process it causes a measurable
> > drop in response time (graphs show tiny spikes at the same time memory is
> > freed). Would be nice to be able to ensure it runs on a different core
> > than our latency sensitive processes at least. We can pin processes to
> > subsets of cores but I don't think there's a way to keep kswapd from
> > waking up on any of them?
> 
> I've never tried it myself but does the following work?
> 
> taskset -p MASK `pidof kswapd`

I would use pgrep rather than pidof which seem to need the whole process
name but yes this should work as kswapdN is not PF_THREAD_BOUND kernel
thread.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

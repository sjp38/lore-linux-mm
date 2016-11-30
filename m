Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB566B0261
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 10:06:19 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id t7so172865263yba.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 07:06:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d67si12490302ybi.67.2016.11.30.07.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 07:06:18 -0800 (PST)
Date: Wed, 30 Nov 2016 16:06:12 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130160612.474ca93c@redhat.com>
In-Reply-To: <20161130140615.3bbn7576iwbyc3op@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
	<20161130134034.3b60c7f0@redhat.com>
	<20161130140615.3bbn7576iwbyc3op@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Rick Jones <rick.jones2@hpe.com>, Paolo Abeni <pabeni@redhat.com>, brouer@redhat.com

On Wed, 30 Nov 2016 14:06:15 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Nov 30, 2016 at 01:40:34PM +0100, Jesper Dangaard Brouer wrote:
> > 
> > On Sun, 27 Nov 2016 13:19:54 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> > 
> > [...]  
> > > SLUB has been the default small kernel object allocator for quite some time
> > > but it is not universally used due to performance concerns and a reliance
> > > on high-order pages. The high-order concerns has two major components --
> > > high-order pages are not always available and high-order page allocations
> > > potentially contend on the zone->lock. This patch addresses some concerns
> > > about the zone lock contention by extending the per-cpu page allocator to
> > > cache high-order pages. The patch makes the following modifications
> > > 
> > > o New per-cpu lists are added to cache the high-order pages. This increases
> > >   the cache footprint of the per-cpu allocator and overall usage but for
> > >   some workloads, this will be offset by reduced contention on zone->lock.  
> > 
> > This will also help performance of NIC driver that allocator
> > higher-order pages for their RX-ring queue (and chop it up for MTU).
> > I do like this patch, even-though I'm working on moving drivers away
> > from allocation these high-order pages.
> > 
> > Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> >   
> 
> Thanks.
> 
> > [...]  
> > > This is the result from netperf running UDP_STREAM on localhost. It was
> > > selected on the basis that it is slab-intensive and has been the subject
> > > of previous SLAB vs SLUB comparisons with the caveat that this is not
> > > testing between two physical hosts.  
> > 
> > I do like you are using a networking test to benchmark this. Looking at
> > the results, my initial response is that the improvements are basically
> > too good to be true.
> >   
> 
> FWIW, LKP independently measured the boost to be 23% so it's expected
> there will be different results depending on exact configuration and CPU.

Yes, noticed that, nice (which was a SCTP test) 
 https://lists.01.org/pipermail/lkp/2016-November/005210.html

It is of-cause great. It is just strange I cannot reproduce it on my
high-end box, with manual testing. I'll try your test suite and try to
figure out what is wrong with my setup.


> > Can you share how you tested this with netperf and the specific netperf
> > parameters?   
> 
> The mmtests config file used is
> configs/config-global-dhp__network-netperf-unbound so all details can be
> extrapolated or reproduced from that.

I didn't know of mmtests: https://github.com/gormanm/mmtests

It looks nice and quite comprehensive! :-)


> > e.g.
> >  How do you configure the send/recv sizes?  
> 
> Static range of sizes specified in the config file.

I'll figure it out... reading your shell code :-)

export NETPERF_BUFFER_SIZES=64,128,256,1024,2048,3312,4096,8192,16384
 https://github.com/gormanm/mmtests/blob/master/configs/config-global-dhp__network-netperf-unbound#L72

I see you are using netperf 2.4.5 and setting both the send an recv
size (-- -m and -M) which is fine.

I don't quite get why you are setting the socket recv size (with -- -s
and -S) to such a small number, size + 256.

 SOCKETSIZE_OPT="-s $((SIZE+256)) -S $((SIZE+256))

 netperf-2.4.5-installed/bin/netperf -t UDP_STREAM -i 3 3 -I 95 5 -H 127.0.0.1 \
   -- -s 320 -S 320 -m 64 -M 64 -P 15895

 netperf-2.4.5-installed/bin/netperf -t UDP_STREAM -i 3 3 -I 95 5 -H 127.0.0.1 \
   -- -s 384 -S 384 -m 128 -M 128 -P 15895

 netperf-2.4.5-installed/bin/netperf -t UDP_STREAM -i 3 3 -I 95 5 -H 127.0.0.1 \
   -- -s 1280 -S 1280 -m 1024 -M 1024 -P 15895
 
> >  Have you pinned netperf and netserver on different CPUs?
> >   
> 
> No. While it's possible to do a pinned test which helps stability, it
> also tends to be less reflective of what happens in a variety of
> workloads so I took the "harder" option.

Agree.
 
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

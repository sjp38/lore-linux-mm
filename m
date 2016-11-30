Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D86666B0269
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:35:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so51917440wmf.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 08:35:22 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id ge18si64716849wjc.226.2016.11.30.08.35.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 08:35:21 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 3C2EC986BD
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:35:21 +0000 (UTC)
Date: Wed, 30 Nov 2016 16:35:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130163520.hg7icdflagmvarbr@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <20161130134034.3b60c7f0@redhat.com>
 <20161130140615.3bbn7576iwbyc3op@techsingularity.net>
 <20161130160612.474ca93c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161130160612.474ca93c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Rick Jones <rick.jones2@hpe.com>, Paolo Abeni <pabeni@redhat.com>

On Wed, Nov 30, 2016 at 04:06:12PM +0100, Jesper Dangaard Brouer wrote:
> > > [...]  
> > > > This is the result from netperf running UDP_STREAM on localhost. It was
> > > > selected on the basis that it is slab-intensive and has been the subject
> > > > of previous SLAB vs SLUB comparisons with the caveat that this is not
> > > > testing between two physical hosts.  
> > > 
> > > I do like you are using a networking test to benchmark this. Looking at
> > > the results, my initial response is that the improvements are basically
> > > too good to be true.
> > >   
> > 
> > FWIW, LKP independently measured the boost to be 23% so it's expected
> > there will be different results depending on exact configuration and CPU.
> 
> Yes, noticed that, nice (which was a SCTP test) 
>  https://lists.01.org/pipermail/lkp/2016-November/005210.html
> 
> It is of-cause great. It is just strange I cannot reproduce it on my
> high-end box, with manual testing. I'll try your test suite and try to
> figure out what is wrong with my setup.
> 

That would be great. I had seen the boost on multiple machines and LKP
verifying it is helpful. 

> 
> > > Can you share how you tested this with netperf and the specific netperf
> > > parameters?   
> > 
> > The mmtests config file used is
> > configs/config-global-dhp__network-netperf-unbound so all details can be
> > extrapolated or reproduced from that.
> 
> I didn't know of mmtests: https://github.com/gormanm/mmtests
> 
> It looks nice and quite comprehensive! :-)
> 

Thanks.

> > > e.g.
> > >  How do you configure the send/recv sizes?  
> > 
> > Static range of sizes specified in the config file.
> 
> I'll figure it out... reading your shell code :-)
> 
> export NETPERF_BUFFER_SIZES=64,128,256,1024,2048,3312,4096,8192,16384
>  https://github.com/gormanm/mmtests/blob/master/configs/config-global-dhp__network-netperf-unbound#L72
> 
> I see you are using netperf 2.4.5 and setting both the send an recv
> size (-- -m and -M) which is fine.
> 

Ok.

> I don't quite get why you are setting the socket recv size (with -- -s
> and -S) to such a small number, size + 256.
> 

Maybe I missed something at the time I wrote that but why would it need
to be larger?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

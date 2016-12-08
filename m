Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06FED6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 10:17:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so7343535wma.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 07:17:04 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id m76si13630043wmh.131.2016.12.08.07.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 07:17:03 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 2FE961C218F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 15:17:03 +0000 (GMT)
Date: Thu, 8 Dec 2016 15:11:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208151101.pigfrnqd5i4n45uv@techsingularity.net>
References: <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207194801.krhonj7yggbedpba@techsingularity.net>
 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
 <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
 <20161208092231.55c7eacf@redhat.com>
 <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
 <20161208114308.1c6a424f@redhat.com>
 <20161208110656.bnkvqg73qnjkehbc@techsingularity.net>
 <20161208154813.5dafae7b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161208154813.5dafae7b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 03:48:13PM +0100, Jesper Dangaard Brouer wrote:
> On Thu, 8 Dec 2016 11:06:56 +0000
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > On Thu, Dec 08, 2016 at 11:43:08AM +0100, Jesper Dangaard Brouer wrote:
> > > > That's expected. In the initial sniff-test, I saw negligible packet loss.
> > > > I'm waiting to see what the full set of network tests look like before
> > > > doing any further adjustments.  
> > > 
> > > For netperf I will not recommend adjusting the global default
> > > /proc/sys/net/core/rmem_default as netperf have means of adjusting this
> > > value from the application (which were the options you setup too low
> > > and just removed). I think you should keep this as the default for now
> > > (unless Eric says something else), as this should cover most users.
> > >   
> > 
> > Ok, the current state is that buffer sizes are only set for netperf
> > UDP_STREAM and only when running over a real network. The values selected
> > were specific to the network I had available so milage may vary.
> > localhost is left at the defaults.
> 
> Looks like you made a mistake when re-implementing using buffer sizes
> for netperf.

We appear to have a disconnect. This was reintroduced in response to your
comment "For netperf I will not recommend adjusting the global default
/proc/sys/net/core/rmem_default as netperf have means of adjusting this
value from the application".

My understanding was that netperfs means was the -s and -S switches for
send and recv buffers so I reintroduced them and avoided altering
[r|w]mem_default.

Leaving the defaults resulted in some UDP packet loss on a 10GbE network
so some upward adjustment.

>From my perspective, either adjusting [r|w]mem_default or specifying -s
-S works for the UDP_STREAM issue but using the switches meant only this
is affected and other loads like sockperf and netpipe will need to be
evaluated separately which I don't mind doing.

> See patch below signature.
> 
> Besides I think you misunderstood me, you can adjust:
>  sysctl net.core.rmem_max
>  sysctl net.core.wmem_max
> 
> And you should if you plan to use/set 851968 as socket size for UDP
> remote tests, else you will be limited to the "max" values (212992 well
> actually 425984 2x default value, for reasons I cannot remember)
> 

The intent is to use the larger values to avoid packet loss on
UDP_STREAM.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

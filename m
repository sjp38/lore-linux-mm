Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F74A280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 04:27:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o85so35625603qkh.15
        for <linux-mm@kvack.org>; Sat, 20 May 2017 01:27:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d27si11610281qtb.47.2017.05.20.01.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 01:27:34 -0700 (PDT)
Date: Sat, 20 May 2017 05:26:46 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170520082646.GA16139@amt.cnet>
References: <20170512122704.GA30528@amt.cnet>
 <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
 <20170512154026.GA3556@amt.cnet>
 <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet>
 <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet>
 <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, May 19, 2017 at 12:13:26PM -0500, Christoph Lameter wrote:
> On Fri, 19 May 2017, Marcelo Tosatti wrote:
> 
> > Use-case: realtime application on an isolated core which for some reason
> > updates vmstatistics.
> 
> Ok that is already only happening every 2 seconds by default and that
> interval is configurable via the vmstat_interval proc setting.
> 
> > > Just a measurement of vmstat_worker. Pointless.
> >
> > Shouldnt the focus be on general scenarios rather than particular
> > usecases, so that the solution covers a wider range of usecases?
> 
> Yes indeed and as far as I can tell the wider usecases are covered. Not
> sure that there is anything required here.
> 
> > The situation as i see is as follows:
> >
> > Your point of view is: an "isolated CPU" with a set of applications
> > cannot update vm statistics, otherwise they pay the vmstat_update cost:
> >
> >      kworker/5:1-245   [005] ....1..   673.454295: workqueue_execute_start: work struct ffffa0cf6e493e20: function vmstat_update
> >      kworker/5:1-245   [005] ....1..   673.454305: workqueue_execute_end: work struct ffffa0cf6e493e20
> >
> > Thats 10us for example.
> 
> Well with a decent cpu that is 3 usec and it occurs infrequently on the
> order of once per multiple seconds.
> 
> > So if want to customize a realtime setup whose code updates vmstatistic,
> > you are dead. You have to avoid any systemcall which possibly updates
> > vmstatistics (now and in the future kernel versions).
> 
> You are already dead because you allow IPIs and other kernel processing
> which creates far more overhead. Still fail to see the point.
> 
> > The point is that these vmstat updates are rare. From
> > http://www.7-cpu.com/cpu/Haswell.html:
> >
> > RAM Latency = 36 cycles + 57 ns (3.4 GHz i7-4770)
> > RAM Latency = 62 cycles + 100 ns (3.6 GHz E5-2699 dual)
> >
> > Lets round to 100ns = 0.1us.
> 
> That depends on the kernel functionality used.
> 
> > You need 100 vmstat updates (all misses to RAM, the worst possible case)
> > to have equivalent amount of time of the batching version.
> 
> The batching version occurs every couple of seconds if at all.
> 
> > But thats not the point. The point is the 10us interruption
> > to execution of the realtime app (which can either mean
> > your current deadline requirements are not met, or that
> > another application with lowest latency requirement can't
> > be used).
> 
> Ok then you need to get rid of the IPIs and the other stuff that you have
> going on with the OS first I think.

I'll measure the cost of all IPIs in the system to confirm
vmstat_update's costs is larger than the cost of any IPI.

> > So why are you against integrating this simple, isolated patch which
> > does not affect how current logic works?
> 
> Frankly the argument does not make sense. Vmstat updates occur very
> infrequently (probably even less than you IPIs and the other OS stuff that
> also causes additional latencies that you seem to be willing to tolerate).
> 
> And you can configure the interval of vmstat updates freely.... Set
> the vmstat_interval to 60 seconds instead of 2 for a try? Is that rare
> enough?

Not rare enough. Never is rare enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

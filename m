Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62C5C2806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 10:34:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k74so28202867qke.4
        for <linux-mm@kvack.org>; Fri, 19 May 2017 07:34:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d12si8536649qkb.95.2017.05.19.07.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 07:34:41 -0700 (PDT)
Date: Fri, 19 May 2017 11:34:08 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170519143407.GA19282@amt.cnet>
References: <20170502131527.7532fc2e@redhat.com>
 <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
 <20170512122704.GA30528@amt.cnet>
 <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
 <20170512154026.GA3556@amt.cnet>
 <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet>
 <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

Hi Christoph,

On Tue, May 16, 2017 at 08:37:11AM -0500, Christoph Lameter wrote:
> On Mon, 15 May 2017, Marcelo Tosatti wrote:
> 
> > > NOHZ already does that. I wanted to know what your problem is that you
> > > see. The latency issue has already been solved as far as I can tell .
> > > Please tell me why the existing solutions are not sufficient for you.
> >
> > We don't want vmstat_worker to execute on a given CPU, even if the local
> > CPU updates vm-statistics.
> 
> Instead of responding you repeat describing what you want.
> 
> > Because:
> >
> >     vmstat_worker increases latency of the application
> >        (i can measure it if you want on a given CPU,
> >         how many ns's the following takes:
> 
> That still is no use case. 

Use-case: realtime application on an isolated core which for some reason
updates vmstatistics.

> Just a measurement of vmstat_worker. Pointless.

Shouldnt the focus be on general scenarios rather than particular
usecases, so that the solution covers a wider range of usecases?

The situation as i see is as follows:

Your point of view is: an "isolated CPU" with a set of applications
cannot update vm statistics, otherwise they pay the vmstat_update cost:

     kworker/5:1-245   [005] ....1..   673.454295: workqueue_execute_start: work struct ffffa0cf6e493e20: function vmstat_update
     kworker/5:1-245   [005] ....1..   673.454305: workqueue_execute_end: work struct ffffa0cf6e493e20

Thats 10us for example.

So if want to customize a realtime setup whose code updates vmstatistic, 
you are dead. You have to avoid any systemcall which possibly updates
vmstatistics (now and in the future kernel versions).

> If you move the latency from the vmstat worker into the code thats
> updating the counters then you will require increased use of atomics
> which will increase contention which in turn will significantly
> increase the overall latency.

The point is that these vmstat updates are rare. From 
http://www.7-cpu.com/cpu/Haswell.html:

RAM Latency = 36 cycles + 57 ns (3.4 GHz i7-4770)
RAM Latency = 62 cycles + 100 ns (3.6 GHz E5-2699 dual)

Lets round to 100ns = 0.1us.

You need 100 vmstat updates (all misses to RAM, the worst possible case)
to have equivalent amount of time of the batching version.

With more than 100 vmstat updates, then the batching is more efficient
(as in total amount of time to transfer to global counters).

But thats not the point. The point is the 10us interruption 
to execution of the realtime app (which can either mean 
your current deadline requirements are not met, or that 
another application with lowest latency requirement can't 
be used).

So i'd rather spend more time updating the aggregate of vmstatistics
(with the local->global transfer taking a small amount of time,
therefore not interrupting the realtime application for a long period),
than to batch the updates (which increases overall performance beyond 
a certain number of updates, but which is _ONE_ large interruption).

So lets assume i go and count the vmstat updates on the DPDK case 
(or any other realtime app), batching is more efficient 
for that case.

Still, the one-time interruption of batching is worse than less
efficient one bean at a time vmstatistics accounting.

No?

Also, you could reply that: "oh, there are no vmstat updates 
in fact in this setup, but the logic of disabling vmstat_update 
is broken". Lets assume thats the case.

Even if its fixed (vmstat_update properly shut down) the proposed patch
deals with both cases: no vmstat updates on isolated cpus, and vmstat
updates on isolated cpus.

So why are you against integrating this simple, isolated patch which 
does not affect how current logic works?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1732806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 13:13:31 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r63so50223020itc.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 10:13:31 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id d5si9834450iog.219.2017.05.19.10.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 10:13:30 -0700 (PDT)
Date: Fri, 19 May 2017 12:13:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170519143407.GA19282@amt.cnet>
Message-ID: <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
References: <20170502131527.7532fc2e@redhat.com> <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org> <20170512122704.GA30528@amt.cnet> <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org> <20170512154026.GA3556@amt.cnet> <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet> <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org> <20170515191531.GA31483@amt.cnet> <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org> <20170519143407.GA19282@amt.cnet>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 19 May 2017, Marcelo Tosatti wrote:

> Use-case: realtime application on an isolated core which for some reason
> updates vmstatistics.

Ok that is already only happening every 2 seconds by default and that
interval is configurable via the vmstat_interval proc setting.

> > Just a measurement of vmstat_worker. Pointless.
>
> Shouldnt the focus be on general scenarios rather than particular
> usecases, so that the solution covers a wider range of usecases?

Yes indeed and as far as I can tell the wider usecases are covered. Not
sure that there is anything required here.

> The situation as i see is as follows:
>
> Your point of view is: an "isolated CPU" with a set of applications
> cannot update vm statistics, otherwise they pay the vmstat_update cost:
>
>      kworker/5:1-245   [005] ....1..   673.454295: workqueue_execute_start: work struct ffffa0cf6e493e20: function vmstat_update
>      kworker/5:1-245   [005] ....1..   673.454305: workqueue_execute_end: work struct ffffa0cf6e493e20
>
> Thats 10us for example.

Well with a decent cpu that is 3 usec and it occurs infrequently on the
order of once per multiple seconds.

> So if want to customize a realtime setup whose code updates vmstatistic,
> you are dead. You have to avoid any systemcall which possibly updates
> vmstatistics (now and in the future kernel versions).

You are already dead because you allow IPIs and other kernel processing
which creates far more overhead. Still fail to see the point.

> The point is that these vmstat updates are rare. From
> http://www.7-cpu.com/cpu/Haswell.html:
>
> RAM Latency = 36 cycles + 57 ns (3.4 GHz i7-4770)
> RAM Latency = 62 cycles + 100 ns (3.6 GHz E5-2699 dual)
>
> Lets round to 100ns = 0.1us.

That depends on the kernel functionality used.

> You need 100 vmstat updates (all misses to RAM, the worst possible case)
> to have equivalent amount of time of the batching version.

The batching version occurs every couple of seconds if at all.

> But thats not the point. The point is the 10us interruption
> to execution of the realtime app (which can either mean
> your current deadline requirements are not met, or that
> another application with lowest latency requirement can't
> be used).

Ok then you need to get rid of the IPIs and the other stuff that you have
going on with the OS first I think.

> So why are you against integrating this simple, isolated patch which
> does not affect how current logic works?

Frankly the argument does not make sense. Vmstat updates occur very
infrequently (probably even less than you IPIs and the other OS stuff that
also causes additional latencies that you seem to be willing to tolerate).

And you can configure the interval of vmstat updates freely.... Set
the vmstat_interval to 60 seconds instead of 2 for a try? Is that rare
enough?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

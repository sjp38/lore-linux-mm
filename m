Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7CBA6B0522
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:21:21 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v143so2171238qkb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:21:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w62si193516qkw.64.2017.07.11.08.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 08:21:21 -0700 (PDT)
Date: Mon, 10 Jul 2017 12:05:20 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170710150520.GA16692@amt.cnet>
References: <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet>
 <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
 <20170519134934.0c298882@redhat.com>
 <20170525193508.GA30252@amt.cnet>
 <alpine.DEB.2.20.1705252220130.7596@east.gentwo.org>
 <20170526190926.GA8974@amt.cnet>
 <alpine.DEB.2.20.1705301310100.7195@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705301310100.7195@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Tue, May 30, 2017 at 01:17:41PM -0500, Christoph Lameter wrote:
> On Fri, 26 May 2017, Marcelo Tosatti wrote:
> 
> > > interrupts and scheduler ticks. But what does this have to do with vmstat?
> > >
> > > Show me your dpdk code running and trace the tick on / off events  as well
> > > as the vmstat invocations. Also show all system calls occurring on the cpu
> > > that runs dpdk. That is necessary to see what triggers vmstat and how the
> > > system reacts to the changes to the differentials.

This was in the host, while performing virtual machine migration... Which you can
say "invalidates the argument" because virtual machine migration takes 
MUCH longer time than what vmstat_update introduces.

> >
> > Sure, i can get that to you. The question remains: Are you arguing
> > its not valid for a realtime application to use any system call
> > which changes a vmstat counter?
> 
> A true realtime app would be conscientious of its use of the OS services
> because the use of the services may cause additional latencies and also
> cause timers etc to fire later. A realtime app that is willing to use
> these services is therefore willing to tolerate larger latencies. A
> realtime app that is using OS service may cause the timer tick to be
> enabled which also causes additional latencies.
> 
> I have seen completely OS noise free processing for extended time period
> when not using OS services and using RDMA for I/O. This fits my use case
> well.

People might want to use O/S services.

> If there are really these high latencies because of kworker processing for
> vmstat then maybe we need a different mechanism there (bh? or other
> triggers) and maybe we are using far too many counters so that the
> processing becomes a heavy user of resources.
> 
> > Because if they are allowed, then its obvious something like
> > this is needed.
> 
> I am still wondering what benefit there is. Lets get clear on the test
> load and see if this actually makes sense.

Ok, test load: 

	* Any userspace app that causes a systemcall which triggers
	vmstat_update is susceptible to vmstat_update running on that
	CPU, which might be detrimental to latency.

So either something which moves vmstat_update work to another CPU, 
or that avoids vmstat_update (which is what the proposed patchset does),
must be necessary.

So if a customer comes to me and says: "i am using sys_XXX in my
application, but my latency is high", i'll have to tell him: "ok, please
don't use that system call since it triggers kernel activity on the CPU
which does not allow you to achieve the latency you desire".

But it seems the "no syscalls" rule seems to be a good idea for 
CPU isolated, low latency stuff...

So i give up on the use-case behind this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

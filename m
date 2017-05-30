Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35B2F6B02F4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:44 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t133so100658000oif.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:44 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id y10si5657940oia.48.2017.05.30.11.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 11:17:43 -0700 (PDT)
Date: Tue, 30 May 2017 13:17:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170526190926.GA8974@amt.cnet>
Message-ID: <alpine.DEB.2.20.1705301310100.7195@east.gentwo.org>
References: <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org> <20170512161915.GA4185@amt.cnet> <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org> <20170515191531.GA31483@amt.cnet> <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet> <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org> <20170519134934.0c298882@redhat.com> <20170525193508.GA30252@amt.cnet> <alpine.DEB.2.20.1705252220130.7596@east.gentwo.org> <20170526190926.GA8974@amt.cnet>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 26 May 2017, Marcelo Tosatti wrote:

> > interrupts and scheduler ticks. But what does this have to do with vmstat?
> >
> > Show me your dpdk code running and trace the tick on / off events  as well
> > as the vmstat invocations. Also show all system calls occurring on the cpu
> > that runs dpdk. That is necessary to see what triggers vmstat and how the
> > system reacts to the changes to the differentials.
>
> Sure, i can get that to you. The question remains: Are you arguing
> its not valid for a realtime application to use any system call
> which changes a vmstat counter?

A true realtime app would be conscientious of its use of the OS services
because the use of the services may cause additional latencies and also
cause timers etc to fire later. A realtime app that is willing to use
these services is therefore willing to tolerate larger latencies. A
realtime app that is using OS service may cause the timer tick to be
enabled which also causes additional latencies.

I have seen completely OS noise free processing for extended time period
when not using OS services and using RDMA for I/O. This fits my use case
well.

If there are really these high latencies because of kworker processing for
vmstat then maybe we need a different mechanism there (bh? or other
triggers) and maybe we are using far too many counters so that the
processing becomes a heavy user of resources.

> Because if they are allowed, then its obvious something like
> this is needed.

I am still wondering what benefit there is. Lets get clear on the test
load and see if this actually makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

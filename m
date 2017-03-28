Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 682406B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:11:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r71so52482872wrb.17
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:11:26 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id s2si5960407wra.10.2017.03.28.14.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 14:11:25 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id u18so5152540wrc.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:11:24 -0700 (PDT)
Date: Tue, 28 Mar 2017 23:11:22 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170328211121.GA8615@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
 <20170328143431.GB4216@lerouge>
 <20170328172303.78a3c6d4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170328172303.78a3c6d4@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Tue, Mar 28, 2017 at 05:23:03PM +0200, Jesper Dangaard Brouer wrote:
> On Tue, 28 Mar 2017 16:34:36 +0200
> Frederic Weisbecker <fweisbec@gmail.com> wrote:
> 
> > On Tue, Mar 28, 2017 at 10:14:03AM +0200, Jesper Dangaard Brouer wrote:
> > > 
> > > (While evaluating some changes to the page allocator) I ran into an
> > > issue with ksoftirqd getting too much CPU sched time.
> > > 
> > > I bisected the problem to
> > >  a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqtime account")
> > > 
> > >  a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
> > >  commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
> > >  Author: Frederic Weisbecker <fweisbec@gmail.com>
> > >  Date:   Tue Jan 31 04:09:32 2017 +0100
> > > 
> > >     sched/cputime: Increment kcpustat directly on irqtime account
> > >     
> > >     The irqtime is accounted is nsecs and stored in
> > >     cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once the
> > >     accumulated amount reaches a new jiffy, this one gets accounted to the
> > >     kcpustat.
> > >     
> > >     This was necessary when kcpustat was stored in cputime_t, which could at
> > >     worst have jiffies granularity. But now kcpustat is stored in nsecs
> > >     so this whole discretization game with temporary irqtime storage has
> > >     become unnecessary.
> > >     
> > >     We can now directly account the irqtime to the kcpustat.
> > >     
> > >     Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
> > >     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > >     Cc: Fenghua Yu <fenghua.yu@intel.com>
> > >     Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > >     Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > >     Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > >     Cc: Michael Ellerman <mpe@ellerman.id.au>
> > >     Cc: Paul Mackerras <paulus@samba.org>
> > >     Cc: Peter Zijlstra <peterz@infradead.org>
> > >     Cc: Rik van Riel <riel@redhat.com>
> > >     Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> > >     Cc: Thomas Gleixner <tglx@linutronix.de>
> > >     Cc: Tony Luck <tony.luck@intel.com>
> > >     Cc: Wanpeng Li <wanpeng.li@hotmail.com>
> > >     Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-email-fweisbec@gmail.com
> > >     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > > 
> > > The reproducer is running a userspace udp_sink[1] program, and taskset
> > > pinning the process to the same CPU as softirq RX is running on, and
> > > starting a UDP flood with pktgen (tool part of kernel tree:
> > > samples/pktgen/pktgen_sample03_burst_single_flow.sh).  
> > 
> > So that means I need to run udp_sink on the same CPU than pktgen?
> 
> No, you misunderstood.  I run pktgen on another physical machine, which
> is sending UDP packets towards my Device-Under-Test (DUT) target.  The
> DUT-target is receiving packets and I observe which CPU the NIC is
> delivering these packets to.

Ah ok, so I tried to run pktgen on another machine and I get that strange write error:

    # ./pktgen_sample03_burst_single_flow.sh -d 192.168.1.3  -i wlan0
    ./functions.sh: ligne 76 : echo: erreur d'i? 1/2 criture : Erreur inconnue 524
    ERROR: Write error(1) occurred cmd: "clone_skb 100000 > /proc/net/pktgen/wlan0@0"

Any idea?

> 
> E.g determine RX-CPU via mpstat command:
>  mpstat -P ALL -u -I SCPU -I SUM 2
> 
> I then start udp_sink, pinned to the RX-CPU, like:
>  sudo taskset -c 2 ./udp_sink --port 9 --count $((10**6)) --recvmsg --repeat 1000

Ah thanks for these hints!

> > > After this commit, the udp_sink program does not get any sched CPU
> > > time, and no packets are delivered to userspace.  (All packets are
> > > dropped by softirq due to a full socket queue, nstat
> > > UdpRcvbufErrors).
> > > 
> > > A related symptom is that ksoftirqd no longer get accounted in
> > > top.  
> > 
> > That's indeed what I observe. udp_sink has almost no CPU time,
> > neither has ksoftirqd but kpktgend_0 has everything.
> > 
> > Finally a bug I can reproduce!
> 
> Good to hear you can reproduce it! :-)

Well, since I was generating the packets locally, maybe it didn't trigger
the expected interrupts...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

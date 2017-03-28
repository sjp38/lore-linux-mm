Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 528136B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:23:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p22so60545951qka.4
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 08:23:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 144si3675600qkj.311.2017.03.28.08.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 08:23:12 -0700 (PDT)
Date: Tue, 28 Mar 2017 17:23:03 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170328172303.78a3c6d4@redhat.com>
In-Reply-To: <20170328143431.GB4216@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
	<20170328143431.GB4216@lerouge>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, brouer@redhat.com

On Tue, 28 Mar 2017 16:34:36 +0200
Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Tue, Mar 28, 2017 at 10:14:03AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > (While evaluating some changes to the page allocator) I ran into an
> > issue with ksoftirqd getting too much CPU sched time.
> > 
> > I bisected the problem to
> >  a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqtime account")
> > 
> >  a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
> >  commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
> >  Author: Frederic Weisbecker <fweisbec@gmail.com>
> >  Date:   Tue Jan 31 04:09:32 2017 +0100
> > 
> >     sched/cputime: Increment kcpustat directly on irqtime account
> >     
> >     The irqtime is accounted is nsecs and stored in
> >     cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once the
> >     accumulated amount reaches a new jiffy, this one gets accounted to the
> >     kcpustat.
> >     
> >     This was necessary when kcpustat was stored in cputime_t, which could at
> >     worst have jiffies granularity. But now kcpustat is stored in nsecs
> >     so this whole discretization game with temporary irqtime storage has
> >     become unnecessary.
> >     
> >     We can now directly account the irqtime to the kcpustat.
> >     
> >     Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
> >     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> >     Cc: Fenghua Yu <fenghua.yu@intel.com>
> >     Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> >     Cc: Linus Torvalds <torvalds@linux-foundation.org>
> >     Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> >     Cc: Michael Ellerman <mpe@ellerman.id.au>
> >     Cc: Paul Mackerras <paulus@samba.org>
> >     Cc: Peter Zijlstra <peterz@infradead.org>
> >     Cc: Rik van Riel <riel@redhat.com>
> >     Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> >     Cc: Thomas Gleixner <tglx@linutronix.de>
> >     Cc: Tony Luck <tony.luck@intel.com>
> >     Cc: Wanpeng Li <wanpeng.li@hotmail.com>
> >     Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-email-fweisbec@gmail.com
> >     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > 
> > The reproducer is running a userspace udp_sink[1] program, and taskset
> > pinning the process to the same CPU as softirq RX is running on, and
> > starting a UDP flood with pktgen (tool part of kernel tree:
> > samples/pktgen/pktgen_sample03_burst_single_flow.sh).  
> 
> So that means I need to run udp_sink on the same CPU than pktgen?

No, you misunderstood.  I run pktgen on another physical machine, which
is sending UDP packets towards my Device-Under-Test (DUT) target.  The
DUT-target is receiving packets and I observe which CPU the NIC is
delivering these packets to.

E.g determine RX-CPU via mpstat command:
 mpstat -P ALL -u -I SCPU -I SUM 2

I then start udp_sink, pinned to the RX-CPU, like:
 sudo taskset -c 2 ./udp_sink --port 9 --count $((10**6)) --recvmsg --repeat 1000


> > [1] udp_sink
> >  https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c
> > 
> > The expected results (after commit 4cd13c21b207 ("softirq: Let
> > ksoftirqd do its job")) is that the scheduler split the CPU time 50/50
> > between udp_sink and ksoftirqd.  
> 
> I guess you mean that this is what happened before this commit?

Yes. (I just pointed out the kernel had another softirq bug, that I was
involved in fixing)
 
> > 
> > After this commit, the udp_sink program does not get any sched CPU
> > time, and no packets are delivered to userspace.  (All packets are
> > dropped by softirq due to a full socket queue, nstat
> > UdpRcvbufErrors).
> > 
> > A related symptom is that ksoftirqd no longer get accounted in
> > top.  
> 
> That's indeed what I observe. udp_sink has almost no CPU time,
> neither has ksoftirqd but kpktgend_0 has everything.
> 
> Finally a bug I can reproduce!

Good to hear you can reproduce it! :-)

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39BEE6B03A3
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 05:30:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q46so3556969qtb.16
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:30:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y33si5768345qtb.91.2017.03.29.02.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 02:30:40 -0700 (PDT)
Date: Wed, 29 Mar 2017 11:30:30 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170329113030.671ff443@redhat.com>
In-Reply-To: <20170328211121.GA8615@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
	<20170328143431.GB4216@lerouge>
	<20170328172303.78a3c6d4@redhat.com>
	<20170328211121.GA8615@lerouge>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, brouer@redhat.com

On Tue, 28 Mar 2017 23:11:22 +0200
Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Tue, Mar 28, 2017 at 05:23:03PM +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 28 Mar 2017 16:34:36 +0200
> > Frederic Weisbecker <fweisbec@gmail.com> wrote:
> >  =20
> > > On Tue, Mar 28, 2017 at 10:14:03AM +0200, Jesper Dangaard Brouer wrot=
e: =20
> > > >=20
> > > > (While evaluating some changes to the page allocator) I ran into an
> > > > issue with ksoftirqd getting too much CPU sched time.
> > > >=20
> > > > I bisected the problem to
> > > >  a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqti=
me account")
> > > >=20
> > > >  a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
> > > >  commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
> > > >  Author: Frederic Weisbecker <fweisbec@gmail.com>
> > > >  Date:   Tue Jan 31 04:09:32 2017 +0100
> > > >=20
> > > >     sched/cputime: Increment kcpustat directly on irqtime account
> > > >    =20
> > > >     The irqtime is accounted is nsecs and stored in
> > > >     cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once t=
he
> > > >     accumulated amount reaches a new jiffy, this one gets accounted=
 to the
> > > >     kcpustat.
> > > >    =20
> > > >     This was necessary when kcpustat was stored in cputime_t, which=
 could at
> > > >     worst have jiffies granularity. But now kcpustat is stored in n=
secs
> > > >     so this whole discretization game with temporary irqtime storag=
e has
> > > >     become unnecessary.
> > > >    =20
> > > >     We can now directly account the irqtime to the kcpustat.
> > > >    =20
> > > >     Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
> > > >     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > > >     Cc: Fenghua Yu <fenghua.yu@intel.com>
> > > >     Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > > >     Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > > >     Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > > >     Cc: Michael Ellerman <mpe@ellerman.id.au>
> > > >     Cc: Paul Mackerras <paulus@samba.org>
> > > >     Cc: Peter Zijlstra <peterz@infradead.org>
> > > >     Cc: Rik van Riel <riel@redhat.com>
> > > >     Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> > > >     Cc: Thomas Gleixner <tglx@linutronix.de>
> > > >     Cc: Tony Luck <tony.luck@intel.com>
> > > >     Cc: Wanpeng Li <wanpeng.li@hotmail.com>
> > > >     Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-ema=
il-fweisbec@gmail.com
> > > >     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > > >=20
> > > > The reproducer is running a userspace udp_sink[1] program, and task=
set
> > > > pinning the process to the same CPU as softirq RX is running on, and
> > > > starting a UDP flood with pktgen (tool part of kernel tree:
> > > > samples/pktgen/pktgen_sample03_burst_single_flow.sh).   =20
> > >=20
> > > So that means I need to run udp_sink on the same CPU than pktgen? =20
> >=20
> > No, you misunderstood.  I run pktgen on another physical machine, which
> > is sending UDP packets towards my Device-Under-Test (DUT) target.  The
> > DUT-target is receiving packets and I observe which CPU the NIC is
> > delivering these packets to. =20
>=20
> Ah ok, so I tried to run pktgen on another machine and I get that strange=
 write error:
>=20
>     # ./pktgen_sample03_burst_single_flow.sh -d 192.168.1.3  -i wlan0
>     ./functions.sh: ligne 76 : echo: erreur d'=EF=BF=BDcriture : Erreur i=
nconnue 524
>     ERROR: Write error(1) occurred cmd: "clone_skb 100000 > /proc/net/pkt=
gen/wlan0@0"
>=20
> Any idea?

Yes, this interface does not support pktgen "clone_skb".  You can
supply cmdline argument "-c 0" to fix this.  But I suspect that this
interface also does not support "burst", thus you also need "-b 0".

See all cmdline args via: ./pktgen_sample03_burst_single_flow.sh -h

Why are you using a wifi interface for this kind of overload testing?
(the basic test here is making sure softirq is busy 100%, and at slow
wifi speeds this might not be possible to force ksoftirqd into this
scheduler state)


> >=20
> > E.g determine RX-CPU via mpstat command:
> >  mpstat -P ALL -u -I SCPU -I SUM 2
> >=20
> > I then start udp_sink, pinned to the RX-CPU, like:
> >  sudo taskset -c 2 ./udp_sink --port 9 --count $((10**6)) --recvmsg --r=
epeat 1000 =20
>=20
> Ah thanks for these hints!
>=20
> > > > After this commit, the udp_sink program does not get any sched CPU
> > > > time, and no packets are delivered to userspace.  (All packets are
> > > > dropped by softirq due to a full socket queue, nstat
> > > > UdpRcvbufErrors).
> > > >=20
> > > > A related symptom is that ksoftirqd no longer get accounted in
> > > > top.   =20
> > >=20
> > > That's indeed what I observe. udp_sink has almost no CPU time,
> > > neither has ksoftirqd but kpktgend_0 has everything.
> > >=20
> > > Finally a bug I can reproduce! =20
> >=20
> > Good to hear you can reproduce it! :-) =20
>=20
> Well, since I was generating the packets locally, maybe it didn't trigger
> the expected interrupts...

Well, you definitely didn't create the test case I was using.  I cannot
remember if the pktgen kthreads runs in softirq context, but I suspect
it does. If so, you can recreate the main problem, which is a softirq
thread using 100% CPU time, which cause no other processes getting
sched time on that CPU.

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

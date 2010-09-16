Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 15AF96B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 10:00:53 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o8GE0tSE026812
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 00:00:55 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8GE0sXt2220196
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 00:00:55 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8GE0sYR027654
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 00:00:54 +1000
Date: Thu, 16 Sep 2010 23:30:45 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100916233045.73aecc26@lilo>
In-Reply-To: <4C91E01E.4070209@inria.fr>
References: <20100915104855.41de3ebf@lilo>
	<4C90A6C7.9050607@redhat.com>
	<20100916001232.0c496b02@lilo>
	<4C91B9E9.4020701@ens-lyon.org>
	<4C91E01E.4070209@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010 11:15:10 +0200
Brice Goglin <Brice.Goglin@inria.fr> wrote:

> Le 16/09/2010 08:32, Brice Goglin a =E9crit :
> > I am the guy doing KNEM so I can comment on this. The I/OAT part of
> > KNEM was mostly a research topic, it's mostly useless on current
> > machines since the memcpy performance is much larger than I/OAT DMA
> > Engine. We also have an offload model with a kernel thread, but it
> > wasn't used a lot so far. These features can be ignored for the
> > current discussion.
>=20
> I've just created a knem branch where I removed all the above, and
> some other stuff that are not necessary for normal users. So it just
> contains the region management code and two commands to copy between
> regions or between a region and some local iovecs.

When I did the original hpcc runs for CMA vs shared mem double copy I
also did some KNEM runs as a bit of a sanity check. The CMA OpenMPI
implementation actually uses the infrastructure KNEM put into the
OpenMPI shared mem btl - thanks for that btw it made things much easier
for me to test CMA.

Interestingly although KNEM and CMA fundamentally are doing very
similar things, at least with hpcc I didn't see as much of a gain with
KNEM as with CMA:

MB/s			=09
Naturally Ordered	4	8	16	32
Base	1235	935	622	419
CMA	4741	3769	1977	703
KNEM	3362	3091	1857	681
			=09
MB/s			=09
Randomly Ordered	4	8	16	32
Base	1227	947	638	412
CMA	4666	3682	1978	710
KNEM	3348	3050	1883	684
			=09
MB/s			=09
Max Ping Pong	4	8	16	32
Base	2028	1938	1928	1882
CMA	7424	7510	7598	7708
KNEM	5661	5476	6050	6290

I don't know the reason behind the difference - if its something
perculiar to hpcc,  or if there's extra overhead the way that
knem does setup for copying, or if knem wasn't configured
optimally. I haven't done any comparison IMB or NPB runs...

syscall and setup overhead does have some measurable effect - although I
don't have the numbers for it here, neither KNEM nor CMA does quite as
well with hpcc when compared against a hacked version of hpcc  where
everything is declared ahead of time as shared memory so the receiver
can just do a single copy from userspace - which I think is
representative of a theoretical maximum gain from the single copy
approach.

Chris
--=20
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA09913
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 17:03:04 -0700 (PDT)
Message-ID: <3D8D08B7.419DD093@digeo.com>
Date: Sat, 21 Sep 2002 17:03:03 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: overcommit stuff
References: <3D8D0046.EF119E03@digeo.com> <14599773.1032625910@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > running 10,000 tiobench threads I'm showing 23 gigs of
> > `Commited_AS'.  Is this right?  Those pages are shared,
> > and if they're not PROT_WRITEable then there's no way in
> > which they can become unshared?   Seems to be excessively
> > pessimistic?
> >
> > Or is 2.5 not up to date?
> 
> It's also a global atomic counter that burns up a fair amount
> of CPU time bouncing cachelines on the NUMA boxes ... even when
> overcommit is set to 1, and it's not used for anything other
> than meminfo ... any chance of this either becoming a per-cpu
> thing, or dying, or not being used when overcommit is 1?

"It" being vm_committed_space.

The problem is that it's read from frequently, as well as
updated frequently.  So we would still have problems when
we have to reach across and fish the cpu-local counters
out of remote corners of the machine all the time.

The usual tricks for amortising this counter's cost have (serious)
accuracy implications.

I am planning on sitting down and working out exactly what we're
trying to account here - presumably there's another way.  Just
havent got onto it yet.

Worst come to worst, we can hide it inside CONFIG_NOT_WHACKOMATIC
I guess.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

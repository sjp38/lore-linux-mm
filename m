Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA08179
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 14:32:27 -0700 (PDT)
Message-ID: <3DA4A06A.B84D4C05@digeo.com>
Date: Wed, 09 Oct 2002 14:32:26 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Hangs in 2.5.41-mm1
References: <3DA48EEA.8100302C@digeo.com> <1034195372.30973.64.camel@plars>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> On Wed, 2002-10-09 at 15:17, Andrew Morton wrote:
> > Paul Larson wrote:
> > > echo 768 > /proc/sys/vm/nr_hugepages
> >
> > Paul, this is not very clear to me, sorry.
> Sorry about that, let me try to restate it better.  First let me add
> though, these have been somewhat random and hard to reproduce the same
> way every time, but if I run this test enough though, I eventually get
> it to lock up cold.
> 
> Here are the situations where I saw it happen so far under 2.5.41-mm1:
> 
> Case 1:
> from ltp, 'runalltests.sh -l /tmp/mm1.log |tee /tmp/mm1.out
> shmt01 (attached test from before)
> shmt01& (repeated 10 times)
> echo 768 > /proc/sys/vm/nr_hugepages
> *hang*
> 
> Case 2:
> cold boot
> echo 768 > /proc/sys/vm/nr_hugepages
> echo 1610612736 > /proc/sys/kernel/shmmax
> shmt01 -s 1610612736&
> shmt01 (immediately after starting the previous command)
> *hang*

OK, thanks.

> > There is a locks-up-for-ages bug in refill_inactive_zone() - could
> > be that.  Dunno.
> I'm not aware of that one, do you know of a reliable way to reproduce that?

You need to torture it.  It happens when there's a huge amount
of mapped memory in a zone and the `swappiness' knob is set low.
We end up doing a ton of scanning of the active list, but not
actually doing anything.  Fix is to only scan a little bit, then
fall back and scan the inactive list a bit, let the scanning
priority increase until it's high enough to trigger reclaim of
mapped memory.

-mm2 will cure all ills ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

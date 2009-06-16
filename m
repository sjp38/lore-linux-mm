Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F5306B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 02:12:42 -0400 (EDT)
Message-ID: <4A3737CE.3020305@gmail.com>
Date: Tue, 16 Jun 2009 08:12:30 +0200
From: Eric Dumazet <eric.dumazet@gmail.com>
MIME-Version: 1.0
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced  by  tuning?
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <20090527131437.5870e342.akpm@linux-foundation.org> <20090527231949.GB30002@elte.hu> <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx> <4A3702CF.9070303@gmail.com> <6.2.5.6.2.20090616000017.05b5da70@binnacle.cx>
In-Reply-To: <6.2.5.6.2.20090616000017.05b5da70@binnacle.cx>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Please dont top post, we prefer other way around :)

starlight@binnacle.cx a ecrit :
> Eric,
> 
> Great thought--thank you.  Running a similar server with 
> 82571/e1000e and it does not exhibit the problem.  'e1000e' has 
> default copybreak=256 while 'ixgbe' has no copybreak.  Rational 
> given is
> 
>    http://osdir.com/ml/linux.drivers.e1000.devel/2008-01/msg00103.html
> 
> But the comparion is a bit apples-and-oranges since the 'e1000e' 
> system is dual Opteron 2354 while the 'ixgbe' system is Xeon 
> E5430 (a painful choice thus far).  Also 'e1000e' system passes 
> data via a PACKET socket while the 'ixgbe' system passes data 
> via UDP (a configurable option).
> 
> I'm not fully up on how this all works: am I to understand that 
> the error could result from RX ring-queue buffers not freeing 
> quickly enough because they have a use-count held non-zero as
> the packet travels the stack?

Well, error is normal in stress situation, when no more kernel
memory is available.

cat /proc/net/udp

can show you (in last column) sockets where packets where dropped
by UDP stack if their receive queue was full.

> 
> I've just doubled some SLAB tuneables that seem relevant, but 
> if the cause is the aforementioned, this won't help.  Will
> have the answer on the tweaks by the end of Tuesday.
> 
> David

copybreak in drivers themselves is nice because driver can recycle
its rx skbs much faster, but that is suboptimal in forwarding (routers)
workloads. Its also a lot of duplicated code in every driver.

So we could do the skb trimming (ie : reallocating the data portion to exactly
the size of packet) in core network stack, when we know packet must be handled
by an application, and not dropped or forwarded by kernel.

Because of slab rounding, this reallocation should be done only if resulting data
portion is really smaller (50 %) than original skb.

> 
> 
> 
> At 04:26 AM 6/16/2009 +0200, Eric Dumazet wrote:
>> 152691992335/724246449 = 210 bytes per rx packet in average
>>
>> It could make sense to add copybreak feature in this driver to 
>> reduce memory needs, but that also would consume more cpu 
>> cycles, and slow down forwarding setups.
>>
>> Maybe this packet trimming could be done generically in UDP 
>> stack input path, before queueing packet into a receive queue, 
>> if amount of available memory is under a given threshold.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

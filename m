Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 844776B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 00:23:30 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090616000017.05b5da70@binnacle.cx>
Date: Tue, 16 Jun 2009 00:12:14 -0400
From: starlight@binnacle.cx
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced
  by  tuning?
In-Reply-To: <4A3702CF.9070303@gmail.com>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
 <20090527131437.5870e342.akpm@linux-foundation.org>
 <20090527231949.GB30002@elte.hu>
 <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx>
 <4A3702CF.9070303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

Eric,

Great thought--thank you.  Running a similar server with 
82571/e1000e and it does not exhibit the problem.  'e1000e' has 
default copybreak=256 while 'ixgbe' has no copybreak.  Rational 
given is

   http://osdir.com/ml/linux.drivers.e1000.devel/2008-01/msg00103.html

But the comparion is a bit apples-and-oranges since the 'e1000e' 
system is dual Opteron 2354 while the 'ixgbe' system is Xeon 
E5430 (a painful choice thus far).  Also 'e1000e' system passes 
data via a PACKET socket while the 'ixgbe' system passes data 
via UDP (a configurable option).

I'm not fully up on how this all works: am I to understand that 
the error could result from RX ring-queue buffers not freeing 
quickly enough because they have a use-count held non-zero as
the packet travels the stack?

I've just doubled some SLAB tuneables that seem relevant, but 
if the cause is the aforementioned, this won't help.  Will
have the answer on the tweaks by the end of Tuesday.

David



At 04:26 AM 6/16/2009 +0200, Eric Dumazet wrote:
>
>152691992335/724246449 = 210 bytes per rx packet in average
>
>It could make sense to add copybreak feature in this driver to 
>reduce memory needs, but that also would consume more cpu 
>cycles, and slow down forwarding setups.
>
>Maybe this packet trimming could be done generically in UDP 
>stack input path, before queueing packet into a receive queue, 
>if amount of available memory is under a given threshold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

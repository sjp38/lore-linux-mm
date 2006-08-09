Message-ID: <44D98CAB.8090202@garzik.org>
Date: Wed, 09 Aug 2006 03:20:11 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
References: <20060808193447.1396.59301.sendpatchset@lappy>	 <44D9191E.7080203@garzik.org>	<44D977D8.5070306@google.com>	 <20060808.225537.112622421.davem@davemloft.net>	 <44D980EB.5010608@garzik.org> <1155107002.23134.40.camel@lappy>
In-Reply-To: <1155107002.23134.40.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>, phillips@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Wed, 2006-08-09 at 02:30 -0400, Jeff Garzik wrote:
>> David Miller wrote:
>>> From: Daniel Phillips <phillips@google.com>
>>> Date: Tue, 08 Aug 2006 22:51:20 -0700
>>>
>>>> Elaborate please.  Do you think that all drivers should be updated to
>>>> fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
>>>> If so, I trust you will help audit for it?
>>> I think he's saying that he doesn't think your code is yet a
>>> reasonable way to solve the problem, and therefore doesn't belong
>>> upstream.
>> Pretty much.  It is completely non-sensical to add NETIF_F_MEMALLOC, 
>> when it should be blindingly obvious that every net driver will be 
>> allocating memory, and every net driver could potentially be used with 
>> NBD and similar situations.
> 
> Sure, but until every single driver is converted I'd like to warn people
> about the fact that their setups is not up to expectations. Iff all
> drivers are converted I'll be the forst to submit a patch that removes
> the feature flag.

A temporary-for-years flag is not a good approach.  The flag is not 
_needed_ for technical reasons, but for supposed user expectation reasons.

Rather, just go ahead and convert drivers to netdev_alloc_skb() where 
people care.  If someone suddenly gets a burr up their ass about the 
sunlance or epic100 driver deadlocking on NBD, then they can convert it 
or complain loudly themselves.

Overall, a good solution needs to be uniform across all net drivers. 
NETIF_F_MEMALLOC is just _encouraging_ people to be slackers and delay 
converting other drivers, creating two classes of drivers, the "haves" 
and the "have nots".

Just make a big netdev_alloc_skb() patch that converts most users. 
netdev_alloc_skb() is a good thing to use, because it builds an 
association with struct net_device and the allocation.

	Jeff



P.S.  Since netdev_alloc_skb() calls skb_reserve(), you need to take 
that into account.  That's a bug in current patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

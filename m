Message-ID: <39CD1732.AA1874B0@norran.net>
Date: Sat, 23 Sep 2000 22:48:50 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: memory pressure and kswapd
References: <OF84F4052E.D0DA6D69-ON88256963.005F5758@LocalDomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This code was mostly mine...

keep_kswapd_awake returns one if:
 all zones are 'zone_wake_kswapd'
or
 any zone is MIN or below [critically low]

memory_pressure returns one if:
 any zone has less than LOW.
 (this test is rarely used...)

It is the keep_kswapd_awake that is the interesting one.
In test5 we did not check for critically low risking
to have run into a situation were DMA memory is needed
but none is available...

Your situation is probably that while trying to find one
of those files it has to scan throu lots of pages.


You might try to remove the test for MIN in
keep_kswapd_awake to see if things improve.

I have thought about adding more steps on the memory
stair to avoid this problem.

/RogerL

Ying Chen/Almaden/IBM wrote:
> 
> Hi,
> 
> I have a question on the memory_pressure() and keep_kswapd_awake() calls.
> The question may be specific to test6, since vm has been changed in more
> recently releases.
> Why should memory_pressure() and keep_kswapd_awake() return 1 as long as
> one of the zones is low on memory? Shouldn't it be the case that when all
> of the zones are low then return 1? I noticed that in some cases, when I
> ran out of memory in DMA and low memory zones, kswapd would kick in and is
> kept awake for ever, despite the fact that I still have about 1GB memory in
> the HIGH memory zone. At least I'd think that for NORMAL memory
> allocations, they should be able to use both LOW and HIGH memory zones, and
> only kick kswapd when both LOW and HIGH zones are short of memory.
> Am I missing something here?
> 
> Ying
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j53Gh5Cg030509
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 12:43:05 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j53Gh5sX239430
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 12:43:05 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j53Gh4cj007114
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 12:43:05 -0400
Subject: Re: Avoiding external fragmentation with a placement policy
	Version 12
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <369850000.1117807062@[10.10.2.4]>
References: <429E50B8.1060405@yahoo.com.au><429F2B26.9070509@austin.ibm.com>
	 <1117770488.5084.25.camel@npiggin-nld.site>
	 <20050602.214927.59657656.davem@davemloft.net>
	 <357240000.1117776882@[10.10.2.4]> <429FFC21.1020108@yahoo.com.au>
	 <369850000.1117807062@[10.10.2.4]>
Content-Type: text/plain
Date: Fri, 03 Jun 2005 09:43:00 -0700
Message-Id: <1117816980.5985.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "David S. Miller" <davem@davemloft.net>, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-06-03 at 06:57 -0700, Martin J. Bligh wrote:
> 
> >>> Actually, even with TSO enabled, you'll get large order
> >>> allocations, but for receive packets, and these allocations
> >>> happen in software interrupt context.
> >> 
> >> Sounds like we still need to cope then ... ?
> > 
> > Sure. Although we should try to not use higher order allocs if
> > possible of course. Even with a fallback mode, you will still be
> > putting more pressure on higher order areas and thus degrading
> > the service for *other* allocators, so such schemes should
> > obviously be justified by performance improvements.
> 
> My point is that outside of a benchmark situation (where we just
> rebooted the machine to run a test) you will NEVER get an order 4
> block free anyway, so it's pointless.

I ran a little test overnight on a 16GB i386 system.

	cat /dev/zero | ./nc localhost 9999 & ; ./nc -l -p 9999

It pushed around 200MB of traffic through lo.  Is that (relatively low)
transmission rate due to having to kick off kswapd any time it wants to
send a packet?

partial mem/buddyinfo before:
MemTotal:     16375212 kB
MemFree:        214248 kB
HighTotal:    14548952 kB
HighFree:       198272 kB
LowTotal:      1826260 kB
LowFree:         15976 kB
Cached:       14415800 kB

Node 0, zone      DMA    217     35      2      1      1      1      1      0      1      1      1
Node 0, zone   Normal   7236   3020   3885    104      7      0      0      0      0      0      1
Node 0, zone  HighMem     18    503      0      0      1      0      0      1      0      0      0

partial mem/buddyinfo after:
MemTotal:     16375212 kB
MemFree:      13471604 kB
HighTotal:    14548952 kB
HighFree:     13450624 kB
LowTotal:      1826260 kB
LowFree:         20980 kB
Cached:         972988 kB

Node 0, zone      DMA      1      0      1      1      1      1      1      0      1      1      1
Node 0, zone   Normal   1488     52     10     66      7      0      0      0      0      0      1
Node 0, zone  HighMem   1322   3541   3165  20611  20651  14062   8054   5400   2643    664    169

There was surely plenty of other stuff going on, but it looks like
ZONE_HIGHMEM got eaten, and has plenty of large contiguous areas
available.  This probably shows the collateral damage when kswapd goes
randomly shooting down pages.  Are those loopback allocations
GFP_KERNEL?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

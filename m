Message-ID: <429FFC21.1020108@yahoo.com.au>
Date: Fri, 03 Jun 2005 16:43:45 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <429E50B8.1060405@yahoo.com.au><429F2B26.9070509@austin.ibm.com><1117770488.5084.25.camel@npiggin-nld.site> <20050602.214927.59657656.davem@davemloft.net> <357240000.1117776882@[10.10.2.4]>
In-Reply-To: <357240000.1117776882@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: "David S. Miller" <davem@davemloft.net>, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>>It would really help your cause in the short term if you can
>>>demonstrate improvements for say order-3 allocations (eg. use
>>>gige networking, TSO, jumbo frames, etc).
>>
>>TSO chops up the user data into PAGE_SIZE chunks, it doesn't
>>make use of non-zero page orders.
>>

My mistake. Thanks for correcting me.


> One of the calls I got the other day was for loopback interface. 
> Default MTU is 16K, which seems to screw everything up and do higher 
> order allocs. Turning it down to under 4K seemed to fix things. I'm 
> fairly sure loopback doesn't really need phys contig memory, but it 
> seems to use it at the moment ;-)
> 

Out of interest, I did do some tests a while back that showed
16K is good for TCP over loopback bandwidth on a few different
types of CPUs (P3, Xeon, Opteron...).

IIRC 32K may have been slightly faster, but not enough to warrant
that size allocation.

Bandwidth for smaller sizes dropped off quite significantly,
although I'm not sure if that would have been from the actual
memory copy overhead or increased per-'something' overhead in the
network code. If the latter, that would suggest at least in theory
it could use noncongiguous physical pages.

> 
>>Actually, even with TSO enabled, you'll get large order
>>allocations, but for receive packets, and these allocations
>>happen in software interrupt context.
> 
> 
> Sounds like we still need to cope then ... ?
> 

Sure. Although we should try to not use higher order allocs if
possible of course. Even with a fallback mode, you will still be
putting more pressure on higher order areas and thus degrading
the service for *other* allocators, so such schemes should
obviously be justified by performance improvements.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

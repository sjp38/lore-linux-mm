Message-ID: <43DE9583.5050700@us.ibm.com>
Date: Mon, 30 Jan 2006 14:38:59 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 0/9] Critical Mempools
References: <1138217992.2092.0.camel@localhost.localdomain>	 <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>	 <43D954D8.2050305@us.ibm.com>	 <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>	 <43D95BFE.4010705@us.ibm.com> <20060127000304.GG10409@kvack.org>	 <43D968E4.5020300@us.ibm.com>	 <84144f020601262335g49c21b62qaa729732e9275c0@mail.gmail.com>	 <20060127021050.f50d358d.pj@sgi.com>	 <84144f020601270307t7266a4ccs5071d4b288a9257f@mail.gmail.com>	 <43DABDBF.7010006@us.ibm.com> <1138443711.8657.16.camel@localhost>
In-Reply-To: <1138443711.8657.16.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Paul Jackson <pj@sgi.com>, bcrl@kvack.org, clameter@engr.sgi.com, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi,
> 
> On Fri, 2006-01-27 at 16:41 -0800, Matthew Dobson wrote:
> 
>>Now, a few pages of memory could be incredibly crucial, since
>>we're discussing an emergency (presumably) low-mem situation, but if
>>we're going to be getting several requests for the same
>>slab/kmalloc-size then we're probably better of giving a whole page to
>>the slab allocator.  This is pure speculation, of course... :)
> 
> 
> Yeah but even then there's no guarantee that the critical allocations
> will be serviced first. The slab allocator can as well be giving away
> bits of the fresh page to non-critical allocations. For the exact same
> reason, I don't think it's enough that you pass a subsystem-specific
> page pool to the slab allocator.

Well, it would give at least one object from the new slab to the critical
request, but you're right, the rest of the slab could be allocated to
non-critical users.  I had planned on a small follow-on patch to add
exclusivity to mempool/critical slab pages, but going a different route
seems to be the consensus.


> Sorry if this has been explained before but why aren't mempools
> sufficient for your purposes? Also one more alternative would be to
> create a separate object cache for each subsystem-specific critical
> allocation and implement a internal "page pool" for the slab allocator
> so that you could specify for the number of pages an object cache
> guarantees to always hold on to.

Mempools aren't sufficient because in order to create a real critical pool
for the whole networking subsystem, we'd have to create dozens of mempools,
one each for all the different slabs & kmalloc sizes the networking stack
requires, plus another for whole pages.  Not impossible, but U-G-L-Y.  And
wasteful.  Creating all those mempools is surely more wasteful than
creating one reasonably sized pool to back ALL the allocations.  Or, at
least, such was my rationale... :)

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

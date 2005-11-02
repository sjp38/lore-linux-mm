Message-ID: <43680D8C.5080500@yahoo.com.au>
Date: Wed, 02 Nov 2005 11:51:24 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030235440.6938a0e9.akpm@osdl.org>	 <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au>	 <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au>	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>	 <1130854224.14475.60.camel@localhost>  <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost>
In-Reply-To: <1130856555.14475.77.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> What the fragmentation patches _can_ give us is the ability to have 100%
> success in removing certain areas: the "user-reclaimable" areas
> referenced in the patch.  This gives a customer at least the ability to
> plan for how dynamically reconfigurable a system should be.
> 

But the "user-reclaimable" areas can still be taken over by other
areas which become fragmented.

That's like saying we can already guarantee 100% success in removing
areas that are unfragmented and free, or freeable.

> After these patches, the next logical steps are to increase the
> knowledge that the slabs have about fragmentation, and to teach some of
> the shrinkers about fragmentation.
> 

I don't like all this work and complexity and overheads going into a
partial solution.

Look: if you have to guarantee memory can be shrunk, set aside a zone
for it (that only fills with user reclaimable areas). This is better
than the current frag patches because it will give you the 100%
guarantee that you need (provided we have page migration to move mlocked
pages).

If you don't need a guarantee, then our current, simple system does the
job perfectly.

> After that, we'll need some kind of virtual remapping, breaking the 1:1
> kernel virtual mapping, so that the most problematic pages can be
> remapped.  These pages would retain their virtual address, but getting a
> new physical.  However, this is quite far down the road and will require
> some serious evaluation because it impacts how normal devices are able
> to to DMA.  The ppc64 proprietary hypervisor has features to work around
> these issues, and any new hypervisors wishing to support partition
> memory hotplug would likely have to follow suit.
> 

I would more like to see something like this happen (provided it was
nicely abstracted away and could be CONFIGed out for the 99.999% of
users who don't need the overhead or complexity).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

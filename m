Message-ID: <445DF3AB.9000009@yahoo.com.au>
Date: Sun, 07 May 2006 23:18:35 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
References: <44576688.6050607@mbligh.org> <44576BF5.8070903@yahoo.com.au>	 <20060504013239.GG19859@localhost>	 <1146756066.22503.17.camel@localhost.localdomain>	 <20060504154652.GA4530@localhost> <20060504192528.GA26759@elte.hu>	 <20060504194334.GH19859@localhost> <445A7725.8030401@shadowen.org>	 <20060505135503.GA5708@localhost>	 <1146839590.22503.48.camel@localhost.localdomain>	 <20060505145018.GI19859@localhost> <1146841064.22503.53.camel@localhost.localdomain> <445C5F36.3030207@yahoo.com.au> <445DF114.4090708@shadowen.org>
In-Reply-To: <445DF114.4090708@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, Bob Picco <bob.picco@hp.com>, Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:

> I agree that there is no need for these checks to leak out of
> page_is_buddy().  If its not there or in another zone, its not my buddy.
>  The allocator loop is nasty enough as it is.

OK, glad you agree.

> 
> I think we need to do a couple of things:
> 
> 1) check the alignment of the zones matches the implied alignment
> constraints and correct it as we go.

Yes. And preferably have checks in the generic page allocator setup
code, so we can do something sane if the arch code gets it wrong.

> 2) optionally allow an architecture to say its not aligning and doesn't
> want to have to align its zone -- providing a config option to add the
> zone index checks
> 
> I think the later is valuable for these test builds and potentially for
> the embedded side where megabytes mean something.

Yes. Depends whether we fold it under the HOLES_IN_ZONE config. I guess
HOLES_IN_ZONE is potentially quite a bit more expensive than the plain
zone check, so having 2 config options may not be unreasonable.

Also, if the architecture doesn't align the ends of zones, *and* they are
not adjacent to another zone, they need either CONFIG_HOLES_IN_ZONE or
they need to provide dummy 'struct page's that never have PageBuddy set.


> 
> I'm testing a patch for this at the moment and will drop it out when I'm
> done.

Great!

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

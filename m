Message-ID: <436877DB.7020808@yahoo.com.au>
Date: Wed, 02 Nov 2005 19:24:59 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030235440.6938a0e9.akpm@osdl.org>	 <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au>	 <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au>	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>	 <1130854224.14475.60.camel@localhost>  <20051101142959.GA9272@elte.hu>	 <1130856555.14475.77.camel@localhost>  <43680D8C.5080500@yahoo.com.au> <1130917338.14475.133.camel@localhost>
In-Reply-To: <1130917338.14475.133.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Wed, 2005-11-02 at 11:51 +1100, Nick Piggin wrote:
> 
>>Look: if you have to guarantee memory can be shrunk, set aside a zone
>>for it (that only fills with user reclaimable areas). This is better
>>than the current frag patches because it will give you the 100%
>>guarantee that you need (provided we have page migration to move mlocked
>>pages).
> 
> 
> With Mel's patches, you can easily add the same guarantee.  Look at the
> code in  fallback_alloc() (patch 5/8).  It would be quite easy to modify
> the fallback lists to disallow fallbacks into areas from which we would
> like to remove memory.  That was left out for simplicity.  As you say,
> they're quite complex as it is.  Would you be interested in seeing a
> patch to provide those kinds of guarantees?
> 

On top of Mel's patch? I think this is essiential for any guarantees
that you might be interested... but it would just mean that now you
have a redundant extra zoning layer.

I think ZONE_REMOVABLE is something that really needs to be looked at
again if you need a hotunplug solution in the kernel.

> We've had a bit of experience with a hotpluggable zone approach  before.
> Just like the current topic patches, you're right, that approach can
> also provide strong guarantees.  However, the issue comes if the system
> ever needs to move memory between such zones, such as if a user ever
> decides that they'd prefer to break hotplug guarantees rather than OOM.
> 

I can imagine one could have a sysctl to allow/disallow non-easy-reclaim
allocations from ZONE_REMOVABLE.

As Ingo says, neither way is going to give a 100% solution - I wouldn't
like to see so much complexity added to bring us from a ZONE_REMOVABLE 80%
solution to a 90% solution. I believe this is where Linus' "perfect is
the enemy of good" quote applies.

> Do you think changing what a particular area of memory is being used for
> would ever be needed?
> 

Perhaps, but Mel's patch only guarantees you to change once, same as
ZONE_REMOVABLE. Once you eat up those easy-to-reclaim areas, you can't
get them back.

> One other thing, if we decide to take the zones approach, it would have
> no other side benefits for the kernel.  It would be for hotplug only and
> I don't think even the large page users would get much benefit.  
> 

Hugepage users? They can be satisfied with ZONE_REMOVABLE too. If you're
talking about other higher-order users, I still think we can't guarantee
past about order 1 or 2 with Mel's patch and they simply need to have
some other ways to do things.

But I think using zones would have advantages in that they would help
give zones and zone balancing more scrutiny and test coverage in the
kernel, which is sorely needed since everyone threw out their highmem
systems :P

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

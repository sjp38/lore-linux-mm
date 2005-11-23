Message-ID: <4383CF6C.4060001@yahoo.com.au>
Date: Wed, 23 Nov 2005 13:09:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 6/12] mm: remove bad_range
References: <20051121123906.14370.3039.sendpatchset@didi.local0.net>	 <20051121124126.14370.50844.sendpatchset@didi.local0.net> <1132662725.6696.45.camel@localhost>
In-Reply-To: <1132662725.6696.45.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> 
> I seem to also remember a case with this bad_range() check was useful
> for zones that don't have their boundaries aligned on a MAX_ORDER
> boundary.  Would this change break such a zone?  Do we care?
> 

Hmm, I guess that would be covered by the:

         if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
                 return 1;
         if (page_to_pfn(page) < zone->zone_start_pfn)
                 return 1;

checks in bad_range. ISTR some "warning: zone not aligned, kernel
*will* crash" message got printed in that case. I always thought
that zones were supposed to be MAX_ORDER aligned, but I can see how
that restriction might be relaxed with these checks in place.

This commit introduced the change:
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=d60c9dbc4589766ef5fe88f082052ccd4ecaea59

I think this basically says that architectures who care need to define
CONFIG_HOLES_IN_ZONE and handle this in pfn_valid.

Unless this is a very common requirement and such a solution would have
too much performance cost? Anyone?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

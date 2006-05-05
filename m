Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k45Ewd46017354
	for <linux-mm@kvack.org>; Fri, 5 May 2006 10:58:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k45EwdnG219914
	for <linux-mm@kvack.org>; Fri, 5 May 2006 08:58:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k45EwdVX004947
	for <linux-mm@kvack.org>; Fri, 5 May 2006 08:58:39 -0600
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060505145018.GI19859@localhost>
References: <44576688.6050607@mbligh.org> <44576BF5.8070903@yahoo.com.au>
	 <20060504013239.GG19859@localhost>
	 <1146756066.22503.17.camel@localhost.localdomain>
	 <20060504154652.GA4530@localhost> <20060504192528.GA26759@elte.hu>
	 <20060504194334.GH19859@localhost> <445A7725.8030401@shadowen.org>
	 <20060505135503.GA5708@localhost>
	 <1146839590.22503.48.camel@localhost.localdomain>
	 <20060505145018.GI19859@localhost>
Content-Type: text/plain
Date: Fri, 05 May 2006 07:57:44 -0700
Message-Id: <1146841064.22503.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-05-05 at 10:50 -0400, Bob Picco wrote:
> Dave Hansen wrote:	[Fri May 05 2006, 10:33:10AM EDT]
> > The page_zonenum() checks look good, but I'm not sure I understand the
> > page_in_zone_hole() part.  If a page is in a hole in a zone, it will
> > still have a valid mem_map entry, right?  It should also never have been
> > put into the allocator, so it also won't ever be coalesced.  
> This has always been subtle and not too revealing.  It probably should
> have a comment. The page_in_zone_hole check is for ia64 
> VIRTUAL_MEM_MAP. You might compute a page structure which is in a hole not 
> backed by memory; an unallocated page which covers pages structures. 
> VIRTUAL_MEM_MAP uses a contiguous virtual region with virtual space holes
> not backed by memory. Take a look at ia64_pfn_valid.

Ahhh.  I hadn't made the ia64 connection.  I wonder if it is worth
making CONFIG_HOLES_IN_ZONE say ia64 or something about vmem_map in it
somewhere.  Might be worth at least a comment like this:

+               if (page_in_zone_hole(buddy)) /* noop on all but ia64 */
+                       break;
+               else if (page_zonenum(buddy) != page_zonenum(page))
+                       break;
+               else if (!page_is_buddy(buddy, order))
                        break;          /* Move the buddy up one level. */

BTW, wasn't the whole idea of discontig to have holes in zones (before
NUMA) without tricks like this? ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

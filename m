Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5BF8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:28:53 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VKGpQm007248
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:16:51 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VKSktw125732
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:28:46 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VKShLu024919
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:28:45 -0600
Subject: Re: [PATCH 05/12] mm: alloc_contig_range() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vs7umufd3l0zgt@mnazarewicz-glaptop>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
	 <1301587361.31087.1040.camel@nimitz>
	 <op.vs7umufd3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 13:28:42 -0700
Message-ID: <1301603322.31087.1196.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, 2011-03-31 at 18:26 +0200, Michal Nazarewicz wrote:
> > On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> >> +       ret = 0;
> >> +       while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
> >> +               if (WARN_ON(++ret >= MAX_ORDER))
> >> +                       return -EINVAL;
> 
> On Thu, 31 Mar 2011 18:02:41 +0200, Dave Hansen wrote:
> > Holy cow, that's dense.  Is there really no more straightforward way to
> > do that?
> 
> Which part exactly is dense?  What would be qualify as a more
> straightforward way?

I'm still not 100% sure what it's trying to do.  It looks like it
attempts to check all of "start"'s buddy pages.

unsigned long find_buddy(unsigned long pfn, int buddy)
{
	unsigned long page_idx = pfn & ((1 << MAX_ORDER) - 1); // You had a macro for this I think
	unsigned long buddy_idx = __find_buddy_index(page_idx, order);
	return page_idx + buddy_idx;
}

Is something like this equivalent?

int order;
for (order = 0; order <= MAX_ORDER; order++) {
	unsigned long buddy_pfn = find_buddy(start, order);
	struct page *buddy = pfn_to_page(buddy_pfn);
	if (PageBuddy(buddy)
		break;
	WARN();
	return -EINVAL;
}

I'm wondering also if you can share some code with __rmqueue().

> > In any case, please pull the ++ret bit out of the WARN_ON().  Some
> > people like to do:
> >
> > #define WARN_ON(...) do{}while(0)
> >
> > to save space on some systems.
> 
> I don't think that's the case.  Even if WARN_ON() decides not to print
> a warning, it will still return the value of the argument.  If not,
> a lot of code will brake.

Bah, sorry.  I'm confusing WARN_ON() and WARN().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

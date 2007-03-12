Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2CIaJXx009040
	for <linux-mm@kvack.org>; Mon, 12 Mar 2007 14:36:19 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2CIaIKM061696
	for <linux-mm@kvack.org>; Mon, 12 Mar 2007 12:36:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2CIaIJa024801
	for <linux-mm@kvack.org>; Mon, 12 Mar 2007 12:36:18 -0600
Subject: Re: [PATCH 1/3] Lumpy Reclaim V4
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <5239d2d31cd39bf4fc33426648f97be0@pinky>
References: <exportbomb.1173723760@pinky>
	 <5239d2d31cd39bf4fc33426648f97be0@pinky>
Content-Type: text/plain
Date: Mon, 12 Mar 2007 11:36:16 -0700
Message-Id: <1173724576.11945.100.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-03-12 at 18:23 +0000, Andy Whitcroft wrote:
> 
> +                       /* The target page is in the block, ignore it. */
> +                       if (unlikely(pfn == page_pfn))
> +                               continue;
> +#ifdef CONFIG_HOLES_IN_ZONE
> +                       /* Avoid holes within the zone. */
> +                       if (unlikely(!pfn_valid(pfn)))
> +                               break;
> +#endif 

Would having something like:

        static inline int pfn_in_zone_hole(unsigned long pfn)
        {
        #ifdef CONFIG_HOLES_IN_ZONE
        	if (unlikely(!pfn_valid(pfn)))
        		return 1;
        #endif 
        	return 0;
        }
        
help us out?  page_is_buddy() and page_is_consistent() appear to do the
exact same thing, with the same #ifdef.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

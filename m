Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id A70106B017E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:40:34 -0500 (EST)
Date: Mon, 12 Dec 2011 14:40:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/11] mm: mmzone: introduce zone_pfn_same_memmap()
Message-ID: <20111212144030.GF3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-4-git-send-email-m.szyprowski@samsung.com>
 <20111212141953.GD3277@csn.ul.ie>
 <op.v6dr4pj43l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v6dr4pj43l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Mon, Dec 12, 2011 at 03:35:03PM +0100, Michal Nazarewicz wrote:
> >On Fri, Nov 18, 2011 at 05:43:10PM +0100, Marek Szyprowski wrote:
> >>From: Michal Nazarewicz <mina86@mina86.com>
> >>diff --git a/mm/compaction.c b/mm/compaction.c
> >>index 6afae0e..09c9702 100644
> >>--- a/mm/compaction.c
> >>+++ b/mm/compaction.c
> >>@@ -111,7 +111,10 @@ skip:
> >>
> >> next:
> >> 		pfn += isolated;
> >>-		page += isolated;
> >>+		if (zone_pfn_same_memmap(pfn - isolated, pfn))
> >>+			page += isolated;
> >>+		else
> >>+			page = pfn_to_page(pfn);
> >> 	}
> 
> On Mon, 12 Dec 2011 15:19:53 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> >Is this necessary?
> >
> >We are isolating pages, the largest of which is a MAX_ORDER_NR_PAGES
> >page.  [...]
> 
> This is not true for CMA.
> 

To be clear, I'm referring to a single page being isolated here. It may
or may not be a high-order page but it's still going to be less then
MAX_ORDER_NR_PAGES so you should be able check when a new block is
entered and pfn_to_page is necessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

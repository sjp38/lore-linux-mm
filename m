Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 9709F6B0181
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:42:33 -0500 (EST)
Date: Mon, 12 Dec 2011 14:42:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/11] mm: page_alloc: handle MIGRATE_ISOLATE in
 free_pcppages_bulk()
Message-ID: <20111212144229.GH3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-2-git-send-email-m.szyprowski@samsung.com>
 <20111212134235.GB3277@csn.ul.ie>
 <op.v6drko0p3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v6drko0p3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Mon, Dec 12, 2011 at 03:23:02PM +0100, Michal Nazarewicz wrote:
> >On Fri, Nov 18, 2011 at 05:43:08PM +0100, Marek Szyprowski wrote:
> >>From: Michal Nazarewicz <mina86@mina86.com>
> >>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>index 9dd443d..58d1a2e 100644
> >>--- a/mm/page_alloc.c
> >>+++ b/mm/page_alloc.c
> >>@@ -628,6 +628,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >> 			page = list_entry(list->prev, struct page, lru);
> >> 			/* must delete as __free_one_page list manipulates */
> >> 			list_del(&page->lru);
> >>+
> >>+			/*
> >>+			 * When page is isolated in set_migratetype_isolate()
> >>+			 * function it's page_private is not changed since the
> >>+			 * function has no way of knowing if it can touch it.
> >>+			 * This means that when a page is on PCP list, it's
> >>+			 * page_private no longer matches the desired migrate
> >>+			 * type.
> >>+			 */
> >>+			if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> >>+				set_page_private(page, MIGRATE_ISOLATE);
> >>+
> 
> On Mon, 12 Dec 2011 14:42:35 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> >How much of a problem is this in practice?
> 
> IIRC, this lead to allocation being made from area marked as isolated
> or some such.
> 

And I believe that nothing prevents that from happening. I was just
wondering how common it was in practice. Draining the per-cpu lists
should work as a substitute either way.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

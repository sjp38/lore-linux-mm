Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7F4D96B006E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 14:19:44 -0500 (EST)
Date: Tue, 20 Nov 2012 11:19:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT PATCH v1 4/5] mm: provide more accurate estimation of
 pages occupied by memmap
Message-Id: <20121120111942.c9596d3f.akpm@linux-foundation.org>
In-Reply-To: <50AB9F4A.5050500@gmail.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
	<1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
	<1353254850-27336-5-git-send-email-jiang.liu@huawei.com>
	<20121119154240.91efcc53.akpm@linux-foundation.org>
	<50AB9F4A.5050500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Nov 2012 23:18:34 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> >> +static unsigned long calc_memmap_size(unsigned long spanned_pages,
> >> +				      unsigned long present_pages)
> >> +{
> >> +	unsigned long pages = spanned_pages;
> >> +
> >> +	/*
> >> +	 * Provide a more accurate estimation if there are big holes within
> >> +	 * the zone and SPARSEMEM is in use.
> >> +	 */
> >> +	if (spanned_pages > present_pages + (present_pages >> 4) &&
> >> +	    IS_ENABLED(CONFIG_SPARSEMEM))
> >> +		pages = present_pages;
> >> +
> >> +	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
> >> +}
> > 
> > Please explain the ">> 4" heuristc more completely - preferably in both
> > the changelog and code comments.  Why can't we calculate this
> > requirement exactly?  That might require a second pass, but that's OK for
> > code like this?
> Hi Andrew,
> 	A normal x86 platform always have some holes within the DMA ZONE,
> so the ">> 4" heuristic is to avoid applying this adjustment to the DMA
> ZONE on x86 platforms. 
> 	Because the memmap_size is just an estimation, I feel it's OK to
> remove the ">> 4" heuristic, that shouldn't affect much.

Again: why can't we calculate this requirement exactly?  That might
require a second pass, but that's OK for code like this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

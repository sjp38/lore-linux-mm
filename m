Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8592C6B002E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 14:39:26 -0400 (EDT)
Received: by pzd13 with SMTP id 13so9663178pzd.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2011 11:39:22 -0700 (PDT)
Date: Mon, 17 Oct 2011 11:39:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
Message-Id: <20111017113919.3b7ac253.akpm@linux-foundation.org>
In-Reply-To: <01b201cc8cc7$3f6117d0$be234770$%szyprowski@samsung.com>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
	<20111014162933.d8fead58.akpm@linux-foundation.org>
	<01b201cc8cc7$3f6117d0$be234770$%szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>

On Mon, 17 Oct 2011 14:21:07 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> > > +
> > > +void free_contig_pages(unsigned long pfn, unsigned nr_pages)
> > > +{
> > > +	struct page *page = pfn_to_page(pfn);
> > > +
> > > +	while (nr_pages--) {
> > > +		__free_page(page);
> > > +		++pfn;
> > > +		if (likely(zone_pfn_same_memmap(pfn - 1, pfn)))
> > > +			++page;
> > > +		else
> > > +			page = pfn_to_page(pfn);
> > > +	}
> > > +}
> > 
> > You're sure these functions don't need EXPORT_SYMBOL()?  Maybe the
> > design is that only DMA core calls into here (if so, that's good).
> 
> Drivers should not call it, it is intended to be used by low-level DMA
> code.

OK, thanks for checking.

> Do you think that a comment about missing EXPORT_SYMBOL is 
> required?

No.  If someone later wants to use these from a module then we can look
at their reasons and make a decision at that time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

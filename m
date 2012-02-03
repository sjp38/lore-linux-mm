Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9EC606B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 06:27:07 -0500 (EST)
Date: Fri, 3 Feb 2012 11:27:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/15] mm: page_alloc: update migrate type of pages on
 pcp when isolating
Message-ID: <20120203112703.GB5796@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
 <20120130111522.GE25268@csn.ul.ie>
 <op.v8wlu8ws3l0zgt@mpn-glaptop>
 <20120130161447.GU25268@csn.ul.ie>
 <022e01cce034$bc6cf440$3546dcc0$%szyprowski@samsung.com>
 <20120202124729.GA5796@csn.ul.ie>
 <op.v82hjbd13l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v82hjbd13l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

On Thu, Feb 02, 2012 at 08:53:25PM +0100, Michal Nazarewicz wrote:
> >On Tue, Jan 31, 2012 at 05:23:59PM +0100, Marek Szyprowski wrote:
> >>Pages, which have incorrect migrate type on free finally
> >>causes pageblock migration type change from MIGRATE_CMA to MIGRATE_MOVABLE.
> 
> On Thu, 02 Feb 2012 13:47:29 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> >I'm not quite seeing this. In free_hot_cold_page(), the pageblock
> >type is checked so the page private should be set to MIGRATE_CMA or
> >MIGRATE_ISOLATE for the CMA area. It's not clear how this can change a
> >pageblock to MIGRATE_MOVABLE in error.
> 
> Here's what I think may happen:
> 
> When drain_all_pages() is called, __free_one_page() is called for each page on
> pcp list with migrate type deducted from page_private() which is MIGRATE_CMA.
> This result in the page being put on MIGRATE_CMA freelist even though its
> pageblock's migrate type is MIGRATE_ISOLATE.
> 

Ok, although it will only be allocated for MIGRATE_CMA-compatible
requests so it is not a disaster.

> When allocation happens and pcp list is empty, rmqueue_bulk() will get executed
> with migratetype argument set to MIGRATE_MOVABLE.  It calls __rmqueue() to grab
> some pages and because the page described above is on MIGRATE_CMA freelist it
> may be returned back to rmqueue_bulk().
> 

This will allocate the page from a pageblock we are trying to isolate
pages from, but only for a movable page that can still be migrated. It
does mean that CMA is doing more work than it should of course and
the problem also impacts memory hot-remove. It's worse for memory
hot-remove because potentially an UNMOVABLE page was allocated from
a MIGRATE_ISOLATE pageblock.

> But, pageblock's migrate type is not MIGRATE_CMA but MIGRATE_ISOLATE, so the
> following code:
> 
> #ifdef CONFIG_CMA
> 		if (is_pageblock_cma(page))
> 			set_page_private(page, MIGRATE_CMA);
> 		else
> #endif
> 			set_page_private(page, migratetype);
> 
> will set it's private to MIGRATE_MOVABLE and in the end the page lands back
> on MIGRATE_MOVABLE pcp list but this time with page_private == MIGRATE_MOVABLE
> and not MIGRATE_CMA.
> 
> One more drain_all_pages() (which may happen since alloc_contig_range() calls
> set_migratetype_isolate() for each block) and next __rmqueue_fallback() may
> convert the whole pageblock to MIGRATE_MOVABLE.
> 
> I know, this sounds crazy and improbable, but I couldn't find an easier path
> to destruction.  As you pointed, once the page is allocated, free_hot_cold_page()
> will do the right thing by reading pageblock's migrate type.
> 

Ok, it's crazy but the problem is there.

> Marek is currently experimenting with various patches including the following
> change:
> 
> #ifdef CONFIG_CMA
>                 int mt = get_pageblock_migratetype(page);
>                 if (is_migrate_cma(mt) || mt == MIGRATE_ISOLATE)
>                         set_page_private(page, mt);
>                 else
> #endif
>                         set_page_private(page, migratetype);
> 
> As a matter of fact, if __rmqueue() was changed to return migrate type of the
> freelist it took page from, we could avoid this get_pageblock_migratetype() all
> together.  For now, however, I'd rather not go that way just yet -- I'll be happy
> to dig into it once CMA gets merged.
> 

Ok, thanks for persisting with this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

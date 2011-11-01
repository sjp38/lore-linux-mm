Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB596B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 11:04:54 -0400 (EDT)
Date: Tue, 1 Nov 2011 15:04:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
Message-ID: <20111101150448.GD14998@csn.ul.ie>
References: <20111018122109.GB6660@csn.ul.ie>
 <809d0a2afe624c06505e0df51e7657f66aaf9007.1319428526.git.mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <809d0a2afe624c06505e0df51e7657f66aaf9007.1319428526.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Sun, Oct 23, 2011 at 09:05:05PM -0700, Michal Nazarewicz wrote:
> > On Thu, Oct 06, 2011 at 03:54:42PM +0200, Marek Szyprowski wrote:
> >> This commit introduces alloc_contig_freed_pages() function
> >> which allocates (ie. removes from buddy system) free pages
> >> in range. Caller has to guarantee that all pages in range
> >> are in buddy system.
> 
> On Tue, 18 Oct 2011 05:21:09 -0700, Mel Gorman <mel@csn.ul.ie> wrote:
> > Straight away, I'm wondering why you didn't use
> > mm/compaction.c#isolate_freepages()
> 
> Does the below look like a step in the right direction?
> 
> It basically moves isolate_freepages_block() to page_alloc.c (changing

For the purposes of review, have a separate patch for moving
isolate_freepages_block to another file that does not alter the
function in any way. When the function is updated in a follow-on patch,
it'll be far easier to see what has changed.

page_isolation.c may also be a better fit than page_alloc.c

As it is, the patch for isolate_freepages_block is almost impossible
to read because it's getting munged with existing code that is already
in page_alloc.c . About all I caught from it is that scannedp does
not have a type. It defaults to unsigned int but it's unnecessarily
obscure.

> it name to isolate_freepages_range()) and changes it so that depending
> on arguments it treats holes (either invalid PFN or non-free page) as
> errors so that CMA can use it.
> 

I haven't actually read the function because it's too badly mixed with
page_alloc.c code but this description fits what I'm looking for.

> It also accepts a range rather then just assuming a single pageblock
> thus the change moves range calculation in compaction.c from
> isolate_freepages_block() up to isolate_freepages().
> 
> The change also modifies spilt_free_page() so that it does not try to
> change pageblock's migrate type if current migrate type is ISOLATE or
> CMA.
> 

This is fine. Later, the flags that determine what happens to pageblocks
may be placed in compact_control.

> ---
>  include/linux/mm.h             |    1 -
>  include/linux/page-isolation.h |    4 +-
>  mm/compaction.c                |   73 +++--------------------
>  mm/internal.h                  |    5 ++
>  mm/page_alloc.c                |  128 +++++++++++++++++++++++++---------------
>  5 files changed, 95 insertions(+), 116 deletions(-)
> 

I confess I didn't read closely because of the mess in page_alloc.c but
the intent seems fine. Hopefully there will be a new version of CMA
posted that will be easier to review.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

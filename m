Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 54FE76B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 16:13:07 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id up15so4659543pbc.6
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 13:13:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gn5si9534286pbc.56.2014.03.07.13.13.06
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 13:13:06 -0800 (PST)
Date: Fri, 7 Mar 2014 13:13:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in
 isolate_freepages_block
Message-Id: <20140307131305.36547cc3346e23c0a64d95af@linux-foundation.org>
In-Reply-To: <20140307025852.GC3787@bbox>
References: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
	<20140307025852.GC3787@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 7 Mar 2014 11:58:52 +0900 Minchan Kim <minchan@kernel.org> wrote:

> On Thu, Mar 06, 2014 at 10:21:32AM -0800, Laura Abbott wrote:
> > We received several reports of bad page state when freeing CMA pages
> > previously allocated with alloc_contig_range:
> > 
> > <1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
> > <1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null) index:0x7dfbf
> > <1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)
> > 
> > Based on the page state, it looks like the page was still in use. The page
> > flags do not make sense for the use case though. Further debugging showed
> > that despite alloc_contig_range returning success, at least one page in the
> > range still remained in the buddy allocator.
> > 
> > There is an issue with isolate_freepages_block. In strict mode (which CMA
> > uses), if any pages in the range cannot be isolated,
> > isolate_freepages_block should return failure 0. The current check keeps
> > track of the total number of isolated pages and compares against the size
> > of the range:
> > 
> >         if (strict && nr_strict_required > total_isolated)
> >                 total_isolated = 0;
> > 
> > After taking the zone lock, if one of the pages in the range is not
> > in the buddy allocator, we continue through the loop and do not
> > increment total_isolated. If in the last iteration of the loop we isolate
> > more than one page (e.g. last page needed is a higher order page), the
> > check for total_isolated may pass and we fail to detect that a page was
> > skipped. The fix is to bail out if the loop immediately if we are in
> > strict mode. There's no benfit to continuing anyway since we need all
> > pages to be isolated. Additionally, drop the error checking based on
> > nr_strict_required and just check the pfn ranges. This matches with
> > what isolate_freepages_range does.
> > 
> > Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> 
> Nice catch! stable stuff?

Yes, I was wondering that.  I think I will add the cc:stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

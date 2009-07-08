Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 200CD6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 17:20:32 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:29:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Performance degradation seen after using one list for hot/cold
 pages.
Message-Id: <20090708142946.83c40331.akpm@linux-foundation.org>
In-Reply-To: <20090622100632.GB3981@csn.ul.ie>
References: <70875432E21A4185AD2E007941B6A792@sisodomain.com>
	<20090622164147.720683f8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090622100632.GB3981@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kamezawa.hiroyu@jp.fujitsu.com, narayanan.g@samsung.com, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, stable@kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

(cc stable, linux-kernel and linux-scsi)

> On Mon, 22 Jun 2009 11:06:32 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> [PATCH] page-allocator: Preserve PFN ordering when __GFP_COLD is set
> 
> The page allocator tries to preserve contiguous PFN ordering when returning
> pages such that repeated callers to the allocator have a strong chance of
> getting physically contiguous pages, particularly when external fragmentation
> is low. However, of the bulk of the allocations have __GFP_COLD set as
> they are due to aio_read() for example, then the PFNs are in reverse PFN
> order. This can cause performance degration when used with IO
> controllers that could have merged the requests.
> 
> This patch attempts to preserve the contiguous ordering of PFNs for
> users of __GFP_COLD.

Thanks.

I'll add the rather important text:

  Fix a post-2.6.24 performance regression caused by
  3dfa5721f12c3d5a441448086bee156887daa961 ("page-allocator: preserve PFN
  ordering when __GFP_COLD is set").

This was a pretty major screwup.

This is why changing core MM is so worrisome - there's so much secret and
subtle history to it, and performance dependencies are unobvious and quite
indirect and the lag time to discover regressions is long.

Narayanan, are you able to quantify the regression more clearly?  All I
have is "2 MBps lower" which isn't very useful.  What is this as a
percentage, and with what sort of disk controller?  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

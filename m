Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CC3966B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 21:12:39 -0400 (EDT)
Date: Thu, 8 Aug 2013 02:59:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/9] mm: compaction: don't require high order pages below
 min wmark
Message-ID: <20130808005941.GH4661@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-6-git-send-email-aarcange@redhat.com>
 <20130807154201.GS2296@suse.de>
 <20130807161437.GC4661@redhat.com>
 <20130807164741.GX2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807164741.GX2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Wed, Aug 07, 2013 at 05:47:41PM +0100, Mel Gorman wrote:
> On Wed, Aug 07, 2013 at 06:14:37PM +0200, Andrea Arcangeli wrote:
> > Hi Mel,
> > 
> > On Wed, Aug 07, 2013 at 04:42:01PM +0100, Mel Gorman wrote:
> > > On Fri, Aug 02, 2013 at 06:06:32PM +0200, Andrea Arcangeli wrote:
> > > > The min wmark should be satisfied with just 1 hugepage.
> > > 
> > > This depends on the size of the machine and if THP is enabled or not
> > > (which adjusts min_free_kbytes).  I expect that it is generally true but
> > > wonder how often it is true on something like ARM which does high-order
> > > allocators for stack.
> > 
> > I exclude ARM is allocating stacks with GFP_ATOMIC, or how could it be
> > reliable?
> 
> I assumed they were GFP_KERNEL allocations. High-order atomic allocations would
> be jumbo frame allocations.
> 
> Anyway, my general concern is that min watermark can be smaller than 1
> hugepage on some platforms and making assumptions about the watermarks

Without my patch the min wmark is always smaller than 1 hugepage
anyway. I tried to go over the details of this in my previous email to
Johannes.

> and their relative size in comparison to THP seems dangerous.  If it is
> possible that ((low - min) > requested_size) then a high-order allocation
> from the allocator slowpath will be allowed to go below the min
> watermark which is not expected.

I don't see what you mean here with regard to the min watermark and
THP allocations.

Please elaborate the difference does it make to order 9 THP
allocations, if the min is 0 as with my patch or set to a few dozen
kbyte like in upstream? Does it make any difference? If yes where?

> if (WARN_ON(min < 0))
> 	return false;
> 
> ?
> 
> Seems odd to just fall through and make decisions based on a negative
> watermark. It'll erronously return true when the revised watermark should
> have returned false. As it is likely due to a min_free_kbytes or hot-add
> event then it probably does not matter a great deal. I'm not massively
> pushed and the WARN_ON is fine if you like. It just struck me as being
> strange looking.

This is an high order allocation check that has no relevancy with
reliability of PF_MEMALLOC. So I don't think it worth to keep a
special branch just to be sure to obey the min in the race condition
case with a write to /proc/sys. If we temporarily try to get more
pages nothing goes wrong like it would with the order 0
allocations. We could actually nuke the WARN_ON as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

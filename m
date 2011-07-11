Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 350306B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 13:24:59 -0400 (EDT)
Date: Mon, 11 Jul 2011 13:24:44 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110711172444.GA6657@infradead.org>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110706151229.GA1998@redhat.com>
 <20110708095456.GI1026@dastard>
 <20110711172050.GA2849@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110711172050.GA2849@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jul 11, 2011 at 07:20:50PM +0200, Johannes Weiner wrote:
> > Yet the file pages on the active list are unlikely to be dirty -
> > overwrite-in-place cache hot workloads are pretty scarce in my
> > experience. hence writeback of dirty pages from the active LRU is
> > unlikely to be a problem.
> 
> Just to clarify, I looked at this too much from the reclaim POV, where
> use-once applies to full pages, not bytes.
> 
> Even if you do not overwrite the same bytes over and over again,
> issuing two subsequent write()s that end up against the same page will
> have it activated.
> 
> Are your workloads writing in perfectly page-aligned chunks?

Many workloads do, given that we already tell them our preferred
I/O size through struct stat, which alway is the page size or larger.

That won't help with workloads having to write in small chunksizes.
The performance critical ones using small chunksizes usually use
O_(D)SYNC, so pages will be clean after the write returned to userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 47FC16B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:15:53 -0400 (EDT)
Date: Thu, 14 Jun 2012 12:15:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: add gfp_mask parameter to vm_map_ram()
Message-ID: <20120614021547.GC7339@dastard>
References: <20120612012134.GA7706@localhost>
 <20120613123932.GA1445@localhost>
 <20120614012026.GL3019@devil.redhat.com>
 <20120614014902.GB7289@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120614014902.GB7289@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com

On Thu, Jun 14, 2012 at 09:49:02AM +0800, Fengguang Wu wrote:
> On Thu, Jun 14, 2012 at 11:20:26AM +1000, Dave Chinner wrote:
> > 
> > Bug in vm_map_ram - it does an unconditional GFP_KERNEL allocation
> > here, and we are in a GFP_NOFS context. We can't pass a gfp_mask to
> > vm_map_ram(), so until vm_map_ram() grows that we can't fix it...
> 
> This trivial patch should fix it.
> 
> The only behavior change is the XFS part:
> 
> @@ -406,7 +406,7 @@ _xfs_buf_map_pages(
>  
>                 do {
>                         bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> -                                               -1, PAGE_KERNEL);
> +                                               -1, GFP_NOFS, PAGE_KERNEL);

This function isn't always called in GFP_NOFS context - readahead
uses different memory allocation semantics (no retry, no warn), so
there are flags that tell it what to do. i.e.

-						-1, PAGE_KERNEL);
+						-1, xb_to_gfp(flags), PAGE_KERNEL);

Otherwise looks fine to me...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

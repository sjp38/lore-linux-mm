Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D036A6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 06:42:11 -0400 (EDT)
Date: Wed, 15 Aug 2012 05:42:32 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
Message-ID: <20120815094232.GC2865@phenom.dumpdata.com>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
 <20120814023530.GA9787@kroah.com>
 <5029E3EF.9080301@vflare.org>
 <502A8D4D.3080101@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502A8D4D.3080101@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On Tue, Aug 14, 2012 at 12:39:25PM -0500, Seth Jennings wrote:
> On 08/14/2012 12:36 AM, Nitin Gupta wrote:
> > On 08/13/2012 07:35 PM, Greg Kroah-Hartman wrote:
> >> On Wed, Aug 08, 2012 at 03:12:13PM +0900, Minchan Kim wrote:
> >>> This patchset promotes zram/zsmalloc from staging.
> >>> Both are very clean and zram is used by many embedded product
> >>> for a long time.
> >>>
> >>> [1-3] are patches not merged into linux-next yet but needed
> >>> it as base for [4-5] which promotes zsmalloc.
> >>> Greg, if you merged [1-3] already, skip them.
> >>
> >> I've applied 1-3 and now 4, but that's it, I can't apply the rest
> >> without getting acks from the -mm maintainers, sorry.  Please work with
> >> them to get those acks, and then I will be glad to apply the rest (after
> >> you resend them of course...)
> >>
> > 
> > On a second thought, I think zsmalloc should stay in drivers/block/zram
> > since zram is now the only user of zsmalloc since zcache and ramster are
> > moving to another allocator.
> 
> The removal of zsmalloc from zcache has not been agreed upon
> yet.

<nods>
> 
> Dan _suggested_ removing zsmalloc as the persistent
> allocator for zcache in favor of zbud to solve "flaws" in
> zcache.  However, zbud has large deficiencies.
> 
> A zero-filled 4k page will compress with LZO to 103 bytes.
> zbud can only store two compressed pages in each memory pool
> page, resulting in 95% fragmentation (i.e. 95% of the memory
> pool page goes unused).  While this might not be a typical
> case, it is the worst case and absolutely does happen.
> 
> zbud's design also effectively limits the useful page
> compression to 50%. If pages are compressed beyond that, the
> added space savings is lost in memory pool fragmentation.
> For example, if two pages compress to 30% of their original
> size, those two pages take up 60% of the zbud memory pool
> page, and 40% is lost to fragmentation because zbud can't
> store anything in the remaining space.
> 
> To say it another way, for every two page cache pages that
> cleancache stores in zcache, zbud _must_ allocate a memory
> pool page, regardless of how well those pages compress.
> This reduces the efficiency of the page cache reclaim
> mechanism by half.
> 
> I have posted some work (zsmalloc shrinker interface, user
> registered alloc/free functions for the zsmalloc memory
> pool) that begins to make zsmalloc a suitable replacement
> for zbud, but that work was put on hold until the path out
> of staging was established.
> 
> I'm hoping to continue this work once the code is in
> mainline.  While zbud has deficiencies, it doesn't prevent
> zcache from having value as I have already demonstrated.
> However, replacing zsmalloc with zbud would step backward
> for the reasons mentioned above.

What would be nice is having only one engine instead
of two - and I believe that is what you and Dan are aiming at.

Dan is looking at it from the perspective of re-engineering
zcache to use an LRU for keeping track of pages and pushing
those to the compression engine. And redoing the zbud engine
a bit (I think, let me double-check the git tree he pointed
out).

> 
> I do not support the removal of zsmalloc from zcache.  As
> such, I think the zsmalloc code should remain independent.
> 
> Seth
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

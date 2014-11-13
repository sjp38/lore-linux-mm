Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BF2F36B00DC
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 01:34:58 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so14691916pad.11
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 22:34:58 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id oj8si24667476pbb.207.2014.11.12.22.34.55
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 22:34:57 -0800 (PST)
Date: Thu, 13 Nov 2014 15:37:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141113063711.GA18369@js1304-P5Q-DELUXE>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
 <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
 <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
 <20141112012241.GA17446@node.dhcp.inet.fi>
 <20141112021716.GB21951@js1304-P5Q-DELUXE>
 <20141112103924.GQ22907@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141112103924.GQ22907@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wed, Nov 12, 2014 at 10:39:24AM +0000, Mel Gorman wrote:
> On Wed, Nov 12, 2014 at 11:17:16AM +0900, Joonsoo Kim wrote:
> > On Wed, Nov 12, 2014 at 03:22:41AM +0200, Kirill A. Shutemov wrote:
> > > On Tue, Nov 11, 2014 at 04:49:13PM -0800, Andrew Morton wrote:
> > > > On Tue, 11 Nov 2014 18:36:28 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:
> > > > 
> > > > > On Tue, 11 Nov 2014, Andrew Morton wrote:
> > > > > 
> > > > > > There's no point in doing
> > > > > >
> > > > > > 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> > > > > >
> > > > > > because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.
> > > > > 
> > > > > ?? ~__GFP_BITS_MASK means bits 25 to 31 are set.
> > > > > 
> > > > > __GFP_DMA32 is bit 2 and __GFP_HIGHMEM is bit 1.
> > > > 
> > > > Ah, yes, OK.
> > > > 
> > > > I suppose it's possible that __GFP_HIGHMEM was set.
> > > > 
> > > > do_huge_pmd_anonymous_page
> > > > ->pte_alloc_one
> > > >   ->alloc_pages(__userpte_alloc_gfp==__GFP_HIGHMEM)
> > > 
> > > do_huge_pmd_anonymous_page
> > >  alloc_hugepage_vma
> > >   alloc_pages_vma(GFP_TRANSHUGE)
> > > 
> > > GFP_TRANSHUGE contains GFP_HIGHUSER_MOVABLE, which has __GFP_HIGHMEM.
> > 
> > Hello, Kirill.
> > 
> > BTW, why does GFP_TRANSHUGE have MOVABLE flag despite it isn't
> > movable? After breaking hugepage, it could be movable, but, it may
> > prevent CMA from working correctly until break.
> > 
> 
> Because THP can use the Movable zone if it's allocated. When movable was
> introduced it did not just mean migratable. It meant it could also be
> moved to swap. THP can be broken up and swapped so it tagged as movable.

Great explanation!

Thanks Mel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

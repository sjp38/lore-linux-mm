Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C92176B00E4
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 05:39:28 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id r20so4422133wiv.4
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 02:39:28 -0800 (PST)
Received: from gir.skynet.ie (gir.skynet.ie. [193.1.99.77])
        by mx.google.com with ESMTPS id df6si22210340wib.106.2014.11.12.02.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 02:39:27 -0800 (PST)
Date: Wed, 12 Nov 2014 10:39:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141112103924.GQ22907@csn.ul.ie>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
 <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
 <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
 <20141112012241.GA17446@node.dhcp.inet.fi>
 <20141112021716.GB21951@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20141112021716.GB21951@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wed, Nov 12, 2014 at 11:17:16AM +0900, Joonsoo Kim wrote:
> On Wed, Nov 12, 2014 at 03:22:41AM +0200, Kirill A. Shutemov wrote:
> > On Tue, Nov 11, 2014 at 04:49:13PM -0800, Andrew Morton wrote:
> > > On Tue, 11 Nov 2014 18:36:28 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:
> > > 
> > > > On Tue, 11 Nov 2014, Andrew Morton wrote:
> > > > 
> > > > > There's no point in doing
> > > > >
> > > > > 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> > > > >
> > > > > because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.
> > > > 
> > > > ?? ~__GFP_BITS_MASK means bits 25 to 31 are set.
> > > > 
> > > > __GFP_DMA32 is bit 2 and __GFP_HIGHMEM is bit 1.
> > > 
> > > Ah, yes, OK.
> > > 
> > > I suppose it's possible that __GFP_HIGHMEM was set.
> > > 
> > > do_huge_pmd_anonymous_page
> > > ->pte_alloc_one
> > >   ->alloc_pages(__userpte_alloc_gfp==__GFP_HIGHMEM)
> > 
> > do_huge_pmd_anonymous_page
> >  alloc_hugepage_vma
> >   alloc_pages_vma(GFP_TRANSHUGE)
> > 
> > GFP_TRANSHUGE contains GFP_HIGHUSER_MOVABLE, which has __GFP_HIGHMEM.
> 
> Hello, Kirill.
> 
> BTW, why does GFP_TRANSHUGE have MOVABLE flag despite it isn't
> movable? After breaking hugepage, it could be movable, but, it may
> prevent CMA from working correctly until break.
> 

Because THP can use the Movable zone if it's allocated. When movable was
introduced it did not just mean migratable. It meant it could also be
moved to swap. THP can be broken up and swapped so it tagged as movable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

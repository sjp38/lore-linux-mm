Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 019146B013C
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:47:18 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id a1so12985995wgh.20
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 17:47:17 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id dg2si15550744wib.17.2014.11.11.17.47.17
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 17:47:17 -0800 (PST)
Date: Wed, 12 Nov 2014 03:47:03 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141112014703.GB17446@node.dhcp.inet.fi>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
 <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
 <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
 <20141112012241.GA17446@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141112012241.GA17446@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wed, Nov 12, 2014 at 03:22:41AM +0200, Kirill A. Shutemov wrote:
> On Tue, Nov 11, 2014 at 04:49:13PM -0800, Andrew Morton wrote:
> > On Tue, 11 Nov 2014 18:36:28 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:
> > 
> > > On Tue, 11 Nov 2014, Andrew Morton wrote:
> > > 
> > > > There's no point in doing
> > > >
> > > > 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> > > >
> > > > because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.
> > > 
> > > ?? ~__GFP_BITS_MASK means bits 25 to 31 are set.
> > > 
> > > __GFP_DMA32 is bit 2 and __GFP_HIGHMEM is bit 1.
> > 
> > Ah, yes, OK.
> > 
> > I suppose it's possible that __GFP_HIGHMEM was set.
> > 
> > do_huge_pmd_anonymous_page
> > ->pte_alloc_one
> >   ->alloc_pages(__userpte_alloc_gfp==__GFP_HIGHMEM)
> 
> do_huge_pmd_anonymous_page
>  alloc_hugepage_vma
>   alloc_pages_vma(GFP_TRANSHUGE)
> 
> GFP_TRANSHUGE contains GFP_HIGHUSER_MOVABLE, which has __GFP_HIGHMEM.

Looks like it's reasonable to sanitize flags in shrink_slab() by dropping
flags incompatible with slab expectation. Like this:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb47074ae03..eb165d29c5e5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -369,6 +369,8 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
        if (nr_pages_scanned == 0)
                nr_pages_scanned = SWAP_CLUSTER_MAX;
 
+       shrinkctl->gfp_mask &= ~(__GFP_DMA32 | __GFP_HIGHMEM);
+
        if (!down_read_trylock(&shrinker_rwsem)) {
                /*
                 * If we would return 0, our callers would understand that we
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

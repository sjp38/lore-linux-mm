Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E68736B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 14:27:36 -0400 (EDT)
Date: Fri, 21 May 2010 13:24:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F256284AECC@orsmsx501.amr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1005211322320.14851@router.home>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com> <alpine.DEB.2.00.1005211305340.14851@router.home> <80769D7B14936844A23C0C43D9FBCF0F256284AECC@orsmsx501.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 21 May 2010, Duyck, Alexander H wrote:

> Christoph Lameter wrote:
> > On Thu, 20 May 2010, Alexander Duyck wrote:
> >
> >> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> >> index 0249d41..e6217bb 100644 --- a/include/linux/slub_def.h
> >> +++ b/include/linux/slub_def.h
> >> @@ -52,7 +52,7 @@ struct kmem_cache_node {
> >>  	atomic_long_t total_objects;
> >>  	struct list_head full;
> >>  #endif
> >> -};
> >> +} ____cacheline_internodealigned_in_smp;
> >
> > What does this do? Leftovers?
>
> It aligns it to the correct size so that no two instances can occupy a shared cacheline.  I put that in place to avoid any false sharing of the objects should they fit into a shared cacheline on a NUMA system.

It has no effect in the NUMA case since the slab allocator is used to
allocate the object. Alignments would have to be specified at slab creation.

Maybe in the SMP case? But then struct kmem_cache_node is part of the
struct kmem_cache.

internode aligned? This creates > 4k kmem_cache structures on some
platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

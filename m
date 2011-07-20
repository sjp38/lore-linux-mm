Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0186B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 12:31:16 -0400 (EDT)
Received: by wyg36 with SMTP id 36so378243wyg.14
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:31:13 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1107201114480.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
	 <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201033080.1472@router.home>
	 <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201114480.1472@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 18:31:05 +0200
Message-ID: <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  11:17 -0500, Christoph Lameter a A(C)crit :
> On Wed, 20 Jul 2011, Eric Dumazet wrote:
> 
> > Note that adding ____cacheline_aligned_in_smp on nodelists[] actually
> > helps performance, as all following fields are readonly after kmem_cache
> > setup.
> 
> Well but that is not addresssing the same issue. Could you separate that
> out?
> 

I would like this patch not being a performance regression. I know some
people really want fast SLAB/SLUB ;)

> The other question that follows from this is then: Does that
> alignment compensate for the loss of performance due to the additional
> lookup in hot code paths and the additional cacheline reference required?
> 

In fact resulting code is smaller, because most fields are now with <
127 offset (x86 assembly code can use shorter instructions)

Before patch :
# size mm/slab.o
   text	   data	    bss	    dec	    hex	filename
  22605	 361665	     32	 384302	  5dd2e	mm/slab.o

After patch :
# size mm/slab.o
   text	   data	    bss	    dec	    hex	filename
  22347	 328929	  32800	 384076	  5dc4c	mm/slab.o

> The per node pointers are lower priority in terms of performance than the
> per cpu pointers. I'd rather have the per node pointers requiring an
> additional lookup. Less impact on hot code paths.
> 

Sure. I'll post a V2 to have CPU array before NODE array.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

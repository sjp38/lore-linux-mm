Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E2FC46B00EE
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:08:24 -0400 (EDT)
Received: by wyg36 with SMTP id 36so248460wyg.14
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 07:08:21 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1107200854390.32737@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 16:08:13 +0200
Message-ID: <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  08:56 -0500, Christoph Lameter a A(C)crit :
> On Wed, 20 Jul 2011, Mel Gorman wrote:
> 
> > > The changelog isn't that convincing, really. This is
> > > kmem_cache_create() so I'm surprised we'd ever get NULL here in
> > > practice. Does this fix some problem you're seeing? If this is
> > > really an issue, I'd blame the page allocator as GFP_KERNEL should
> > > just work.
> > >
> >
> > Besides, is allocating from cache_cache really a
> > PAGE_ALLOC_COSTLY_ORDER allocation? On my laptop at least, it's an
> > order-2 allocation which is supporting up to 512 CPUs and 512 nodes.
> 
> Slab's kmem_cache is configured with an array of NR_CPUS which is the
> maximum nr of cpus supported. Some distros support 4096 cpus in order to
> accomodate SGI machines. That array then will have the size of 4096 * 8 =
> 32k

We currently support a dynamic schem for the possible nodes :

cache_cache.buffer_size = offsetof(struct kmem_cache, nodelists) + 
	nr_node_ids * sizeof(struct kmem_list3 *);

We could have a similar trick to make the real size both depends on
nr_node_ids and nr_cpu_ids.

(struct kmem_cache)->array would become a pointer.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

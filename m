Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2F88A6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 07:37:18 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so10724644pdj.0
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:37:17 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id k2si9654545pdn.229.2014.08.11.04.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 04:37:17 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so10626940pdi.20
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:37:16 -0700 (PDT)
Date: Mon, 11 Aug 2014 04:37:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slab: fix cpuset check in fallback_alloc
In-Reply-To: <20140811071315.GA18709@esperanza>
Message-ID: <alpine.DEB.2.02.1408110433140.15519@chino.kir.corp.google.com>
References: <1407692891-24312-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.02.1408101512500.706@chino.kir.corp.google.com> <20140811071315.GA18709@esperanza>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 11 Aug 2014, Vladimir Davydov wrote:

> > diff --git a/mm/slab.c b/mm/slab.c
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3047,16 +3047,19 @@ retry:
> >  	 * from existing per node queues.
> >  	 */
> >  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> > -		nid = zone_to_nid(zone);
> > +		struct kmem_cache_node *n;
> >  
> > -		if (cpuset_zone_allowed_hardwall(zone, flags) &&
> > -			get_node(cache, nid) &&
> > -			get_node(cache, nid)->free_objects) {
> > -				obj = ____cache_alloc_node(cache,
> > -					flags | GFP_THISNODE, nid);
> > -				if (obj)
> > -					break;
> > -		}
> > +		nid = zone_to_nid(zone);
> > +		if (!cpuset_zone_allowed(zone, flags | __GFP_HARDWALL))
> 
> We must use softwall check here, otherwise we will proceed to
> alloc_pages even if there are lots of free slabs on other nodes.
> alloc_pages, in turn, may allocate from other nodes in case
> cpuset.mem_hardwall=0, because it uses softwall check, so it may add yet
> another free slab to another node's list even if it isn't empty. As a
> result, we may get free list bloating on other nodes. I've seen a
> machine with one of its nodes almost completely filled with inactive
> slabs for buffer_heads (dozens of GBs) w/o any chance to drop them. So,
> this is a bug that must be fixed.
> 

Right, I understand, and my patch makes no attempt to fix that issue, it's 
simply collapsing the code down into a single cpuset_zone_allowed() 
function and the context for the allocation is controlled by the gfp 
flags (and hardwall is controlled by setting __GFP_HARDWALL) as it should 
be.  I understand the issue you face, but I can't combine a cleanup with a 
fix and I would prefer to have your patch keep your commit description.  

The diffstat for my proposal removes many more lines than it adds and I 
think it will avoid this type of issue in the future for new callers.  
Your patch could then be based on the single cpuset_zone_allowed() 
function where you would simply have to remove the __GFP_HARDWALL above.  
Or, your patch could be merged first and then my cleanup on top, but it 
seems like your one-liner would be more clear if it is based on mine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

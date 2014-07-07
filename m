Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id DA44E6B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:45:54 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so3053766lbv.28
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:45:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qp9si27454091lbb.61.2014.07.07.08.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 08:45:53 -0700 (PDT)
Date: Mon, 7 Jul 2014 19:45:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/8] memcg: keep all children of each root cache on a
 list
Message-ID: <20140707154546.GI13827@esperanza>
References: <cover.1404733720.git.vdavydov@parallels.com>
 <e58c0491eebc594f6e80a91dc0ed6905d65050bd.1404733720.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1407071022200.22121@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407071022200.22121@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 10:24:35AM -0500, Christoph Lameter wrote:
> On Mon, 7 Jul 2014, Vladimir Davydov wrote:
> 
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index d31c4bacc6a2..95a8f772b0d1 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -294,8 +294,12 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >  	if (IS_ERR(s)) {
> >  		kfree(cache_name);
> >  		s = NULL;
> > +		goto out_unlock;
> >  	}
> >
> > +	list_add(&s->memcg_params->siblings,
> > +		 &root_cache->memcg_params->children);
> > +
> >  out_unlock:
> >  	mutex_unlock(&slab_mutex);
> >
> 
> If there is an error then s is set to NULL. And then
> the list_add is done dereferencing s?

No, we skip list_add on error. I think you missed "goto out_unlock"
right after "s = NULL" (btw do_kmem_cache_create never returns NULL).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DDAF36B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:44:21 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so36612331wib.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:44:21 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id eu3si7654210wib.105.2015.06.09.23.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 23:44:20 -0700 (PDT)
Date: Wed, 10 Jun 2015 08:44:17 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy()
 functions
In-Reply-To: <20150610064108.GB566@swordfish>
Message-ID: <alpine.DEB.2.02.1506100841420.2087@localhost6.localdomain6>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org> <1433894769.2730.87.camel@perches.com> <alpine.DEB.2.02.1506100743200.2087@localhost6.localdomain6>
 <20150610064108.GB566@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 10 Jun 2015, Sergey Senozhatsky wrote:

> On (06/10/15 07:46), Julia Lawall wrote:
> > > > Well I like it, even though it's going to cause a zillion little cleanup
> > > > patches.
> > 
> > Actually only at most 87.  There are some functions that look quite a bit 
> > nicer with the change, like:
> > 
> >  void jffs2_destroy_slab_caches(void)
> >  {
> > -       if(full_dnode_slab)
> > -               kmem_cache_destroy(full_dnode_slab);
> > -       if(raw_dirent_slab)
> > -               kmem_cache_destroy(raw_dirent_slab);
> > -       if(raw_inode_slab)
> > -               kmem_cache_destroy(raw_inode_slab);
> > -       if(tmp_dnode_info_slab)
> > -               kmem_cache_destroy(tmp_dnode_info_slab);
> > -       if(raw_node_ref_slab)
> > -               kmem_cache_destroy(raw_node_ref_slab);
> > -       if(node_frag_slab)
> > -               kmem_cache_destroy(node_frag_slab);
> > -       if(inode_cache_slab)
> > -               kmem_cache_destroy(inode_cache_slab);
> > +       kmem_cache_destroy(full_dnode_slab);
> > +       kmem_cache_destroy(raw_dirent_slab);
> > +       kmem_cache_destroy(raw_inode_slab);
> > +       kmem_cache_destroy(tmp_dnode_info_slab);
> > +       kmem_cache_destroy(raw_node_ref_slab);
> > +       kmem_cache_destroy(node_frag_slab);
> > +       kmem_cache_destroy(inode_cache_slab);
> >  #ifdef CONFIG_JFFS2_FS_XATTR
> > -       if (xattr_datum_cache)
> > -               kmem_cache_destroy(xattr_datum_cache);
> > -       if (xattr_ref_cache)
> > -               kmem_cache_destroy(xattr_ref_cache);
> > +       kmem_cache_destroy(xattr_datum_cache);
> > +       kmem_cache_destroy(xattr_ref_cache);
> >  #endif
> >  }
> > 
> 
> and some goto labels can go away either. like
> 
> [..]
> 
> err_percpu_counter_init:
> 	kmem_cache_destroy(sctp_chunk_cachep);
> err_chunk_cachep:
> 	kmem_cache_destroy(sctp_bucket_cachep);
> 
> [..]
> 
> and others.

This I find much less appealing.  The labels make clear what is needed at 
what point.  At least from a tool point of view, this is useful 
infomation.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

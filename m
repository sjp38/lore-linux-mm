Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 112196B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:40:44 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so28475548pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:40:43 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id rc3si12302423pbc.149.2015.06.09.23.40.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:40:43 -0700 (PDT)
Received: by payr10 with SMTP id r10so28618941pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:40:43 -0700 (PDT)
Date: Wed, 10 Jun 2015 15:41:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-ID: <20150610064108.GB566@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
 <1433894769.2730.87.camel@perches.com>
 <alpine.DEB.2.02.1506100743200.2087@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1506100743200.2087@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (06/10/15 07:46), Julia Lawall wrote:
> > > Well I like it, even though it's going to cause a zillion little cleanup
> > > patches.
> 
> Actually only at most 87.  There are some functions that look quite a bit 
> nicer with the change, like:
> 
>  void jffs2_destroy_slab_caches(void)
>  {
> -       if(full_dnode_slab)
> -               kmem_cache_destroy(full_dnode_slab);
> -       if(raw_dirent_slab)
> -               kmem_cache_destroy(raw_dirent_slab);
> -       if(raw_inode_slab)
> -               kmem_cache_destroy(raw_inode_slab);
> -       if(tmp_dnode_info_slab)
> -               kmem_cache_destroy(tmp_dnode_info_slab);
> -       if(raw_node_ref_slab)
> -               kmem_cache_destroy(raw_node_ref_slab);
> -       if(node_frag_slab)
> -               kmem_cache_destroy(node_frag_slab);
> -       if(inode_cache_slab)
> -               kmem_cache_destroy(inode_cache_slab);
> +       kmem_cache_destroy(full_dnode_slab);
> +       kmem_cache_destroy(raw_dirent_slab);
> +       kmem_cache_destroy(raw_inode_slab);
> +       kmem_cache_destroy(tmp_dnode_info_slab);
> +       kmem_cache_destroy(raw_node_ref_slab);
> +       kmem_cache_destroy(node_frag_slab);
> +       kmem_cache_destroy(inode_cache_slab);
>  #ifdef CONFIG_JFFS2_FS_XATTR
> -       if (xattr_datum_cache)
> -               kmem_cache_destroy(xattr_datum_cache);
> -       if (xattr_ref_cache)
> -               kmem_cache_destroy(xattr_ref_cache);
> +       kmem_cache_destroy(xattr_datum_cache);
> +       kmem_cache_destroy(xattr_ref_cache);
>  #endif
>  }
> 

and some goto labels can go away either. like

[..]

err_percpu_counter_init:
	kmem_cache_destroy(sctp_chunk_cachep);
err_chunk_cachep:
	kmem_cache_destroy(sctp_bucket_cachep);

[..]

and others.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

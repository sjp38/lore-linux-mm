Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id BAE9F6B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:09:19 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id cl4so95170796igb.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:09:19 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 197si3691827ion.193.2016.03.30.01.09.18
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:09:18 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:11:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/11] mm/slab: hold a slab_mutex when calling
 __kmem_cache_shrink()
Message-ID: <20160330081116.GA1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1603281940300.31323@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603281940300.31323@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 28, 2016 at 07:50:36PM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2016, js1304@gmail.com wrote:
> 
> > Major kmem_cache metadata in slab subsystem is synchronized with
> > the slab_mutex. In SLAB, if some of them is changed, node's shared
> > array cache would be freed and re-populated. If __kmem_cache_shrink()
> > is called at the same time, it will call drain_array() with n->shared
> > without holding node lock so problem can happen.
> >
> > We can fix this small theoretical race condition by holding node lock
> > in drain_array(), but, holding a slab_mutex in kmem_cache_shrink()
> > looks more appropriate solution because stable state would make things
> > less error-prone and this is not performance critical path.
> 
> Ummm.. The mutex taking is added to common code. So this will also affect
> SLUB.  The patch needs to consider this. Do we want to force all
> allocators to run shrinking only when holding the lock? SLUB does not
> need to hold the mutex. And frankly the mutex is for reconfiguration of
> metadata which is *not* occurring here. A shrink operation does not do
> that. Can we figure out a slab specific way of handling synchronization
> in the strange free/realloc cycle?
> 
> It seems that taking the node lock is the appropriate level of
> synchrnonization since the concern is with the contents of a shared cache
> at that level. There is no change of metadata which would require the
> mutex.

Okay. I will fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

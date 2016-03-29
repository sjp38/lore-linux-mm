Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id C65116B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 20:50:38 -0400 (EDT)
Received: by mail-io0-f170.google.com with SMTP id a129so4206716ioe.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 17:50:38 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id q64si25603379ioe.49.2016.03.28.17.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 17:50:38 -0700 (PDT)
Date: Mon, 28 Mar 2016 19:50:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/11] mm/slab: hold a slab_mutex when calling
 __kmem_cache_shrink()
In-Reply-To: <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1603281940300.31323@east.gentwo.org>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com> <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016, js1304@gmail.com wrote:

> Major kmem_cache metadata in slab subsystem is synchronized with
> the slab_mutex. In SLAB, if some of them is changed, node's shared
> array cache would be freed and re-populated. If __kmem_cache_shrink()
> is called at the same time, it will call drain_array() with n->shared
> without holding node lock so problem can happen.
>
> We can fix this small theoretical race condition by holding node lock
> in drain_array(), but, holding a slab_mutex in kmem_cache_shrink()
> looks more appropriate solution because stable state would make things
> less error-prone and this is not performance critical path.

Ummm.. The mutex taking is added to common code. So this will also affect
SLUB.  The patch needs to consider this. Do we want to force all
allocators to run shrinking only when holding the lock? SLUB does not
need to hold the mutex. And frankly the mutex is for reconfiguration of
metadata which is *not* occurring here. A shrink operation does not do
that. Can we figure out a slab specific way of handling synchronization
in the strange free/realloc cycle?

It seems that taking the node lock is the appropriate level of
synchrnonization since the concern is with the contents of a shared cache
at that level. There is no change of metadata which would require the
mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

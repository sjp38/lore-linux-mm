Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5104A8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:00:52 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id uo6so71882681pac.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:00:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wb3si45158502pab.114.2016.02.08.01.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 01:00:51 -0800 (PST)
Date: Mon, 8 Feb 2016 12:00:34 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: slab: free kmem_cache_node after destroy sysfs file
Message-ID: <20160208090034.GA30053@esperanza>
References: <1454692612-14856-1-git-send-email-dsafonov@virtuozzo.com>
 <20160207191006.GC19151@esperanza>
 <56B85663.9030406@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <56B85663.9030406@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Feb 08, 2016 at 11:48:35AM +0300, Dmitry Safonov wrote:
...
> >>  /*
> >>   * Attempt to free all partial slabs on a node.
> >>- * This is called from kmem_cache_close(). We must be the last thread
> >>+ * This is called from __kmem_cache_shutdown(). We must be the last thread
> >>   * using the cache and therefore we do not need to lock anymore.
> >Well, that's not true as we've found out - sysfs might still access the
> >cache in parallel. And alloc_calls_show -> list_locations does walk over
> >the kmem_cache_node->partial list, which we prune on shutdown.
> >
> >I guess we should reintroduce locking for free_partial() in the scope of
> >this patch, partially reverting 69cb8e6b7c298.
> I think, we can omit locking for !SLAB_SUPPORTS_SYSFS and reintroduce
> for sysfs case. Will do

I really don't think there's any point in cluttering the code with
ifdefs here - we'd better just enable locking in any case. It won't hurt
performance, because it's a very-very slow path anyway. Besides, SYSFS
is on by default on most builds.

FWIW SLAB does not omit locking on shutdown, although it doesn't support
sysfs.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

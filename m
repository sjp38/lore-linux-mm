Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 804696B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:26:52 -0400 (EDT)
Date: Thu, 5 Jul 2012 09:26:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock
 is failed in __slab_free()
In-Reply-To: <1340389359-2407-3-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207050924330.4138@router.home>
References: <yes> <1340389359-2407-1-git-send-email-js1304@gmail.com> <1340389359-2407-3-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 23 Jun 2012, Joonsoo Kim wrote:

> In some case of __slab_free(), we need a lock for manipulating partial list.
> If freeing object with a lock is failed, a lock doesn't needed anymore
> for some reasons.
>
> Case 1. prior is NULL, kmem_cache_debug(s) is true
>
> In this case, another free is occured before our free is succeed.
> When slab is full(prior is NULL), only possible operation is slab_free().
> So in this case, we guess another free is occured.
> It may make a slab frozen, so lock is not needed anymore.

A free cannot freeze the slab without taking the lock. The taken lock
makes sure that the thread that first enters slab_free() will be able to
hold back the thread that wants to freeze the slab.

> Case 2. inuse is NULL
>
> In this case, acquire_slab() is occured before out free is succeed.
> We have a last object for slab, so other operation for this slab is
> not possible except acquire_slab().
> Acquire_slab() makes a slab frozen, so lock is not needed anymore.

acquire_slab() also requires lock acquisition and would be held of by
slab_free holding the lock.

> This also make logic somehow simple that 'was_frozen with a lock' case
> is never occured. Remove it.

That is actually interesting and would be a good optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

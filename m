Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 98D946B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:01:26 -0400 (EDT)
Message-ID: <5044C587.60801@parallels.com>
Date: Mon, 3 Sep 2012 18:58:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [08/14] Get rid of __kmem_cache_destroy
References: <20120824160903.168122683@linux.com> <000001395967d71c-8ea585e1-ebf1-43ac-a9e4-b3b89f7d64d9-000000@email.amazonses.com>
In-Reply-To: <000001395967d71c-8ea585e1-ebf1-43ac-a9e4-b3b89f7d64d9-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:12 PM, Christoph Lameter wrote:
> What is done there can be done in __kmem_cache_shutdown.
> 
> This affects RCU handling somewhat. On rcu free all slab allocators
> do not refer to other management structures than the kmem_cache structure.
> Therefore these other structures can be freed before the rcu deferred
> free to the page allocator occurs.
> 
> Reviewed-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Here is the code for that in slab_common.c:

    if (!__kmem_cache_shutdown(s)) {
        if (s->flags & SLAB_DESTROY_BY_RCU)
            rcu_barrier();

        __kmem_cache_destroy(s);
    } ...

All that code that used to belong in __kmem_cache_destroy(), will not be
executed in kmem_cache_shutdown() without an rcu_barrier.

You need at least Paul's ack here to guarantee it is safe, but I believe
it is not. Take a look for instance at 7ed9f7e5db5, which describes a
subtle bug arising from such a situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

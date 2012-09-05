Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 6019B6B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:28:30 -0400 (EDT)
Message-ID: <50470C6D.201@parallels.com>
Date: Wed, 5 Sep 2012 12:25:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [08/14] Get rid of __kmem_cache_destroy
References: <20120824160903.168122683@linux.com> <000001395967d71c-8ea585e1-ebf1-43ac-a9e4-b3b89f7d64d9-000000@email.amazonses.com> <5044C587.60801@parallels.com> <00000139937082ef-c61760a5-47fe-42d9-a043-ba81b2dfd216-000000@email.amazonses.com>
In-Reply-To: <00000139937082ef-c61760a5-47fe-42d9-a043-ba81b2dfd216-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, David
 Rientjes <rientjes@google.com>

On 09/05/2012 02:39 AM, Christoph Lameter wrote:
> On Mon, 3 Sep 2012, Glauber Costa wrote:
> 
>> Here is the code for that in slab_common.c:
>>
>>     if (!__kmem_cache_shutdown(s)) {
>>         if (s->flags & SLAB_DESTROY_BY_RCU)
>>             rcu_barrier();
>>
>>         __kmem_cache_destroy(s);
>>     } ...
>>
>> All that code that used to belong in __kmem_cache_destroy(), will not be
>> executed in kmem_cache_shutdown() without an rcu_barrier.
> 
> But that allocator specific code in __kmem_cache_destroy will not free the
> kmem_cache structure. That is the only important thing to be aware of.
> Only deferred frees of slab pages may still be in progress at this time
> until the close of the RCU period. These deferred freeing actions do not
> refer to anything but the kmem_cache structure. Therefore the rest can be
> freed before the period is over. And we check that the rest can be freed.
> Should there be a leftover at that point then f.e.
> free_partial() will issue a warning.
> 

Ok. That sounds reasonable.
(not sure if correct, but reasonable)

> kmem_cache_destroy() can only be called after all objects have been freed
> and it checks that this actually was done. "Have been freed" means in the
> context of an SLAB_DESTROY_BY_RCU slab that the rcu delayed frees for the
> individual objects are complete. During kmem_cache_destroy() only slab
> pages that contain no objects are freed back to the page allocator. Those
> will be also freed in a deferred way at kmem_cache_destroy. Hmmm.... we
> could simply delete the SLAB_DESTROY_BY_RCU flag and free the objects
> without obeying the rcu period since no objects should be allocated at
> that point.
> 
>> You need at least Paul's ack here to guarantee it is safe, but I believe
>> it is not. Take a look for instance at 7ed9f7e5db5, which describes a
>> subtle bug arising from such a situation.
> 
> The commit that you referred to ensures that kmem_cache is not freed
> before the rcu period is over. This patch does not change that guarantee.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

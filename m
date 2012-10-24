Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3EFD16B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 06:03:58 -0400 (EDT)
Message-ID: <5087BD06.5010904@parallels.com>
Date: Wed, 24 Oct 2012 14:03:50 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-3-git-send-email-glommer@parallels.com> <CAOJsxLEcUJzZnyYDPwzEkjirSKEWXcGM6PxY=nyrktFZgP7ztg@mail.gmail.com>
In-Reply-To: <CAOJsxLEcUJzZnyYDPwzEkjirSKEWXcGM6PxY=nyrktFZgP7ztg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On 10/24/2012 12:56 PM, Pekka Enberg wrote:
> On Mon, Oct 22, 2012 at 5:05 PM, Glauber Costa <glommer@parallels.com> wrote:
>> +/**
>> + * kmem_cache_free - Deallocate an object
>> + * @cachep: The cache the allocation was from.
>> + * @objp: The previously allocated object.
>> + *
>> + * Free an object which was previously allocated from this
>> + * cache.
>> + */
>> +void kmem_cache_free(struct kmem_cache *s, void *x)
>> +{
>> +       __kmem_cache_free(s, x);
>> +       trace_kmem_cache_free(_RET_IP_, x);
>> +}
>> +EXPORT_SYMBOL(kmem_cache_free);
> 
> As Christoph mentioned, this is going to hurt performance. The proper
> way to do this is to implement the *hook* in mm/slab_common.c and call
> that from all the allocator specific kmem_cache_free() functions.
> 
>                         Pekka
> 
We would ideally like the hooks to be inlined as well. Specially for the
memcg-disabled case, this will only get us a function call for no reason.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

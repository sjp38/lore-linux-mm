Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3EC1E6B0069
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:52:52 -0400 (EDT)
Message-ID: <508676FA.4000107@parallels.com>
Date: Tue, 23 Oct 2012 14:52:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-3-git-send-email-glommer@parallels.com> <0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com> <508561E0.5000406@parallels.com> <CAAmzW4PJkDbLJBKZ1zPNDw+dHPcgzX_25tMw3rWoX0ybpXACSQ@mail.gmail.com> <50865024.60309@parallels.com>
In-Reply-To: <50865024.60309@parallels.com>
Content-Type: multipart/mixed;
	boundary="------------030003060004030207070807"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

--------------030003060004030207070807
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 10/23/2012 12:07 PM, Glauber Costa wrote:
> On 10/23/2012 04:48 AM, JoonSoo Kim wrote:
>> Hello, Glauber.
>>
>> 2012/10/23 Glauber Costa <glommer@parallels.com>:
>>> On 10/22/2012 06:45 PM, Christoph Lameter wrote:
>>>> On Mon, 22 Oct 2012, Glauber Costa wrote:
>>>>
>>>>> + * kmem_cache_free - Deallocate an object
>>>>> + * @cachep: The cache the allocation was from.
>>>>> + * @objp: The previously allocated object.
>>>>> + *
>>>>> + * Free an object which was previously allocated from this
>>>>> + * cache.
>>>>> + */
>>>>> +void kmem_cache_free(struct kmem_cache *s, void *x)
>>>>> +{
>>>>> +    __kmem_cache_free(s, x);
>>>>> +    trace_kmem_cache_free(_RET_IP_, x);
>>>>> +}
>>>>> +EXPORT_SYMBOL(kmem_cache_free);
>>>>> +
>>>>
>>>> This results in an additional indirection if tracing is off. Wonder if
>>>> there is a performance impact?
>>>>
>>> if tracing is on, you mean?
>>>
>>> Tracing already incurs overhead, not sure how much a function call would
>>> add to the tracing overhead.
>>>
>>> I would not be concerned with this, but I can measure, if you have any
>>> specific workload in mind.
>>
>> With this patch, kmem_cache_free() invokes __kmem_cache_free(),
>> that is, it add one more "call instruction" than before.
>>
>> I think that Christoph's comment means above fact.
> 
> Ah, this. Ok, I got fooled by his mention to tracing.
> 
> I do agree, but since freeing is ultimately dependent on the allocator
> layout, I don't see a clean way of doing this without dropping tears of
> sorrow around. The calls in slub/slab/slob would have to be somehow
> inlined. Hum... maybe it is possible to do it from
> include/linux/sl*b_def.h...
> 
> Let me give it a try and see what I can come up with.
> 

Ok.

I am attaching a PoC for this for your appreciation. This gets quite
ugly, but it's the way I found without including sl{a,u,o}b.c directly -
which would be even worse.

But I guess if we really want to avoid the cost of a function call,
there has to be a tradeoff...

For the record, the proposed usage for this would be:

1) Given a (inline) function, defined in mm/slab.h that translates the
cache from its object address (and then sanity checks it against the
cache parameter), translate_cache():

#define KMEM_CACHE_FREE(allocator_fn)                   \
void kmem_cache_free(struct kmem_cache *s, void *x)     \
{                                                       \
        struct kmem_cache *cachep;                      \
        cachep = translate_cache(s, x);                 \
        if (!cachep)                                    \
                return;                                 \
        allocator_fn(cachep, x);                        \
        trace_kmem_cache_free(_RET_IP_, x);             \
}                                                       \
EXPORT_SYMBOL(kmem_cache_free)



--------------030003060004030207070807
Content-Type: text/x-patch;
	name="0001-slab-move-kmem_cache_free-to-common-code.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-slab-move-kmem_cache_free-to-common-code.patch"


--------------030003060004030207070807--

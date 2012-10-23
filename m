Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 85BF76B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 11:43:10 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so4485358obc.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 08:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508676FA.4000107@parallels.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com>
	<1350914737-4097-3-git-send-email-glommer@parallels.com>
	<0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com>
	<508561E0.5000406@parallels.com>
	<CAAmzW4PJkDbLJBKZ1zPNDw+dHPcgzX_25tMw3rWoX0ybpXACSQ@mail.gmail.com>
	<50865024.60309@parallels.com>
	<508676FA.4000107@parallels.com>
Date: Wed, 24 Oct 2012 00:43:09 +0900
Message-ID: <CAAmzW4M9Casm+b4TOe7MOuZMYf7PKmzOHs1wZOXvybhRxCqZRA@mail.gmail.com>
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

2012/10/23 Glauber Costa <glommer@parallels.com>:
> On 10/23/2012 12:07 PM, Glauber Costa wrote:
>> On 10/23/2012 04:48 AM, JoonSoo Kim wrote:
>>> Hello, Glauber.
>>>
>>> 2012/10/23 Glauber Costa <glommer@parallels.com>:
>>>> On 10/22/2012 06:45 PM, Christoph Lameter wrote:
>>>>> On Mon, 22 Oct 2012, Glauber Costa wrote:
>>>>>
>>>>>> + * kmem_cache_free - Deallocate an object
>>>>>> + * @cachep: The cache the allocation was from.
>>>>>> + * @objp: The previously allocated object.
>>>>>> + *
>>>>>> + * Free an object which was previously allocated from this
>>>>>> + * cache.
>>>>>> + */
>>>>>> +void kmem_cache_free(struct kmem_cache *s, void *x)
>>>>>> +{
>>>>>> +    __kmem_cache_free(s, x);
>>>>>> +    trace_kmem_cache_free(_RET_IP_, x);
>>>>>> +}
>>>>>> +EXPORT_SYMBOL(kmem_cache_free);
>>>>>> +
>>>>>
>>>>> This results in an additional indirection if tracing is off. Wonder if
>>>>> there is a performance impact?
>>>>>
>>>> if tracing is on, you mean?
>>>>
>>>> Tracing already incurs overhead, not sure how much a function call would
>>>> add to the tracing overhead.
>>>>
>>>> I would not be concerned with this, but I can measure, if you have any
>>>> specific workload in mind.
>>>
>>> With this patch, kmem_cache_free() invokes __kmem_cache_free(),
>>> that is, it add one more "call instruction" than before.
>>>
>>> I think that Christoph's comment means above fact.
>>
>> Ah, this. Ok, I got fooled by his mention to tracing.
>>
>> I do agree, but since freeing is ultimately dependent on the allocator
>> layout, I don't see a clean way of doing this without dropping tears of
>> sorrow around. The calls in slub/slab/slob would have to be somehow
>> inlined. Hum... maybe it is possible to do it from
>> include/linux/sl*b_def.h...
>>
>> Let me give it a try and see what I can come up with.
>>
>
> Ok.
>
> I am attaching a PoC for this for your appreciation. This gets quite
> ugly, but it's the way I found without including sl{a,u,o}b.c directly -
> which would be even worse.

Hmm...
This is important issue for sl[aou]b common allocators.
Because there are similar functions like as kmem_cache_alloc, ksize, kfree, ...
So it is good time to resolve this issue.

As far as I know, now, we have 3 solutions.

1. include/linux/slab.h
__always_inline kmem_cache_free()
{
__kmem_cache_free();
blablabla...
}

2. define macro like as Glauber's solution
3. include sl[aou]b.c directly.

Is there other good solution?
Among them, I prefer "solution 3", because future developing cost may
be minimum among them.

"Solution 2" may be error-prone for future developing.
"Solution 1" may make compile-time longer and larger code.

Is my understanding right?
Is "Solution 3" really ugly?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

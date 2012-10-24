Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3A03F6B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 13:47:16 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so919130obc.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 10:47:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a8f59a08d-c08e9180-a368-4edd-b9ac-d512e2a3ce19-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com>
	<0000013a797cda39-907d3721-264e-4d75-8d4d-4122eb0a981c-000000@email.amazonses.com>
	<CAAmzW4Pmb5uFGC=qaC0WfM_pZ1s+x4Knz0QJogZZ8vesnkF6qw@mail.gmail.com>
	<0000013a8f59a08d-c08e9180-a368-4edd-b9ac-d512e2a3ce19-000000@email.amazonses.com>
Date: Thu, 25 Oct 2012 02:47:15 +0900
Message-ID: <CAAmzW4PZOJHE96zyG+mNSMpVo95nEwgdwM+sK-UK+HKLTicXbA@mail.gmail.com>
Subject: Re: CK2 [08/15] slab: Use common kmalloc_index/kmalloc_size functions
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

2012/10/24 Christoph Lameter <cl@linux.com>:
> On Sun, 21 Oct 2012, JoonSoo Kim wrote:
>
>> 2012/10/19 Christoph Lameter <cl@linux.com>:
>>
>> > @@ -693,20 +657,19 @@ static inline struct array_cache *cpu_ca
>> >  static inline struct kmem_cache *__find_general_cachep(size_t size,
>> >                                                         gfp_t gfpflags)
>> >  {
>> > -       struct cache_sizes *csizep = malloc_sizes;
>> > +       int i;
>> >
>> >  #if DEBUG
>> >         /* This happens if someone tries to call
>> >          * kmem_cache_create(), or __kmalloc(), before
>> >          * the generic caches are initialized.
>> >          */
>> > -       BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
>> > +       BUG_ON(kmalloc_caches[INDEX_AC] == NULL);
>> >  #endif
>> >         if (!size)
>> >                 return ZERO_SIZE_PTR;
>> >
>> > -       while (size > csizep->cs_size)
>> > -               csizep++;
>> > +       i = kmalloc_index(size);
>>
>> Above kmalloc_index(size) is called with arbitrary size, therefore it
>> cannot be folded.
>
> The size is passed into an inline function that is folded and therefore
> the kmalloc_index function can also be folded if the size passed into
> __find_general_cachep was constant.
>

__find_general_cachep() is called by __do_kmalloc().
And __do_kmalloc() is called by __kmalloc().
__kmalloc() is called by kmalloc() when buildin_constant_p is failed.
Therefore __find_general_cachep() is called with arbitrary size value
and kmalloc_index() cannot be folded.
But, I think it doesn't matter, because CK2[15/15] also solve this problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

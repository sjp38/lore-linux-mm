Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 647196B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 02:24:37 -0400 (EDT)
Received: by fxm24 with SMTP id 24so1053868fxm.38
        for <linux-mm@kvack.org>; Wed, 17 Jun 2009 23:25:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
References: <20090617203337.399182817@gentwo.org>
	 <20090617203445.302169275@gentwo.org>
	 <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
Date: Thu, 18 Jun 2009 09:25:21 +0300
Message-ID: <84144f020906172325m5de946gd8aa90328da26906@mail.gmail.com>
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 9:20 AM, Pekka Enberg<penberg@cs.helsinki.fi> wrote=
:
> Hi Christoph,
>
> On Wed, Jun 17, 2009 at 11:33 PM, <cl@linux-foundation.org> wrote:
>> @@ -1604,9 +1595,6 @@ static void *__slab_alloc(struct kmem_ca
>> =A0 =A0 =A0 =A0void **object;
>> =A0 =A0 =A0 =A0struct page *new;
>>
>> - =A0 =A0 =A0 /* We handle __GFP_ZERO in the caller */
>> - =A0 =A0 =A0 gfpflags &=3D ~__GFP_ZERO;
>> -
>
> This should probably not be here.
>
>> @@ -2724,7 +2607,19 @@ static noinline struct kmem_cache *dma_k
>> =A0 =A0 =A0 =A0realsize =3D kmalloc_caches[index].objsize;
>> =A0 =A0 =A0 =A0text =3D kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned int)realsize);
>> - =A0 =A0 =A0 s =3D kmalloc(kmem_size, flags & ~SLUB_DMA);
>> +
>> + =A0 =A0 =A0 if (flags & __GFP_WAIT)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D kmalloc(kmem_size, flags & ~SLUB_DMA=
);
>> + =A0 =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < SLUB_PAGE_SHIFT; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kmalloc_caches[i].size=
) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D kmal=
loc_caches + i;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>
> [snip]
>
>> A particular problem for the dynamic dma kmalloc slab creation is that t=
he
>> new percpu allocator cannot be called from an atomic context. The soluti=
on
>> adopted here for the atomic context is to track spare elements in the pe=
r
>> cpu kmem_cache array for non dma kmallocs. Use them if necessary for dma
>> cache creation from an atomic context. Otherwise we just fail the alloca=
tion.
>
> OK, I am confused. Isn't the whole point in separating DMA caches that
> we don't mix regular and DMA allocations in the same slab and using up
> precious DMA memory on some archs?
>
> So I don't think the above hunk is a good solution to this at all. We
> certainly can remove the lazy DMA slab creation (why did we add it in
> the first place?) but how hard is it to fix the per-cpu allocator to
> work in atomic contexts?

Oh, and how does this work with the early boot slab code? We're
creating all the kmalloc caches with interrupts disabled and doing
per-cpu allocations, no?

                                                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

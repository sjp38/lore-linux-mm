Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 09AF46B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 12:12:36 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so4526170obc.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 09:12:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350973015.8609.1444.camel@edumazet-glaptop>
References: <1350748093-7868-1-git-send-email-js1304@gmail.com>
	<1350748093-7868-2-git-send-email-js1304@gmail.com>
	<0000013a88e2e9dc-9f72abd3-9a31-454c-b70b-9937ba54c0ee-000000@email.amazonses.com>
	<CAAmzW4Nz_=_Tj-D=DXaO-SR5pRZ_n7-gfVbKHa+=DP0NQioAaQ@mail.gmail.com>
	<1350973015.8609.1444.camel@edumazet-glaptop>
Date: Wed, 24 Oct 2012 01:12:36 +0900
Message-ID: <CAAmzW4PyEB+GSPDGFV-B436wA+avTQ_1BomGaYDq-3s6wRZpjQ@mail.gmail.com>
Subject: Re: [PATCH for-v3.7 2/2] slub: optimize kmalloc* inlining for GFP_DMA
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Eric.

2012/10/23 Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2012-10-23 at 11:29 +0900, JoonSoo Kim wrote:
>> 2012/10/22 Christoph Lameter <cl@linux.com>:
>> > On Sun, 21 Oct 2012, Joonsoo Kim wrote:
>> >
>> >> kmalloc() and kmalloc_node() of the SLUB isn't inlined when @flags = __GFP_DMA.
>> >> This patch optimize this case,
>> >> so when @flags = __GFP_DMA, it will be inlined into generic code.
>> >
>> > __GFP_DMA is a rarely used flag for kmalloc allocators and so far it was
>> > not considered that it is worth to directly support it in the inlining
>> > code.
>> >
>> >
>>
>> Hmm... but, the SLAB already did that optimization for __GFP_DMA.
>> Almost every kmalloc() is invoked with constant flags value,
>> so I think that overhead from this patch may be negligible.
>> With this patch, code size of vmlinux is reduced slightly.
>
> Only because you asked a allyesconfig
>
> GFP_DMA is used for less than 0.1 % of kmalloc() calls, for legacy
> hardware (from last century)

I'm not doing with allyesconfig,
but localmodconfig on my ubuntu desktop system.
On my system, 700 bytes of text of vmlinux is reduced
which mean there may be more than 100 callsite with GFP_DMA.

> In fact if you want to reduce even more your vmlinux, you could test
>
> if (__builtin_constant_p(flags) && (flags & SLUB_DMA))
>     return kmem_cache_alloc_trace(s, flags, size);
>
> to force the call to out of line code.

The reason why I mention about code size is that I want to say it may
be good for performance,
although it has a just small impact.
I'm not interest of reducing code size :)

Thanks for comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

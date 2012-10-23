Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B5B4F6B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:16:59 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so1481370eek.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 23:16:58 -0700 (PDT)
Subject: Re: [PATCH for-v3.7 2/2] slub: optimize kmalloc* inlining for
 GFP_DMA
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CAAmzW4Nz_=_Tj-D=DXaO-SR5pRZ_n7-gfVbKHa+=DP0NQioAaQ@mail.gmail.com>
References: <1350748093-7868-1-git-send-email-js1304@gmail.com>
	 <1350748093-7868-2-git-send-email-js1304@gmail.com>
	 <0000013a88e2e9dc-9f72abd3-9a31-454c-b70b-9937ba54c0ee-000000@email.amazonses.com>
	 <CAAmzW4Nz_=_Tj-D=DXaO-SR5pRZ_n7-gfVbKHa+=DP0NQioAaQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Oct 2012 08:16:55 +0200
Message-ID: <1350973015.8609.1444.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2012-10-23 at 11:29 +0900, JoonSoo Kim wrote:
> 2012/10/22 Christoph Lameter <cl@linux.com>:
> > On Sun, 21 Oct 2012, Joonsoo Kim wrote:
> >
> >> kmalloc() and kmalloc_node() of the SLUB isn't inlined when @flags = __GFP_DMA.
> >> This patch optimize this case,
> >> so when @flags = __GFP_DMA, it will be inlined into generic code.
> >
> > __GFP_DMA is a rarely used flag for kmalloc allocators and so far it was
> > not considered that it is worth to directly support it in the inlining
> > code.
> >
> >
> 
> Hmm... but, the SLAB already did that optimization for __GFP_DMA.
> Almost every kmalloc() is invoked with constant flags value,
> so I think that overhead from this patch may be negligible.
> With this patch, code size of vmlinux is reduced slightly.

Only because you asked a allyesconfig

GFP_DMA is used for less than 0.1 % of kmalloc() calls, for legacy
hardware (from last century)


In fact if you want to reduce even more your vmlinux, you could test

if (__builtin_constant_p(flags) && (flags & SLUB_DMA))
    return kmem_cache_alloc_trace(s, flags, size);

to force the call to out of line code.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

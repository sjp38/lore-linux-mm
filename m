Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5DE6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 08:18:16 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so554829pdi.31
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:18:16 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id x2si1935467pdj.69.2014.11.25.05.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 25 Nov 2014 05:18:14 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFL00EZDJR22N60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 25 Nov 2014 13:21:02 +0000 (GMT)
Message-id: <5474818E.7030704@samsung.com>
Date: Tue, 25 Nov 2014 16:18:06 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v7 08/12] mm: slub: add kernel address sanitizer support
 for slub allocator
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-9-git-send-email-a.ryabinin@samsung.com>
 <CAA6XgkETqmoDFi7Kdi9o3DTE-3=CT5imdCydFjvh83EayHHfpQ@mail.gmail.com>
In-reply-to: 
 <CAA6XgkETqmoDFi7Kdi9o3DTE-3=CT5imdCydFjvh83EayHHfpQ@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Chernenkov <dmitryc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 11/25/2014 03:17 PM, Dmitry Chernenkov wrote:
> FYI, when I backported Kasan to 3.14, in kasan_mark_slab_padding()
> sometimes a negative size of padding was generated.

I don't see how this could happen if pointers passed to kasan_mark_slab_padding() are correct.

Negative padding would mean that (object + s->size) is crossing slab page boundary.
This is either slub allocator bug (very unlikely), or some pointers passed to kasan_mark_slab_padding()
not correct.

Or maybe I'm missing something?

> This started
> working when the patch below was applied:
> 
> @@ -262,12 +264,11 @@ void kasan_free_pages(struct page *page,
> unsigned int order)
>  void kasan_mark_slab_padding(struct kmem_cache *s, void *object,
>   struct page *page)
>  {
> - unsigned long object_end = (unsigned long)object + s->size;
> - unsigned long padding_start = round_up(object_end,
> - KASAN_SHADOW_SCALE_SIZE);
> - unsigned long padding_end = (unsigned long)page_address(page) +
> - (PAGE_SIZE << compound_order(page));
> - size_t size = padding_end - padding_start;
> + unsigned long page_start = (unsigned long) page_address(page);
> + unsigned long page_end = page_start + (PAGE_SIZE << compound_order(page));
> + unsigned long padding_start = round_up(page_end - s->reserved,
> + KASAN_SHADOW_SCALE_SIZE);
> + size_t size = page_end - padding_start;
> 
>   kasan_poison_shadow((void *)padding_start, size, KASAN_SLAB_PADDING);
>  }
> 
> Also, in kasan_slab_free you poison the shadow with FREE not just the
> object space, but also redzones. This is inefficient and will mistake
> right out-of-bounds error for the next object with use-after-free.
> This is fixed here
> https://github.com/google/kasan/commit/4b3238be392ba0bc56bbc934ac545df3ff840782
> , please patch.
> 

Makes sense.


> 
> LGTM
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

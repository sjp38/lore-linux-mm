Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id DB8536B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 11:56:17 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id x3so3948659qcv.27
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 08:56:16 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id x9si6201168qai.121.2014.09.26.08.56.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 08:56:16 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id a108so8823504qge.38
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 08:56:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1409260918460.32028@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-10-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+a0DMk8vyCcesrsKt7rXVDD2LZsfnGemJAgeRiVbMxxxw@mail.gmail.com> <alpine.DEB.2.11.1409260918460.32028@gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Sep 2014 08:55:55 -0700
Message-ID: <CACT4Y+YmZ_G6B4mAx0+K-chcDpNzVtR9mA=b5vam0tXD02-CQA@mail.gmail.com>
Subject: Re: [PATCH v3 09/13] mm: slub: add kernel address sanitizer support
 for slub allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Fri, Sep 26, 2014 at 7:22 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 25 Sep 2014, Dmitry Vyukov wrote:
>
>> > +       depends on SLUB_DEBUG
>>
>>
>> What does SLUB_DEBUG do? I think that generally we don't want any
>> other *heavy* debug checks to be required for kasan.
>
> SLUB_DEBUG includes the capabilties for debugging. It does not switch
> debug on by default. SLUB_DEBUG_ON will results in a kernel that boots
> with active debugging. Without SLUB_DEBUG_ON a kernel parameter activates
> debugging.

Ack
thanks for explanation


>> > +{
>> > +       unsigned long size = cache->size;
>> > +       unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
>> > +
>>
>> Add a comment saying that SLAB_DESTROY_BY_RCU objects can be "legally"
>> used after free.
>
> Add "within the rcu period"
>
>> >  static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>> > @@ -1416,8 +1426,10 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>> >                 setup_object(s, page, p);
>> >                 if (likely(idx < page->objects))
>> >                         set_freepointer(s, p, p + s->size);
>>
>> Sorry, I don't fully follow this code, so I will just ask some questions.
>> Can we have some slab padding after last object in this case as well?
>
> This is the free case. If poisoing is enabled then the object will be
> overwritten on free. Padding is used depending on the need to align the
> object and is optional. Redzoning will occur if requested. Are you asking
> for redzoning?

I am not asking for redzoning yet.


>> kasan_mark_slab_padding poisons only up to end of the page. Can there
>> be multiple pages that we need to poison?
>
> If there is a higher order page then only the end portion needs to be
> poisoned. Objects may straddle order 0 boundaries then.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

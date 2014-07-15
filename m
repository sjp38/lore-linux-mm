Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 626E46B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 10:38:04 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so7461314pab.31
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 07:38:04 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id qj6si11931901pac.52.2014.07.15.07.38.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 07:38:03 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8R00JT3CN7QP50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 15:37:55 +0100 (BST)
Content-transfer-encoding: 8BIT
Message-id: <53C53B77.3080000@samsung.com>
Date: Tue, 15 Jul 2014 18:32:23 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: Re: [RFC/PATCH -next 00/21] Address sanitizer for kernel (kasan) -
 dynamic memory error detector.
References: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com>
 <53C08876.10209@zytor.com>
 <CAPAsAGwb2sLmu0o_o-pFP5pXhMs-1sZSJbA3ji=W+JPOZRepgg@mail.gmail.com>
 <alpine.DEB.2.11.1407141012520.25405@gentwo.org>
In-reply-to: <alpine.DEB.2.11.1407141012520.25405@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/14/14 19:13, Christoph Lameter wrote:
> On Sun, 13 Jul 2014, Andrey Ryabinin wrote:
> 
>>> How does that work when memory is sparsely populated?
>>>
>>
>> Sparsemem configurations currently may not work with kasan.
>> I suppose I will have to move shadow area to vmalloc address space and
>> make it (shadow) sparse too if needed.
> 
> Well it seems to work with sparsemem / vmemmap? So non vmmemmapped configs
> of sparsemem only. vmemmmap can also handle holes in memory.
> 
> 

Not sure. This sparsemem/vmemmap thing is kinda new to me, so I need to dig some more
to understand how it iN?teracts with kasan.

As far as I understand the main problem with sparsemem & kasan is shadow allocation:

	unsigned long lowmem_size = (unsigned long)high_memory - PAGE_OFFSET;
	shadow_size = lowmem_size >> KASAN_SHADOW_SCALE_SHIFT;

	shadow_phys_start = memblock_alloc(shadow_size, PAGE_SIZE);

If we don't have one big enough physically contiguous block for shadow it will fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

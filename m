Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B7BD46B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:08:32 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so4501221pab.26
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:08:32 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id no12si5973367pdb.457.2014.07.15.08.08.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 08:08:31 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8R00M8TE24NF60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 16:08:28 +0100 (BST)
Message-id: <53C542A0.5050107@samsung.com>
Date: Tue, 15 Jul 2014 19:02:56 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 14/21] mm: slub: kasan: disable kasan when
 touching unaccessible memory
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-15-git-send-email-a.ryabinin@samsung.com>
 <20140715060405.GI11317@js1304-P5Q-DELUXE> <53C4DA54.3010502@samsung.com>
 <20140715081852.GL11317@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1407150924320.10593@gentwo.org>
In-reply-to: <alpine.DEB.2.11.1407150924320.10593@gentwo.org>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/15/14 18:26, Christoph Lameter wrote:
> On Tue, 15 Jul 2014, Joonsoo Kim wrote:
> 
>>> I think putting disable/enable only where we strictly need them might be a problem for future maintenance of slub.
>>> If someone is going to add a new function call somewhere, he must ensure that it this call won't be a problem
>>> for kasan.
>>
>> I don't agree with this.
>>
>> If someone is going to add a slab_pad_check() in other places in
>> slub.c, we should disable/enable kasan there, too. This looks same
>> maintenance problem to me. Putting disable/enable only where we
>> strictly need at least ensures that we don't need to care when using
>> slub internal functions.
>>
>> And, if memchr_inv() is problem, I think that you also need to add hook
>> into validate_slab_cache().
>>
>> validate_slab_cache() -> validate_slab_slab() -> validate_slab() ->
>> check_object() -> check_bytes_and_report() -> memchr_inv()
> 
> I think adding disable/enable is good because it separates the payload
> access from metadata accesses. This may be useful for future checkers.
> Maybe call it something different so that this is more generic.
> 
> metadata_access_enable()
> 
> metadata_access_disable()
> 
> ?
> 
It sounds like a good idea to me. However in this patch, besides from protecting metadata accesses,
this calls also used in setup_objects for wrapping ctor call. It used there because all pages in allocate_slab
are poisoned, so at the time when ctors are called all object's memory marked as poisoned.

I think this could be solved by removing kasan_alloc_slab_pages() hook form allocate_slab() and adding
kasan_slab_free() hook after ctor call.
But I guess in that case padding at the end of slab will be unpoisoined.

> Maybe someone else has a better idea?
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

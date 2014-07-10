Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 79FC56B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 03:48:43 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so10376882pdj.36
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:48:43 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id rz10si47917988pbc.56.2014.07.10.00.48.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 00:48:42 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8H00A9WKCZBJ70@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 08:48:35 +0100 (BST)
Message-id: <53BE4412.6030707@samsung.com>
Date: Thu, 10 Jul 2014 11:43:14 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 12/21] mm: util: move krealloc/kzfree to
 slab_common.c
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-13-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.11.1407090931350.1384@gentwo.org>
In-reply-to: <alpine.DEB.2.11.1407090931350.1384@gentwo.org>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/14 18:32, Christoph Lameter wrote:
> On Wed, 9 Jul 2014, Andrey Ryabinin wrote:
> 
>> To avoid false positive reports in kernel address sanitizer krealloc/kzfree
>> functions shouldn't be instrumented. Since we want to instrument other
>> functions in mm/util.c, krealloc/kzfree moved to slab_common.c which is not
>> instrumented.
>>
>> Unfortunately we can't completely disable instrumentation for one function.
>> We could disable compiler's instrumentation for one function by using
>> __atribute__((no_sanitize_address)).
>> But the problem here is that memset call will be replaced by instumented
>> version kasan_memset since currently it's implemented as define:
> 
> Looks good to me and useful regardless of the sanitizer going in.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

I also noticed in mm/util.c:

	/* Tracepoints definitions. */
	EXPORT_TRACEPOINT_SYMBOL(kmalloc);
	EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
	EXPORT_TRACEPOINT_SYMBOL(kmalloc_node);
	EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc_node);
	EXPORT_TRACEPOINT_SYMBOL(kfree);
	EXPORT_TRACEPOINT_SYMBOL(kmem_cache_free);

Should I send another patch to move this to slab_common.c?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

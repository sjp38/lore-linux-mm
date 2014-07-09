Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE726B0037
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 16:37:49 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so9568155pdj.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 13:37:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pk4si46772153pbc.252.2014.07.09.13.37.46
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 13:37:47 -0700 (PDT)
Message-ID: <53BDA80E.9060602@intel.com>
Date: Wed, 09 Jul 2014 13:37:34 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/2014 04:29 AM, Andrey Ryabinin wrote:
> +void __init kasan_alloc_shadow(void)
> +{
> +	unsigned long lowmem_size = (unsigned long)high_memory - PAGE_OFFSET;
> +	unsigned long shadow_size;
> +	phys_addr_t shadow_phys_start;
> +
> +	shadow_size = lowmem_size >> KASAN_SHADOW_SCALE_SHIFT;

This calculation is essentially meaningless, and it's going to break
when we have sparse memory situations like having big holes.  This code
attempts to allocate non-sparse data for backing what might be very
sparse memory ranges.

It's quite OK for us to handle configurations today where we have 2GB of
RAM with 1GB at 0x0 and 1GB at 0x10000000000.  This code would attempt
to allocate a 128GB shadow area for this configuration with 2GB of RAM. :)

You're probably going to get stuck doing something similar to the
sparsemem-vmemmap code does.  You could handle this for normal sparsemem
by adding a shadow area pointer to the memory section.
Or, just vmalloc() (get_vm_area() really) the virtual space and then
make sure to allocate the backing store before you need it (handling the
faults would probably get too tricky).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

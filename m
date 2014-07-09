Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A35B6B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 15:32:52 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so9672509pab.20
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 12:32:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id c6si7695768pdj.314.2014.07.09.12.32.50
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 12:32:50 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH RESEND -next 03/21] x86: add kasan hooks fort memcpy/memmove/memset functions
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-4-git-send-email-a.ryabinin@samsung.com>
Date: Wed, 09 Jul 2014 12:31:58 -0700
In-Reply-To: <1404905415-9046-4-git-send-email-a.ryabinin@samsung.com> (Andrey
	Ryabinin's message of "Wed, 09 Jul 2014 15:29:57 +0400")
Message-ID: <87ion6nxap.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> +
> +#undef memcpy
> +void *kasan_memset(void *ptr, int val, size_t len);
> +void *kasan_memcpy(void *dst, const void *src, size_t len);
> +void *kasan_memmove(void *dst, const void *src, size_t len);
> +
> +#define memcpy(dst, src, len) kasan_memcpy((dst), (src), (len))
> +#define memset(ptr, val, len) kasan_memset((ptr), (val), (len))
> +#define memmove(dst, src, len) kasan_memmove((dst), (src), (len))

I don't think just define is enough, gcc can call these functions
implicitely too (both with and without __). For example for a struct copy.

You need to have true linker level aliases. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

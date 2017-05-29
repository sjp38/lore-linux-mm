Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72AB86B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:49:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i77so12697564wmh.10
        for <linux-mm@kvack.org>; Mon, 29 May 2017 03:49:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g39si10245419wrg.284.2017.05.29.03.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 03:49:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4TAnCRH000444
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:49:24 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2arha4aekw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:49:24 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 29 May 2017 11:49:22 +0100
Date: Mon, 29 May 2017 12:49:16 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 2/7] x86: use long long for 64-bit atomic ops
References: <cover.1495825151.git.dvyukov@google.com>
 <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com>
Message-Id: <20170529104916.GB12975@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, akpm@linux-foundation.org, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, tglx@linutronix.de, hpa@zytor.com, willy@infradead.org, linux-mm@kvack.org

On Fri, May 26, 2017 at 09:09:04PM +0200, Dmitry Vyukov wrote:
> Some 64-bit atomic operations use 'long long' as operand/return type
> (e.g. asm-generic/atomic64.h, arch/x86/include/asm/atomic64_32.h);
> while others use 'long' (e.g. arch/x86/include/asm/atomic64_64.h).
> This makes it impossible to write portable code.
> For example, there is no format specifier that prints result of
> atomic64_read() without warnings. atomic64_try_cmpxchg() is almost
> impossible to use in portable fashion because it requires either
> 'long *' or 'long long *' as argument depending on arch.
> 
> Switch arch/x86/include/asm/atomic64_64.h to 'long long'.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> 
> ---
> Changes since v1:
>  - reverted stray s/long/long long/ replace in comment
>  - added arch/s390 changes to fix build errors/warnings

If you change s390 code, please add the relevant mailing list and/or
maintainers please.

> diff --git a/arch/s390/include/asm/atomic_ops.h b/arch/s390/include/asm/atomic_ops.h
> index ac9e2b939d04..055a9083e52d 100644
> --- a/arch/s390/include/asm/atomic_ops.h
> +++ b/arch/s390/include/asm/atomic_ops.h
> @@ -31,10 +31,10 @@ __ATOMIC_OPS(__atomic_and, int, "lan")
>  __ATOMIC_OPS(__atomic_or,  int, "lao")
>  __ATOMIC_OPS(__atomic_xor, int, "lax")
>  
> -__ATOMIC_OPS(__atomic64_add, long, "laag")
> -__ATOMIC_OPS(__atomic64_and, long, "lang")
> -__ATOMIC_OPS(__atomic64_or,  long, "laog")
> -__ATOMIC_OPS(__atomic64_xor, long, "laxg")
> +__ATOMIC_OPS(__atomic64_add, long long, "laag")
> +__ATOMIC_OPS(__atomic64_and, long long, "lang")
> +__ATOMIC_OPS(__atomic64_or,  long long, "laog")
> +__ATOMIC_OPS(__atomic64_xor, long long, "laxg")
>  
>  #undef __ATOMIC_OPS
>  #undef __ATOMIC_OP
> @@ -46,7 +46,7 @@ static inline void __atomic_add_const(int val, int *ptr)
>  		: [ptr] "+Q" (*ptr) : [val] "i" (val) : "cc");
>  }
>  
> -static inline void __atomic64_add_const(long val, long *ptr)
> +static inline void __atomic64_add_const(long val, long long *ptr)

If you change this then val should be long long (or s64) too.

> -static inline long op_name(long val, long *ptr)				\
> +static inline long op_name(long val, long long *ptr)			\
>  {									\
>  	long old, new;							\

Same here. You only changed the type of *ptr, but left the rest
alone. Everything should have the same type.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

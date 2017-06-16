Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E732683293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:27:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b9so41571656pfl.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:27:47 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0134.outbound.protection.outlook.com. [104.47.0.134])
        by mx.google.com with ESMTPS id r69si2278906pfg.481.2017.06.16.09.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 09:27:47 -0700 (PDT)
Subject: Re: [PATCH v3 7/7] asm-generic, x86: add comments for atomic
 instrumentation
References: <cover.1496743523.git.dvyukov@google.com>
 <658c169bdc4d486b19d161579168a425b064b6f5.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <96e64715-20b7-0aba-6bf8-ede926c804fb@virtuozzo.com>
Date: Fri, 16 Jun 2017 19:29:28 +0300
MIME-Version: 1.0
In-Reply-To: <658c169bdc4d486b19d161579168a425b064b6f5.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> The comments are factored out from the code changes to make them
> easier to read. Add them separately to explain some non-obvious
> aspects.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> ---
>  arch/x86/include/asm/atomic.h             |  7 +++++++
>  include/asm-generic/atomic-instrumented.h | 30 ++++++++++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
> 
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
> index b7900346c77e..8a9e65e585db 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -23,6 +23,13 @@
>   */
>  static __always_inline int arch_atomic_read(const atomic_t *v)
>  {
> +	/*
> +	 * Note: READ_ONCE() here leads to double instrumentation as
> +	 * both READ_ONCE() and atomic_read() contain instrumentation.
> +	 * This is a deliberate choice. READ_ONCE_NOCHECK() is compiled to a
> +	 * non-inlined function call that considerably increases binary size
> +	 * and stack usage under KASAN.
> +	 */


Not sure that this worth commenting. Whoever is looking into arch_atomic_read() internals
probably don't even think about KASAN instrumentation, so I'd remove this comment.


>  	return READ_ONCE((v)->counter);
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

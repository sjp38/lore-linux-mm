Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8F86B03A4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:51:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u36so88364379pgn.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 03:51:00 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a11si7714413pgd.459.2017.06.19.03.50.58
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 03:50:59 -0700 (PDT)
Date: Mon, 19 Jun 2017 11:50:08 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v4 5/7] kasan: allow kasan_check_read/write() to accept
 pointers to volatiles
Message-ID: <20170619105008.GD10246@leverpostej>
References: <cover.1497690003.git.dvyukov@google.com>
 <e5a4c25bda8eccce2317da6d97138bfbea730e64.1497690003.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5a4c25bda8eccce2317da6d97138bfbea730e64.1497690003.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Jun 17, 2017 at 11:15:31AM +0200, Dmitry Vyukov wrote:
> Currently kasan_check_read/write() accept 'const void*', make them
> accept 'const volatile void*'. This is required for instrumentation
> of atomic operations and there is just no reason to not allow that.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> Cc: linux-mm@kvack.org
> Cc: kasan-dev@googlegroups.com

Looks sane to me, and I can confirm this doesn't advervsely affect
arm64. FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> ---
>  include/linux/kasan-checks.h | 10 ++++++----
>  mm/kasan/kasan.c             |  4 ++--
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> index b7f8aced7870..41960fecf783 100644
> --- a/include/linux/kasan-checks.h
> +++ b/include/linux/kasan-checks.h
> @@ -2,11 +2,13 @@
>  #define _LINUX_KASAN_CHECKS_H
>  
>  #ifdef CONFIG_KASAN
> -void kasan_check_read(const void *p, unsigned int size);
> -void kasan_check_write(const void *p, unsigned int size);
> +void kasan_check_read(const volatile void *p, unsigned int size);
> +void kasan_check_write(const volatile void *p, unsigned int size);
>  #else
> -static inline void kasan_check_read(const void *p, unsigned int size) { }
> -static inline void kasan_check_write(const void *p, unsigned int size) { }
> +static inline void kasan_check_read(const volatile void *p, unsigned int size)
> +{ }
> +static inline void kasan_check_write(const volatile void *p, unsigned int size)
> +{ }
>  #endif
>  
>  #endif
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index c81549d5c833..edacd161c0e5 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -333,13 +333,13 @@ static void check_memory_region(unsigned long addr,
>  	check_memory_region_inline(addr, size, write, ret_ip);
>  }
>  
> -void kasan_check_read(const void *p, unsigned int size)
> +void kasan_check_read(const volatile void *p, unsigned int size)
>  {
>  	check_memory_region((unsigned long)p, size, false, _RET_IP_);
>  }
>  EXPORT_SYMBOL(kasan_check_read);
>  
> -void kasan_check_write(const void *p, unsigned int size)
> +void kasan_check_write(const volatile void *p, unsigned int size)
>  {
>  	check_memory_region((unsigned long)p, size, true, _RET_IP_);
>  }
> -- 
> 2.13.1.518.g3df882009-goog
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

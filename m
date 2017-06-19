Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86E8B6B03B9
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:11:43 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 93so78194304oto.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:11:43 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id t125si1746125oib.92.2017.06.19.06.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 06:11:42 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id c189so31072942oia.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:11:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170619105008.GD10246@leverpostej>
References: <cover.1497690003.git.dvyukov@google.com> <e5a4c25bda8eccce2317da6d97138bfbea730e64.1497690003.git.dvyukov@google.com>
 <20170619105008.GD10246@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 19 Jun 2017 15:11:21 +0200
Message-ID: <CACT4Y+Zc1EzTLq+cAf2hg8s4CynJdWVc_9sOROkRs9+XU3AXPg@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] kasan: allow kasan_check_read/write() to accept
 pointers to volatiles
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 19, 2017 at 12:50 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Sat, Jun 17, 2017 at 11:15:31AM +0200, Dmitry Vyukov wrote:
>> Currently kasan_check_read/write() accept 'const void*', make them
>> accept 'const volatile void*'. This is required for instrumentation
>> of atomic operations and there is just no reason to not allow that.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: linux-kernel@vger.kernel.org
>> Cc: x86@kernel.org
>> Cc: linux-mm@kvack.org
>> Cc: kasan-dev@googlegroups.com
>
> Looks sane to me, and I can confirm this doesn't advervsely affect
> arm64. FWIW:
>
> Acked-by: Mark Rutland <mark.rutland@arm.com>
>
> Mark.


Great! Thanks for testing.

Ingo, what are your thoughts? Are you taking this to locking tree? When?



>> ---
>>  include/linux/kasan-checks.h | 10 ++++++----
>>  mm/kasan/kasan.c             |  4 ++--
>>  2 files changed, 8 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
>> index b7f8aced7870..41960fecf783 100644
>> --- a/include/linux/kasan-checks.h
>> +++ b/include/linux/kasan-checks.h
>> @@ -2,11 +2,13 @@
>>  #define _LINUX_KASAN_CHECKS_H
>>
>>  #ifdef CONFIG_KASAN
>> -void kasan_check_read(const void *p, unsigned int size);
>> -void kasan_check_write(const void *p, unsigned int size);
>> +void kasan_check_read(const volatile void *p, unsigned int size);
>> +void kasan_check_write(const volatile void *p, unsigned int size);
>>  #else
>> -static inline void kasan_check_read(const void *p, unsigned int size) { }
>> -static inline void kasan_check_write(const void *p, unsigned int size) { }
>> +static inline void kasan_check_read(const volatile void *p, unsigned int size)
>> +{ }
>> +static inline void kasan_check_write(const volatile void *p, unsigned int size)
>> +{ }
>>  #endif
>>
>>  #endif
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index c81549d5c833..edacd161c0e5 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -333,13 +333,13 @@ static void check_memory_region(unsigned long addr,
>>       check_memory_region_inline(addr, size, write, ret_ip);
>>  }
>>
>> -void kasan_check_read(const void *p, unsigned int size)
>> +void kasan_check_read(const volatile void *p, unsigned int size)
>>  {
>>       check_memory_region((unsigned long)p, size, false, _RET_IP_);
>>  }
>>  EXPORT_SYMBOL(kasan_check_read);
>>
>> -void kasan_check_write(const void *p, unsigned int size)
>> +void kasan_check_write(const volatile void *p, unsigned int size)
>>  {
>>       check_memory_region((unsigned long)p, size, true, _RET_IP_);
>>  }
>> --
>> 2.13.1.518.g3df882009-goog
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

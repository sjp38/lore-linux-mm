Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id F11DF6B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 06:59:10 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 36so12187333otx.0
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:59:10 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id y60si9378713otb.10.2017.02.02.03.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 03:59:10 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id f9so1525559otd.0
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:59:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLc8z0Q-etB-=9rBnt-mNPKEL3t5rDooSwTyACPX2NW0g@mail.gmail.com>
References: <20170201161311.2050831-1-arnd@arndb.de> <CAGXu5jLc8z0Q-etB-=9rBnt-mNPKEL3t5rDooSwTyACPX2NW0g@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 2 Feb 2017 12:59:09 +0100
Message-ID: <CAK8P3a2Qmc0H5sE2w106We1P=OpQ_CRQ-A8b+2rZR7Zb5C40fw@mail.gmail.com>
Subject: Re: [PATCH] initity: try to improve __nocapture annotations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: PaX Team <pageexec@freemail.hu>, Emese Revfy <re.emese@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Josh Triplett <josh@joshtriplett.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, minipli@ld-linux.so, Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jlayton@poochiereds.net>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, devel@acpica.org, linux-arch <linux-arch@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Feb 2, 2017 at 1:39 AM, Kees Cook <keescook@chromium.org> wrote:
> On Wed, Feb 1, 2017 at 8:11 AM, Arnd Bergmann <arnd@arndb.de> wrote:

>> -void ACPI_INTERNAL_VAR_XFACE
>> +void __unverified_nocapture(3) ACPI_INTERNAL_VAR_XFACE
>>  acpi_debug_print(u32 requested_debug_level,
>>                  u32 line_number,
>>                  const char *function_name,
>
> This might be better by marking acpi_ut_trim_function_name() as
> __nocapture. I'll give it a try...

I tried that without success: the problem is actually the later acpi_os_printf()
that takes the result from acpi_ut_trim_function_name().

>> diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
>> index 9f4637e9dd92..9644cec5b082 100644
>> --- a/include/acpi/acpixf.h
>> +++ b/include/acpi/acpixf.h
>> @@ -946,7 +946,7 @@ ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6) __nocapture(3)
>>                                                 const char *module_name,
>>                                                 u32 component_id,
>>                                                 const char *format, ...))
>> -ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6)
>> +ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6) __nocapture(3)
>>                                 void ACPI_INTERNAL_VAR_XFACE
>>                                 acpi_debug_print_raw(u32 requested_debug_level,
>>                                                      u32 line_number,
>
> I wonder why the plugin needs this at all: function_name (the third
> arg) isn't even used in the function.

This one wasn't needed, I should probably have left it out. It just seemed
right for consistency to do the same for acpi_debug_print_raw() and
acpi_debug_print().

>> diff --git a/include/linux/string.h b/include/linux/string.h
>> index 8b3b97e7b2b0..0ee877593464 100644
>> --- a/include/linux/string.h
>> +++ b/include/linux/string.h
>> @@ -76,7 +76,7 @@ static inline __must_check char *strstrip(char *str)
>>  extern char * strstr(const char *, const char *) __nocapture(-1, 2);
>>  #endif
>>  #ifndef __HAVE_ARCH_STRNSTR
>> -extern char * strnstr(const char *, const char *, size_t) __nocapture(-1, 2);
>> +extern char * strnstr(const char *, const char *, size_t);
>
> That doesn't seem right: strnstr doesn't capture...

Right, so better __unverified_nocapture() then?

>>  #endif
>>  #ifndef __HAVE_ARCH_STRLEN
>>  extern __kernel_size_t strlen(const char *) __nocapture(1);
>> diff --git a/lib/string.c b/lib/string.c
>> index ed83562a53ae..01151a1a0b61 100644
>> --- a/lib/string.c
>> +++ b/lib/string.c
>> @@ -870,7 +870,7 @@ void *memchr(const void *s, int c, size_t n)
>>  EXPORT_SYMBOL(memchr);
>>  #endif
>>
>> -static void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)
>> +static __always_inline void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)
>
> Is this from another fix? Seems unrelated?

This fixed a warning about memchr_inv() for me: when check_bytes8()
is inlined, the compiler can see that the argument is not captured, but
if gcc decides against inlining, it warns.

>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 5f6e09c88d25..ebc02ee1118e 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -343,7 +343,7 @@ void *memset(void *addr, int c, size_t len)
>>  }
>>
>>  #undef memmove
>> -void *memmove(void *dest, const void *src, size_t len)
>> +__unverified_nocapture(2) void *memmove(void *dest, const void *src, size_t len)
>>  {
>>         check_memory_region((unsigned long)src, len, false, _RET_IP_);
>>         check_memory_region((unsigned long)dest, len, true, _RET_IP_);
>> @@ -352,7 +352,7 @@ void *memmove(void *dest, const void *src, size_t len)
>>  }
>>
>>  #undef memcpy
>> -void *memcpy(void *dest, const void *src, size_t len)
>> +__unverified_nocapture(2) void *memcpy(void *dest, const void *src, size_t len)
>>  {
>>         check_memory_region((unsigned long)src, len, false, _RET_IP_);
>>         check_memory_region((unsigned long)dest, len, true, _RET_IP_);
>> --
>> 2.9.0
>>
>
> Thanks for the patch! I'll try to reproduce the warnings and get some
> fixes built if Emese or PaX Team don't beat me to it. :)

I later got more warnings for some of the string functions, but we can
deal with them
separately.

    Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

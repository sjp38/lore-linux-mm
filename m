Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1B166B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 17:44:49 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o185so39270019itb.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 14:44:49 -0800 (PST)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id c4si13615331iti.91.2017.02.01.14.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 14:44:49 -0800 (PST)
Received: by mail-it0-x22f.google.com with SMTP id 203so27828118ith.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 14:44:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0ioJO1HU6yRpuX70hVQB-P9Sx1SkyRiH+hL0mw0_qX3MQ@mail.gmail.com>
References: <20170201161311.2050831-1-arnd@arndb.de> <CAJZ5v0ioJO1HU6yRpuX70hVQB-P9Sx1SkyRiH+hL0mw0_qX3MQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 1 Feb 2017 14:44:48 -0800
Message-ID: <CAGXu5jKsENwq2nb0sw4R80yqPZ6HK_4QCFeGv1=H-Lgbsuhzbg@mail.gmail.com>
Subject: Re: [PATCH] initity: try to improve __nocapture annotations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, PaX Team <pageexec@freemail.hu>, Emese Revfy <re.emese@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Josh Triplett <josh@joshtriplett.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, minipli@ld-linux.so, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jlayton@poochiereds.net>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "devel@acpica.org" <devel@acpica.org>, linux-arch <linux-arch@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Feb 1, 2017 at 1:05 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
> On Wed, Feb 1, 2017 at 5:11 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> There are some additional declarations that got missed in the original patch,
>> and some annotated functions that use the pointer is a correct but nonobvious
>> way:
>>
>> mm/kasan/kasan.c: In function 'memmove':
>> mm/kasan/kasan.c:346:7: error: 'memmove' captures its 2 ('src') parameter, please remove it from the nocapture attribute. [-Werror]
>>  void *memmove(void *dest, const void *src, size_t len)
>>        ^~~~~~~
>> mm/kasan/kasan.c: In function 'memcpy':
>> mm/kasan/kasan.c:355:7: error: 'memcpy' captures its 2 ('src') parameter, please remove it from the nocapture attribute. [-Werror]
>>  void *memcpy(void *dest, const void *src, size_t len)
>>        ^~~~~~
>> drivers/acpi/acpica/utdebug.c: In function 'acpi_debug_print':
>> drivers/acpi/acpica/utdebug.c:158:1: error: 'acpi_debug_print' captures its 3 ('function_name') parameter, please remove it from the nocapture attribute. [-Werror]
>>
>> lib/string.c:893:7: error: 'memchr_inv' captures its 1 ('start') parameter, please remove it from the nocapture attribute. [-Werror]
>>  void *memchr_inv(const void *start, int c, size_t bytes)
>> lib/string.c: In function 'strnstr':
>> lib/string.c:832:7: error: 'strnstr' captures its 1 ('s1') parameter, please remove it from the nocapture attribute. [-Werror]
>>  char *strnstr(const char *s1, const char *s2, size_t len)
>>        ^~~~~~~
>> lib/string.c:832:7: error: 'strnstr' captures its 2 ('s2') parameter, please remove it from the nocapture attribute. [-Werror]
>>
>> I'm not sure if these are all appropriate fixes, please have a careful look
>>
>> Fixes: c2bc07665495 ("initify: Mark functions with the __nocapture attribute")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  drivers/acpi/acpica/utdebug.c        | 2 +-
>>  include/acpi/acpixf.h                | 2 +-
>>  include/asm-generic/asm-prototypes.h | 8 ++++----
>>  include/linux/string.h               | 2 +-
>>  lib/string.c                         | 2 +-
>>  mm/kasan/kasan.c                     | 4 ++--
>>  6 files changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/acpi/acpica/utdebug.c b/drivers/acpi/acpica/utdebug.c
>> index 044df9b0356e..de3c9cb305a2 100644
>> --- a/drivers/acpi/acpica/utdebug.c
>> +++ b/drivers/acpi/acpica/utdebug.c
>> @@ -154,7 +154,7 @@ static const char *acpi_ut_trim_function_name(const char *function_name)
>>   *
>>   ******************************************************************************/
>>
>> -void ACPI_INTERNAL_VAR_XFACE
>> +void __unverified_nocapture(3) ACPI_INTERNAL_VAR_XFACE
>
> Generally speaking, there is a problem with adding annotations like
> this to ACPICA code.
>
> We get that code from an external project (upstream ACPICA) and the
> more Linux-specific stuff is there in it, the more difficult to
> maintain it becomes.

We need to find a way to solve this. Why can't take take our changes?
Or better yet, why can't we keep a delta from them if they won't take
them?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDD4C6B026E
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 19:33:44 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w185so41871918ita.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:33:44 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id j68si13773954itb.14.2017.02.01.16.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 16:33:44 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id v96so74144775ioi.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:33:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0gy8UfcERZ1BOL2YTRDtKLPswJT0exH6J6UEQxDoQ9RHw@mail.gmail.com>
References: <20170201161311.2050831-1-arnd@arndb.de> <CAJZ5v0ioJO1HU6yRpuX70hVQB-P9Sx1SkyRiH+hL0mw0_qX3MQ@mail.gmail.com>
 <CAGXu5jKsENwq2nb0sw4R80yqPZ6HK_4QCFeGv1=H-Lgbsuhzbg@mail.gmail.com> <CAJZ5v0gy8UfcERZ1BOL2YTRDtKLPswJT0exH6J6UEQxDoQ9RHw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 1 Feb 2017 16:33:42 -0800
Message-ID: <CAGXu5j+gNAb8R2yq1ieGENMaVknjykgrLi-+hfNs-482OpYfHA@mail.gmail.com>
Subject: Re: [PATCH] initity: try to improve __nocapture annotations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, PaX Team <pageexec@freemail.hu>, Emese Revfy <re.emese@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Josh Triplett <josh@joshtriplett.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, minipli@ld-linux.so, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jlayton@poochiereds.net>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "devel@acpica.org" <devel@acpica.org>, linux-arch <linux-arch@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Feb 1, 2017 at 3:38 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
> On Wed, Feb 1, 2017 at 11:44 PM, Kees Cook <keescook@chromium.org> wrote:
>> On Wed, Feb 1, 2017 at 1:05 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
>>> On Wed, Feb 1, 2017 at 5:11 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>>> diff --git a/drivers/acpi/acpica/utdebug.c b/drivers/acpi/acpica/utdebug.c
>>>> index 044df9b0356e..de3c9cb305a2 100644
>>>> --- a/drivers/acpi/acpica/utdebug.c
>>>> +++ b/drivers/acpi/acpica/utdebug.c
>>>> @@ -154,7 +154,7 @@ static const char *acpi_ut_trim_function_name(const char *function_name)
>>>>   *
>>>>   ******************************************************************************/
>>>>
>>>> -void ACPI_INTERNAL_VAR_XFACE
>>>> +void __unverified_nocapture(3) ACPI_INTERNAL_VAR_XFACE
>>>
>>> Generally speaking, there is a problem with adding annotations like
>>> this to ACPICA code.
>>>
>>> We get that code from an external project (upstream ACPICA) and the
>>> more Linux-specific stuff is there in it, the more difficult to
>>> maintain it becomes.
>>
>> We need to find a way to solve this. Why can't take take our changes?
>
> Basically because it has to be possible to build their code using
> other compilers and build environments (some of them sort of exotic).

Surely those environments can support macros to make this all work sanely?

>> Or better yet, why can't we keep a delta from them if they won't take them?
>
> The coding style of the original code is different from the kernel one
> and the process used to keep track of the differences is non-trivial.
> The more differences there are, the more difficult it becomes to
> generate patches to backport upstream changes to the kernel code base
> and the more likely it is to introduce bugs in the process which sort
> of would defeat the purpose of the whole hardening exercise.
>
> Let me reverse the question, then: Why is it necessary to annotate the
> ACPICA code this way instead of just leaving it alone?

With the GCC plugins there are going to be more and more automatic
analysis of the kernel code base, and it'll require global changes to
the kernel to mark things one way or another, opt in or out of things,
etc. We need to be able to treat the kernel code as a single code
base, since that's how the plugins see it. Without this, we're
restricting the value those plugins bring.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

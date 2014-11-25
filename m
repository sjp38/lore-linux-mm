Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id A724E6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:47:49 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id vb8so211030obc.28
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 02:47:49 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id m1si597695oig.46.2014.11.25.02.47.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 02:47:48 -0800 (PST)
Received: by mail-oi0-f50.google.com with SMTP id a141so196293oig.37
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 02:47:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGyBRKnCfAZTaDNKG8Qa3NyT6B4vsDZNvrXixr7SUuWknw@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-4-git-send-email-a.ryabinin@samsung.com>
 <54737CD7.7080908@oracle.com> <CAPAsAGyBRKnCfAZTaDNKG8Qa3NyT6B4vsDZNvrXixr7SUuWknw@mail.gmail.com>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 25 Nov 2014 14:47:27 +0400
Message-ID: <CAA6XgkEvf+Y+6PybQRCWn96G36D-Sj36UKspAAi4YCDgCZP-Gw@mail.gmail.com>
Subject: Re: [PATCH v7 03/12] x86_64: add KASan support
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

LGTM.

Also, please send a pull request to google/kasan whenever you're ready
(for the whole bulk of changes).



On Tue, Nov 25, 2014 at 12:26 AM, Andrey Ryabinin
<ryabinin.a.a@gmail.com> wrote:
> 2014-11-24 21:45 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
>> On 11/24/2014 01:02 PM, Andrey Ryabinin wrote:
>>> +static int kasan_die_handler(struct notifier_block *self,
>>> +                          unsigned long val,
>>> +                          void *data)
>>> +{
>>> +     if (val =3D=3D DIE_GPF) {
>>> +             pr_emerg("CONFIG_KASAN_INLINE enabled\n");
>>> +             pr_emerg("GPF could be caused by NULL-ptr deref or user m=
emory access\n");
>>> +     }
>>> +     return NOTIFY_OK;
>>> +}
>>> +
>>> +static struct notifier_block kasan_die_notifier =3D {
>>> +     .notifier_call =3D kasan_die_handler,
>>> +};
>>
>> This part fails to compile:
>>
>>   CC      arch/x86/mm/kasan_init_64.o
>> arch/x86/mm/kasan_init_64.c: In function =E2=80=98kasan_die_handler=E2=
=80=99:
>> arch/x86/mm/kasan_init_64.c:72:13: error: =E2=80=98DIE_GPF=E2=80=99 unde=
clared (first use in this function)
>>   if (val =3D=3D DIE_GPF) {
>>              ^
>> arch/x86/mm/kasan_init_64.c:72:13: note: each undeclared identifier is r=
eported only once for each function it appears in
>> arch/x86/mm/kasan_init_64.c: In function =E2=80=98kasan_init=E2=80=99:
>> arch/x86/mm/kasan_init_64.c:89:2: error: implicit declaration of functio=
n =E2=80=98register_die_notifier=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
>>   register_die_notifier(&kasan_die_notifier);
>>   ^
>> cc1: some warnings being treated as errors
>> make[1]: *** [arch/x86/mm/kasan_init_64.o] Error 1
>>
>>
>> Simple fix:
>>
>
> Thanks, I thought I've fixed this, but apparently I forgot to commit it.
>
>
>> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>> index 70041fd..c8f7f3e 100644
>> --- a/arch/x86/mm/kasan_init_64.c
>> +++ b/arch/x86/mm/kasan_init_64.c
>> @@ -5,6 +5,7 @@
>>  #include <linux/vmalloc.h>
>>
>>  #include <asm/tlbflush.h>
>> +#include <linux/kdebug.h>
>>
>>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>>  extern struct range pfn_mapped[E820_X_MAX];
>>
>>
>> Thanks,
>> Sasha
>>
>
> --
> Best regards,
> Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

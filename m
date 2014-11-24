Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6E34A6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:26:50 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so10300211pac.11
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:26:50 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id bc14si23216738pdb.238.2014.11.24.13.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:26:49 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10315743pab.28
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:26:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54737CD7.7080908@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1416852146-9781-1-git-send-email-a.ryabinin@samsung.com>
	<1416852146-9781-4-git-send-email-a.ryabinin@samsung.com>
	<54737CD7.7080908@oracle.com>
Date: Tue, 25 Nov 2014 01:26:48 +0400
Message-ID: <CAPAsAGyBRKnCfAZTaDNKG8Qa3NyT6B4vsDZNvrXixr7SUuWknw@mail.gmail.com>
Subject: Re: [PATCH v7 03/12] x86_64: add KASan support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

2014-11-24 21:45 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
> On 11/24/2014 01:02 PM, Andrey Ryabinin wrote:
>> +static int kasan_die_handler(struct notifier_block *self,
>> +                          unsigned long val,
>> +                          void *data)
>> +{
>> +     if (val =3D=3D DIE_GPF) {
>> +             pr_emerg("CONFIG_KASAN_INLINE enabled\n");
>> +             pr_emerg("GPF could be caused by NULL-ptr deref or user me=
mory access\n");
>> +     }
>> +     return NOTIFY_OK;
>> +}
>> +
>> +static struct notifier_block kasan_die_notifier =3D {
>> +     .notifier_call =3D kasan_die_handler,
>> +};
>
> This part fails to compile:
>
>   CC      arch/x86/mm/kasan_init_64.o
> arch/x86/mm/kasan_init_64.c: In function =E2=80=98kasan_die_handler=E2=80=
=99:
> arch/x86/mm/kasan_init_64.c:72:13: error: =E2=80=98DIE_GPF=E2=80=99 undec=
lared (first use in this function)
>   if (val =3D=3D DIE_GPF) {
>              ^
> arch/x86/mm/kasan_init_64.c:72:13: note: each undeclared identifier is re=
ported only once for each function it appears in
> arch/x86/mm/kasan_init_64.c: In function =E2=80=98kasan_init=E2=80=99:
> arch/x86/mm/kasan_init_64.c:89:2: error: implicit declaration of function=
 =E2=80=98register_die_notifier=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
>   register_die_notifier(&kasan_die_notifier);
>   ^
> cc1: some warnings being treated as errors
> make[1]: *** [arch/x86/mm/kasan_init_64.o] Error 1
>
>
> Simple fix:
>

Thanks, I thought I've fixed this, but apparently I forgot to commit it.


> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 70041fd..c8f7f3e 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -5,6 +5,7 @@
>  #include <linux/vmalloc.h>
>
>  #include <asm/tlbflush.h>
> +#include <linux/kdebug.h>
>
>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>  extern struct range pfn_mapped[E820_X_MAX];
>
>
> Thanks,
> Sasha
>

--=20
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D34FA6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 07:50:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so69277644pfy.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 04:50:28 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0112.outbound.protection.outlook.com. [104.47.0.112])
        by mx.google.com with ESMTPS id m10si30745033paz.6.2016.11.08.04.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 04:50:28 -0800 (PST)
Subject: Re: [PATCHv3 0/8] powerpc/mm: refactor vDSO mapping code
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
 <CAJwJo6b16mt0N_xJeeQ0EikyPhoo-UvAx-FaXO9hGzwW=o+s5Q@mail.gmail.com>
 <87pom6lu6a.fsf@concordia.ellerman.id.au>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <97bc21c0-d7b7-d771-3f2b-1d7a862a2eee@virtuozzo.com>
Date: Tue, 8 Nov 2016 15:47:22 +0300
MIME-Version: 1.0
In-Reply-To: <87pom6lu6a.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Dmitry Safonov <0x7f454c46@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>

On 11/08/2016 02:57 AM, Michael Ellerman wrote:
> Dmitry Safonov <0x7f454c46@gmail.com> writes:
>
>> 2016-10-27 20:09 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
>>
>> ping?
>
> There's another series doing some similar changes:
>
> http://www.spinics.net/lists/linux-mm/msg115860.html

Well, that version makes arch_mremap hook more general with renaming
vdso pointer. While this series erases that hook totaly.
So, we've agreed that it would be better without this hook, but with
generic version of vdso_mremap special_mapping helper:
https://marc.info/?i=d1aa8bec-a53e-cd30-e66a-39bebb6a400a@codeaurora.org

> And I don't like all the macro games in 3/8, eg:
>
> +#ifndef BITS
> +#define BITS 32
> +#endif
> +
> +#undef Elf_Ehdr
> +#undef Elf_Sym
> +#undef Elf_Shdr
> +
> +#define _CONCAT3(a, b, c)	a ## b ## c
> +#define CONCAT3(a, b, c)	_CONCAT3(a, b, c)
> +#define Elf_Ehdr	CONCAT3(Elf,  BITS, _Ehdr)
> +#define Elf_Sym		CONCAT3(Elf,  BITS, _Sym)
> +#define Elf_Shdr	CONCAT3(Elf,  BITS, _Shdr)
> +#define VDSO_LBASE	CONCAT3(VDSO, BITS, _LBASE)
> +#define vdso_kbase	CONCAT3(vdso, BITS, _kbase)
> +#define vdso_pages	CONCAT3(vdso, BITS, _pages)
> +
> +#undef pr_fmt
> +#define pr_fmt(fmt)	"vDSO" __stringify(BITS) ": " fmt
> +
> +#define lib_elfinfo CONCAT3(lib, BITS, _elfinfo)
> +
> +#define find_section CONCAT3(find_section, BITS,)
> +static void * __init find_section(Elf_Ehdr *ehdr, const char *secname,
> +		unsigned long *size)
>
>
> I'd rather we kept the duplication of code than the obfuscation those
> macros add.
>
> If we can come up with a way to share more of the code without having to
> do all those tricks then I'd be interested.

Well, ok, I thought it's quite common even outside of tracing:
e.g, fs/compat_binfmt_elf.c does quite the same trick.
But as you find it obscured - than ok, I will resend without that
common-vdso part.

>
> cheers
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 406C96B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 16:29:16 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so13188406wjy.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 13:29:16 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id d14si3664223wra.226.2017.02.10.13.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 13:29:15 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id k90so16321199wrc.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 13:29:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1702102057330.4042@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-2-dsafonov@virtuozzo.com>
 <20170209135525.qlwrmlo7njk3fsaq@pd.tnic> <alpine.DEB.2.20.1702102057330.4042@nanos>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Sat, 11 Feb 2017 00:28:54 +0300
Message-ID: <CAJwJo6b5oSbcDjE+L=wwS_cdYnimAR+mD5BTyuHQtb8zUQX4fA@mail.gmail.com>
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native versions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Borislav Petkov <bp@alien8.de>, Dmitry Safonov <dsafonov@virtuozzo.com>, open list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, linux-mm@kvack.org

2017-02-10 23:10 GMT+03:00 Thomas Gleixner <tglx@linutronix.de>:
> On Thu, 9 Feb 2017, Borislav Petkov wrote:
>> I can't say that I'm thrilled about the ifdeffery this is adding.
>>
>> But I can't think of a cleaner approach at a quick glance, though -
>> that's generic and arch-specific code intertwined muck. Sad face.
>
> It's trivial enough to do ....
>
> Thanks,
>
>         tglx
>
> ---
>  arch/x86/mm/mmap.c |   22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
>
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -55,6 +55,10 @@ static unsigned long stack_maxrandom_siz
>  #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
>  #define MAX_GAP (TASK_SIZE/6*5)
>
> +#ifndef CONFIG_COMPAT
> +# define mmap_rnd_compat_bits  mmap_rnd_bits
> +#endif
> +

>From my POV, I can't say that it's clearer to shadow mmap_compat_bits
like that then to have two functions with native/compat names.
But if you insist, I'll resend patches set with your version.

>  static int mmap_is_legacy(void)
>  {
>         if (current->personality & ADDR_COMPAT_LAYOUT)
> @@ -66,20 +70,14 @@ static int mmap_is_legacy(void)
>         return sysctl_legacy_va_layout;
>  }
>
> -unsigned long arch_mmap_rnd(void)
> +static unsigned long arch_rnd(unsigned int rndbits)
>  {
> -       unsigned long rnd;
> -
> -       if (mmap_is_ia32())
> -#ifdef CONFIG_COMPAT
> -               rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> -#else
> -               rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> -#endif
> -       else
> -               rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> +       return (get_random_long() & ((1UL << rndbits) - 1)) << PAGE_SHIFT;
> +}
>
> -       return rnd << PAGE_SHIFT;
> +unsigned long arch_mmap_rnd(void)
> +{
> +       return arch_rnd(mmap_is_ia32() ? mmap_rnd_compat_bits : mmap_rnd_bits);
>  }
>
>  static unsigned long mmap_base(unsigned long rnd)

-- 
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

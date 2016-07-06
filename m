Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3980C828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:22:18 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v18so528119657qtv.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:22:18 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id y20si936859vkd.80.2016.07.06.07.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:22:17 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id b192so6917895vke.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:22:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629105736.15017-3-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-3-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:21:57 -0700
Message-ID: <CALCETrXUvxx_BLqUxwz0ENNeaCbS5zLqxsSE1+Ts03mTyQWZjw@mail.gmail.com>
Subject: Re: [PATCHv2 2/6] x86/vdso: introduce do_map_vdso() and vdso_type enum
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Make in-kernel API to map vDSO blobs on x86.

I think the addr calculation was already confusing and is now even
worse.  How about simplifying it?  Get rid of calculate_addr entirely
and push the vdso_addr calls into arch_setup_additional_pages, etc.
Then just use addr directly in the map_vdso code.

> +int do_map_vdso(vdso_type type, unsigned long addr, bool randomize_addr)
>  {
> -       if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
> -               return 0;
> -
> -       return map_vdso(&vdso_image_32, false);
> -}
> +       switch (type) {
> +#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
> +       case VDSO_32:
> +               if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
> +                       return 0;
> +               /* vDSO aslr turned off for i386 vDSO */
> +               return map_vdso(&vdso_image_32, addr, false);
> +#endif
> +#ifdef CONFIG_X86_64
> +       case VDSO_64:
> +               if (!vdso64_enabled)
> +                       return 0;
> +               return map_vdso(&vdso_image_64, addr, randomize_addr);
> +#endif
> +#ifdef CONFIG_X86_X32_ABI
> +       case VDSO_X32:
> +               if (!vdso64_enabled)
> +                       return 0;
> +               return map_vdso(&vdso_image_x32, addr, randomize_addr);
>  #endif
> +       default:
> +               return -EINVAL;
> +       }
> +}

Why is this better than just passing the vdso_image pointer in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

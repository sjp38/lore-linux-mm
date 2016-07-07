Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7C856B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:05:48 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id gv4so27307501obc.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:05:48 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0135.outbound.protection.outlook.com. [104.47.1.135])
        by mx.google.com with ESMTPS id g133si3257216itg.61.2016.07.07.04.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:05:47 -0700 (PDT)
Subject: Re: [PATCHv2 2/6] x86/vdso: introduce do_map_vdso() and vdso_type
 enum
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-3-dsafonov@virtuozzo.com>
 <CALCETrXUvxx_BLqUxwz0ENNeaCbS5zLqxsSE1+Ts03mTyQWZjw@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <23274480-7eec-f5da-8eb3-301ed7882a9f@virtuozzo.com>
Date: Thu, 7 Jul 2016 14:04:35 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrXUvxx_BLqUxwz0ENNeaCbS5zLqxsSE1+Ts03mTyQWZjw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On 07/06/2016 05:21 PM, Andy Lutomirski wrote:
> On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Make in-kernel API to map vDSO blobs on x86.
>
> I think the addr calculation was already confusing and is now even
> worse.  How about simplifying it?  Get rid of calculate_addr entirely
> and push the vdso_addr calls into arch_setup_additional_pages, etc.
> Then just use addr directly in the map_vdso code.

Thanks, will do.

>> +int do_map_vdso(vdso_type type, unsigned long addr, bool randomize_addr)
>>  {
>> -       if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
>> -               return 0;
>> -
>> -       return map_vdso(&vdso_image_32, false);
>> -}
>> +       switch (type) {
>> +#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
>> +       case VDSO_32:
>> +               if (vdso32_enabled != 1)  /* Other values all mean "disabled" */
>> +                       return 0;
>> +               /* vDSO aslr turned off for i386 vDSO */
>> +               return map_vdso(&vdso_image_32, addr, false);
>> +#endif
>> +#ifdef CONFIG_X86_64
>> +       case VDSO_64:
>> +               if (!vdso64_enabled)
>> +                       return 0;
>> +               return map_vdso(&vdso_image_64, addr, randomize_addr);
>> +#endif
>> +#ifdef CONFIG_X86_X32_ABI
>> +       case VDSO_X32:
>> +               if (!vdso64_enabled)
>> +                       return 0;
>> +               return map_vdso(&vdso_image_x32, addr, randomize_addr);
>>  #endif
>> +       default:
>> +               return -EINVAL;
>> +       }
>> +}
>
> Why is this better than just passing the vdso_image pointer in?

Hmm, then all callers should be under the same ifdefs as vdso_image
blobs. Ok, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

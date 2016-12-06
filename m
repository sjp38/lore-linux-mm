Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD516B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 15:10:52 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m203so259889858iom.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 12:10:52 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id v63si14994421iof.137.2016.12.06.12.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 12:10:52 -0800 (PST)
Received: by mail-io0-x22b.google.com with SMTP id l140so58488553iol.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 12:10:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161206181859.GH24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-10-git-send-email-labbott@redhat.com> <CAGXu5jKrBc6R9JYay1L6pd958Vm5-6p=37tiUYgg6uPeZb1HtQ@mail.gmail.com>
 <20161206181859.GH24177@leverpostej>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 6 Dec 2016 12:10:50 -0800
Message-ID: <CAGXu5jKTdZUbbHU91mbN+Qy80AGXRhpzdLNXr3oxxZyxAzmjmQ@mail.gmail.com>
Subject: Re: [PATCHv4 09/10] mm/usercopy: Switch to using lm_alias
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Dec 6, 2016 at 10:18 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Nov 29, 2016 at 11:39:44AM -0800, Kees Cook wrote:
>> On Tue, Nov 29, 2016 at 10:55 AM, Laura Abbott <labbott@redhat.com> wrote:
>> >
>> > The usercopy checking code currently calls __va(__pa(...)) to check for
>> > aliases on symbols. Switch to using lm_alias instead.
>> >
>> > Signed-off-by: Laura Abbott <labbott@redhat.com>
>>
>> Acked-by: Kees Cook <keescook@chromium.org>
>>
>> I should probably add a corresponding alias test to lkdtm...
>>
>> -Kees
>
> Something like the below?
>
> It uses lm_alias(), so it depends on Laura's patches. We seem to do the
> right thing, anyhow:

Cool, this looks good. What happens on systems without an alias?

Laura, feel free to add this to your series:

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> root@ribbensteg:/home/nanook# echo USERCOPY_KERNEL_ALIAS > /sys/kernel/debug/provoke-crash/DIRECT
> [   44.493400] usercopy: kernel memory exposure attempt detected from ffff80000031a730 (<linear kernel text>) (4096 bytes)
> [   44.504263] kernel BUG at mm/usercopy.c:75!
>
> Thanks,
> Mark.
>
> ---->8----
> diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
> index fdf954c..96d8d76 100644
> --- a/drivers/misc/lkdtm.h
> +++ b/drivers/misc/lkdtm.h
> @@ -56,5 +56,6 @@
>  void lkdtm_USERCOPY_STACK_FRAME_FROM(void);
>  void lkdtm_USERCOPY_STACK_BEYOND(void);
>  void lkdtm_USERCOPY_KERNEL(void);
> +void lkdtm_USERCOPY_KERNEL_ALIAS(void);
>
>  #endif
> diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
> index f9154b8..f6bc6d6 100644
> --- a/drivers/misc/lkdtm_core.c
> +++ b/drivers/misc/lkdtm_core.c
> @@ -228,6 +228,7 @@ struct crashtype crashtypes[] = {
>         CRASHTYPE(USERCOPY_STACK_FRAME_FROM),
>         CRASHTYPE(USERCOPY_STACK_BEYOND),
>         CRASHTYPE(USERCOPY_KERNEL),
> +       CRASHTYPE(USERCOPY_KERNEL_ALIAS),
>  };
>
>
> diff --git a/drivers/misc/lkdtm_usercopy.c b/drivers/misc/lkdtm_usercopy.c
> index 1dd6114..955f2dc 100644
> --- a/drivers/misc/lkdtm_usercopy.c
> +++ b/drivers/misc/lkdtm_usercopy.c
> @@ -279,9 +279,16 @@ void lkdtm_USERCOPY_STACK_BEYOND(void)
>         do_usercopy_stack(true, false);
>  }
>
> -void lkdtm_USERCOPY_KERNEL(void)
> +static void do_usercopy_kernel(bool use_alias)
>  {
>         unsigned long user_addr;
> +       const void *rodata = test_text;
> +       void *text = vm_mmap;
> +
> +       if (use_alias) {
> +               rodata = lm_alias(rodata);
> +               text = lm_alias(text);
> +       }
>
>         user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
>                             PROT_READ | PROT_WRITE | PROT_EXEC,
> @@ -292,14 +299,14 @@ void lkdtm_USERCOPY_KERNEL(void)
>         }
>
>         pr_info("attempting good copy_to_user from kernel rodata\n");
> -       if (copy_to_user((void __user *)user_addr, test_text,
> +       if (copy_to_user((void __user *)user_addr, rodata,
>                          unconst + sizeof(test_text))) {
>                 pr_warn("copy_to_user failed unexpectedly?!\n");
>                 goto free_user;
>         }
>
>         pr_info("attempting bad copy_to_user from kernel text\n");
> -       if (copy_to_user((void __user *)user_addr, vm_mmap,
> +       if (copy_to_user((void __user *)user_addr, text,
>                          unconst + PAGE_SIZE)) {
>                 pr_warn("copy_to_user failed, but lacked Oops\n");
>                 goto free_user;
> @@ -309,6 +316,16 @@ void lkdtm_USERCOPY_KERNEL(void)
>         vm_munmap(user_addr, PAGE_SIZE);
>  }
>
> +void lkdtm_USERCOPY_KERNEL(void)
> +{
> +       do_usercopy_kernel(false);
> +}
> +
> +void lkdtm_USERCOPY_KERNEL_ALIAS(void)
> +{
> +       do_usercopy_kernel(true);
> +}
> +
>  void __init lkdtm_usercopy_init(void)
>  {
>         /* Prepare cache that lacks SLAB_USERCOPY flag. */



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

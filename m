Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 132106B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 18:50:26 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b130so6054006oii.4
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:50:26 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id a2si1411588oif.325.2017.08.16.15.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 15:50:25 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id m34so23683887iti.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:50:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816224650.1089-2-labbott@redhat.com>
References: <20170816224650.1089-1-labbott@redhat.com> <20170816224650.1089-2-labbott@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 16 Aug 2017 15:50:24 -0700
Message-ID: <CAGXu5jK=K5DmW=TODb6ZOd7fHqhjHjoOP2yTW-v_0jONsti4yw@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] init: Move stack canary initialization after setup_arch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Micay <danielmicay@gmail.com>

On Wed, Aug 16, 2017 at 3:46 PM, Laura Abbott <labbott@redhat.com> wrote:
> From: Laura Abbott <lauraa@codeaurora.org>
>
> Stack canary intialization involves getting a random number.
> Getting this random number may involve accessing caches or other
> architectural specific features which are not available until
> after the architecture is setup. Move the stack canary initialization
> later to accomodate this.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
> v2: Also moved add_latent_entropy per suggestion of Kees.
> ---
>  init/main.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/init/main.c b/init/main.c
> index 052481fbe363..21d599eaad06 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -515,12 +515,6 @@ asmlinkage __visible void __init start_kernel(void)
>         smp_setup_processor_id();
>         debug_objects_early_init();
>
> -       /*
> -        * Set up the initial canary ASAP:
> -        */
> -       add_latent_entropy();
> -       boot_init_stack_canary();
> -
>         cgroup_init_early();
>
>         local_irq_disable();
> @@ -534,6 +528,11 @@ asmlinkage __visible void __init start_kernel(void)
>         page_address_init();
>         pr_notice("%s", linux_banner);
>         setup_arch(&command_line);
> +       /*
> +        * Set up the the initial canary and entropy after arch
> +        */
> +       add_latent_entropy();
> +       boot_init_stack_canary();
>         mm_init_cpumask(&init_mm);
>         setup_command_line(command_line);
>         setup_nr_cpu_ids();
> --
> 2.13.0
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

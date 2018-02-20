Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6446D6B0022
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:26:14 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id g24so7378951oiy.0
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:26:14 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w69si17394ota.207.2018.02.20.10.26.12
        for <linux-mm@kvack.org>;
        Tue, 20 Feb 2018 10:26:13 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 01/11] ACPI / APEI: Move the estatus queue code up, and under its own ifdef
References: <20180215185606.26736-1-james.morse@arm.com>
	<20180215185606.26736-2-james.morse@arm.com>
Date: Tue, 20 Feb 2018 18:26:10 +0000
Message-ID: <87zi43zfel.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi James,

A couple of nitpicks below.

James Morse <james.morse@arm.com> writes:

> To support asynchronous NMI-like notifications on arm64 we need to use
> the estatus-queue. These patches refactor it to allow multiple APEI
> notification types to use it.
>
> First we move the estatus-queue code higher in the file so that any
> notify_foo() handler can make user of it.
                                ^
                                use

>
> This patch moves code around ... and makes the following trivial change:
> Freshen the dated comment above ghes_estatus_llist. printk() is no
> longer the issue, its the helpers like memory_failure_queue() that
> still aren't nmi safe.
>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 267 ++++++++++++++++++++++++-----------------------
>  1 file changed, 139 insertions(+), 128 deletions(-)
>
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 1efefe919555..e42b587c509b 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -545,6 +545,16 @@ static int ghes_print_estatus(const char *pfx,
>  	return 0;
>  }
>  
> +static void __ghes_panic(struct ghes *ghes)
> +{
> +	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
> +
> +	/* reboot to log the error! */
> +	if (!panic_timeout)
> +		panic_timeout = ghes_panic_timeout;
> +	panic("Fatal hardware error!");
> +}
> +
>  /*
>   * GHES error status reporting throttle, to report more kinds of
>   * errors, instead of just most frequently occurred errors.
> @@ -672,6 +682,135 @@ static void ghes_estatus_cache_add(
>  	rcu_read_unlock();
>  }
>  
> +#ifdef CONFIG_HAVE_ACPI_APEI_NMI
> +/*
> + * While printk() now has an in_nmi() path, the handling for CPER records
> + * does not. For example, memory_failure_queue() takes spinlocks and calls
> + * schedule_work_on().
> + *
> + * So in any NMI-like handler, we allocate required memory from lock-less
> + * memory allocator (ghes_estatus_pool), save estatus into it, put them into
> + * lock-less list (ghes_estatus_llist), then delay printk into IRQ context via
> + * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
> + * required pool size by all NMI error source.

I am not sure it is worth keeping specific references to printk
around. As you're refreshing the comment, I'd suggest replacing the
above reference with "...processing of error status reported by the
NMI..." or something similar.

Thanks,
Punit


[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

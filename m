Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 425668E0008
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:58:59 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id l17so2668386wme.1
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:58:59 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id x20si32279934wmh.163.2019.01.21.09.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 09:58:57 -0800 (PST)
Date: Mon, 21 Jan 2019 18:58:50 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 22/25] ACPI / APEI: Kick the memory_failure() queue
 for synchronous errors
Message-ID: <20190121175850.GO29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-23-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-23-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:06:10PM +0000, James Morse wrote:
> memory_failure() offlines or repairs pages of memory that have been
> discovered to be corrupt. These may be detected by an external
> component, (e.g. the memory controller), and notified via an IRQ.
> In this case the work is queued as not all of memory_failure()s work
> can happen in IRQ context.
> 
> If the error was detected as a result of user-space accessing a
> corrupt memory location the CPU may take an abort instead. On arm64
> this is a 'synchronous external abort', and on a firmware first
> system it is replayed using NOTIFY_SEA.
> 
> This notification has NMI like properties, (it can interrupt
> IRQ-masked code), so the memory_failure() work is queued. If we
> return to user-space before the queued memory_failure() work is
> processed, we will take the fault again. This loop may cause platform
> firmware to exceed some threshold and reboot when Linux could have
> recovered from this error.
> 
> If a ghes notification type indicates that it may be triggered again
> when we return to user-space, use the task-work and notify-resume
> hooks to kick the relevant memory_failure() queue before returning
> to user-space.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> 
> ---
> current->mm == &init_mm ? I couldn't find a helper for this.
> The intent is not to set TIF flags on kernel threads. What happens
> if a kernel-thread takes on of these? Its just one of the many
> not-handled-very-well cases we have already, as memory_failure()
> puts it: "try to be lucky".
> 
> I assume that if NOTIFY_NMI is coming from SMM it must suffer from
> this problem too.

Good question.

I'm guessing all those things should be queued on a normal struct
work_struct queue, no?

Now, memory_failure_queue() does that and can run from IRQ context so
you need only an irq_work which can queue from NMI context. We do it
this way in the MCA code:

We queue in an irq_work in NMI context and work through the items in
process context.

> ---
>  drivers/acpi/apei/ghes.c | 65 ++++++++++++++++++++++++++++++++++++----
>  1 file changed, 60 insertions(+), 5 deletions(-)

...

> @@ -407,7 +447,22 @@ static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int
>  
>  	if (flags != -1)
>  		memory_failure_queue(pfn, flags);
> -#endif
> +
> +	/*
> +	 * If the notification indicates that it was the interrupted
> +	 * instruction that caused the error, try to kick the
> +	 * memory_failure() queue before returning to user-space.
> +	 */
> +	if (ghes_is_synchronous(ghes) && current->mm != &init_mm) {
> +		callback = kzalloc(sizeof(*callback), GFP_ATOMIC);

Can we avoid that GFP_ATOMIC allocation and kfree() in
ghes_kick_memory_failure()?

I mean, that struct ghes_memory_failure_work is small enough and we
already do lockless allocation:

	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);

so I guess we could add that ghes_memory_failure_work struct to that
estatus_node, hand it into ghes_do_proc() and then free it.

No?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

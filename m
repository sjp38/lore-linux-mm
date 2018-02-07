Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE1B6B035E
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 13:38:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 199so784663pfy.18
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 10:38:38 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id n128si1262381pgn.247.2018.02.07.10.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 10:38:37 -0800 (PST)
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
Date: Wed, 7 Feb 2018 10:38:35 -0800
MIME-Version: 1.0
In-Reply-To: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, luto@kernel.org, bp@alien8.de, jpoimboe@redhat.com, jgross@suse.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, minipli@googlemail.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

On 02/07/2018 08:14 AM, Kirill Tkhai wrote:
> Sometimes it is possible to meet a situation,
> when irq stack is corrupted, while innocent
> callback function is being executed. This may
> happen because of crappy drivers irq handlers,
> when they access wrong memory on the irq stack.

Can you be more clear about the actual issue?  Which drivers do this?
How do they even find an IRQ stack pointer?

> This patch aims to catch such the situations
> and adds checks of unauthorized stack access.

I think I forgot how KASAN did this.  KASAN has metadata that says which
areas of memory are good or bad to access, right?  So, this just tags
IRQ stacks as bad when we are not _in_ an interrupt?

> +#define KASAN_IRQ_STACK_SIZE \
> +	(sizeof(union irq_stack_union) - \
> +		(offsetof(union irq_stack_union, stack_canary) + 8))

Just curious, but why leave out the canary?  It shouldn't be accessed
either.

> +#ifdef CONFIG_KASAN
> +void __visible x86_poison_irq_stack(void)
> +{
> +	if (this_cpu_read(irq_count) == -1)
> +		kasan_poison_irq_stack();
> +}
> +void __visible x86_unpoison_irq_stack(void)
> +{
> +	if (this_cpu_read(irq_count) == -1)
> +		kasan_unpoison_irq_stack();
> +}
> +#endif

It might be handy to point out here that -1 means "not in an interrupt"
and >=0 means "in an interrupt".

Otherwise, this looks pretty straightforward.  Would it be something to
extend to the other stacks like the NMI or double-fault stacks?  Or are
those just not worth it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

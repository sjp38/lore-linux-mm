Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7F856B0363
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 14:32:15 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b24-v6so417797pls.15
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 11:32:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f1-v6sor827751pld.131.2018.02.07.11.32.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 11:32:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain> <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 7 Feb 2018 20:31:53 +0100
Message-ID: <CACT4Y+bbVRpdUJsK9pZshbJW-0D7bvquK2QVpzrpomw5cS1X_g@mail.gmail.com>
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, Mathias Krause <minipli@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Wed, Feb 7, 2018 at 7:38 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> On 02/07/2018 08:14 AM, Kirill Tkhai wrote:
>> Sometimes it is possible to meet a situation,
>> when irq stack is corrupted, while innocent
>> callback function is being executed. This may
>> happen because of crappy drivers irq handlers,
>> when they access wrong memory on the irq stack.
>
> Can you be more clear about the actual issue?  Which drivers do this?
> How do they even find an IRQ stack pointer?
>
>> This patch aims to catch such the situations
>> and adds checks of unauthorized stack access.
>
> I think I forgot how KASAN did this.  KASAN has metadata that says which
> areas of memory are good or bad to access, right?  So, this just tags
> IRQ stacks as bad when we are not _in_ an interrupt?

Correct.
kasan_poison/unpoison_shadow effectively memset separate "shadow"
memory range, which is then checked by memory accesses to understand
if it's OK to access corresponding memory.


>> +#define KASAN_IRQ_STACK_SIZE \
>> +     (sizeof(union irq_stack_union) - \
>> +             (offsetof(union irq_stack_union, stack_canary) + 8))
>
> Just curious, but why leave out the canary?  It shouldn't be accessed
> either.
>
>> +#ifdef CONFIG_KASAN
>> +void __visible x86_poison_irq_stack(void)
>> +{
>> +     if (this_cpu_read(irq_count) == -1)
>> +             kasan_poison_irq_stack();
>> +}
>> +void __visible x86_unpoison_irq_stack(void)
>> +{
>> +     if (this_cpu_read(irq_count) == -1)
>> +             kasan_unpoison_irq_stack();
>> +}
>> +#endif
>
> It might be handy to point out here that -1 means "not in an interrupt"
> and >=0 means "in an interrupt".
>
> Otherwise, this looks pretty straightforward.  Would it be something to
> extend to the other stacks like the NMI or double-fault stacks?  Or are
> those just not worth it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

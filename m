Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4396B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 08:50:04 -0500 (EST)
Received: by igvi2 with SMTP id i2so68526580igv.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 05:50:04 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id q67si20736930ioi.116.2015.11.03.05.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 05:50:03 -0800 (PST)
Received: by pasz6 with SMTP id z6so19305322pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 05:50:02 -0800 (PST)
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu area setup
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
Date: Tue, 3 Nov 2015 22:49:56 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <F4C06691-60EF-45FA-9AD7-9FBF8F1960AB@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org> <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@linux.com>, mark.rutland@arm.com, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, james.morse@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Nov 3, 2015, at 1:22 AM, Catalin Marinas wrote:

Hi Catalin,

> On Mon, Nov 02, 2015 at 10:10:23AM -0600, Christoph Lameter wrote:
>> On Sun, 1 Nov 2015, Jungseok Lee wrote:
>>=20
>>> There is no room to adjust 'atom_size' now when a generic percpu =
area
>>> is used. It would be redundant to write down an =
architecture-specific
>>> setup_per_cpu_areas() in order to only change the 'atom_size'. Thus,
>>> this patch adds a new definition, PERCPU_ATOM_SIZE, which is =
PAGE_SIZE
>>> by default. The value could be updated if needed by architecture.
>>=20
>> What is atom_size? Why would you want a difference allocation size =
here?
>> The percpu area is virtually mapped regardless. So you will have
>> contiguous addresses even without atom_size.
>=20
> I haven't looked at the patch 3/3 in detail but I'm pretty sure I'll =
NAK
> the approach (and the definition of PERCPU_ATOM_SIZE), therefore
> rendering this patch unnecessary. IIUC, this is used to enforce some
> alignment of the per-CPU IRQ stack to be able to check whether the
> current stack is process or IRQ on exception entry. But there are =
other,
> less intrusive ways to achieve the same (e.g. x86).

First of all, thanks for clarification!

That is why I chose the word, 'doubtable', in the cover letter. I will
give up this approach. I've been paranoid about "another pointer read"
which you mentioned [1] for over a week. This wrong idea is my =
conclusion
with respect to your feedback. I think I've failed to follow you here.

Most ideas came from x86 implementation when I started this work. v2, =
[2]
might be close to x86 approach. At that time, for IRQ re-entrance check,
count based method was used. But count was considered a redundant =
variable
since we have preempt_count. As a result, the top-bit comparison idea,
which is an origin of this IRQ_STACK_SIZE alignment, have taken the =
work,
re-entrance check. Like x86, if we pick up the count method, we could
achieve the goal without this unnecessary alignment. How about your =
opinon?

I copy and paste x86 code (arch/x86/entry/entry_64.S) for convenience. =
It has
a comment on why the redundancy is allowed.

----8<----
        .macro interrupt func
        cld
        ALLOC_PT_GPREGS_ON_STACK
        SAVE_C_REGS
        SAVE_EXTRA_REGS

        testb   $3, CS(%rsp)
        jz      1f

        /*
         * IRQ from user mode.  Switch to kernel gsbase and inform =
context
         * tracking that we're in kernel mode.
         */
        SWAPGS
#ifdef CONFIG_CONTEXT_TRACKING
        call enter_from_user_mode
#endif

1:
        /*
         * Save previous stack pointer, optionally switch to interrupt =
stack.
         * irq_count is used to check if a CPU is already on an =
interrupt stack
         * or not. While this is essentially redundant with =
preempt_count it is
         * a little cheaper to use a separate counter in the PDA (short =
of
         * moving irq_enter into assembly, which would be too much work)
         */
        movq    %rsp, %rdi
        incl    PER_CPU_VAR(irq_count)
        cmovzq  PER_CPU_VAR(irq_stack_ptr), %rsp
        pushq   %rdi
        /* We entered an interrupt context - irqs are off: */
        TRACE_IRQS_OFF

        call    \func   /* rdi points to pt_regs */
        .endm

        /*
         * The interrupt stubs push (~vector+0x80) onto the stack and
         * then jump to common_interrupt.
         */
        .p2align CONFIG_X86_L1_CACHE_SHIFT
common_interrupt:
        ASM_CLAC
        addq    $-0x80, (%rsp)                  /* Adjust vector to =
[-256, -1] range */
        interrupt do_IRQ
----8<----

Additionally, I've been thinking of do_softirq_own_stack() which is your
another comment [3]. Recently, I've realized there is possibility that
I misunderstood your intention. Did you mean that irq_handler hook is =
not
enough? Should do_softirq_own_stack() be implemented together? If so,
this is my another failure.. It perfectly makes sense.

I hope these are the last two pieces of this interesting feature.

Thanks again!

Best Regards
Jungseok Lee

[1] https://lkml.org/lkml/2015/10/19/596
[2] http://article.gmane.org/gmane.linux.kernel/2037257
[3] http://article.gmane.org/gmane.linux.kernel/2041877=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

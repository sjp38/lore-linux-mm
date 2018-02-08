Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B86CD6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 11:41:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q13so1939669pgt.17
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 08:41:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l12-v6sor98406plc.127.2018.02.08.08.41.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 08:41:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208163041.zy7dbz4tlbit4i2h@treble>
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
 <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com> <d1b8c22c-79bf-55a1-37a1-2ce508881f3d@virtuozzo.com>
 <20180208163041.zy7dbz4tlbit4i2h@treble>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 8 Feb 2018 17:41:19 +0100
Message-ID: <CACT4Y+bZ2JtwTK+a2=wuTm3891Zu1qksreyO63i6whKqFv66Cw@mail.gmail.com>
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, Mathias Krause <minipli@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Feb 8, 2018 at 5:30 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Thu, Feb 08, 2018 at 01:03:49PM +0300, Kirill Tkhai wrote:
>> On 07.02.2018 21:38, Dave Hansen wrote:
>> > On 02/07/2018 08:14 AM, Kirill Tkhai wrote:
>> >> Sometimes it is possible to meet a situation,
>> >> when irq stack is corrupted, while innocent
>> >> callback function is being executed. This may
>> >> happen because of crappy drivers irq handlers,
>> >> when they access wrong memory on the irq stack.
>> >
>> > Can you be more clear about the actual issue?  Which drivers do this?
>> > How do they even find an IRQ stack pointer?
>>
>> I can't say actual driver making this, because I'm still investigating the guilty one.
>> But I have couple of crash dumps with the crash inside update_sd_lb_stats() function,
>> where stack variable sg becomes corrupted. This time all scheduler-related not-stack
>> variables are in ideal state. And update_sd_lb_stats() is the function, which can't
>> corrupt its own stack. So, I thought this functionality may be useful for something else,
>> especially because of irq stack is one of the last stacks, which are not sanitized.
>> Task's stacks are already covered, as I know
>>
>> [1595450.678971] Call Trace:
>> [1595450.683991]  <IRQ>
>> [1595450.684038]
>> [1595450.688926]  [<ffffffff81320005>] cpumask_next_and+0x35/0x50
>> [1595450.693984]  [<ffffffff810d91d3>] find_busiest_group+0x143/0x950
>> [1595450.699088]  [<ffffffff810d9b7a>] load_balance+0x19a/0xc20
>> [1595450.704289]  [<ffffffff810cde55>] ? sched_clock_cpu+0x85/0xc0
>> [1595450.709457]  [<ffffffff810c29aa>] ? update_rq_clock.part.88+0x1a/0x150
>> [1595450.714711]  [<ffffffff810da770>] rebalance_domains+0x170/0x2b0
>> [1595450.719997]  [<ffffffff810da9d2>] run_rebalance_domains+0x122/0x1e0
>> [1595450.725321]  [<ffffffff816bb10f>] __do_softirq+0x10f/0x2aa
>> [1595450.730746]  [<ffffffff816b62ac>] call_softirq+0x1c/0x30
>> [1595450.736169]  [<ffffffff8102d325>] do_softirq+0x65/0xa0
>> [1595450.741754]  [<ffffffff81093ec5>] irq_exit+0x105/0x110
>> [1595450.747279]  [<ffffffff816baad2>] smp_apic_timer_interrupt+0x42/0x50
>> [1595450.752905]  [<ffffffff816b7a62>] apic_timer_interrupt+0x232/0x240
>> [1595450.758519]  <EOI>
>> [1595450.758569]
>> [1595450.764100]  [<ffffffff8152f282>] ? cpuidle_enter_state+0x52/0xc0
>> [1595450.769652]  [<ffffffff8152f3c8>] cpuidle_idle_call+0xd8/0x210
>> [1595450.775198]  [<ffffffff8103540e>] arch_cpu_idle+0xe/0x30
>> [1595450.780813]  [<ffffffff810effba>] cpu_startup_entry+0x14a/0x1c0
>> [1595450.786286]  [<ffffffff810523e6>] start_secondary+0x1d6/0x250
>
> I'm not seeing how this patch would help.  If you're running on the irq
> stack, the *entire* irq stack would be unpoisoned.  So there's still no
> KASAN protection.  Or am I missing something?
>
> Seems like it would be more useful for KASAN to detect redzone accesses
> on the irq stack (if it's not doing that already).

KASAN should do this already (unless there is something terribly
broken). Compiler instrumentation adds redzones around all stack
variables and injects code to poision/unpoison these redzones on
function entry/exit.
KASAN can also detect use-after-scope bugs for stack variables, but
this requires a more recent gcc (6 or 7, don't remember exactly now)
and CONFIG_KASAN_EXTRA since recently.
User-space ASAN can also detect so called use-after-return bugs
(dangling references to stack variables), but this requires manual
management of stack frames and quarantine for stack frames. This is
more tricky to do inside of kernel, so this was never implemented in
KASAN. KASAN still can detect some of these, if it will happen so that
the dangling reference happen to point to a redzone in a new frame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

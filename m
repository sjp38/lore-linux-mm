Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 632EC6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 11:30:46 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d15so4163785qtg.2
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 08:30:46 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h2si279870qkc.74.2018.02.08.08.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 08:30:45 -0800 (PST)
Date: Thu, 8 Feb 2018 10:30:41 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
Message-ID: <20180208163041.zy7dbz4tlbit4i2h@treble>
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
 <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
 <d1b8c22c-79bf-55a1-37a1-2ce508881f3d@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <d1b8c22c-79bf-55a1-37a1-2ce508881f3d@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, luto@kernel.org, bp@alien8.de, jgross@suse.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, minipli@googlemail.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

On Thu, Feb 08, 2018 at 01:03:49PM +0300, Kirill Tkhai wrote:
> On 07.02.2018 21:38, Dave Hansen wrote:
> > On 02/07/2018 08:14 AM, Kirill Tkhai wrote:
> >> Sometimes it is possible to meet a situation,
> >> when irq stack is corrupted, while innocent
> >> callback function is being executed. This may
> >> happen because of crappy drivers irq handlers,
> >> when they access wrong memory on the irq stack.
> > 
> > Can you be more clear about the actual issue?  Which drivers do this?
> > How do they even find an IRQ stack pointer?
> 
> I can't say actual driver making this, because I'm still investigating the guilty one.
> But I have couple of crash dumps with the crash inside update_sd_lb_stats() function,
> where stack variable sg becomes corrupted. This time all scheduler-related not-stack
> variables are in ideal state. And update_sd_lb_stats() is the function, which can't
> corrupt its own stack. So, I thought this functionality may be useful for something else,
> especially because of irq stack is one of the last stacks, which are not sanitized.
> Task's stacks are already covered, as I know
> 
> [1595450.678971] Call Trace:
> [1595450.683991]  <IRQ>
> [1595450.684038]
> [1595450.688926]  [<ffffffff81320005>] cpumask_next_and+0x35/0x50
> [1595450.693984]  [<ffffffff810d91d3>] find_busiest_group+0x143/0x950
> [1595450.699088]  [<ffffffff810d9b7a>] load_balance+0x19a/0xc20
> [1595450.704289]  [<ffffffff810cde55>] ? sched_clock_cpu+0x85/0xc0
> [1595450.709457]  [<ffffffff810c29aa>] ? update_rq_clock.part.88+0x1a/0x150
> [1595450.714711]  [<ffffffff810da770>] rebalance_domains+0x170/0x2b0
> [1595450.719997]  [<ffffffff810da9d2>] run_rebalance_domains+0x122/0x1e0
> [1595450.725321]  [<ffffffff816bb10f>] __do_softirq+0x10f/0x2aa
> [1595450.730746]  [<ffffffff816b62ac>] call_softirq+0x1c/0x30
> [1595450.736169]  [<ffffffff8102d325>] do_softirq+0x65/0xa0
> [1595450.741754]  [<ffffffff81093ec5>] irq_exit+0x105/0x110
> [1595450.747279]  [<ffffffff816baad2>] smp_apic_timer_interrupt+0x42/0x50
> [1595450.752905]  [<ffffffff816b7a62>] apic_timer_interrupt+0x232/0x240
> [1595450.758519]  <EOI>
> [1595450.758569]
> [1595450.764100]  [<ffffffff8152f282>] ? cpuidle_enter_state+0x52/0xc0
> [1595450.769652]  [<ffffffff8152f3c8>] cpuidle_idle_call+0xd8/0x210
> [1595450.775198]  [<ffffffff8103540e>] arch_cpu_idle+0xe/0x30
> [1595450.780813]  [<ffffffff810effba>] cpu_startup_entry+0x14a/0x1c0
> [1595450.786286]  [<ffffffff810523e6>] start_secondary+0x1d6/0x250

I'm not seeing how this patch would help.  If you're running on the irq
stack, the *entire* irq stack would be unpoisoned.  So there's still no
KASAN protection.  Or am I missing something?

Seems like it would be more useful for KASAN to detect redzone accesses
on the irq stack (if it's not doing that already).

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

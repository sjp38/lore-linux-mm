Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA976B0267
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:00:15 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id l127so17712075lfl.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:00:15 -0800 (PST)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id d203si44953672lfd.193.2017.01.05.07.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 07:00:13 -0800 (PST)
Received: by mail-lf0-x235.google.com with SMTP id k86so36607825lfi.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:00:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105144942.whqucdwmeqybng3s@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble> <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
 <20161220233640.pc4goscldmpkvtqa@treble> <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
 <20161222051701.soqwh47frxwsbkni@treble> <CACT4Y+ZxTLcpwQOBCyMZGFuXeDrbu9-RBaqzgnE57UPeDSPE+g@mail.gmail.com>
 <20170105144942.whqucdwmeqybng3s@treble>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 5 Jan 2017 15:59:52 +0100
Message-ID: <CACT4Y+agcezesdRUKtrho6sRmoRiCH6q4GU1J2QrTYqVkmJpKA@mail.gmail.com>
Subject: Re: x86: warning in unwind_get_return_address
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzkaller <syzkaller@googlegroups.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Kostya Serebryany <kcc@google.com>

On Thu, Jan 5, 2017 at 3:49 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Tue, Dec 27, 2016 at 05:38:59PM +0100, Dmitry Vyukov wrote:
>> On Thu, Dec 22, 2016 at 6:17 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>> > On Wed, Dec 21, 2016 at 01:46:36PM +0100, Andrey Konovalov wrote:
>> >> On Wed, Dec 21, 2016 at 12:36 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>> >> >
>> >> > Thanks.  Looking at the stack trace, my guess is that an interrupt hit
>> >> > while running in generated BPF code, and the unwinder got confused
>> >> > because regs->ip points to the generated code.  I may need to disable
>> >> > that warning until we figure out a better solution.
>> >> >
>> >> > Can you share your .config file?
>> >>
>> >> Sure, attached.
>> >
>> > Ok, I was able to recreate with your config.  The culprit was generated
>> > code, as I suspected, though it wasn't BPF, it was a kprobe (created by
>> > dccpprobe_init()).
>> >
>> > I'll make a patch to disable the warning.
>>
>> Hi,
>>
>> I am also seeing the following warnings:
>>
>> [  281.889259] WARNING: kernel stack regs at ffff8801c29a7ea8 in
>> syz-executor8:1302 has bad 'bp' value ffff8801c29a7f28
>> [  833.994878] WARNING: kernel stack regs at ffff8801c4e77ea8 in
>> syz-executor1:13094 has bad 'bp' value ffff8801c4e77f28
>>
>> Can it also be caused by bpf/kprobe?
>
> This is a different warning.  I suspect it's due to unwinding the stack
> of another CPU while it's running, which is still possible in a few
> places.  I'm going to have to disable all these warnings for now.


I also have the following diff locally. These loads trigger episodic
KASAN warnings about stack-of-bounds reads on rcu stall warnings when
it does backtrace of all cpus.
If it looks correct to you, can you please also incorporate it into your patch?


diff --git a/arch/x86/include/asm/stacktrace.h
b/arch/x86/include/asm/stacktrace.h
index a3269c897ec5..d8d4fc66ffec 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -58,7 +58,7 @@ get_frame_pointer(struct task_struct *task, struct
pt_regs *regs)
        if (task == current)
                return __builtin_frame_address(0);

-       return (unsigned long *)((struct inactive_task_frame
*)task->thread.sp)->bp;
+       return (unsigned long *)READ_ONCE_NOCHECK(((struct
inactive_task_frame *)task->thread.sp)->bp);
 }
 #else
 static inline unsigned long *
diff --git a/arch/x86/kernel/unwind_frame.c b/arch/x86/kernel/unwind_frame.c
index 4443e499f279..f3a225ffa231 100644
--- a/arch/x86/kernel/unwind_frame.c
+++ b/arch/x86/kernel/unwind_frame.c
@@ -162,7 +162,7 @@ bool unwind_next_frame(struct unwind_state *state)
        if (state->regs)
                next_bp = (unsigned long *)state->regs->bp;
        else
-               next_bp = (unsigned long *)*state->bp;
+               next_bp = (unsigned long *)READ_ONCE_NOCHECK(*state->bp);

        /* is the next frame pointer an encoded pointer to pt_regs? */
        regs = decode_frame_pointer(next_bp);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

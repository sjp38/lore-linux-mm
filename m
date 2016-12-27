Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7E5B6B025E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:39:21 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id y21so118636926lfa.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 08:39:21 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id g69si9903612lji.16.2016.12.27.08.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 08:39:20 -0800 (PST)
Received: by mail-lf0-x229.google.com with SMTP id b14so190305484lfg.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 08:39:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161222051701.soqwh47frxwsbkni@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble> <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
 <20161220233640.pc4goscldmpkvtqa@treble> <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
 <20161222051701.soqwh47frxwsbkni@treble>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 27 Dec 2016 17:38:59 +0100
Message-ID: <CACT4Y+ZxTLcpwQOBCyMZGFuXeDrbu9-RBaqzgnE57UPeDSPE+g@mail.gmail.com>
Subject: Re: x86: warning in unwind_get_return_address
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, syzkaller <syzkaller@googlegroups.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Kostya Serebryany <kcc@google.com>

On Thu, Dec 22, 2016 at 6:17 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Wed, Dec 21, 2016 at 01:46:36PM +0100, Andrey Konovalov wrote:
>> On Wed, Dec 21, 2016 at 12:36 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>> >
>> > Thanks.  Looking at the stack trace, my guess is that an interrupt hit
>> > while running in generated BPF code, and the unwinder got confused
>> > because regs->ip points to the generated code.  I may need to disable
>> > that warning until we figure out a better solution.
>> >
>> > Can you share your .config file?
>>
>> Sure, attached.
>
> Ok, I was able to recreate with your config.  The culprit was generated
> code, as I suspected, though it wasn't BPF, it was a kprobe (created by
> dccpprobe_init()).
>
> I'll make a patch to disable the warning.

Hi,

I am also seeing the following warnings:

[  281.889259] WARNING: kernel stack regs at ffff8801c29a7ea8 in
syz-executor8:1302 has bad 'bp' value ffff8801c29a7f28
[  833.994878] WARNING: kernel stack regs at ffff8801c4e77ea8 in
syz-executor1:13094 has bad 'bp' value ffff8801c4e77f28

Can it also be caused by bpf/kprobe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

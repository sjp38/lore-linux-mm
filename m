Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3466A6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:17:09 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id c47so226268721qtc.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:17:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r45si34677130qte.148.2017.01.05.07.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 07:17:08 -0800 (PST)
Date: Thu, 5 Jan 2017 09:17:00 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: x86: warning in unwind_get_return_address
Message-ID: <20170105151700.4n7wpynvsv2yjotp@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble>
 <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
 <20161220233640.pc4goscldmpkvtqa@treble>
 <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
 <20161222051701.soqwh47frxwsbkni@treble>
 <CACT4Y+ZxTLcpwQOBCyMZGFuXeDrbu9-RBaqzgnE57UPeDSPE+g@mail.gmail.com>
 <20170105144942.whqucdwmeqybng3s@treble>
 <CACT4Y+agcezesdRUKtrho6sRmoRiCH6q4GU1J2QrTYqVkmJpKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CACT4Y+agcezesdRUKtrho6sRmoRiCH6q4GU1J2QrTYqVkmJpKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Kostya Serebryany <kcc@google.com>

On Thu, Jan 05, 2017 at 03:59:52PM +0100, Dmitry Vyukov wrote:
> On Thu, Jan 5, 2017 at 3:49 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > On Tue, Dec 27, 2016 at 05:38:59PM +0100, Dmitry Vyukov wrote:
> >> On Thu, Dec 22, 2016 at 6:17 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >> > On Wed, Dec 21, 2016 at 01:46:36PM +0100, Andrey Konovalov wrote:
> >> >> On Wed, Dec 21, 2016 at 12:36 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >> >> >
> >> >> > Thanks.  Looking at the stack trace, my guess is that an interrupt hit
> >> >> > while running in generated BPF code, and the unwinder got confused
> >> >> > because regs->ip points to the generated code.  I may need to disable
> >> >> > that warning until we figure out a better solution.
> >> >> >
> >> >> > Can you share your .config file?
> >> >>
> >> >> Sure, attached.
> >> >
> >> > Ok, I was able to recreate with your config.  The culprit was generated
> >> > code, as I suspected, though it wasn't BPF, it was a kprobe (created by
> >> > dccpprobe_init()).
> >> >
> >> > I'll make a patch to disable the warning.
> >>
> >> Hi,
> >>
> >> I am also seeing the following warnings:
> >>
> >> [  281.889259] WARNING: kernel stack regs at ffff8801c29a7ea8 in
> >> syz-executor8:1302 has bad 'bp' value ffff8801c29a7f28
> >> [  833.994878] WARNING: kernel stack regs at ffff8801c4e77ea8 in
> >> syz-executor1:13094 has bad 'bp' value ffff8801c4e77f28
> >>
> >> Can it also be caused by bpf/kprobe?
> >
> > This is a different warning.  I suspect it's due to unwinding the stack
> > of another CPU while it's running, which is still possible in a few
> > places.  I'm going to have to disable all these warnings for now.
> 
> 
> I also have the following diff locally. These loads trigger episodic
> KASAN warnings about stack-of-bounds reads on rcu stall warnings when
> it does backtrace of all cpus.
> If it looks correct to you, can you please also incorporate it into your patch?

Ok, will do.

BTW, I think there's an issue with your mail client.  Your last two
replies to me didn't have me on To/Cc.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

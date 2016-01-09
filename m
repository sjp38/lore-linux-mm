Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBD0828EE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 17:33:04 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id w75so872338oie.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 14:33:04 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id cm10si25934815oec.84.2016.01.09.14.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 14:33:03 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id k206so31434163oia.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 14:33:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbJHXTv=-OP1+dwq5KCursi8jRnWR5Mg=MavD_sVSY05eA@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com> <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
 <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
 <CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
 <CALCETrV29dB_5PrT044NYg_p2CDaOgQ9p92mSc2rzKdRrAsviw@mail.gmail.com> <CA+8MBbJHXTv=-OP1+dwq5KCursi8jRnWR5Mg=MavD_sVSY05eA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 9 Jan 2016 14:32:43 -0800
Message-ID: <CALCETrUAO3gYiVpi5BO+o6=bika2D9JFZJ4xa9Ph8ArGMfftgA@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Robert <elliott@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

On Jan 9, 2016 11:51 AM, "Tony Luck" <tony.luck@gmail.com> wrote:
>
> > Oh, I see.  Is it the case that the MC code can't cleanly handle the
> > case where the error was nominally recoverable but the kernel doesn't
> > know how to recover from it due to the lack of a handler that's okay
> > with it, because the handler's refusal to handle the fault wouldn't be
> > known until too late?
>
> The code is just too clunky right now.  We have a table driven
> severity calculator that we invoke on each machine check bank
> that has some valid data to report.  Part of that calculation is
> "what context am I in?". Which happens earlier in the sequence
> than "Is MCi_STATUS.MCACOD some known recoverable type".
> If I invoke the fixup code I'll change regs->ip right away ... even
> if I'm executing on some innocent bystander processor that wasn't
> the source of the machine check (the bystanders on the same
> socket can usually see something logged in one of the memory
> controller banks).

Makes sense, sort of.  But even if there is an MC fixup registered,
don't you still have to make sure to execute it on the actual victim
CPU?  After all, you don't want to fail an mcsafe copy just because a
different CPU coincidentally machine checked while the mcsafe copy has
the recoverable RIP value.

>
> There are definitely some cleanups that should be done
> in this code (e.g. figuring our context just once, not once
> per bank).  But I'm pretty sure I'll always want to know
> "am I executing an instruction with a #MC recoverable
> handler?" in a way that doesn't actually invoke the recovery.

What's wrong with:

Step 1: determine that the HW context is, in principle, recoverable.

Step 2: ask the handler to try to recover.

Step 3: if the handler doesn't recover, panic

I'm not saying that restructuring the code like this should be a
prerequisite for merging this, but I'm wondering whether it would make
sense at some point in the future.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

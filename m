Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id CC3466B0256
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 13:00:38 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id ba1so378745059obb.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 10:00:38 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id xs11si7005376oec.89.2016.01.09.10.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 10:00:38 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id wp13so242906465obc.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 10:00:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com> <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
 <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com> <CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 9 Jan 2016 10:00:18 -0800
Message-ID: <CALCETrV29dB_5PrT044NYg_p2CDaOgQ9p92mSc2rzKdRrAsviw@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Sat, Jan 9, 2016 at 9:45 AM, Tony Luck <tony.luck@gmail.com> wrote:
> On Fri, Jan 8, 2016 at 5:52 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> Also, I think it would be nicer if the machine check code would invoke
>> the handler regardless of which handler (or class) is selected.  Then
>> the handlers that don't want to handle #MC can just reject them.
>
> The machine check code is currently a two pass process.
>
> First we scan all the machine check banks (on all processors
> at the moment because machine checks are broadcast). We
> assess the severity of all errors found.
>
> Then we take action. Panic if the most severe error was fatal,
> recover if not.
>
> This patch series tweaks the severity calculation. In-kernel
> errors at IPs with a EXTABLE_CLASS_FAULT handler are
> now ranked as recoverable. All other kernel errors remain
> fatal.
>
> I don't think it is right to unconditionally execute the fix code in the
> severity assessment phase.

I would argue that unconditionally calling the handler would be
cleaner.  The handler would return 0 or false to indicate that it
refuses to fix the exception.

This is similar to the logic that, for regular user memory access, we
shouldn't fix up faults other than #PF.  Given that we're adding
flexible handler callbacks, lets push all the "is this an acceptable
fault to fix up" down into the callback.  Does that make sense?

>
> Perhaps later we can revisit the two pass process?

Oh, I see.  Is it the case that the MC code can't cleanly handle the
case where the error was nominally recoverable but the kernel doesn't
know how to recover from it due to the lack of a handler that's okay
with it, because the handler's refusal to handle the fault wouldn't be
known until too late?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

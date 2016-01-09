Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 04C9F6B0258
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 14:51:37 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so171413003wmf.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 11:51:36 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id u65si8885362wmu.29.2016.01.09.11.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 11:51:35 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u188so20537409wmu.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 11:51:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrV29dB_5PrT044NYg_p2CDaOgQ9p92mSc2rzKdRrAsviw@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
	<CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
	<CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
	<CALCETrV29dB_5PrT044NYg_p2CDaOgQ9p92mSc2rzKdRrAsviw@mail.gmail.com>
Date: Sat, 9 Jan 2016 11:51:35 -0800
Message-ID: <CA+8MBbJHXTv=-OP1+dwq5KCursi8jRnWR5Mg=MavD_sVSY05eA@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

> Oh, I see.  Is it the case that the MC code can't cleanly handle the
> case where the error was nominally recoverable but the kernel doesn't
> know how to recover from it due to the lack of a handler that's okay
> with it, because the handler's refusal to handle the fault wouldn't be
> known until too late?

The code is just too clunky right now.  We have a table driven
severity calculator that we invoke on each machine check bank
that has some valid data to report.  Part of that calculation is
"what context am I in?". Which happens earlier in the sequence
than "Is MCi_STATUS.MCACOD some known recoverable type".
If I invoke the fixup code I'll change regs->ip right away ... even
if I'm executing on some innocent bystander processor that wasn't
the source of the machine check (the bystanders on the same
socket can usually see something logged in one of the memory
controller banks).

There are definitely some cleanups that should be done
in this code (e.g. figuring our context just once, not once
per bank).  But I'm pretty sure I'll always want to know
"am I executing an instruction with a #MC recoverable
handler?" in a way that doesn't actually invoke the recovery.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

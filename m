Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 00A00828DE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 12:45:50 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so167897616wmf.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:45:50 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id y142si8127867wmd.48.2016.01.09.09.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 09:45:49 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id b14so20324109wmb.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:45:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
	<CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
Date: Sat, 9 Jan 2016 09:45:49 -0800
Message-ID: <CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Jan 8, 2016 at 5:52 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> Also, I think it would be nicer if the machine check code would invoke
> the handler regardless of which handler (or class) is selected.  Then
> the handlers that don't want to handle #MC can just reject them.

The machine check code is currently a two pass process.

First we scan all the machine check banks (on all processors
at the moment because machine checks are broadcast). We
assess the severity of all errors found.

Then we take action. Panic if the most severe error was fatal,
recover if not.

This patch series tweaks the severity calculation. In-kernel
errors at IPs with a EXTABLE_CLASS_FAULT handler are
now ranked as recoverable. All other kernel errors remain
fatal.

I don't think it is right to unconditionally execute the fix code in the
severity assessment phase.

Perhaps later we can revisit the two pass process?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

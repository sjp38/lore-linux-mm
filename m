Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9FB828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 20:53:15 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ba1so368915769obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 17:53:15 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id fj3si14236359obc.64.2016.01.08.17.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 17:53:14 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id k206so21974866oia.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 17:53:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
References: <cover.1452297867.git.tony.luck@intel.com> <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 17:52:54 -0800
Message-ID: <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Jan 8, 2016 at 12:49 PM, Tony Luck <tony.luck@intel.com> wrote:
> Huge amounts of help from  Andy Lutomirski and Borislav Petkov to
> produce this. Andy provided the inspiration to add classes to the
> exception table with a clever bit-squeezing trick, Boris pointed
> out how much cleaner it would all be if we just had a new field.
>
> Linus Torvalds blessed the expansion with:
>   I'd rather not be clever in order to save just a tiny amount of space
>   in the exception table, which isn't really criticial for anybody.
>
> The third field is a simple integer indexing into an array of handler
> functions (I thought it couldn't be a relative pointer like the other
> fields because a module may have its ex_table loaded more than 2GB away
> from the handler function - but that may not be actually true. But the
> integer is pretty flexible, we are only really using low two bits now).
>
> We start out with three handlers:
>
> 0: Legacy - just jumps the to fixup IP
> 1: Fault - provide the trap number in %ax to the fixup code
> 2: Cleaned up legacy for the uaccess error hack

I think I preferred the relative function pointer approach.

Also, I think it would be nicer if the machine check code would invoke
the handler regardless of which handler (or class) is selected.  Then
the handlers that don't want to handle #MC can just reject them.

Also, can you make the handlers return bool instead of int?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

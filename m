Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id DE77D6B02C8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 07:20:14 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ba1so126509092obb.3
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 04:20:14 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id y127si32132716oig.49.2015.12.27.04.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 04:20:14 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id bx1so100924528obb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 04:20:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151227100919.GA19398@nazgul.tnic>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
 <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
 <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
 <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com> <20151227100919.GA19398@nazgul.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 27 Dec 2015 04:19:54 -0800
Message-ID: <CALCETrUcSB8ix0HSPyTwXT46gMAE2iGVZ8V1kEbkQVxVqrQFiQ@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 27, 2015 at 2:09 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Sat, Dec 26, 2015 at 10:57:26PM -0800, Tony Luck wrote:
>> ... will get the right value.  Maybe this would still work out
>> if the fixup is a 31-bit value plus a flag, but the external
>> tool thinks it is a 32-bit value?  I'd have to ponder that.
>
> I still fail to see why do we need to make it so complicated and can't
> do something like:
>
>
> fixup_exception:
>         ...
>
> #ifdef CONFIG_MCE_KERNEL_RECOVERY
>                 if (regs->ip >= (unsigned long)__mcsafe_copy &&
>                     regs->ip <= (unsigned long)__mcsafe_copy_end)
>                         run_special_handler();
> #endif
>
> and that special handler does all the stuff we want. And we pass
> X86_TRAP* etc through fixup_exception along with whatever else we
> need from the trap handler...
>
> Hmmm?

You certainly can, but it doesn't scale well to multiple users of
similar mechanisms.  It also prevents you from using the same
mechanism in anything that could be inlined, which is IMO kind of
unfortunate.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

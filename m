Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id E67B282FE2
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 08:26:05 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id bx1so101396076obb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 05:26:05 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id z128si44725501oiz.78.2015.12.27.05.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 05:26:05 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id bx1so101396008obb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 05:26:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6c0b3214-f120-47ee-b7fe-677b4f27f039@email.android.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
 <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
 <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
 <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
 <20151227100919.GA19398@nazgul.tnic> <CALCETrUcSB8ix0HSPyTwXT46gMAE2iGVZ8V1kEbkQVxVqrQFiQ@mail.gmail.com>
 <6c0b3214-f120-47ee-b7fe-677b4f27f039@email.android.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 27 Dec 2015 05:25:45 -0800
Message-ID: <CALCETrVY7407jf-o4n1ZjKu=QNfUv9fnbxDQwX8Sa=o4PY+aFA@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 27, 2015 at 5:17 AM, Boris Petkov <bp@alien8.de> wrote:
> Andy Lutomirski <luto@amacapital.net> wrote:
>>You certainly can, but it doesn't scale well to multiple users of
>>similar mechanisms.  It also prevents you from using the same
>>mechanism in anything that could be inlined, which is IMO kind of
>>unfortunate.
>
> Well, but the bit 31 game doesn't make it any better than the bit 63 fun IMO. Should the exception table entry maybe grow a u32 flags instead?
>

That could significantly bloat the kernel image.

Anyway, the bit 31 game isn't so bad IMO because it's localized to the
extable macros and the extable reader, whereas the bit 63 thing is all
tangled up with the __mcsafe_copy thing, and that's just the first
user of a more general mechanism.

Did you see this:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=strict_uaccess_fixups/patch_v1&id=16644d9460fc6531456cf510d5efc57f89e5cd34

(If you and/or Tony use it, take out the uaccess stuff -- it's not
useful for what you're doing, and I should have stuck that in a
separate patch in the first place.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

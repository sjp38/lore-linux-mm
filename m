Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1565B6B0009
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 18:32:32 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so52831067wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:32:32 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id v20si114621132wjq.230.2015.12.30.15.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 15:32:31 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id l65so38531807wmf.3
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:32:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrV2g6vSQcpNUADWeLMj5O_HDEGgp6vvLw9KgJVTWxZ1+g@mail.gmail.com>
References: <20151224214632.GF4128@pd.tnic>
	<ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
	<20151225114937.GA862@pd.tnic>
	<5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
	<20151226103252.GA21988@pd.tnic>
	<CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
	<CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
	<CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
	<CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
	<CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
	<CALCETrV2g6vSQcpNUADWeLMj5O_HDEGgp6vvLw9KgJVTWxZ1+g@mail.gmail.com>
Date: Wed, 30 Dec 2015 15:32:30 -0800
Message-ID: <CA+8MBbK842Ov74ZSU_fmxoZNw_72J+3hg3KQ4C5aBjd_cDYfAA@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 27, 2015 at 4:18 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> I think I can save you some pondering.  This old patch gives two flag
> bits.  Feel free to borrow the patch, but you'll probably want to
> change the _EXTABLE_CLASS_XYZ macros:
>
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=strict_uaccess_fixups/patch_v1&id=16644d9460fc6531456cf510d5efc57f89e5cd34

Thanks!

I took that, and some of Boris's changes, and stirred it altogether at:

git://git.kernel.org/pub/scm/linux/kernel/git/ras/ras.git mcsafev6

First commit is just your patch from above (patch wouldn't apply it
directly because of other nearby changes, but I think I didn't break
it)

Second commit pulls the core of fixup_exception() into separate
functions for each class

Third adds a new class that provides the fault number to the fixup
code in regs->ax.

Fourth is just a jumble of the rest .. needs to be split into two
parts (one for machine check handler, second to add __mcsafe_copy())

Fifth is just a hack because I clearly didn't understand what I was
doing in parts 2&3 because my new class shows up as '3' not '1'!

Andy: Can you explain the assembler/linker arithmetic for the class?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

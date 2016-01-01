Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D10386B0003
	for <linux-mm@kvack.org>; Fri,  1 Jan 2016 17:19:53 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id u188so93051509wmu.1
        for <linux-mm@kvack.org>; Fri, 01 Jan 2016 14:19:53 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id hj10si127907581wjb.128.2016.01.01.14.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jan 2016 14:19:52 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id f206so145288969wmf.0
        for <linux-mm@kvack.org>; Fri, 01 Jan 2016 14:19:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBb+MaZUK1vMPNwUchZJed0Fi3vh9_vFP2OoPZsUMoDO=ZQ@mail.gmail.com>
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
	<CA+8MBbK842Ov74ZSU_fmxoZNw_72J+3hg3KQ4C5aBjd_cDYfAA@mail.gmail.com>
	<CA+8MBb+MaZUK1vMPNwUchZJed0Fi3vh9_vFP2OoPZsUMoDO=ZQ@mail.gmail.com>
Date: Fri, 1 Jan 2016 14:19:52 -0800
Message-ID: <CA+8MBbKqKp=AsKiNcaS+zcfw26KQj9CwcDLNqtYLECrt3T4W=g@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Somehow this didn't get sent ... found it in the "Drafts" folder.  But
it's rubbish, skip to the
bottom.

On Thu, Dec 31, 2015 at 12:30 PM, Tony Luck <tony.luck@gmail.com> wrote:
> I switched to BIAS 0xC0000000 ... and now I should get class 1 entries
> (bit31=0, bit30=1).
>
> New patch series coming soon.

Or not :-(

arch/x86/lib/lib.a(memcpy_64.o):(__ex_table+0x4): relocation truncated
to fit: R_X86_64_PC32 against `.fixup'
arch/x86/lib/lib.a(memcpy_64.o):(__ex_table+0xc): relocation truncated
to fit: R_X86_64_PC32 against `.fixup'
...

I guess it was something like this that made you do the 0x20000000 and
subtract the BIAS?

I have a bad feeling that we may not really have four classes, just three:

00: no funny arithmetic
10: BIAS = 0x80000000 ... doesn't trigger truncation warning because
sign bit is set
11: BIAS = 0x40000000 ... ditto
01: BIAS = ? ... Is there some magic value for BIAS that gets this?

--- end of Draft ... now to the real bit

Not sure why I was hung up on *subtracting* values to get the desired
class bits. Just
blindly copying the initial case from your patch?

If you can't get from A to B one way, try going around the other
direction. Subtracting
0xC0000000 is the same as adding 0x40000000 (when playing with u32 values).
That doesn't upset the linker.

I rebased:
git://git.kernel.org/pub/scm/linux/kernel/git/ras/ras.git mcsafev6

still needs a little cleanup, but it all works, and seems to be a much
cleaner approach.  So clean that I wonder whether I really need
the CONFIG_MCE_KERNEL_RECOVERY any more?? The only
place it is used now is around the __mcsafe_copy()

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

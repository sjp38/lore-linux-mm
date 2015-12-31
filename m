Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 28A586B002A
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 15:30:44 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so121717269wmf.0
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 12:30:44 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id x16si39776716wme.57.2015.12.31.12.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Dec 2015 12:30:42 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id l65so42349661wmf.3
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 12:30:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbK842Ov74ZSU_fmxoZNw_72J+3hg3KQ4C5aBjd_cDYfAA@mail.gmail.com>
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
Date: Thu, 31 Dec 2015 12:30:42 -0800
Message-ID: <CA+8MBb+MaZUK1vMPNwUchZJed0Fi3vh9_vFP2OoPZsUMoDO=ZQ@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 30, 2015 at 3:32 PM, Tony Luck <tony.luck@gmail.com> wrote:
> Fifth is just a hack because I clearly didn't understand what I was
> doing in parts 2&3 because my new class shows up as '3' not '1'!
>
> Andy: Can you explain the assembler/linker arithmetic for the class?

Never mind ... figured it out.

The fixup entry in the extable is:

label - . + 0x2000000 - BIAS

The "label - ." part evaluates to a smallish negative value (because
the .fixup section is bundled in towards the end of .text, and the
ex_table section comes right after.

Then you add 0x20000000 to get a positive number, then *subtract*
the BIAS.  I'd picked BIAS = 0x40000000 thinking that would show
up directly in class bits. But 0x1ffff000 - 0x40000000 is 0xdffff000
so bits 31 & 31 are both set, and this is class3

I switched to BIAS 0xC0000000 ... and now I get class 1 entries
(bit31=0, bit30=1).

New patch series coming soon.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

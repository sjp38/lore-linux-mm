Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2906B002A
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 16:22:40 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id wp13so67643940obc.1
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 13:22:40 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id n4si12954623obq.48.2015.12.31.13.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Dec 2015 13:22:39 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id ba1so202101512obb.3
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 13:22:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBb+MaZUK1vMPNwUchZJed0Fi3vh9_vFP2OoPZsUMoDO=ZQ@mail.gmail.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
 <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
 <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
 <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
 <CALCETrV2g6vSQcpNUADWeLMj5O_HDEGgp6vvLw9KgJVTWxZ1+g@mail.gmail.com>
 <CA+8MBbK842Ov74ZSU_fmxoZNw_72J+3hg3KQ4C5aBjd_cDYfAA@mail.gmail.com> <CA+8MBb+MaZUK1vMPNwUchZJed0Fi3vh9_vFP2OoPZsUMoDO=ZQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 31 Dec 2015 13:22:19 -0800
Message-ID: <CALCETrUHiEfCKaD63pU_9mBYSS_msOLQ3C86MirCk+QYB4e-zw@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Robert <elliott@hpe.com>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

On Jan 1, 2016 4:30 AM, "Tony Luck" <tony.luck@gmail.com> wrote:
>
> On Wed, Dec 30, 2015 at 3:32 PM, Tony Luck <tony.luck@gmail.com> wrote:
> > Fifth is just a hack because I clearly didn't understand what I was
> > doing in parts 2&3 because my new class shows up as '3' not '1'!
> >
> > Andy: Can you explain the assembler/linker arithmetic for the class?
>
> Never mind ... figured it out.
>
> The fixup entry in the extable is:
>
> label - . + 0x2000000 - BIAS
>
> The "label - ." part evaluates to a smallish negative value (because
> the .fixup section is bundled in towards the end of .text, and the
> ex_table section comes right after.
>
> Then you add 0x20000000 to get a positive number, then *subtract*
> the BIAS.  I'd picked BIAS = 0x40000000 thinking that would show
> up directly in class bits. But 0x1ffff000 - 0x40000000 is 0xdffff000
> so bits 31 & 31 are both set, and this is class3
>
> I switched to BIAS 0xC0000000 ... and now I get class 1 entries
> (bit31=0, bit30=1).
>
> New patch series coming soon.

That all sounds correct.

You could also just to s/UACCESS/INDIRECT/ or whatever and leave using
the next bit for whoever does the uaccess part, too.  After all,
introducing the "uaccess" class without actually implementing it isn't
very useful.

>
> -Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

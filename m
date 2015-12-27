Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3651A6B000E
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 07:19:03 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id l9so135117260oia.2
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 04:19:03 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id w8si13603002oia.92.2015.12.27.04.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 04:19:02 -0800 (PST)
Received: by mail-ob0-x233.google.com with SMTP id iw8so217860707obc.1
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 04:19:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
 <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
 <CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com> <CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 27 Dec 2015 04:18:42 -0800
Message-ID: <CALCETrV2g6vSQcpNUADWeLMj5O_HDEGgp6vvLw9KgJVTWxZ1+g@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Dec 26, 2015 at 10:57 PM, Tony Luck <tony.luck@gmail.com> wrote:
> On Sat, Dec 26, 2015 at 6:16 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>> We could make one of them 31-bits (since even an "allyesconfig" kernel
>>>> is still much smaller than a gigabyte) to free a bit for a flag. But there
>>>> are those external tools to pre-sort exception tables that would all
>>>> need to be fixed too.
>>
>> Wait, why?  The external tools sort by source address, and we'd
>> squeeze the flag into the target address, no?
>
> I was thinking that we'd need to recompute the fixup when we move
> the entry to its new sorted location. So that:
>
>  ex_fixup_addr(const struct exception_table_entry *x)
>  {
>           return (unsigned long)&x->fixup + x->fixup;
>  }
>
> will get the right value.  Maybe this would still work out
> if the fixup is a 31-bit value plus a flag, but the external
> tool thinks it is a 32-bit value?  I'd have to ponder that.

I think I can save you some pondering.  This old patch gives two flag
bits.  Feel free to borrow the patch, but you'll probably want to
change the _EXTABLE_CLASS_XYZ macros:

https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=strict_uaccess_fixups/patch_v1&id=16644d9460fc6531456cf510d5efc57f89e5cd34

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

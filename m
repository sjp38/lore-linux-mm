Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id A3A0F6B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:12:14 -0500 (EST)
Received: by oian133 with SMTP id n133so21308516oia.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:12:14 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id h5si4124640obe.20.2015.12.14.12.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 12:12:14 -0800 (PST)
Received: by obciw8 with SMTP id iw8so140914627obc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:12:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151214194648.GA15222@agluck-desk.sc.intel.com>
References: <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
 <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
 <CALCETrUFQXPB9HM8O+4UfMij7nodfrWtjicy0XNhOiWCka+4yw@mail.gmail.com>
 <20151214083625.GA28073@gmail.com> <20151214194648.GA15222@agluck-desk.sc.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Dec 2015 12:11:53 -0800
Message-ID: <CALCETrUGro3+Ef6H4cJ1Ti1R5TZZ-DBEx4bR1c7drvsGyAr--w@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Mon, Dec 14, 2015 at 11:46 AM, Luck, Tony <tony.luck@intel.com> wrote:
> On Mon, Dec 14, 2015 at 09:36:25AM +0100, Ingo Molnar wrote:
>> >     /* deal with it */
>> >
>> > That way the magic is isolated to the function that needs the magic.
>>
>> Seconded - this is the usual pattern we use in all assembly functions.
>
> Ok - you want me to write some x86 assembly code (you may regret that).
>

All you have to do is erase all of the ia64 asm knowledge from your
brain and repurpose 1% of that space for x86 asm.  You'll be a
world-class expert!

> Initial question ... here's the fixup for __copy_user_nocache()
>
>                 .section .fixup,"ax"
>         30:     shll $6,%ecx
>                 addl %ecx,%edx
>                 jmp 60f
>         40:     lea (%rdx,%rcx,8),%rdx
>                 jmp 60f
>         50:     movl %ecx,%edx
>         60:     sfence
>                 jmp copy_user_handle_tail
>                 .previous
>
> Are %ecx and %rcx synonyms for the same register? Is there some
> super subtle reason we use the 'r' names in the "40" fixup, but
> the 'e' names everywhere else in this code (and the 'e' names in
> the body of the original function)?

rcx is a 64-bit register.  ecx is the low 32 bits of it.  If you read
from ecx, you get the low 32 bits, but if you write to ecx, you zero
the high bits as a side-effect.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

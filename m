Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id DCEB382FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 21:16:12 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id ba1so122707063obb.3
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 18:16:12 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id n8si17391892oed.49.2015.12.26.18.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 18:16:12 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id iw8so214064378obc.1
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 18:16:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic> <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
 <CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 26 Dec 2015 18:15:52 -0800
Message-ID: <CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Dec 26, 2015 at 6:08 PM, Tony Luck <tony.luck@gmail.com> wrote:
> On Sat, Dec 26, 2015 at 6:54 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Dec 26, 2015 6:33 PM, "Borislav Petkov" <bp@alien8.de> wrote:
>>> Andy, why is that? It makes the exception handling much simpler this way...
>>>
>>
>> I like the idea of moving more logic into C, but I don't like
>> splitting the logic across files and adding nasty special cases like
>> this.
>>
>> But what if we generalized it?  An extable entry gives a fault IP and
>> a landing pad IP.  Surely we can squeeze a flag bit in there.
>
> The clever squeezers have already been here. Instead of a pair
> of 64-bit values for fault_ip and fixup_ip they managed with a pair
> of 32-bit values that are each the relative offset of the desired address
> from the table location itself.
>
> We could make one of them 31-bits (since even an "allyesconfig" kernel
> is still much smaller than a gigabyte) to free a bit for a flag. But there
> are those external tools to pre-sort exception tables that would all
> need to be fixed too.
>
> Or we could direct the new fixups into a .fixup2 ELF section and put
> begin/end labels around that ... so we could check the address of the
> fixup to see whether it is a legacy or new format entry.
>

Either of those sounds good to me.

>> set the bit, you get an extended extable entry.  Instead of storing a
>> landing pad, it stores a pointer to a handler descriptor:
>>
>> struct extable_handler {
>>   bool (*handler)(struct pt_regs *, struct extable_handler *, ...):
>> };
>>
>> handler returns true if it handled the error and false if it didn't.
>
> It may be had to call that from the machine check handler ... the
> beauty of just patching the IP and returning from the handler was
> that it got us out of machine check context.

Your handler will need to know that it's in machine check context :)
In most cases (e.g. yours), the handler should just modify regs and
return.

>
>> The "..." encodes the fault number, error code, cr2, etc.  Maybe it
>> would be "unsigned long exception, const struct extable_info *info"
>> where extable_info contains a union?  I really wish C would grow up
>> and learn about union types.
>
> All this is made more difficult because the h/w doesn't give us
> all the things we might want to know (e.g. the virtual address).
> We just have a physical address (which may be missing some
> low order bits).

True.  I'm afraid that nothing I suggest can possibly help you there.

Anyhow, this could be a decent signature:

bool (*handler)(struct pt_regs *, struct extable_handler *, unsigned
int exception, unsigned long error_code, unsigned long extra):

If exception is X86_TRAP_PF, then extra is CR2.  If exception is
X86_TRAP_MC, then extra is however much of the PA you know.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6F52782FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 09:55:18 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id l9so128527297oia.2
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 06:55:18 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id o7si17808503oia.117.2015.12.26.06.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 06:55:16 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id 18so210718374obc.2
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 06:55:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151226103252.GA21988@pd.tnic>
References: <20151224214632.GF4128@pd.tnic> <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
 <20151225114937.GA862@pd.tnic> <5FBC1CF1-095B-466D-85D6-832FBFA98364@intel.com>
 <20151226103252.GA21988@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 26 Dec 2015 06:54:57 -0800
Message-ID: <CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "Luck, Tony" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Dec 26, 2015 6:33 PM, "Borislav Petkov" <bp@alien8.de> wrote:
>
> On Fri, Dec 25, 2015 at 08:05:39PM +0000, Luck, Tony wrote:
> > mce_in_kernel_recov() should check whether we have a fix up entry for
> > the specific IP that hit the machine check before rating the severity
> > as kernel recoverable.
>
> Yeah, it is not precise right now. But this is easy - I'll change it to
> a simpler version of fixup_mcexception() to iterate over the exception
> table.
>
> > If we add more functions (for different cache behaviour, or to
> > optimize for specific processor model) we can make sure to put them
> > all together inside begin/end labels.
>
> Yeah, I think we can do even better than that as all the info is in the
> ELF file already. For example, ENDPROC(__mcsafe_copy) generates
>
> .type __mcsafe_copy, @function ; .size __mcsafe_copy, .-__mcsafe_copy
>
> and there's the size of the function, I guess we can macroize something
> like that or even parse the ELF file:
>
> $ readelf --syms vmlinux | grep mcsafe
>    706: ffffffff819df73e    14 OBJECT  LOCAL  DEFAULT   11 __kstrtab___mcsafe_copy
>    707: ffffffff819d0e18     8 OBJECT  LOCAL  DEFAULT    9 __kcrctab___mcsafe_copy
>  56107: ffffffff819b3bb0    16 OBJECT  GLOBAL DEFAULT    7 __ksymtab___mcsafe_copy
>  58581: ffffffff812e6d70   179 FUNC    GLOBAL DEFAULT    1 __mcsafe_copy
>  62233: 000000003313f9d4     0 NOTYPE  GLOBAL DEFAULT  ABS __crc___mcsafe_copy
>  68818: ffffffff812e6e23     0 NOTYPE  GLOBAL DEFAULT    1 __mcsafe_copy_end
>
> __mcsafe_copy is of size 179 bytes:
>
> 0xffffffff812e6d70 + 179 = 0xffffffff812e6e23 which is __mcsafe_copy_end
> so those labels should not really be necessary as they're global and
> polluting the binary unnecessarily.
>
> > We would run into trouble if we want to have some in-line macros for
> > use from arbitrary C-code like we have for the page fault case.
>
> Example?
>
> > I might make the arbitrary %rax value be #PF and #MC to reflect the
> > h/w fault that got us here rather than -EINVAL/-EFAULT. But that's
> > just bike shedding.
>
> Yeah, I picked those arbitrarily to show the intention.
>
> > But now we are back to having the fault handler poke %rax again, which
> > made Andy twitch before.
>
> Andy, why is that? It makes the exception handling much simpler this way...
>

I like the idea of moving more logic into C, but I don't like
splitting the logic across files and adding nasty special cases like
this.

But what if we generalized it?  An extable entry gives a fault IP and
a landing pad IP.  Surely we can squeeze a flag bit in there.  If you
set the bit, you get an extended extable entry.  Instead of storing a
landing pad, it stores a pointer to a handler descriptor:

struct extable_handler {
  bool (*handler)(struct pt_regs *, struct extable_handler *, ...):
};

handler returns true if it handled the error and false if it didn't.
The "..." encodes the fault number, error code, cr2, etc.  Maybe it
would be "unsigned long exception, const struct extable_info *info"
where extable_info contains a union?  I really wish C would grow up
and learn about union types.

Now the copy routine can do whatever it pleases, in C, locally.   For
example, if you set up a full stack frame (or even just a known SP
offset), you could unwind it in C and just return a value directly,
or, even better, you could manually tail-call a C fixup that goes one
byte at a time instead of writing that mess in asm.  Like this,
assuming I got it right:

regs->sp = regs->bp;
regs->bp = *(unsigned long *)regs->sp;
regs->sp += sizeof(unsigned long);
regs->ip = fix_it;
regs->di = something useful?

Bonus points if you can figure out a clean way to register a handler
for an IP range without bloating struct extable_entry.

--Andy

P.S. this mechanism could potentially clean up some entry nastiness, too.

P.P.S.  Why the hell doesn't *user* code have a mechanism like this?
Windows does, and it's been around for longer than I've known how to
write C code...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEA1F6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 06:20:17 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id f206so24017814wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 03:20:17 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ha10si151694591wjc.117.2016.01.05.03.20.16
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 03:20:16 -0800 (PST)
Date: Tue, 5 Jan 2016 12:20:14 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a
 bit)
Message-ID: <20160105112014.GC3718@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com>
 <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic>
 <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
 <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
 <20160104210228.GR22941@pd.tnic>
 <CALCETrVOF9P3YFKMeShp0FYX15cqppkWhhiOBi6pxfu6k+XDmA@mail.gmail.com>
 <20160104230246.GU22941@pd.tnic>
 <CALCETrUcuZSp_D-bsZi3i7m2-DKHBOe4KpmJnbR+1bVvbyp5Mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrUcuZSp_D-bsZi3i7m2-DKHBOe4KpmJnbR+1bVvbyp5Mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@gmail.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 04, 2016 at 03:25:58PM -0800, Andy Lutomirski wrote:
> On Mon, Jan 4, 2016 at 3:02 PM, Borislav Petkov <bp@alien8.de> wrote:
> > On Mon, Jan 04, 2016 at 02:29:09PM -0800, Andy Lutomirski wrote:
> >> Josh will argue with you if he sees that :)
> >
> > Except Josh doesn't need allyesconfigs. tinyconfig's __ex_table is 2K.
> 
> If we do the make-it-bigger approach, we get a really nice
> simplification.  Screw the whole 'class' idea -- just store an offset
> to a handler.
> 
> bool extable_handler_default(struct pt_regs *regs, unsigned int fault,
> unsigned long error_code, unsigned long info)
> {
>     if (fault == X86_TRAP_MC)
>         return false;
> 
>     ...
> }
> 
> bool extable_handler_mc_copy(struct pt_regs *regs, unsigned int fault,
> unsigned long error_code, unsigned long info);
> bool extable_handler_getput_ex(struct pt_regs *regs, unsigned int
> fault, unsigned long error_code, unsigned long info);
> 
> and then shove ".long extable_handler_whatever - ." into the extable entry.

And to make it even cooler and more generic, you can make the exception
table entry look like this:

{ <offset to fault address>, <offset to handler>, <offset to an opaque pointer> }

and that opaque pointer would be a void * to some struct we pass to
that handler and filled with stuff it needs. For starters, it would
contain the return address where the fixup wants us to go.

The struct will have to be statically allocated but ok, that's fine.

And this way you can do all the sophisticated handling you desire.

> Major bonus points to whoever can figure out how to make
> extable_handler_iret work -- the current implementation of that is a
> real turd.  (Hint: it's not clear to me that it's even possible
> without preserving at least part of the asm special case.)

What's extable_handler_iret? IRET-ting from an exception? Where do we do
that?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

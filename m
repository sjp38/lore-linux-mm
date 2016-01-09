Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 014AF828DE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 01:36:35 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id wp13so235989539obc.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 22:36:34 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id m100si17918654oik.31.2016.01.08.22.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 22:36:33 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id y66so347847138oig.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 22:36:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMzpN2jAvhM74ZGNecnqU3ozLUXb185Cb2iZN6LB0bToFo4Xhw@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com> <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
 <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
 <CAMzpN2j=ZRrL=rXLOTOoUeodtu_AqkQPm1-K0uQmVwLAC6MQGA@mail.gmail.com> <CAMzpN2jAvhM74ZGNecnqU3ozLUXb185Cb2iZN6LB0bToFo4Xhw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 22:36:14 -0800
Message-ID: <CALCETrVR=_CYHt4R4yurKpnfi76P8GTwHycPLmqPshK2bCv+Fg@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Robert <elliott@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

On Jan 8, 2016 8:31 PM, "Brian Gerst" <brgerst@gmail.com> wrote:
>
> On Fri, Jan 8, 2016 at 10:39 PM, Brian Gerst <brgerst@gmail.com> wrote:
> > On Fri, Jan 8, 2016 at 8:52 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> >> On Fri, Jan 8, 2016 at 12:49 PM, Tony Luck <tony.luck@intel.com> wrote:
> >>> Huge amounts of help from  Andy Lutomirski and Borislav Petkov to
> >>> produce this. Andy provided the inspiration to add classes to the
> >>> exception table with a clever bit-squeezing trick, Boris pointed
> >>> out how much cleaner it would all be if we just had a new field.
> >>>
> >>> Linus Torvalds blessed the expansion with:
> >>>   I'd rather not be clever in order to save just a tiny amount of space
> >>>   in the exception table, which isn't really criticial for anybody.
> >>>
> >>> The third field is a simple integer indexing into an array of handler
> >>> functions (I thought it couldn't be a relative pointer like the other
> >>> fields because a module may have its ex_table loaded more than 2GB away
> >>> from the handler function - but that may not be actually true. But the
> >>> integer is pretty flexible, we are only really using low two bits now).
> >>>
> >>> We start out with three handlers:
> >>>
> >>> 0: Legacy - just jumps the to fixup IP
> >>> 1: Fault - provide the trap number in %ax to the fixup code
> >>> 2: Cleaned up legacy for the uaccess error hack
> >>
> >> I think I preferred the relative function pointer approach.
> >>
> >> Also, I think it would be nicer if the machine check code would invoke
> >> the handler regardless of which handler (or class) is selected.  Then
> >> the handlers that don't want to handle #MC can just reject them.
> >>
> >> Also, can you make the handlers return bool instead of int?
> >
> > I'm hashing up an idea that could eliminate alot of text in the .fixup
> > section, but it needs the integer handler method to work.  We have
> > alot of fixup code that does "mov $-EFAULT, reg; jmp xxxx".  If we
> > encode the register in the third word, the handler can be generic and
> > no fixup code for each user access would be needed.  That would
> > recover alot of the memory used by expanding the exception table.
>
> On second thought, this could still be implemented with a relative
> function pointer.  We'd just need a separate function for each
> register.
>

If we could get gcc to play along (which, IIRC, it already can for
__put_user), we can do much better with jump labels -- the fixup
target would be a jump label.

Even without that, how about using @cc?  Do:

clc
mov whatever, wherever

The fixup sets the carry flag and skips the faulting instruction
(either by knowing the length or by decoding it), and the inline asm
causes gcc to emit jc to the error logic.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

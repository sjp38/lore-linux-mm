Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF706B026B
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 11:30:56 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a9so2197315pff.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:30:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u69si8448230pgb.10.2018.01.19.08.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 08:30:55 -0800 (PST)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B6E2B21759
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 16:30:54 +0000 (UTC)
Received: by mail-io0-f173.google.com with SMTP id f4so964489ioh.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:30:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119095523.GY28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org> <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
 <20180117091853.GI28161@8bytes.org> <CALCETrUPcWfNA6ETktcs2vmcrPgJs32xMpoATGn_BFk+1ueU7g@mail.gmail.com>
 <20180119095523.GY28161@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 19 Jan 2018 08:30:33 -0800
Message-ID: <CALCETrWSUJY=Har-Fvcby4SY_BPSh=WL0X_MqsT2z+tfNshWDA@mail.gmail.com>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Fri, Jan 19, 2018 at 1:55 AM, Joerg Roedel <joro@8bytes.org> wrote:
> Hey Andy,
>
> On Wed, Jan 17, 2018 at 10:10:23AM -0800, Andy Lutomirski wrote:
>> On Wed, Jan 17, 2018 at 1:18 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
>> > Just read up on vm86 mode control transfers and the stack layout then.
>> > Looks like I need to check for eflags.vm=1 and copy four more registers
>> > from/to the entry stack. Thanks for pointing that out.
>>
>> You could just copy those slots unconditionally.  After all, you're
>> slowing down entries by an epic amount due to writing CR3 on with PCID
>> off, so four words copied should be entirely lost in the noise.  OTOH,
>> checking for VM86 mode is just a single bt against EFLAGS.
>>
>> With the modern (rewritten a year or two ago by Brian Gerst) vm86
>> code, all the slots (those actually in pt_regs) are in the same
>> location regardless of whether we're in VM86 mode or not, but we're
>> still fiddling with the bottom of the stack.  Since you're controlling
>> the switch to the kernel thread stack, you can easily just write the
>> frame to the correct location, so you should not need to context
>> switch sp1 -- you can do it sanely and leave sp1 as the actual bottom
>> of the kernel stack no matter what.  In fact, you could probably avoid
>> context switching sp0, either, which would be a nice cleanup.
>
> I am not sure what you mean by "not context switching sp0/sp1" ...

You're supposed to read what I meant, not what I said...

I meant that we could have sp0 have a genuinely constant value per
cpu.  That means that the entry trampoline ends up with RIP, etc in a
different place depending on whether VM was in use, but the entry
trampoline code should be able to handle that.  sp1 would have a value
that varies by task, but it could just point to the top of the stack
instead of being changed depending on whether VM is in use.  Instead,
the entry trampoline would offset the registers as needed to keep
pt_regs in the right place.

I think you already figured all of that out, though :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

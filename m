Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B54846B0270
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:11:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a13so16305575pgt.0
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:11:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l28si13215950pfg.215.2017.12.12.10.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:11:02 -0800 (PST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4AC4C20C0F
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:11:02 +0000 (UTC)
Received: by mail-it0-f51.google.com with SMTP id b5so607526itc.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:11:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de>
 <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com> <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 10:10:40 -0800
Message-ID: <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:09 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Dec 12, 2017 at 10:03:02AM -0800, Andy Lutomirski wrote:
>> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
>> > @@ -171,6 +172,9 @@ static void exit_to_usermode_loop(struct
>> >                 /* Disable IRQs and retry */
>> >                 local_irq_disable();
>> >
>> > +               if (cached_flags & _TIF_LDT)
>> > +                       ldt_exit_user(regs);
>>
>> Nope.  To the extent that this code actually does anything (which it
>> shouldn't since you already forced the access bit),
>
> Without this; even with the access bit set; IRET will go wobbly and
> we'll #GP on the user-space side. Try it ;-)

Maybe later.

But that means that we need Intel and AMD to confirm WTF is going on
before this blows up even with LAR on some other CPU.

>
>> it's racy against
>> flush_ldt() from another thread, and that race will be exploitable for
>> privilege escalation.  It needs to be outside the loopy part.
>
> The flush_ldt (__ldt_install after these patches) would re-set the TIF
> flag. But sure, we can move this outside the loop I suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9F216B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 12:21:38 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y64so9472283itd.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 09:21:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k194sor5104947itb.54.2018.03.05.09.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 09:21:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305164448.GS16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org> <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org> <CAMzpN2gQ0pfSZES_cnNJSzvvGxbzuHdP0iAjx5GG5kJ6FGudbw@mail.gmail.com>
 <20180305164448.GS16484@8bytes.org>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 5 Mar 2018 12:21:36 -0500
Message-ID: <CAMzpN2jnaYSqEwuad5jsi=FJc_BNd_NyKWcjXf7QGq1ugLLrNw@mail.gmail.com>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 11:44 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Mon, Mar 05, 2018 at 09:51:29AM -0500, Brian Gerst wrote:
>> For the IRET fault case you will still need to catch it in the
>> exception code.  See the 64-bit code (.Lerror_bad_iret) for example.
>> For 32-bit, you could just expand that check to cover the whole exit
>> prologue after the CR3 switch, including the data segment loads.
>
> I had a look at the 64 bit code and the exception-in-kernel case seems
> to be handled differently than on 32 bit. The 64 bit entry code has
> checks for certain kinds of errors like iret exceptions.
>
> On 32 bit this is implemented via the standard exception tables which
> get an entry for every EIP that might fault (usually segment loading
> operations, but also iret).
>
> So, unless I am missing something, all the exception entry code has to
> do is to remember the stack and the cr3 with which it was entered (if
> entered from kernel mode) and restore those before iret. And this is
> what I implemented in v3 of this patch-set.

I also noticed that 32-bit will raise SIGILL for all IRET faults,
while 64-bit will raise SIGBUS (#NP/#SS) or SIGSEGV (#GP).  The 64-bit
code is better since it doesn't lose the original fault type, whereas
SIGILL is wrong for this case (illegal opcode).

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

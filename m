Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAE46B0011
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:51:31 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g69so9075635ita.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:51:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor4789236iti.7.2018.03.05.06.51.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 06:51:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305131231.GR16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org> <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 5 Mar 2018 09:51:29 -0500
Message-ID: <CAMzpN2gQ0pfSZES_cnNJSzvvGxbzuHdP0iAjx5GG5kJ6FGudbw@mail.gmail.com>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 8:12 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Mon, Mar 05, 2018 at 04:17:45AM -0800, Linus Torvalds wrote:
>>     Restoring the segments can cause exceptions that need to be
>>     handled. With PTI enabled, we still need to be on kernel cr3
>>     when the exception happens. For the cr3-switch we need
>>     at least one integer scratch register, so we can't switch
>>     with the user integer registers already loaded.
>>
>>
>> This fundamentally seems wrong.
>
> Okay, right, with v3 it is wrong, in v2 I still thought I could get away
> without remembering the entry-cr3, but didn't think about the #DB case
> then.
>
> In v3 I added code which remembers the entry-cr3 and handles the
> entry-from-kernel-mode-with-user-cr3 case for all exceptions including
> #DB.
>
>> The things is, we *know* that we will restore two segment registers with the
>> user cr3 already loaded: CS and SS get restored with the final iret.
>
> Yeah, I know, but the iret-exception path is fine because it will
> deliver a SIGILL and doesn't return to the faulting iret.
>
> Anyway, I will remove these restore-reorderings, they are not needed
> anymore.
>
>> So has this been tested with
>>
>>  - single-stepping through sysenter
>>
>>    This takes a DB fault in the first kernel instruction. We're in kernel mode,
>> but with user cr3.
>>
>>  - ptracing and setting CS/SS to something bad
>>
>>    That should test the "exception on iret" case - again in kernel mode, but
>> with user cr3 restored for the return.
>
> The iret-exception case is tested by the ldt_gdt selftest (the
> do_multicpu_tests subtest). But I didn't actually tested single-stepping
> through sysenter yet. I just re-ran the same tests I did with v2 on this
> patch-set.
>
> Regards,
>
>         Joerg
>

For the IRET fault case you will still need to catch it in the
exception code.  See the 64-bit code (.Lerror_bad_iret) for example.
For 32-bit, you could just expand that check to cover the whole exit
prologue after the CR3 switch, including the data segment loads.

I do wonder though, how expensive is a CR3 read?  The SDM implies that
only writes are serializing.  It may be simpler to just
unconditionally check it.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

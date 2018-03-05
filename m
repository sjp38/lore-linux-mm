Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 828566B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 16:58:34 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g69so10107051ita.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 13:58:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor7117609ioe.58.2018.03.05.13.58.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 13:58:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305213550.GV16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org> <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org> <CA+55aFwn5EkHTfrUFww54CDWovoUornv6rSrao43agbLBQD6-Q@mail.gmail.com>
 <CAMzpN2hscOXJFzm07Hk=2Ttr3wQFSisxP=EZhRMtAU6xSm8zSw@mail.gmail.com>
 <CA+55aFwxiZ9bD2Zu5xV0idz_dDctPvrrWA2r54+NL4aj9oeN8Q@mail.gmail.com> <20180305213550.GV16484@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Mar 2018 13:58:32 -0800
Message-ID: <CA+55aFx2dxZmL487CnhV6rWRiqmJwZNAspyPqCD4Hwqxwncs6Q@mail.gmail.com>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 1:35 PM, Joerg Roedel <joro@8bytes.org> wrote:
> On Mon, Mar 05, 2018 at 12:50:33PM -0800, Linus Torvalds wrote:
>>
>> Ahh, good. So presumably Joerg actually did check it, just didn't even notice ;)
>
> Yeah, sort of. I ran the test, but it didn't catch the failure case in
> previous versions which was return to user with kernel-cr3 :)

Ahh. Yes, that's bad. The NX protection to guarantee that you don't
return to user mode was really good on x86-64.

So some other case could slip through, because user code can happily
run with the kernel page tables.

> I could probably add some debug instrumentation to check for that in my
> future testing, as there is no NX protection in the user address-range
> for the kernel-cr3.

Does not NX work with PAE?

Oh, it looks like the NX bit is marked as "RSVD (must be 0)" in the
PDPDT. Oh well.

                  Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

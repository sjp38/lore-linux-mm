Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 925B06B0009
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 13:24:01 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r79so16882093iod.19
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 10:24:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor5072410itb.129.2018.03.05.10.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 10:24:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305131231.GR16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org> <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Mar 2018 10:23:59 -0800
Message-ID: <CA+55aFwn5EkHTfrUFww54CDWovoUornv6rSrao43agbLBQD6-Q@mail.gmail.com>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 5:12 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
>> The things is, we *know* that we will restore two segment registers with the
>> user cr3 already loaded: CS and SS get restored with the final iret.
>
> Yeah, I know, but the iret-exception path is fine because it will
> deliver a SIGILL and doesn't return to the faulting iret.

That's not so much my worry, as just getting %cr3 wrong. The fact is,
we still take the exception, and we still have to handle it, and that
still needs to get the user<->kernel cr3 right.

So then the whole "restore segments early" must be wrong, because
*that* path must get it all right too, no?

And it appears that the code *does* get it right, and you can just
avoid this patch entirely?

> The iret-exception case is tested by the ldt_gdt selftest (the
> do_multicpu_tests subtest). But I didn't actually tested single-stepping
> through sysenter yet. I just re-ran the same tests I did with v2 on this
> patch-set.

Ok. Maybe we should have a test for the "take DB on first instruction
of sysenter".

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

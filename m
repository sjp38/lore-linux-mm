Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA76F6B0003
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 15:18:19 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e64so2303417itd.1
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 12:18:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s66sor1256135itd.18.2018.02.10.12.18.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Feb 2018 12:18:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50431bff2cda445490f5242c1189c8cd@AcuMS.aculab.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org> <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <aa52108c-4874-9810-8ff5-e6415189cd73@redhat.com> <50431bff2cda445490f5242c1189c8cd@AcuMS.aculab.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 10 Feb 2018 12:18:17 -0800
Message-ID: <CA+55aFwdk9pGMxHpScf9jQAL0K0OkkghCWMrgxcrdFtYPbXmUw@mail.gmail.com>
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Sat, Feb 10, 2018 at 7:26 AM, David Laight <David.Laight@aculab.com> wrote:
>
> The alignment doesn't matter, 'rep movsl' will still work.

.. no it won't. It might not copy the last two bytes or whatever,
because the shift of the count will have ignored the low bits.

But since an unaligned stack pointer really shouldn't be an issue,
it's fine to not care.

>> Indeed, "rep movs" has some setup overhead that makes it undesirable
>> for small sizes. In my testing, moving less than 128 bytes with "rep movs"
>> is a loss.
>
> It very much depends on the cpu.

No again.

It does NOT depend on the CPU, since the only CPU's that are relevant
to this patch are the ones that don't do 64-bit. If you run a 32-bit
Linux on a 64-bit CPU, performance simply isn't an issue. The problem
is between keyboard and chair, not in the kernel.

And absolutely *no* 32-bit-only CPU does "rep movs" really well.  Some
of them do it even worse than others (P4), but none of them do a great
job.

That said, none of them should do _such_ a shitty job that this will
be in the least noticeable compared to all the crazy %cr3 stuff.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

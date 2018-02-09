Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D21A6B025E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:49:01 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n19so8083791iob.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:49:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r77sor1796826ioe.287.2018.02.09.11.49.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 11:49:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180209192515.qvvixkn5rz77oz6l@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org> <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <20180209190226.lqh6twf7thfg52cq@suse.de> <CA+55aFzy6ZJDUpgHY0J2_z4kODaiYPgyHuOsMGiXmrhgR3kyPQ@mail.gmail.com>
 <20180209192515.qvvixkn5rz77oz6l@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 Feb 2018 11:48:59 -0800
Message-ID: <CA+55aFw643jQxVDrm05ZJ6YkVdqBBJ8WH-+=QCx3SDXrVN-TxA@mail.gmail.com>
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 9, 2018 at 11:25 AM, Joerg Roedel <jroedel@suse.de> wrote:
>
> Ugh, okay. So I switch to movsl, that should at least perform on-par
> with the chain of 'pushl' instructions I had before.

It should generally be roughly in the same ballpark.

I think the instruction scheduling ends up basically breaking around
microcoded instructions, which is why you'll get something like 12+n
cycles for "rep movs" on some uarchs, but at that point it's probably
mostly in the noise compared to all the other nasty PTI things.

You won't see any of the _real_ advantages (which are about moving
cachelines at a time), so with smallish copies you really only see the
downsides of "rep movs", which is mainly that instruction scheduling
hickup with any miocrocode.

But with the iret and the cr3 movement, you aren't going to have a
nice well-behaved pipeline anyway.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

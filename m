Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44E436B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:00:22 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r10-v6so150399itc.2
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:00:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w21-v6sor3934311jad.106.2018.07.23.12.00.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 12:00:20 -0700 (PDT)
MIME-Version: 1.0
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <20180723140925.GA4285@amd>
In-Reply-To: <20180723140925.GA4285@amd>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 Jul 2018 12:00:08 -0700
Message-ID: <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
>
> Meanwhile... it looks like gcc is not slowed down significantly, but
> other stuff sees 30% .. 40% slowdowns... which is rather
> significant.

That is more or less expected.

Gcc spends about 90+% of its time in user space, and the system calls
it *does* do tend to be "real work" (open/read/etc). And modern gcc's
no longer have the pipe between cpp and cc1, so they don't have that
issue either (which would have sjhown the PTI slowdown a lot more)

Some other loads will do a lot more time traversing the user/kernel
boundary, and in 32-bit mode you won't be able to take advantage of
the address space ID's, so you really get the full effect.

> Would it be possible to have per-process control of kpti? I have
> some processes where trading of speed for security would make sense.

That was pretty extensively discussed, and no sane model for it was
ever agreed upon.  Some people wanted it per-thread, others per-mm,
and it wasn't clear how to set it either and how it should inherit
across fork/exec, and what the namespace rules etc should be.

You absolutely need to inherit it (so that you can say "I trust this
session" or whatever), but at the same time you *don't* want to
inherit if you have a server you trust that then spawns user processes
(think "I want systemd to not have the overhead, but the user
processes it spawns obviously do need protection").

It was just a morass. Nothing came out of it.  I guess people can
discuss it again, but it's not simple.

               Linus

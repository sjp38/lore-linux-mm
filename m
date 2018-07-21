Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A04FF6B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 17:07:05 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e21-v6so12421784itc.5
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 14:07:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r70-v6sor1677341ioi.299.2018.07.21.14.07.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Jul 2018 14:07:04 -0700 (PDT)
MIME-Version: 1.0
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com>
 <20180720174846.GF18541@8bytes.org> <CALCETrUj4cLpOKUbJUfLqKJFkjAgeraE=ORQ-e-bKU+AHda0=Q@mail.gmail.com>
 <20180720213700.gh6d2qd2ck6nt4ax@suse.de> <D89602E9-E620-4AF0-822C-206D7F0BA071@amacapital.net>
In-Reply-To: <D89602E9-E620-4AF0-822C-206D7F0BA071@amacapital.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 21 Jul 2018 14:06:52 -0700
Message-ID: <CA+55aFyjFjdeAwAOu-WsE=yk_+cAaaOvp4-DSEHDaWG+1g_BSA@mail.gmail.com>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in all page-tables
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Joerg Roedel <jroedel@suse.de>, Andrew Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, Jul 20, 2018 at 3:20 PM Andy Lutomirski <luto@amacapital.net> wrote=
:
> Thanks for digging!  The problem was presumably that vmalloc_fault() will=
 IRET and re-enable NMIs on the way out.
>  But we=E2=80=99ve supported page faults on user memory in NMI handlers o=
n 32-bit and 64-bit for quite a while, and it=E2=80=99s fine now.
>
> I would remove the warning, re-test, and revert the other patch.

Agreed. I don't think we have any issues with page faults during NMI
any more.  Afaik the kprobe people depend on it.

That said, 64-bit mode has that scary PV-op case
(arch_flush_lazy_mmu_mode). Being PV mode, I can't find it in myself
to worry about it, I'm assuming it's ok.

                Linus

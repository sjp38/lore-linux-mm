Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E86D96B000D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:32:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j4-v6so6557196pgq.16
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:32:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a36-v6si2332348pla.207.2018.07.20.12.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:32:32 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 421932086E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:32:32 +0000 (UTC)
Received: by mail-wm0-f42.google.com with SMTP id s14-v6so10875014wmc.1
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:32:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180720174846.GF18541@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com>
 <20180720174846.GF18541@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 20 Jul 2018 12:32:10 -0700
Message-ID: <CALCETrUj4cLpOKUbJUfLqKJFkjAgeraE=ORQ-e-bKU+AHda0=Q@mail.gmail.com>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in all page-tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, Jul 20, 2018 at 10:48 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Fri, Jul 20, 2018 at 10:06:54AM -0700, Andy Lutomirski wrote:
>> > On Jul 20, 2018, at 6:22 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> >
>> > From: Joerg Roedel <jroedel@suse.de>
>> >
>> > The ring-buffer is accessed in the NMI handler, so we better
>> > avoid faulting on it. Sync the vmalloc range with all
>> > page-tables in system to make sure everyone has it mapped.
>> >
>> > This fixes a WARN_ON_ONCE() that can be triggered with PTI
>> > enabled on x86-32:
>> >
>> >    WARNING: CPU: 4 PID: 0 at arch/x86/mm/fault.c:320 vmalloc_fault+0x220/0x230
>> >
>> > This triggers because with PTI enabled on an PAE kernel the
>> > PMDs are no longer shared between the page-tables, so the
>> > vmalloc changes do not propagate automatically.
>>
>> It seems like it would be much more robust to fix the vmalloc_fault()
>> code instead.
>
> The question is whether the NMI path is nesting-safe, then we can remove
> the WARN_ON_ONCE(in_nmi()) in the vmalloc_fault path. It should be
> nesting-safe on x86-32 because of the way the stack-switch happens
> there. If its also nesting-safe on x86-64 the warning there can be
> removed.
>
> Or did you think of something else to fix there?

I'm just reading your changelog, and you said the PMDs are no longer
shared between the page tables.  So this presumably means that
vmalloc_fault() no longer actually works correctly on PTI systems.  I
didn't read the code to figure out *why* it doesn't work, but throwing
random vmalloc_sync_all() calls around is wrong.

Or maybe the bug really just is the warning.  The warning can probably go.

>
>
> Thanks,
>
>         Joerg
>

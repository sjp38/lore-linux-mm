Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7036C6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:37:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b25-v6so5186930eds.17
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:37:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s29-v6si1955558edd.58.2018.07.20.14.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 14:37:04 -0700 (PDT)
Date: Fri, 20 Jul 2018 23:37:00 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in
 all page-tables
Message-ID: <20180720213700.gh6d2qd2ck6nt4ax@suse.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-2-git-send-email-joro@8bytes.org>
 <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com>
 <20180720174846.GF18541@8bytes.org>
 <CALCETrUj4cLpOKUbJUfLqKJFkjAgeraE=ORQ-e-bKU+AHda0=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUj4cLpOKUbJUfLqKJFkjAgeraE=ORQ-e-bKU+AHda0=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, Jul 20, 2018 at 12:32:10PM -0700, Andy Lutomirski wrote:
> I'm just reading your changelog, and you said the PMDs are no longer
> shared between the page tables.  So this presumably means that
> vmalloc_fault() no longer actually works correctly on PTI systems.  I
> didn't read the code to figure out *why* it doesn't work, but throwing
> random vmalloc_sync_all() calls around is wrong.

Hmm, so the whole point of vmalloc_fault() fault is to sync changes from
swapper_pg_dir to process page-tables when the relevant parts of the
kernel page-table are not shared, no?

That is also the reason we don't see this on 64 bit, because there these
parts *are* shared.

So with that reasoning vmalloc_fault() works as designed, except that
a warning is issued when it's happens in the NMI path. That warning comes
from

	ebc8827f75954 x86: Barf when vmalloc and kmemcheck faults happen in NMI

which went into 2.6.37 and was added because the NMI handler were not
nesting-safe back then. Reason probably was that the handler on 64 bit
has to use an IST stack and a nested NMI would overwrite the stack of
the upper handler.  We don't have this problem on 32 bit as a nested NMI
will not do another stack-switch there.

I am not sure about 64 bit, but there is a lot of assembly magic to make
NMIs nesting-safe, so I guess the problem should be gone there too.


Regards,

	Joerg

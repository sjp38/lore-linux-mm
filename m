Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 406276B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:43:28 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i16-v6so6075985wrr.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:43:28 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c135-v6si1981932wmc.125.2018.07.20.12.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jul 2018 12:43:27 -0700 (PDT)
Date: Fri, 20 Jul 2018 21:43:16 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in
 all page-tables
In-Reply-To: <CALCETrW7o=s7esmE4+SxLPsLv2SvJZU6f7jfsedazZVrot2EqA@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1807202142130.1694@nanos.tec.linutronix.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com> <alpine.DEB.2.21.1807202126400.1694@nanos.tec.linutronix.de>
 <CALCETrW7o=s7esmE4+SxLPsLv2SvJZU6f7jfsedazZVrot2EqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, 20 Jul 2018, Andy Lutomirski wrote:
> On Fri, Jul 20, 2018 at 12:27 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Fri, 20 Jul 2018, Andy Lutomirski wrote:
> >> > On Jul 20, 2018, at 6:22 AM, Joerg Roedel <joro@8bytes.org> wrote:
> >> >
> >> > From: Joerg Roedel <jroedel@suse.de>
> >> >
> >> > The ring-buffer is accessed in the NMI handler, so we better
> >> > avoid faulting on it. Sync the vmalloc range with all
> >> > page-tables in system to make sure everyone has it mapped.
> >> >
> >> > This fixes a WARN_ON_ONCE() that can be triggered with PTI
> >> > enabled on x86-32:
> >> >
> >> >    WARNING: CPU: 4 PID: 0 at arch/x86/mm/fault.c:320 vmalloc_fault+0x220/0x230
> >> >
> >> > This triggers because with PTI enabled on an PAE kernel the
> >> > PMDs are no longer shared between the page-tables, so the
> >> > vmalloc changes do not propagate automatically.
> >>
> >> It seems like it would be much more robust to fix the vmalloc_fault()
> >> code instead.
> >
> > Right, but now the obvious fix for the issue at hand is this. We surely
> > should revisit this.
> 
> If you commit this under this reasoning, then please at least make it say:
> 
> /* XXX: The vmalloc_fault() code is buggy on PTI+PAE systems, and this
> is a workaround. */
> 
> Let's not have code in the kernel that pretends to make sense but is
> actually voodoo magic that works around bugs elsewhere.  It's no fun
> to maintain down the road.

Fair enough. Lemme amend it. Joerg is looking into it, but I surely want to
get that stuff some exposure in next ASAP.

Thanks,

	tglx

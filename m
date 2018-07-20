Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B62B6B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:33:38 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d10-v6so8049881pll.22
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:33:38 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w19-v6si2194661plq.236.2018.07.20.12.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:33:37 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AFE2720863
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:33:36 +0000 (UTC)
Received: by mail-wm0-f44.google.com with SMTP id z13-v6so10824277wma.5
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:33:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807202126400.1694@nanos.tec.linutronix.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com>
 <alpine.DEB.2.21.1807202126400.1694@nanos.tec.linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 20 Jul 2018 12:33:14 -0700
Message-ID: <CALCETrW7o=s7esmE4+SxLPsLv2SvJZU6f7jfsedazZVrot2EqA@mail.gmail.com>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in all page-tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, Jul 20, 2018 at 12:27 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Fri, 20 Jul 2018, Andy Lutomirski wrote:
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
> Right, but now the obvious fix for the issue at hand is this. We surely
> should revisit this.

If you commit this under this reasoning, then please at least make it say:

/* XXX: The vmalloc_fault() code is buggy on PTI+PAE systems, and this
is a workaround. */

Let's not have code in the kernel that pretends to make sense but is
actually voodoo magic that works around bugs elsewhere.  It's no fun
to maintain down the road.

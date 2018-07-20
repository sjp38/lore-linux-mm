Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B17D6B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:42:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so5010549edi.12
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:42:39 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id e19-v6si1105584eda.336.2018.07.20.14.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 14:42:38 -0700 (PDT)
Date: Fri, 20 Jul 2018 23:42:37 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 3/3] x86/entry/32: Copy only ptregs on paranoid
 entry/exit path
Message-ID: <20180720214237.GI18541@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-4-git-send-email-joro@8bytes.org>
 <CALCETrWmd3arHdkTzAS7reLRjm96jrJC-1O5dYAPwbh2EqKMSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWmd3arHdkTzAS7reLRjm96jrJC-1O5dYAPwbh2EqKMSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

[ Re-sending because I accidentially replied only to Andy ]

On Fri, Jul 20, 2018 at 10:09:26AM -0700, Andy Lutomirski wrote:
> Can you give an example of the exact scenario in which any of this
> copying happens and why it's needed?  IMO you should just be able to
> *run* on the entry stack without copying anything at all.

So for example when we execute RESTORE_REGS on the path back to
user-space and get an exception while loading the user segment
registers.

When that happens we are already on the entry-stack and on user-cr3.
There is no question that when we return from the exception we need to
get back to entry-stack and user-cr3, despite we are returning to kernel
mode. Otherwise we enter user-space with kernel-cr3 or get a page-fault
and panic.

The exception runs through the common_exception path, and finally ends
up calling C code. And correct me if I am wrong, but calling into C code
from the entry-stack is a bad idea for multiple reasons.

First reason is the size of the stack. We can make it larger, but how
large does it need to be?

Next problem is that current_pt_regs doesn't work in the C code when
pt_regs are on the entry-stack.

These problems can all be solved, but it wouldn't be a robust solution
because when changes to the C code are made they are usually not tested
while on the entry-stack. That case is hard to trigger, so it can easily
break again.

For me, only the x86 selftests triggered all these corner-cases, but not
all developers run them on 32 bit when making changes to generic x86
code.

Regards,

	Joerg

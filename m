Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E26A86B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:15:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s18-v6so165349edr.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:15:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o57-v6si101026edo.114.2018.07.17.00.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 00:15:47 -0700 (PDT)
Date: Tue, 17 Jul 2018 09:15:45 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180717071545.ojdall7tatbjtfai@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-11-git-send-email-joro@8bytes.org>
 <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
 <20180714052110.cobtew6rms23ih37@suse.de>
 <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
 <20180714080159.hqp36q7fxzb2ktlq@suse.de>
 <75BDF04F-9585-438C-AE04-918FBE00A174@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75BDF04F-9585-438C-AE04-918FBE00A174@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Sat, Jul 14, 2018 at 07:36:47AM -0700, Andy Lutomirski wrote:
> But Ia??m still unconvinced. If any code executed with IRQs enabled on
> the entry stack, then that code is terminally buggy. If youa??re
> executing with IRQs off, youa??re not going to get migrated.  64-bit
> kernels run on percpu stacks all the time, and ita??s not a problem.

The code switches to the kernel-stack and kernel-cr3 and just remembers
where it came from (to handle the entry-from-kernel with entry-stack
and/or user-cr3 case). IRQs are disabled in the entry-code path. But
ultimately it calls into C code to handle the exception. And there IRQs
might get enabled again.

> IRET errors are genuinely special and, if theya??re causing a problem
> for you, we should fix them the same way we deal with them on x86_64.

Right, IRET is handled differently and doesn't need this patch. But the
segment-writing exceptions do.

If you insist on it I can try to implement the assumption that we don't
get preempted in this code-path. That will safe us some cycles for
copying stack contents in this unlikely slow-path. But we definitly need
to handle the entry-from-kernel with entry-stack and/or user-cr3 case
correctly and make a switch to kernel-stack/cr3 because we are going to
call into C-code.


Regards,

	Joerg

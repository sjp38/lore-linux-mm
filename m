Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6CE6B027B
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:04:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w10-v6so13231520eds.7
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:04:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3-v6si4636649edq.130.2018.07.13.22.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:04:41 -0700 (PDT)
Date: Sat, 14 Jul 2018 07:04:37 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 30/39] x86/mm/pti: Clone entry-text again in
 pti_finalize()
Message-ID: <20180714050437.b4lztahdehaom6el@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-31-git-send-email-joro@8bytes.org>
 <CALCETrU9pe03cW2d+=nXy_iLbiYWzX1dU2wYCfHEN4gb69Q_EA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU9pe03cW2d+=nXy_iLbiYWzX1dU2wYCfHEN4gb69Q_EA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 04:21:45PM -0700, Andy Lutomirski wrote:
> On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > From: Joerg Roedel <jroedel@suse.de>
> >
> > The mapping for entry-text might have changed in the kernel
> > after it was cloned to the user page-table. Clone again
> > to update the user page-table to bring the mapping in sync
> > with the kernel again.
> 
> Can't we just defer pti_init() until after mark_readonly()?  What am I missing?

I tried that:

	https://lore.kernel.org/lkml/1530618746-23116-1-git-send-email-joro@8bytes.org/

But while testing it turned out that the kernel potentially executes
user-space code already before mark_readonly() has ran. This happens
when some initcall requests a module and the initrd is already
populated. Then usermode-helper kicks in and runs a userspace binary
already. When pti_init() has not run yet the user-space page-table is
completly empty, causing a triple fault when we switch to the user cr3
on the way to user-space.


Regards,

	Joerg

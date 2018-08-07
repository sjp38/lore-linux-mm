Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14D8D6B0010
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:21:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r14-v6so195016wmh.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:21:25 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z74-v6si2090280wrb.165.2018.08.07.13.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 13:21:23 -0700 (PDT)
Date: Tue, 7 Aug 2018 22:21:03 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/3] x86/mm/pti: Don't clear permissions in
 pti_clone_pmd()
In-Reply-To: <CALCETrXj1-CC-rcnM5s2SvbSFKjZPMYj0O-9d1PY0MRdGEKs-g@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1808072218310.1672@nanos.tec.linutronix.de>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org> <1533637471-30953-3-git-send-email-joro@8bytes.org> <feea2aff-91ff-89a6-9d7c-5402a1d6a27f@intel.com> <CALCETrXj1-CC-rcnM5s2SvbSFKjZPMYj0O-9d1PY0MRdGEKs-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Tue, 7 Aug 2018, Andy Lutomirski wrote:

> On Tue, Aug 7, 2018 at 11:34 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > On 08/07/2018 03:24 AM, Joerg Roedel wrote:
> >> The function sets the global-bit on cloned PMD entries,
> >> which only makes sense when the permissions are identical
> >> between the user and the kernel page-table.
> >>
> >> Further, only write-permissions are cleared for entry-text
> >> and kernel-text sections, which are not writeable anyway.
> >
> > I think this patch is correct, but I'd be curious if Andy remembers why
> > we chose to clear _PAGE_RW on these things.  It might have been that we
> > were trying to say that the *entry* code shouldn't write to this stuff,
> > regardless of whether the normal kernel can.
> >
> > But, either way, I agree with the logic here that Global pages must
> > share permissions between both mappings, so feel free to add my Ack.  I
> > just want to make sure Andy doesn't remember some detail I'm forgetting.
> 
> I suspect it's because we used to (and maybe still do) initialize the
> user tables before mark_read_only().

We still do that because we need the entry stuff working for interrupts
early on. We now repeat the clone after mark_ro so the mask RW is not
longer required.

Thanks,

	tglx

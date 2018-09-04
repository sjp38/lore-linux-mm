Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 121F96B6D90
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 08:54:45 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id l14-v6so831475lja.20
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 05:54:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2-v6sor6508755lfg.14.2018.09.04.05.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 05:54:43 -0700 (PDT)
MIME-Version: 1.0
References: <bug-198497-200779@https.bugzilla.kernel.org/> <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org> <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
 <f10cdd77-2fe2-2003-4cac-dfec50f0ee43@suse.com>
In-Reply-To: <f10cdd77-2fe2-2003-4cac-dfec50f0ee43@suse.com>
From: Jason Andryuk <jandryuk@gmail.com>
Date: Tue, 4 Sep 2018 08:54:31 -0400
Message-ID: <CAKf6xpuaBRQRaM-UV9T1b6McR984U8RtXNg5+1v8MLm5Dp1A+w@mail.gmail.com>
Subject: Re: [Bug 198497] handle_mm_fault / xen_pmd_val / radix_tree_lookup_slot
 Null pointer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Matthew Wilcox <willy@infradead.org>, bugzilla-daemon@bugzilla.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, labbott@redhat.com, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Mon, Apr 23, 2018 at 4:17 AM Juergen Gross <jgross@suse.com> wrote:
> On 20/04/18 17:20, Jason Andryuk wrote:
> > Adding xen-devel and the Linux Xen maintainers.
> >
> > Summary: Some Xen users (and maybe others) are hitting a BUG in
> > __radix_tree_lookup() under do_swap_page() - example backtrace is
> > provided at the end.  Matthew Wilcox provided a band-aid patch that
> > prints errors like the following instead of triggering the bug.
> >
> > Skylake 32bit PAE Dom0:
> > Bad swp_entry: 80000000
> > mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
> >
> > Ivy Bridge 32bit PAE Dom0:
> > Bad swp_entry: 40000000
> > mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
> >
> > Other 32bit DomU:
> > Bad swp_entry: 4000000
> > mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
> >
> > Other 32bit:
> > Bad swp_entry: 2000000
> > mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)
> >
> > The Linux bugzilla has more info
> > https://bugzilla.kernel.org/show_bug.cgi?id=198497
> >
> > This may not be exclusive to Xen Linux, but most of the reports are on
> > Xen.  Matthew wonders if Xen might be stepping on the upper bits of a
> > pte.
> >
<snip>
>
> Could it be we just have a race regarding pte_clear()? This will set
> the low part of the pte to zero first and then the hight part.
>
> In case pte_clear() is used in interrupt mode especially Xen will be
> rather slow as it emulates the two writes to the page table resulting
> in a larger window where the race might happen.

It looks like Juergen was correct.  With the L1TF vulnerability, the
Xen hypervisor needs to detect vulnerable PTEs.  For 32bit PAE, Xen
would trap on PTEs like 0x8000'0002'0000'0000  - the same format as
seen in this bug.  He wrote two patches for Linux, now upstream, to
write PTEs with 64bit operations or hypercalls and avoid the invalid
PTEs:
f7c90c2aa400 "x86/xen: don't write ptes directly in 32-bit PV guests"
b2d7a075a1cc "x86/pae: use 64 bit atomic xchg function in
native_ptep_get_and_clear"

With those patches, I have not seen a "Bad swp_entry", so this seems
fixed for me on Xen.

There was also a report of a non-Xen kernel being affected.  Is there
an underlying problem that native PAE code updates PTEs in two writes,
but there is no locking to prevent the intermediate PTE from being
used elsewhere in the kernel?

Regards,
Jason

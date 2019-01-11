Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 491438E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:06:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t72so11214452pfi.21
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:06:44 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si4154052plo.102.2019.01.11.13.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 13:06:43 -0800 (PST)
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 94E27218E2
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 21:06:42 +0000 (UTC)
Received: by mail-wr1-f51.google.com with SMTP id r10so16613367wrs.10
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:06:42 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547153058.git.khalid.aziz@oracle.com> <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
 <7e3b2c4b-51ff-2027-3a53-8c798c2ca588@oracle.com> <8ffc77a9-6eae-7287-0ea3-56bfb61758cd@intel.com>
In-Reply-To: <8ffc77a9-6eae-7287-0ea3-56bfb61758cd@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 11 Jan 2019 13:06:27 -0800
Message-ID: <CALCETrXqJJq1LMxfBA=LK=PYc5Q7hgeDQGap38h1AUAQuF2VHA@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, Kees Cook <keescook@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Fri, Jan 11, 2019 at 12:42 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> >> The second process could easily have the page's old TLB entry.  It could
> >> abuse that entry as long as that CPU doesn't context switch
> >> (switch_mm_irqs_off()) or otherwise flush the TLB entry.
> >
> > That is an interesting scenario. Working through this scenario, physmap
> > TLB entry for a page is flushed on the local processor when the page is
> > allocated to userspace, in xpfo_alloc_pages(). When the userspace passes
> > page back into kernel, that page is mapped into kernel space using a va
> > from kmap pool in xpfo_kmap() which can be different for each new
> > mapping of the same page. The physical page is unmapped from kernel on
> > the way back from kernel to userspace by xpfo_kunmap(). So two processes
> > on different CPUs sharing same physical page might not be seeing the
> > same virtual address for that page while they are in the kernel, as long
> > as it is an address from kmap pool. ret2dir attack relies upon being
> > able to craft a predictable virtual address in the kernel physmap for a
> > physical page and redirect execution to that address. Does that sound right?
>
> All processes share one set of kernel page tables.  Or, did your patches
> change that somehow that I missed?
>
> Since they share the page tables, they implicitly share kmap*()
> mappings.  kmap_atomic() is not *used* by more than one CPU, but the
> mapping is accessible and at least exists for all processors.
>
> I'm basically assuming that any entry mapped in a shared page table is
> exploitable on any CPU regardless of where we logically *want* it to be
> used.
>
>

We can, very easily, have kernel mappings that are private to a given
mm.  Maybe this is useful here.

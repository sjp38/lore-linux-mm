Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 740E56B0069
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:55:25 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 4so6555505wrt.8
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:55:25 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f145si2764668wmf.16.2017.11.20.12.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:55:24 -0800 (PST)
Date: Mon, 20 Nov 2017 21:55:21 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
In-Reply-To: <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711202154540.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193125.EBF58596@viggo.jf.intel.com> <alpine.DEB.2.20.1711202115190.2348@nanos> <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Mon, 20 Nov 2017, Andy Lutomirski wrote:
> On Mon, Nov 20, 2017 at 12:22 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Fri, 10 Nov 2017, Dave Hansen wrote:
> >>       __set_fixmap(get_cpu_gdt_ro_index(cpu), get_cpu_gdt_paddr(cpu), prot);
> >> +
> >> +     /* CPU 0's mapping is done in kaiser_init() */
> >> +     if (cpu) {
> >> +             int ret;
> >> +
> >> +             ret = kaiser_add_mapping((unsigned long) get_cpu_gdt_ro(cpu),
> >> +                                      PAGE_SIZE, __PAGE_KERNEL_RO);
> >> +             /*
> >> +              * We do not have a good way to fail CPU bringup.
> >> +              * Just WARN about it and hope we boot far enough
> >> +              * to get a good log out.
> >> +              */
> >
> > The GDT fixmap can be set up before the CPU is started. There is no reason
> > to do that in cpu_init().
> >
> >> +
> >> +     /*
> >> +      * We could theoretically do this in setup_fixmap_gdt().
> >> +      * But, we would need to rewrite the above page table
> >> +      * allocation code to use the bootmem allocator.  The
> >> +      * buddy allocator is not available at the time that we
> >> +      * call setup_fixmap_gdt() for CPU 0.
> >> +      */
> >> +     kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
> >> +                               __PAGE_KERNEL_RO | _PAGE_GLOBAL);
> >
> > This one is needs to stay.
> 
> When you rebase on to my latest version, this should change to mapping
> the entire cpu_entry_area.

Too much flux left and right :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

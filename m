Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9B36B000C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 17:30:11 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e93-v6so6287239plb.5
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 14:30:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m9-v6si13055436pgq.172.2018.07.25.14.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 14:30:10 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:30:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping
 mirrored memory
Message-Id: <20180725143007.25d5bff352872aba90ca731b@linux-foundation.org>
In-Reply-To: <CAGM2reb4vT59uUkMkJVBx9-GEYQs287oTG08aRwKtjfJ1BVrjA@mail.gmail.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
	<20180724235520.10200-3-pasha.tatashin@oracle.com>
	<20180724183142.d20798b43fd1215f6165649c@linux-foundation.org>
	<CAGM2reb4vT59uUkMkJVBx9-GEYQs287oTG08aRwKtjfJ1BVrjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, 24 Jul 2018 21:46:25 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> > > +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > >  {
> > > +     static unsigned long prev_end_pfn, nr_initialised;
> >
> > So answer me quick, what happens with a static variable in an inlined
> > function?  Is there one copy kernel-wide?  One copy per invocation
> > site?  One copy per compilation unit?
> >
> > Well I didn't know so I wrote a little test.  One copy per compilation
> > unit (.o file), it appears.
> >
> > It's OK in this case because the function is in .c (and has only one
> > call site).  But if someone moves it into a header and uses it from a
> > different .c file, they have problems.
> >
> > So it's dangerous, and poor practice.  I'll make this non-static
> > __meminit.
> 
> I agree, it should not be moved to header it is dangerous.
> 
> But, on the other hand this is a hot-path. memmap_init_zone() might
> need to go through billions of struct pages early in boot, and I did
> not want us to waste time on function calls. With defer_init() this is
> not a problem, because if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
> memmap_init_zone() won't have much work to do, but for
> overlap_memmap_init() this is a problem, especially because I expect
> compiler to optimize the pfn dereference usage in inline function.

Well.  The compiler will just go and inline defer_init() anwyay - it
has a single callsite and is in the same __meminint section as its
calling function.  My gcc-7.2.0 does this.  Marking it noninline
__meminit is basically syntactic fluff designed to encourage people to
think twice.

> >
> > --- a/mm/page_alloc.c~mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix
> > +++ a/mm/page_alloc.c
> > @@ -309,7 +309,8 @@ static inline bool __meminit early_page_
> >   * Returns true when the remaining initialisation should be deferred until
> >   * later in the boot cycle when it can be parallelised.
> >   */
> > -static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > +static bool __meminit
> > +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> >  {
> >         static unsigned long prev_end_pfn, nr_initialised;
> >
> >
> > Also, what locking protects these statics?  Our knowledge that this
> > code is single-threaded, presumably?
> 
> Correct, this is called only from "context == MEMMAP_EARLY", way
> before smp_init().

Might be worth a little comment to put readers minds at ease.

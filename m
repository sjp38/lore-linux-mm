Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 289606B0005
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:39:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n68-v6so2343631ite.8
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:39:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 194-v6si1055779itj.38.2018.07.26.08.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:39:43 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6QFXuhj141343
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:39:42 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2kbv8tbpyf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:39:42 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6QFdf8E004467
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:39:41 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6QFdfue013103
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:39:41 GMT
Received: by mail-oi0-f41.google.com with SMTP id w126-v6so3720569oie.7
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:39:40 -0700 (PDT)
MIME-Version: 1.0
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-3-pasha.tatashin@oracle.com> <20180724183142.d20798b43fd1215f6165649c@linux-foundation.org>
 <CAGM2reb4vT59uUkMkJVBx9-GEYQs287oTG08aRwKtjfJ1BVrjA@mail.gmail.com> <20180725143007.25d5bff352872aba90ca731b@linux-foundation.org>
In-Reply-To: <20180725143007.25d5bff352872aba90ca731b@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 26 Jul 2018 11:39:04 -0400
Message-ID: <CAGM2reZ-DLcSw_DnBFfR8yvZBxpT4W1pUPo5+R6HDNvumx-nsA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Wed, Jul 25, 2018 at 5:30 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 24 Jul 2018 21:46:25 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>
> > > > +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > > >  {
> > > > +     static unsigned long prev_end_pfn, nr_initialised;
> > >
> > > So answer me quick, what happens with a static variable in an inlined
> > > function?  Is there one copy kernel-wide?  One copy per invocation
> > > site?  One copy per compilation unit?
> > >
> > > Well I didn't know so I wrote a little test.  One copy per compilation
> > > unit (.o file), it appears.
> > >
> > > It's OK in this case because the function is in .c (and has only one
> > > call site).  But if someone moves it into a header and uses it from a
> > > different .c file, they have problems.
> > >
> > > So it's dangerous, and poor practice.  I'll make this non-static
> > > __meminit.
> >
> > I agree, it should not be moved to header it is dangerous.
> >
> > But, on the other hand this is a hot-path. memmap_init_zone() might
> > need to go through billions of struct pages early in boot, and I did
> > not want us to waste time on function calls. With defer_init() this is
> > not a problem, because if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
> > memmap_init_zone() won't have much work to do, but for
> > overlap_memmap_init() this is a problem, especially because I expect
> > compiler to optimize the pfn dereference usage in inline function.
>
> Well.  The compiler will just go and inline defer_init() anwyay - it
> has a single callsite and is in the same __meminint section as its
> calling function.  My gcc-7.2.0 does this.  Marking it noninline
> __meminit is basically syntactic fluff designed to encourage people to
> think twice.

Makes sense. I will do the change in the next version of the patches.

>
> > >
> > > --- a/mm/page_alloc.c~mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix
> > > +++ a/mm/page_alloc.c
> > > @@ -309,7 +309,8 @@ static inline bool __meminit early_page_
> > >   * Returns true when the remaining initialisation should be deferred until
> > >   * later in the boot cycle when it can be parallelised.
> > >   */
> > > -static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > > +static bool __meminit
> > > +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > >  {
> > >         static unsigned long prev_end_pfn, nr_initialised;
> > >
> > >
> > > Also, what locking protects these statics?  Our knowledge that this
> > > code is single-threaded, presumably?
> >
> > Correct, this is called only from "context == MEMMAP_EARLY", way
> > before smp_init().
>
> Might be worth a little comment to put readers minds at ease.

Will add it.

Thank you,
Pavel

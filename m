Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F13B86B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:18:32 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w19-v6so4007726ioa.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:18:32 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r24-v6si7633515ioj.123.2018.07.24.19.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 19:18:22 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6P2A2xj020321
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:18:21 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2kbvsnufpn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:18:21 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6P2IIAG021070
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:18:18 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6P2IHsN012803
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:18:17 GMT
Received: by mail-oi0-f54.google.com with SMTP id v8-v6so11066547oie.5
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:47:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-3-pasha.tatashin@oracle.com> <20180724183142.d20798b43fd1215f6165649c@linux-foundation.org>
In-Reply-To: <20180724183142.d20798b43fd1215f6165649c@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 24 Jul 2018 21:46:25 -0400
Message-ID: <CAGM2reb4vT59uUkMkJVBx9-GEYQs287oTG08aRwKtjfJ1BVrjA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 9:31 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 24 Jul 2018 19:55:19 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>
> > update_defer_init() should be called only when struct page is about to be
> > initialized. Because it counts number of initialized struct pages, but
> > there we may skip struct pages if there is some mirrored memory.
> >
> > So move, update_defer_init() after checking for mirrored memory.
> >
> > Also, rename update_defer_init() to defer_init() and reverse the return
> > boolean to emphasize that this is a boolean function, that tells that the
> > reset of memmap initialization should be deferred.
> >
> > Make this function self-contained: do not pass number of already
> > initialized pages in this zone by using static counters.
> >
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -306,24 +306,28 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
> >  }
> >
> >  /*
> > - * Returns false when the remaining initialisation should be deferred until
> > + * Returns true when the remaining initialisation should be deferred until
> >   * later in the boot cycle when it can be parallelised.
> >   */
> > -static inline bool update_defer_init(pg_data_t *pgdat,
> > -                             unsigned long pfn, unsigned long zone_end,
> > -                             unsigned long *nr_initialised)
> > +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> >  {
> > +     static unsigned long prev_end_pfn, nr_initialised;
>
> So answer me quick, what happens with a static variable in an inlined
> function?  Is there one copy kernel-wide?  One copy per invocation
> site?  One copy per compilation unit?
>
> Well I didn't know so I wrote a little test.  One copy per compilation
> unit (.o file), it appears.
>
> It's OK in this case because the function is in .c (and has only one
> call site).  But if someone moves it into a header and uses it from a
> different .c file, they have problems.
>
> So it's dangerous, and poor practice.  I'll make this non-static
> __meminit.

I agree, it should not be moved to header it is dangerous.

But, on the other hand this is a hot-path. memmap_init_zone() might
need to go through billions of struct pages early in boot, and I did
not want us to waste time on function calls. With defer_init() this is
not a problem, because if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
memmap_init_zone() won't have much work to do, but for
overlap_memmap_init() this is a problem, especially because I expect
compiler to optimize the pfn dereference usage in inline function.

>
> --- a/mm/page_alloc.c~mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix
> +++ a/mm/page_alloc.c
> @@ -309,7 +309,8 @@ static inline bool __meminit early_page_
>   * Returns true when the remaining initialisation should be deferred until
>   * later in the boot cycle when it can be parallelised.
>   */
> -static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> +static bool __meminit
> +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
>  {
>         static unsigned long prev_end_pfn, nr_initialised;
>
>
> Also, what locking protects these statics?  Our knowledge that this
> code is single-threaded, presumably?

Correct, this is called only from "context == MEMMAP_EARLY", way
before smp_init().

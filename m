Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90B116B0277
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:47:20 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n68-v6so1261440ite.8
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:47:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x9-v6si782130ioh.205.2018.07.17.07.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 07:47:18 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6HEiK34101652
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:47:18 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2k7a34117q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:47:17 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6HElGYB029936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:47:17 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6HElGe7014252
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:47:16 GMT
Received: by mail-oi0-f52.google.com with SMTP id n84-v6so2497938oib.9
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:47:16 -0700 (PDT)
MIME-Version: 1.0
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com> <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
In-Reply-To: <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 17 Jul 2018 10:46:39 -0400
Message-ID: <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, tony.luck@intel.com, yehs1@lenovo.com, vishal.l.verma@intel.com, jack@suse.cz, willy@infradead.org, dave.jiang@intel.com, hpa@zytor.com, tglx@linutronix.de, dalias@libc.org, fenghua.yu@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, benh@kernel.crashing.org, Michal Hocko <mhocko@suse.com>, paulus@samba.org, hch@lst.de, jglisse@redhat.com, mingo@redhat.com, mpe@ellerman.id.au, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, logang@deltatee.com, ross.zwisler@linux.intel.com, jmoyer@redhat.com, jthumshirn@suse.de, schwidefsky@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, LKML <linux-kernel@vger.kernel.org>

> > Hi Dan,
> >
> > I am worried that this work adds another way to multi-thread struct
> > page initialization without re-use of already existing method. The
> > code is already a mess, and leads to bugs [1] because of the number of
> > different memory layouts, architecture specific quirks, and different
> > struct page initialization methods.
>
> Yes, the lamentations about the complexity of the memory hotplug code
> are known. I didn't think this set made it irretrievably worse, but
> I'm biased and otherwise certainly want to build consensus with other
> mem-hotplug folks.
>
> >
> > So, when DEFERRED_STRUCT_PAGE_INIT is used we initialize struct pages
> > on demand until page_alloc_init_late() is called, and at that time we
> > initialize all the rest of struct pages by calling:
> >
> > page_alloc_init_late()
> >   deferred_init_memmap() (a thread per node)
> >     deferred_init_pages()
> >        __init_single_page()
> >
> > This is because memmap_init_zone() is not multi-threaded. However,
> > this work makes memmap_init_zone() multi-threaded. So, I think we
> > should really be either be using deferred_init_memmap() here, or teach
> > DEFERRED_STRUCT_PAGE_INIT to use new multi-threaded memmap_init_zone()
> > but not both.
>
> I agree it would be good to look at unifying the 2 async
> initialization approaches, however they have distinct constraints. All
> of the ZONE_DEVICE memmap initialization work happens as a hotplug
> event where the deferred_init_memmap() threads have already been torn
> down. For the memory capacities where it takes minutes to initialize
> the memmap it is painful to incur a global flush of all initialization
> work. So, I think that a move to rework deferred_init_memmap() in
> terms of memmap_init_async() is warranted because memmap_init_async()
> avoids a global sync and supports the hotplug case.
>
> Unfortunately, the work to unite these 2 mechanisms is going to be
> 4.20 material, at least for me, since I'm taking an extended leave,
> and there is little time for me to get this in shape for 4.19. I
> wouldn't be opposed to someone judiciously stealing from this set and
> taking a shot at the integration, I likely will not get back to this
> until September.

Hi Dan,

I do not want to hold your work, so if Michal or Andrew are OK with
the general approach of teaching    memmap_init_zone() to be async
without re-using deferred_init_memmap() or without changing
deferred_init_memmap() to use the new memmap_init_async() I will
review your patches.

Thank you,
Pavel

>

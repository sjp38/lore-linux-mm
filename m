Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1CD16B0005
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:50:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d10-v6so801153pll.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:50:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1-v6si1107216plf.453.2018.07.17.08.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:50:56 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:50:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init
 for ZONE_DEVICE
Message-ID: <20180717155006.GL7193@dhcp22.suse.cz>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
 <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
 <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: dan.j.williams@intel.com, Andrew Morton <akpm@linux-foundation.org>, tony.luck@intel.com, yehs1@lenovo.com, vishal.l.verma@intel.com, jack@suse.cz, willy@infradead.org, dave.jiang@intel.com, hpa@zytor.com, tglx@linutronix.de, dalias@libc.org, fenghua.yu@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, benh@kernel.crashing.org, paulus@samba.org, hch@lst.de, jglisse@redhat.com, mingo@redhat.com, mpe@ellerman.id.au, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, logang@deltatee.com, ross.zwisler@linux.intel.com, jmoyer@redhat.com, jthumshirn@suse.de, schwidefsky@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-07-18 10:46:39, Pavel Tatashin wrote:
> > > Hi Dan,
> > >
> > > I am worried that this work adds another way to multi-thread struct
> > > page initialization without re-use of already existing method. The
> > > code is already a mess, and leads to bugs [1] because of the number of
> > > different memory layouts, architecture specific quirks, and different
> > > struct page initialization methods.
> >
> > Yes, the lamentations about the complexity of the memory hotplug code
> > are known. I didn't think this set made it irretrievably worse, but
> > I'm biased and otherwise certainly want to build consensus with other
> > mem-hotplug folks.
> >
> > >
> > > So, when DEFERRED_STRUCT_PAGE_INIT is used we initialize struct pages
> > > on demand until page_alloc_init_late() is called, and at that time we
> > > initialize all the rest of struct pages by calling:
> > >
> > > page_alloc_init_late()
> > >   deferred_init_memmap() (a thread per node)
> > >     deferred_init_pages()
> > >        __init_single_page()
> > >
> > > This is because memmap_init_zone() is not multi-threaded. However,
> > > this work makes memmap_init_zone() multi-threaded. So, I think we
> > > should really be either be using deferred_init_memmap() here, or teach
> > > DEFERRED_STRUCT_PAGE_INIT to use new multi-threaded memmap_init_zone()
> > > but not both.
> >
> > I agree it would be good to look at unifying the 2 async
> > initialization approaches, however they have distinct constraints. All
> > of the ZONE_DEVICE memmap initialization work happens as a hotplug
> > event where the deferred_init_memmap() threads have already been torn
> > down. For the memory capacities where it takes minutes to initialize
> > the memmap it is painful to incur a global flush of all initialization
> > work. So, I think that a move to rework deferred_init_memmap() in
> > terms of memmap_init_async() is warranted because memmap_init_async()
> > avoids a global sync and supports the hotplug case.
> >
> > Unfortunately, the work to unite these 2 mechanisms is going to be
> > 4.20 material, at least for me, since I'm taking an extended leave,
> > and there is little time for me to get this in shape for 4.19. I
> > wouldn't be opposed to someone judiciously stealing from this set and
> > taking a shot at the integration, I likely will not get back to this
> > until September.
> 
> Hi Dan,
> 
> I do not want to hold your work, so if Michal or Andrew are OK with
> the general approach of teaching    memmap_init_zone() to be async
> without re-using deferred_init_memmap() or without changing
> deferred_init_memmap() to use the new memmap_init_async() I will
> review your patches.

Well, I would rather have a sane code base than rush anything in. I do
agree with Pavel that we the number of async methods we have right now
is really disturbing. Applying yet another one will put additional
maintenance burden on whoever comes next.

Is there any reason that this work has to target the next merge window?
The changelog is not really specific about that. There no numbers or
anything that would make this sound as a high priority stuff.
-- 
Michal Hocko
SUSE Labs

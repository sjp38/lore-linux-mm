Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 165A26B715F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:27:00 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r82so11608145oie.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:27:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e65sor9863114otb.51.2018.12.04.16.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 16:26:59 -0800 (PST)
MIME-Version: 1.0
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
 <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
 <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
 <CAPcyv4i=FL4f34H2_1mgWMk=UyyaXFaKPh5zJSnFNyN3cBoJhA@mail.gmail.com>
 <2a3f70b011b56de2289e2f304b3d2d617c5658fb.camel@linux.intel.com>
 <CAPcyv4hPDjHzKd4wTh8Ujv-xL8YsJpcFXOp5ocJ-5fVJZ3=vRw@mail.gmail.com>
 <30ab5fa569a6ede936d48c18e666bc6f718d50db.camel@linux.intel.com>
 <CAPcyv4izGr4dLs_Xpa1wbqJRrHZVEKFWQNb2Qo2Ej_xbEXhbTg@mail.gmail.com>
 <dd7296db5996f15cc3e666d008f209f5f24fa98e.camel@linux.intel.com>
 <20181204182428.11bec385@gnomeregan.cam.corp.google.com> <bb141157ac8bc4a99883800d757aa037a7402b10.camel@linux.intel.com>
In-Reply-To: <bb141157ac8bc4a99883800d757aa037a7402b10.camel@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 16:26:46 -0800
Message-ID: <CAPcyv4ix4aHyivwCiw0YNMxLjRJeqDX3x3m1q1JhyMPCEMOJtQ@mail.gmail.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Barret Rhoden <brho@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Tue, Dec 4, 2018 at 4:01 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> On Tue, 2018-12-04 at 18:24 -0500, Barret Rhoden wrote:
> > Hi -
> >
> > On 2018-12-04 at 14:51 Alexander Duyck
> > <alexander.h.duyck@linux.intel.com> wrote:
> >
> > [snip]
> >
> > > > I think the confusion arises from the fact that there are a few MMIO
> > > > resources with a struct page and all the rest MMIO resources without.
> > > > The problem comes from the coarse definition of pfn_valid(), it may
> > > > return 'true' for things that are not System-RAM, because pfn_valid()
> > > > may be something as simplistic as a single "address < X" check. Then
> > > > PageReserved is a fallback to clarify the pfn_valid() result. The
> > > > typical case is that MMIO space is not caught up in this linear map
> > > > confusion. An MMIO address may or may not have an associated 'struct
> > > > page' and in most cases it does not.
> > >
> > > Okay. I think I understand this somewhat now. So the page might be
> > > physically there, but with the reserved bit it is not supposed to be
> > > touched.
> > >
> > > My main concern with just dropping the bit is that we start seeing some
> > > other uses that I was not certain what the impact would be. For example
> > > the functions like kvm_set_pfn_accessed start going in and manipulating
> > > things that I am not sure should be messed with for a DAX page.
> >
> > One thing regarding the accessed and dirty bits is that we might want
> > to have DAX pages marked dirty/accessed, even if we can't LRU-reclaim
> > or swap them.  I don't have a real example and I'm fairly ignorant
> > about the specifics here.  But one possibility would be using the A/D
> > bits to detect changes to a guest's memory for VM migration.  Maybe
> > there would be issues with KSM too.
> >
> > Barret
>
> I get that, but the issue is that the code associated with those bits
> currently assumes you are working with either an anonymous swap backed
> page or a page cache page. We should really be updating that logic now,
> and then enabling DAX to access it rather than trying to do things the
> other way around which is how this feels.

Agree. I understand the concern about unintended side effects of
dropping PageReserved for dax pages, but they simply don't fit the
definition of the intended use of PageReserved. We've already had
fallout from legacy code paths doing the wrong thing with dax pages
where PageReserved wouldn't have helped. For example, see commit
6e2608dfd934 "xfs, dax: introduce xfs_dax_aops", or commit
6100e34b2526 "mm, memory_failure: Teach memory_failure() about
dev_pagemap pages". So formerly teaching kvm about these page
semantics and dropping the reliance on a side effect of PageReserved()
seems the right direction.

That said, for mark_page_accessed(), it does not look like it will
have any effect on dax pages. PageLRU will be false,
__lru_cache_activate_page() will not find a page on a percpu pagevec,
and workingset_activation() won't find an associated memcg. I would
not be surprised if mark_page_accessed() is already being called today
via the ext4 + dax use case.

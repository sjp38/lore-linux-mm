Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 375C36B716A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:01:22 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so15278834pfa.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:01:22 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l11si16295048pgb.545.2018.12.04.16.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 16:01:20 -0800 (PST)
Message-ID: <bb141157ac8bc4a99883800d757aa037a7402b10.camel@linux.intel.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 04 Dec 2018 16:01:20 -0800
In-Reply-To: <20181204182428.11bec385@gnomeregan.cam.corp.google.com>
References: 
	<154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
	 <97943d2ed62e6887f4ba51b985ef4fb5478bc586.camel@linux.intel.com>
	 <CAPcyv4i=FL4f34H2_1mgWMk=UyyaXFaKPh5zJSnFNyN3cBoJhA@mail.gmail.com>
	 <2a3f70b011b56de2289e2f304b3d2d617c5658fb.camel@linux.intel.com>
	 <CAPcyv4hPDjHzKd4wTh8Ujv-xL8YsJpcFXOp5ocJ-5fVJZ3=vRw@mail.gmail.com>
	 <30ab5fa569a6ede936d48c18e666bc6f718d50db.camel@linux.intel.com>
	 <CAPcyv4izGr4dLs_Xpa1wbqJRrHZVEKFWQNb2Qo2Ej_xbEXhbTg@mail.gmail.com>
	 <dd7296db5996f15cc3e666d008f209f5f24fa98e.camel@linux.intel.com>
	 <20181204182428.11bec385@gnomeregan.cam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Barret Rhoden <brho@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Tue, 2018-12-04 at 18:24 -0500, Barret Rhoden wrote:
> Hi -
> 
> On 2018-12-04 at 14:51 Alexander Duyck
> <alexander.h.duyck@linux.intel.com> wrote:
> 
> [snip]
> 
> > > I think the confusion arises from the fact that there are a few MMIO
> > > resources with a struct page and all the rest MMIO resources without.
> > > The problem comes from the coarse definition of pfn_valid(), it may
> > > return 'true' for things that are not System-RAM, because pfn_valid()
> > > may be something as simplistic as a single "address < X" check. Then
> > > PageReserved is a fallback to clarify the pfn_valid() result. The
> > > typical case is that MMIO space is not caught up in this linear map
> > > confusion. An MMIO address may or may not have an associated 'struct
> > > page' and in most cases it does not.  
> > 
> > Okay. I think I understand this somewhat now. So the page might be
> > physically there, but with the reserved bit it is not supposed to be
> > touched.
> > 
> > My main concern with just dropping the bit is that we start seeing some
> > other uses that I was not certain what the impact would be. For example
> > the functions like kvm_set_pfn_accessed start going in and manipulating
> > things that I am not sure should be messed with for a DAX page.
> 
> One thing regarding the accessed and dirty bits is that we might want
> to have DAX pages marked dirty/accessed, even if we can't LRU-reclaim
> or swap them.  I don't have a real example and I'm fairly ignorant
> about the specifics here.  But one possibility would be using the A/D
> bits to detect changes to a guest's memory for VM migration.  Maybe
> there would be issues with KSM too.
> 
> Barret

I get that, but the issue is that the code associated with those bits
currently assumes you are working with either an anonymous swap backed
page or a page cache page. We should really be updating that logic now,
and then enabling DAX to access it rather than trying to do things the
other way around which is how this feels.

- Alex

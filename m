Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D06006B7142
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:24:35 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so9966836pgi.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:24:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j190sor19218137pfc.20.2018.12.04.15.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 15:24:34 -0800 (PST)
Date: Tue, 4 Dec 2018 18:24:28 -0500
From: Barret Rhoden <brho@google.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
Message-ID: <20181204182428.11bec385@gnomeregan.cam.corp.google.com>
In-Reply-To: <dd7296db5996f15cc3e666d008f209f5f24fa98e.camel@linux.intel.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

Hi -

On 2018-12-04 at 14:51 Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:

[snip]

> > I think the confusion arises from the fact that there are a few MMIO
> > resources with a struct page and all the rest MMIO resources without.
> > The problem comes from the coarse definition of pfn_valid(), it may
> > return 'true' for things that are not System-RAM, because pfn_valid()
> > may be something as simplistic as a single "address < X" check. Then
> > PageReserved is a fallback to clarify the pfn_valid() result. The
> > typical case is that MMIO space is not caught up in this linear map
> > confusion. An MMIO address may or may not have an associated 'struct
> > page' and in most cases it does not.  
> 
> Okay. I think I understand this somewhat now. So the page might be
> physically there, but with the reserved bit it is not supposed to be
> touched.
> 
> My main concern with just dropping the bit is that we start seeing some
> other uses that I was not certain what the impact would be. For example
> the functions like kvm_set_pfn_accessed start going in and manipulating
> things that I am not sure should be messed with for a DAX page.

One thing regarding the accessed and dirty bits is that we might want
to have DAX pages marked dirty/accessed, even if we can't LRU-reclaim
or swap them.  I don't have a real example and I'm fairly ignorant
about the specifics here.  But one possibility would be using the A/D
bits to detect changes to a guest's memory for VM migration.  Maybe
there would be issues with KSM too.

Barret

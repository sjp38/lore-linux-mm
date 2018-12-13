Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E696D8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:18:46 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q16so142819otf.5
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:18:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor154120oto.60.2018.12.12.16.18.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 16:18:45 -0800 (PST)
MIME-Version: 1.0
References: <20181207191620.GD3293@redhat.com> <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com> <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com> <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com> <20181212233703.GB2947@ziepe.ca> <20181213000109.GK5037@redhat.com>
In-Reply-To: <20181213000109.GK5037@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Dec 2018 16:18:33 -0800
Message-ID: <CAPcyv4ii6hyrNj=fijoZ1no8w6N1Kk2jGZyWCn7hFKNKaNsyXQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 4:01 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
> > On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > > > Almost, we need some safety around assuming that DMA is complete the
> > > > page, so the notification would need to go all to way to userspace
> > > > with something like a file lease notification. It would also need to
> > > > be backstopped by an IOMMU in the case where the hardware does not /
> > > > can not stop in-flight DMA.
> > >
> > > You can always reprogram the hardware right away it will redirect
> > > any dma to the crappy page.
> >
> > That causes silent data corruption for RDMA users - we can't do that.
> >
> > The only way out for current hardware is to forcibly terminate the
> > RDMA activity somehow (and I'm not even sure this is possible, at
> > least it would be driver specific)
> >
> > Even the IOMMU idea probably doesn't work, I doubt all current
> > hardware can handle a PCI-E error TLP properly.
>
> What i saying is reprogram hardware to crappy page ie valid page
> dma map but that just has random content as a last resort to allow
> filesystem to reuse block. So their should be no PCIE error unless
> hardware freak out to see its page table reprogram randomly.

Hardware has a hard enough time stopping I/O to existing page let
alone switching to a new one in the middle of a transaction. This is a
non-starter, but it's also a non-concern because the bulk of DMA is
transient. For non-transient DMA there is a usually a registration
phase where the capability to support revocation can be validated,

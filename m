Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF9A8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:01:16 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so183215qkb.23
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:01:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si137693qkb.174.2018.12.12.16.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 16:01:15 -0800 (PST)
Date: Wed, 12 Dec 2018 19:01:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213000109.GK5037@redhat.com>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181212233703.GB2947@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
> On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > > Almost, we need some safety around assuming that DMA is complete the
> > > page, so the notification would need to go all to way to userspace
> > > with something like a file lease notification. It would also need to
> > > be backstopped by an IOMMU in the case where the hardware does not /
> > > can not stop in-flight DMA.
> > 
> > You can always reprogram the hardware right away it will redirect
> > any dma to the crappy page.
> 
> That causes silent data corruption for RDMA users - we can't do that.
> 
> The only way out for current hardware is to forcibly terminate the
> RDMA activity somehow (and I'm not even sure this is possible, at
> least it would be driver specific)
> 
> Even the IOMMU idea probably doesn't work, I doubt all current
> hardware can handle a PCI-E error TLP properly. 

What i saying is reprogram hardware to crappy page ie valid page
dma map but that just has random content as a last resort to allow
filesystem to reuse block. So their should be no PCIE error unless
hardware freak out to see its page table reprogram randomly.

> 
> On some hardware it probably just protects DAX by causing data
> corruption for RDMA - I fail to see how that is a win for system
> stability if the user obviously wants to use DAX and RDMA together...

The question is who do you want to punish ? RDMA user that pin stuff
and expect thing to work forever without worrying for other fs
activities ? Or filesystem to pin block forever :) I am not gonna
take side here but i don't think we can please both side, one will
have to be mean to the user ie either the RDMA user or the file-
system which also percolate to being mean to end user.

> I think your approach with ODP only is the only one that meets your
> requirements, the only other data-integrity-preserving approach is to
> block/fail ftruncate/etc.

> 
> > From my point of view driver should listen to ftruncate before the
> > mmu notifier kicks in and send event to userspace and maybe wait
> > and block ftruncate (or move it to a worker thread).
> 
> We can do this, but we can't guarantee forward progress in userspace
> and the best way we have to cancel that is portable to all RDMA
> hardware is to kill the process(es)..
> 
> So if that is acceptable then we could use user notifiers and allow
> non-ODP users...

Yes ODP with listening to _all_ mmu notifier event is the only
sane way. But for hardware not capable of doing that (GPU are
capable, so are mlx5, i won't do a list of the bad ones). We
either keep the status quo that is today behavior or we do
something either mean to the RDMA user or mean to the file-
system. And previous discussion on failing ftruncate where a
no no, can't remember why. In any case i am personnaly fine with
what ever which is:
    S1: keep block pin until RDMA goes away, even if it means
        that RDMA user is no longer really accessing anything
        that make sense (ie the page is no longer part of the
        file or the original vma so as this point it fully
        disconnected from the original intent ie today status
        quo we pin block and annoy filesystem while we pretend
        that everything is fine.
    S2: notify userspace program through device/sub-system
        specific API and delay ftruncate. After a while if there
        is no answer just be mean and force hardware to use
        crappy page as anyway this is what happens today (note
        we can fully mirror today behavior by allocating pages
        and copying existing content their and then swaping
        out to point the hardware to those pages.
    S3: be mean to filesystem a keep block pin for as long as
        they are active GUP, this means failing ftruncate and
        or possibly munmap().

S3 can be split in sub-choices. Do we want to take vote ? Or
is there a way that can please everyone ?

Cheers,
J�r�me

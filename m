Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 669DD8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:37:07 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id x65so110123oix.0
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:37:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor94872oif.101.2018.12.12.15.37.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 15:37:06 -0800 (PST)
Date: Wed, 12 Dec 2018 16:37:03 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181212233703.GB2947@ziepe.ca>
References: <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212215348.GF5037@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > Almost, we need some safety around assuming that DMA is complete the
> > page, so the notification would need to go all to way to userspace
> > with something like a file lease notification. It would also need to
> > be backstopped by an IOMMU in the case where the hardware does not /
> > can not stop in-flight DMA.
> 
> You can always reprogram the hardware right away it will redirect
> any dma to the crappy page.

That causes silent data corruption for RDMA users - we can't do that.

The only way out for current hardware is to forcibly terminate the
RDMA activity somehow (and I'm not even sure this is possible, at
least it would be driver specific)

Even the IOMMU idea probably doesn't work, I doubt all current
hardware can handle a PCI-E error TLP properly. 

On some hardware it probably just protects DAX by causing data
corruption for RDMA - I fail to see how that is a win for system
stability if the user obviously wants to use DAX and RDMA together...

I think your approach with ODP only is the only one that meets your
requirements, the only other data-integrity-preserving approach is to
block/fail ftruncate/etc.

> From my point of view driver should listen to ftruncate before the
> mmu notifier kicks in and send event to userspace and maybe wait
> and block ftruncate (or move it to a worker thread).

We can do this, but we can't guarantee forward progress in userspace
and the best way we have to cancel that is portable to all RDMA
hardware is to kill the process(es)..

So if that is acceptable then we could use user notifiers and allow
non-ODP users...

Jason

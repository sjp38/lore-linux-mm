Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 192298E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:54:39 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r131so117596oia.7
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:54:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor130408oie.62.2018.12.12.15.54.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 15:54:38 -0800 (PST)
MIME-Version: 1.0
References: <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com> <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com> <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com> <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com> <20181212233703.GB2947@ziepe.ca>
In-Reply-To: <20181212233703.GB2947@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Dec 2018 15:54:26 -0800
Message-ID: <CAPcyv4irkynLsEz=HRwLZacnRX6ifNRFX7ibAN_R+9yqR143bQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 3:37 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
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

My thinking here is that we would at least have the infrastructure for
userspace to opt-in to getting the callback, the threat of an IOMMU
forcibly tearing down mappings, and likely some identification for
pages that are revocable. With "long term" pins I would hope to move
any detection of incompatibility to the memory registration phase
rather than something unacceptable like injecting random truncate
failures.

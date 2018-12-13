Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 252548E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 22:20:47 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id t83so316008oie.16
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:20:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u18sor353200otq.164.2018.12.12.19.20.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 19:20:45 -0800 (PST)
Date: Wed, 12 Dec 2018 20:20:43 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213032043.GA3204@ziepe.ca>
References: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213000109.GK5037@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 07:01:09PM -0500, Jerome Glisse wrote:
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

No, that isn't an option. You can't silently provide corrupted data
for RDMA to transfer out onto the network, or silently discard data
coming in!! 

Think of the consequences of that - I have a fileserver process and
someone does ftruncate and now my clients receive corrupted data??

The only option is to prevent the RDMA transfer from ever happening,
and we just don't have hardware support (beyond destroy everything) to
do that.

> The question is who do you want to punish ? RDMA user that pin stuff
> and expect thing to work forever without worrying for other fs
> activities ? Or filesystem to pin block forever :) 

I don't want to punish everyone, I want both sides to have complete
data integrity as the USER has deliberately decided to combine DAX and
RDMA. So either stop it at the front end (ie get_user_pages_longterm)
or make it work in a way that guarantees integrity for both.

>     S2: notify userspace program through device/sub-system
>         specific API and delay ftruncate. After a while if there
>         is no answer just be mean and force hardware to use
>         crappy page as anyway this is what happens today

I don't think this happens today (outside of DAX).. Does it?

.. and the remedy here is to kill the process, not provide corrupt
data. Kill the process is likely to not go over well with any real
users that want this combination.

Think Samba serving files over RDMA - you can't have random unpriv
users calling ftruncate and causing smbd to be killed or serve corrupt
data.

Jason

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 171DE8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:44:45 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id t18so350356qtj.3
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:44:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si200578qtc.140.2018.12.12.16.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 16:44:43 -0800 (PST)
Date: Wed, 12 Dec 2018 19:44:37 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213004437.GL5037@redhat.com>
References: <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
 <CAPcyv4ii6hyrNj=fijoZ1no8w6N1Kk2jGZyWCn7hFKNKaNsyXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ii6hyrNj=fijoZ1no8w6N1Kk2jGZyWCn7hFKNKaNsyXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 04:18:33PM -0800, Dan Williams wrote:
> On Wed, Dec 12, 2018 at 4:01 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
> > > On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > > > > Almost, we need some safety around assuming that DMA is complete the
> > > > > page, so the notification would need to go all to way to userspace
> > > > > with something like a file lease notification. It would also need to
> > > > > be backstopped by an IOMMU in the case where the hardware does not /
> > > > > can not stop in-flight DMA.
> > > >
> > > > You can always reprogram the hardware right away it will redirect
> > > > any dma to the crappy page.
> > >
> > > That causes silent data corruption for RDMA users - we can't do that.
> > >
> > > The only way out for current hardware is to forcibly terminate the
> > > RDMA activity somehow (and I'm not even sure this is possible, at
> > > least it would be driver specific)
> > >
> > > Even the IOMMU idea probably doesn't work, I doubt all current
> > > hardware can handle a PCI-E error TLP properly.
> >
> > What i saying is reprogram hardware to crappy page ie valid page
> > dma map but that just has random content as a last resort to allow
> > filesystem to reuse block. So their should be no PCIE error unless
> > hardware freak out to see its page table reprogram randomly.
> 
> Hardware has a hard enough time stopping I/O to existing page let
> alone switching to a new one in the middle of a transaction. This is a
> non-starter, but it's also a non-concern because the bulk of DMA is
> transient. For non-transient DMA there is a usually a registration
> phase where the capability to support revocation can be validated,

On many GPUs you can do that, it is hardware dependant and you have
steps to take but it is something you can do (and GPU can do
continuous DMA traffic have they have threads running that can
do continuous memory access). So i assume that other hardware
can do it too.

Any revocation mechanism gonna be device/sub-system specific so it
would probably be better to talk case by case and see what we can
do. Like i said posted patches to remove GUP from GPUs driver, i
am working on improving some core code to make those patches even
simpler and i will keep pushing for that in subsystem i know.

Maybe we should grep for GUP in drivers/ and start discussion within
each sub-system to see what can be done within each. If any common
pattern emerge we can draw up common plans for those at least.

Cheers,
J�r�me

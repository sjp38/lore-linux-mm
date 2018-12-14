Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68FCD8E01C5
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:41:29 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so2578051ede.14
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 02:41:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12-v6si1584735ejk.197.2018.12.14.02.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 02:41:27 -0800 (PST)
Date: Fri, 14 Dec 2018 11:41:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214104125.GE8896@quack2.suse.cz>
References: <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
 <20181213032043.GA3204@ziepe.ca>
 <20181213124325.GA3186@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213124325.GA3186@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Thu 13-12-18 07:43:25, Jerome Glisse wrote:
> On Wed, Dec 12, 2018 at 08:20:43PM -0700, Jason Gunthorpe wrote:
> > On Wed, Dec 12, 2018 at 07:01:09PM -0500, Jerome Glisse wrote:
> > > > Even the IOMMU idea probably doesn't work, I doubt all current
> > > > hardware can handle a PCI-E error TLP properly. 
> > > 
> > > What i saying is reprogram hardware to crappy page ie valid page
> > > dma map but that just has random content as a last resort to allow
> > > filesystem to reuse block. So their should be no PCIE error unless
> > > hardware freak out to see its page table reprogram randomly.
> > 
> > No, that isn't an option. You can't silently provide corrupted data
> > for RDMA to transfer out onto the network, or silently discard data
> > coming in!! 
> > 
> > Think of the consequences of that - I have a fileserver process and
> > someone does ftruncate and now my clients receive corrupted data??
> 
> This is what happens _today_ ie today someone do GUP on page file
> and then someone else do truncate the first GUP is effectively
> streaming _random_ data to network as the page does not correspond
> to anything anymore and once the RDMA MR goes aways and release
> the page the page content will be lost. So i am not changing anything
> here, what i proposed was to make it explicit to device driver at
> least that they were streaming random data. Right now this is all
> silent but this is what is happening wether you like it or not :)

I think you're making the current behaviour sound worse than it really is.
You are correct that currently driver can setup RDMA with some page, one
instant later that page can get truncated from the file and thus has no
association to the file anymore. That can lead to *stale* data being
streamed over RDMA or loss of data that are coming from RDMA. But none of
this is actually a security issue - no streaming of random data or memory
corruption. And that's all kernel cares about. It is userspace
responsibility to make sure file cannot be truncated if it cannot tolerate
stale data.

So your "redirect RDMA to dummy page" solution has to make sure you really
swap one real page for one dummy page and copy old real page contents to
the dummy page contents. Then it will be equivalent to the current behavior
and if the hardware can do the swapping, then I'm fine with such
solution...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

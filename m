Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5341C8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:28:32 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id u17so16247660pgn.17
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:28:32 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id u7si16038889pfu.270.2018.12.19.02.28.29
        for <linux-mm@kvack.org>;
        Wed, 19 Dec 2018 02:28:31 -0800 (PST)
Date: Wed, 19 Dec 2018 21:28:25 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219102825.GN6311@dastard>
References: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
 <20181219030329.GI21992@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219030329.GI21992@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 18, 2018 at 08:03:29PM -0700, Jason Gunthorpe wrote:
> On Wed, Dec 19, 2018 at 10:42:54AM +1100, Dave Chinner wrote:
> 
> > Essentially, what we are talking about is how to handle broken
> > hardware. I say we should just brun it with napalm and thermite
> > (i.e. taint the kernel with "unsupportable hardware") and force
> > wait_for_stable_page() to trigger when there are GUP mappings if
> > the underlying storage doesn't already require it.
> 
> If you want to ban O_DIRECT/etc from writing to file backed pages,
> then just do it.

O_DIRECT IO *isn't the problem*.


iO_DIRECT IO uses a short term pin that the existing prefaulting
during GUP works just fine for. The problem we have is the long term
pins where pages can be cleaned while the pages are pinned. i.e. the
use case we current have to disable for DAX because *we can't make
it work sanely* without either revokable file leases and/or hardware
that is able to trigger page faults when they need write access to a
clean page.

> Otherwise I'm not sure demanding some unrealistic HW design is
> reasonable. ie nvme drives are not likely to add page faulting to
> their IO path any time soon.

Direct IO on nvme drives are not the problem. It's RDMA pinning
pages for hours or days and expecting everyone else to jump through
hoops to support their broken page access access model.

> A SW architecture that relies on page faulting is just not going to
> support real world block IO devices.

The existing software architecture for file backed pages has been
based around page faulting for write notifications since ~2005. That
horse bolted many, many years ago.

> GPUs and one RDMA are about the only things that can do this today,
> and they are basically irrelevant to O_DIRECT.

It's RDMA that we need these changes for, not O_DIRECT.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

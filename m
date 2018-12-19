Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2829A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 11:56:33 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id bj3so15004677plb.17
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 08:56:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l61sor29163168plb.51.2018.12.19.08.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 08:56:31 -0800 (PST)
Date: Wed, 19 Dec 2018 09:56:28 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219165628.GB30553@ziepe.ca>
References: <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
 <20181219030329.GI21992@ziepe.ca>
 <20181219102825.GN6311@dastard>
 <20181219113540.GC18345@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219113540.GC18345@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 19, 2018 at 12:35:40PM +0100, Jan Kara wrote:
> On Wed 19-12-18 21:28:25, Dave Chinner wrote:
> > On Tue, Dec 18, 2018 at 08:03:29PM -0700, Jason Gunthorpe wrote:
> > > On Wed, Dec 19, 2018 at 10:42:54AM +1100, Dave Chinner wrote:
> > > 
> > > > Essentially, what we are talking about is how to handle broken
> > > > hardware. I say we should just brun it with napalm and thermite
> > > > (i.e. taint the kernel with "unsupportable hardware") and force
> > > > wait_for_stable_page() to trigger when there are GUP mappings if
> > > > the underlying storage doesn't already require it.
> > > 
> > > If you want to ban O_DIRECT/etc from writing to file backed pages,
> > > then just do it.
> > 
> > O_DIRECT IO *isn't the problem*.
> 
> That is not true. O_DIRECT IO is a problem. In some aspects it is
> easier than the problem with RDMA but currently O_DIRECT IO can
> crash your machine or corrupt data the same way RDMA can. Just the
> race window is much smaller. So we have to fix the generic GUP
> infrastructure to make O_DIRECT IO work. I agree that fixing RDMA
> will likely require even more work like revokable leases or what
> not.

This is what I've understood, talking to all the experts. Dave? Why do
you think O_DIRECT is actually OK?

I agree the duration issue with RDMA is different, but don't forget,
O_DIRECT goes out to the network too and has potentially very long
timeouts as well.

If O_DIRECT works fine then lets use the same approach in RDMA??

Jason

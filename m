Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83AD88E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 08:24:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so16125844edb.8
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:24:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si796400edq.75.2018.12.19.05.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 05:24:52 -0800 (PST)
Date: Wed, 19 Dec 2018 14:24:49 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181219132449.GD18345@quack2.suse.cz>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181218103306.GC18032@quack2.suse.cz>
 <20181218234254.GC31274@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218234254.GC31274@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed 19-12-18 10:42:54, Dave Chinner wrote:
> On Tue, Dec 18, 2018 at 11:33:06AM +0100, Jan Kara wrote:
> > On Mon 17-12-18 08:58:19, Dave Chinner wrote:
> > > On Fri, Dec 14, 2018 at 04:43:21PM +0100, Jan Kara wrote:
> > > > Yes, for filesystem it is too late. But the plan we figured back in October
> > > > was to do the bouncing in the block layer. I.e., mark the bio (or just the
> > > > particular page) as needing bouncing and then use the existing page
> > > > bouncing mechanism in the block layer to do the bouncing for us. Ext3 (when
> > > > it was still a separate fs driver) has been using a mechanism like this to
> > > > make DIF/DIX work with its metadata.
> > > 
> > > Sure, that's a possibility, but that doesn't close off any race
> > > conditions because there can be DMA into the page in progress while
> > > the page is being bounced, right? AFAICT this ext3+DIF/DIX case is
> > > different in that there is no 3rd-party access to the page while it
> > > is under IO (ext3 arbitrates all access to it's metadata), and so
> > > nothing can actually race for modification of the page between
> > > submission and bouncing at the block layer.
> > >
> > > In this case, the moment the page is unlocked, anyone else can map
> > > it and start (R)DMA on it, and that can happen before the bio is
> > > bounced by the block layer. So AFAICT, block layer bouncing doesn't
> > > solve the problem of racing writeback and DMA direct to the page we
> > > are doing IO on. Yes, it reduces the race window substantially, but
> > > it doesn't get rid of it.
> > 
> > The scenario you describe here cannot happen exactly because of the
> > wait_for_stable_page() in ->page_mkwrite() you mention below.
> 
> In general, no, because stable pages are controlled by block
> devices.
> 
> void wait_for_stable_page(struct page *page)
> {
>         if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
>                 wait_on_page_writeback(page);
> }
> 
> 
> I have previously advocated for the filesystem to be in control of
> stable pages but, well, too many people shouted "but performance!"
> and so we still have all these holes I wanted to close in our
> code...
> 
> > If someone
> > will try to GUP a page that is under writeback (has already PageWriteback
> > set), GUP will have to do a write fault because the page is writeprotected
> > in page tables and go into ->page_mkwrite() which will wait.
> 
> Correct, but that doesn't close the problem down because stable
> pages are something we cannot rely on right now. We need to fix
> wait_for_stable_page() to always block on page writeback before
> this specific race condition goes away.

Right, all I said was assuming that someone actually cares about stable
pages so bdi_cap_stable_pages_required() is set. I agree with filesystem
having ability to control whether stable pages are required or not. But
when stable pages get enforced seems like a separate problem to me.

> > The problem rather is with someone mapping the page *before* writeback
> > starts, giving the page to HW. Then clear_page_dirty_for_io() writeprotects
> > the page in PTEs but the HW gives a damn about that. Then, after we add the
> > page to the bio but before the page gets bounced by the block layer, the HW
> > can still modify it.
> 
> Sure, that's yet another aspect of the same problem - not getting a
> write fault when the page is being written to. If we got a write
> fault, then the wait_for_stable_page() call in ->page_mkwrite would
> then solve the problem.
> 
> Essentially, what we are talking about is how to handle broken
> hardware. I say we should just brun it with napalm and thermite
> (i.e. taint the kernel with "unsupportable hardware") and force
> wait_for_stable_page() to trigger when there are GUP mappings if
> the underlying storage doesn't already require it.

As I wrote in other email, this is also about direct IO using file mapping
as a data buffer. So burn with napalm can hardly be a complete solution...
I agree that for the hardware that cannot support revoking of access /
fault on access and uses long-term page pins, we may just have to put up
with weird behavior in some corner cases.

> > > If it's permanently dirty, how do we trigger new COW operations
> > > after writeback has "cleaned" the page? i.e. we still need a
> > > ->page_mkwrite call to run before we allow the next write to the
> > > page to be done, regardless of whether the page is "permanently
> > > dirty" or not....
> > 
> > Interaction with COW is certainly an interesting problem. When the page
> > gets pinned, GUP will make sure the page is writeably mapped and trigger a
> > write fault if not. So at the moment the page is pinned, we are sure the
> > page is COWed. Now the question is what should happen when the file A
> > containing this pinned page gets reflinked to file B while the page is still
> > pinned.
> > 
> > Options I can see are:
> > 
> > 1) Fail the reflink.
> >   - difficult for sysadmin to discover the source of failure
> >
> > 2) Block reflink until the pin of the page is released.
> >   - can last for a long time, again difficult to discover
> > 
> > 3) Don't do anything special.
> >   - can corrupt data as read accesses through file B won't see
> >     modifications done to the page (and thus eventually the corresponding disk
> >     block) by the HW.
> > 
> > 4) Immediately COW the block during reflink when the corresponding page
> >    cache page is pinned.
> >   - seems as the best solution at this point, although sadly also requires
> >     the most per-filesystem work
> 
> None of the above are acceptable solutions - they all have nasty
> corner cases which are going to be difficult to get right, test,
> etc. IMO, the robust, reliable, testable solution is this:
> 
> 5) The reflink breaks the file lease, the userspace app releases the
> pinned pages on the file and drops the lease. The reflink proceeds,
> does it's work, and then the app gets a new lease on the file. When
> the app pins the pages again, it triggers new ->page_mkwrite calls
> to break any sharing that the reflink created. And if the app fails
> to drop the lease, then we can either fail with a lease related
> error or kill it....

This is certainly fine for the GUP users that are going to support leases.
But do you want GUP in direct IO to create a lease if the pages are from a
file mapping? I belive we need another option at least for GUP references
that are short-term in nature and sometimes also performance critical.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

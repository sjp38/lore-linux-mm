Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBF388E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:30:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so3366729edm.18
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:30:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si2072837edl.165.2019.01.17.01.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:30:49 -0800 (PST)
Date: Thu, 17 Jan 2019 10:30:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190117093047.GB9378@quack2.suse.cz>
References: <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz>
 <20190116130813.GA3617@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116130813.GA3617@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed 16-01-19 08:08:14, Jerome Glisse wrote:
> On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
> > On Tue 15-01-19 09:07:59, Jan Kara wrote:
> > > Agreed. So with page lock it would actually look like:
> > > 
> > > get_page_pin()
> > > 	lock_page(page);
> > > 	wait_for_stable_page();
> > > 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
> > > 	unlock_page(page);
> > > 
> > > And if we perform page_pinned() check under page lock, then if
> > > page_pinned() returned false, we are sure page is not and will not be
> > > pinned until we drop the page lock (and also until page writeback is
> > > completed if needed).
> > 
> > After some more though, why do we even need wait_for_stable_page() and
> > lock_page() in get_page_pin()?
> > 
> > During writepage page_mkclean() will write protect all page tables. So
> > there can be no new writeable GUP pins until we unlock the page as all such
> > GUPs will have to first go through fault and ->page_mkwrite() handler. And
> > that will wait on page lock and do wait_for_stable_page() for us anyway.
> > Am I just confused?
> 
> Yeah with page lock it should synchronize on the pte but you still
> need to check for writeback iirc the page is unlocked after file
> system has queue up the write and thus the page can be unlock with
> write back pending (and PageWriteback() == trye) and i am not sure
> that in that states we can safely let anyone write to that page. I
> am assuming that in some case the block device also expect stable
> page content (RAID stuff).
> 
> So the PageWriteback() test is not only for racing page_mkclean()/
> test_set_page_writeback() and GUP but also for pending write back.

But this is prevented by wait_for_stable_page() that is already present in
->page_mkwrite() handlers. Look:

->writepage()
  /* Page is locked here */
  clear_page_dirty_for_io(page)
    page_mkclean(page)
      -> page tables get writeprotected
    /* The following line will be added by our patches */
    if (page_pinned(page)) -> bounce
    TestClearPageDirty(page)
  set_page_writeback(page);
  unlock_page(page);
  ...submit_io...

IRQ
  - IO completion
  end_page_writeback()

So if GUP happens before page_mkclean() writeprotects corresponding PTE
(and these two actions are synchronized on the PTE lock), page_pinned()
will see the increment and report the page as pinned.

If GUP happens after page_mkclean() writeprotects corresponding PTE, it
will fault:
  handle_mm_fault()
    do_wp_page()
      wp_page_shared()
        do_page_mkwrite()
          ->page_mkwrite() - that is block_page_mkwrite() or
	    iomap_page_mkwrite() or whatever filesystem provides
	  lock_page(page)
          ... prepare page ...
	  wait_for_stable_page(page) -> this blocks until IO completes
	    if someone cares about pages not being modified while under IO.

> > That actually touches on another question I wanted to get opinions on. GUP
> > can be for read and GUP can be for write (that is one of GUP flags).
> > Filesystems with page cache generally have issues only with GUP for write
> > as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
> > hotplug have issues with both (DAX cannot truncate page pinned in any way,
> > memory hotplug will just loop in kernel until the page gets unpinned). So
> > we probably want to track both types of GUP pins and page-cache based
> > filesystems will take the hit even if they don't have to for read-pins?
> 
> Yes the distinction between read and write would be nice. With the map
> count solution you can only increment the mapcount for GUP(write=true).

Well, but if we track only pins for write, DAX or memory hotplug will not
be able to use this mechanism. So at this point I'm more leaning towards
tracking all pins. It will cost some performance needlessly for read pins
and filesystems using page cache when bouncing such pages but it's not like
writeback of pinned pages is some performance critical operation... But I
wanted to spell this out so that people are aware of this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88C6C6B000C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 03:02:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w22-v6so4341015edr.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 00:02:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1-v6si1431541edb.153.2018.07.02.00.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 00:02:28 -0700 (PDT)
Date: Mon, 2 Jul 2018 09:02:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702070227.jj5udrdk3rxzjj4t@quack2.suse.cz>
References: <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
 <20180702055251.GV3014@mtr-leonro.mtl.com>
 <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Leon Romanovsky <leon@kernel.org>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Sun 01-07-18 23:10:04, John Hubbard wrote:
> On 07/01/2018 10:52 PM, Leon Romanovsky wrote:
> > On Thu, Jun 28, 2018 at 11:17:43AM +0200, Jan Kara wrote:
> >> On Wed 27-06-18 19:42:01, John Hubbard wrote:
> >>> On 06/27/2018 10:02 AM, Jan Kara wrote:
> >>>> On Wed 27-06-18 08:57:18, Jason Gunthorpe wrote:
> >>>>> On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
> >>>>>> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
> >>>>>>> On Wed 27-06-18 13:53:49, Jan Kara wrote:
> >>>>>>>> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
> >>>>>>> [...]
> >>> One question though: I'm still vague on the best actions to take in the
> >>> following functions:
> >>>
> >>>     page_mkclean_one
> >>>     try_to_unmap_one
> >>>
> >>> At the moment, they are both just doing an evil little early-out:
> >>>
> >>> 	if (PageDmaPinned(page))
> >>> 		return false;
> >>>
> >>> ...but we talked about maybe waiting for the condition to clear, instead?
> >>> Thoughts?
> >>
> >> What needs to happen in page_mkclean() depends on the caller. Most of the
> >> callers really need to be sure the page is write-protected once
> >> page_mkclean() returns. Those are:
> >>
> >>   pagecache_isize_extended()
> >>   fb_deferred_io_work()
> >>   clear_page_dirty_for_io() if called for data-integrity writeback - which
> >>     is currently known only in its caller (e.g. write_cache_pages()) where
> >>     it can be determined as wbc->sync_mode == WB_SYNC_ALL. Getting this
> >>     information into page_mkclean() will require some plumbing and
> >>     clear_page_dirty_for_io() has some 50 callers but it's doable.
> >>
> >> clear_page_dirty_for_io() for cleaning writeback (wbc->sync_mode !=
> >> WB_SYNC_ALL) can just skip pinned pages and we probably need to do that as
> >> otherwise memory cleaning would get stuck on pinned pages until RDMA
> >> drivers release its pins.
> > 
> > Sorry for naive question, but won't it create too much dirty pages
> > so writeback will be called "non-stop" to rebalance watermarks without
> > ability to progress?
> > 
> 
> That is an interesting point. 
> 
> Holding off page writeback of this region does seem like it could cause
> problems under memory pressure. Maybe adjusting the watermarks so that we
> tell the writeback  system, "all is well, just ignore this region until
> we're done with it" might help? Any ideas here are welcome...
> 
> Longer term, maybe some additional work could allow the kernel to be able
> to writeback the gup-pinned pages (while DMA is happening--snapshots), but
> that seems like a pretty big overhaul.

We could use bounce pages to safely writeback pinned pages. However I don't
think it would buy us anything. From MM point of view these pages are
impossible-to-get-rid-of (page refcount is increased) and pernamently-dirty
when GUP was for write (we don't know when dirty data arrives there). So
let's not just fool MM by pretending we can make them clean. That's going
to lead to just more problems down the road.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

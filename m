Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 283F86B0007
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 02:58:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j11-v6so5259513edr.15
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 23:58:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x51-v6si1931984edx.74.2018.07.01.23.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 23:58:09 -0700 (PDT)
Date: Mon, 2 Jul 2018 08:58:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702065807.zwnsdwww442gqcf6@quack2.suse.cz>
References: <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
 <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
 <20180702055251.GV3014@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702055251.GV3014@mtr-leonro.mtl.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@kernel.org>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon 02-07-18 08:52:51, Leon Romanovsky wrote:
> On Thu, Jun 28, 2018 at 11:17:43AM +0200, Jan Kara wrote:
> > On Wed 27-06-18 19:42:01, John Hubbard wrote:
> > > On 06/27/2018 10:02 AM, Jan Kara wrote:
> > > > On Wed 27-06-18 08:57:18, Jason Gunthorpe wrote:
> > > >> On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
> > > >>> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
> > > >>>> On Wed 27-06-18 13:53:49, Jan Kara wrote:
> > > >>>>> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
> > > >>>> [...]
> > > >>>>>> Appart from that, do we really care about 32b here? Big DIO, IB users
> > > >>>>>> seem to be 64b only AFAIU.
> > > >>>>>
> > > >>>>> IMO it is a bad habit to leave unpriviledged-user-triggerable oops in the
> > > >>>>> kernel even for uncommon platforms...
> > > >>>>
> > > >>>> Absolutely agreed! I didn't mean to keep the blow up for 32b. I just
> > > >>>> wanted to say that we can stay with a simple solution for 32b. I thought
> > > >>>> the g-u-p-longterm has plugged the most obvious breakage already. But
> > > >>>> maybe I just misunderstood.
> > > >>>
> > > >>> Most yes, but if you try hard enough, you can still trigger the oops e.g.
> > > >>> with appropriately set up direct IO when racing with writeback / reclaim.
> > > >>
> > > >> gup longterm is only different from normal gup if you have DAX and few
> > > >> people do, which really means it doesn't help at all.. AFAIK??
> > > >
> > > > Right, what I wrote works only for DAX. For non-DAX situation g-u-p
> > > > longterm does not currently help at all. Sorry for confusion.
> > > >
> > >
> > > OK, I've got an early version of this up and running, reusing the page->lru
> > > fields. I'll clean it up and do some heavier testing, and post as a PATCH v2.
> >
> > Cool.
> >
> > > One question though: I'm still vague on the best actions to take in the
> > > following functions:
> > >
> > >     page_mkclean_one
> > >     try_to_unmap_one
> > >
> > > At the moment, they are both just doing an evil little early-out:
> > >
> > > 	if (PageDmaPinned(page))
> > > 		return false;
> > >
> > > ...but we talked about maybe waiting for the condition to clear, instead?
> > > Thoughts?
> >
> > What needs to happen in page_mkclean() depends on the caller. Most of the
> > callers really need to be sure the page is write-protected once
> > page_mkclean() returns. Those are:
> >
> >   pagecache_isize_extended()
> >   fb_deferred_io_work()
> >   clear_page_dirty_for_io() if called for data-integrity writeback - which
> >     is currently known only in its caller (e.g. write_cache_pages()) where
> >     it can be determined as wbc->sync_mode == WB_SYNC_ALL. Getting this
> >     information into page_mkclean() will require some plumbing and
> >     clear_page_dirty_for_io() has some 50 callers but it's doable.
> >
> > clear_page_dirty_for_io() for cleaning writeback (wbc->sync_mode !=
> > WB_SYNC_ALL) can just skip pinned pages and we probably need to do that as
> > otherwise memory cleaning would get stuck on pinned pages until RDMA
> > drivers release its pins.
> 
> Sorry for naive question, but won't it create too much dirty pages
> so writeback will be called "non-stop" to rebalance watermarks without
> ability to progress?

If the amount of pinned pages is more than allowed dirty limit then yes.
However dirty limit is there exactly to prevent too many
difficult-to-get-rid-of pages in page cache. So if your amount of pinned
pages crosses the dirty limit you have just violated this mm constraint and
you either need to modify your workload not to pin so many pages or you
need to verify so many dirty pages are indeed safe and increase the dirty
limit.

Realistically, I think we need to come up with a hard limit (similar to
mlock or account them as mlock) on these pinned pages because they are even
worse than plain dirty pages. However I'd strongly prefer to keep that
discussion separate to this discussion about method how to avoid memory
corruption / oopses because that is another can of worms with a big
bikeshedding potential.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

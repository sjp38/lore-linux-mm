Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6C776B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 03:52:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s21-v6so170733edq.23
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 00:52:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13-v6si697659edc.98.2018.06.26.00.52.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 00:52:16 -0700 (PDT)
Date: Tue, 26 Jun 2018 09:52:13 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180626075213.qn7ykt7j5usgvuiq@quack2.suse.cz>
References: <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
 <20180620120824.bghoklv7qu2z5wgy@quack2.suse.cz>
 <151edbf3-66ff-df0c-c1cc-5998de50111e@nvidia.com>
 <20180621163036.jvdbsv3t2lu34pdl@quack2.suse.cz>
 <20180625152150.jnf5suiubecfppcl@quack2.suse.cz>
 <d007873c-4454-4c70-4829-b222155be0ff@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d007873c-4454-4c70-4829-b222155be0ff@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon 25-06-18 12:03:37, John Hubbard wrote:
> On 06/25/2018 08:21 AM, Jan Kara wrote:
> > On Thu 21-06-18 18:30:36, Jan Kara wrote:
> >> On Wed 20-06-18 15:55:41, John Hubbard wrote:
> >>> On 06/20/2018 05:08 AM, Jan Kara wrote:
> >>>> On Tue 19-06-18 11:11:48, John Hubbard wrote:
> >>>>> On 06/19/2018 03:41 AM, Jan Kara wrote:
> >>>>>> On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
> >>>>>>> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
> >>> [...]
> > I've spent some time on this. There are two obstacles with my approach of
> > putting special entry into inode's VMA tree:
> > 
> > 1) If I want to place this special entry in inode's VMA tree, I either need
> > to allocate full VMA, somehow initiate it so that it's clear it's a special
> > "pinned" range, not a VMA => uses unnecessarily too much memory, it is
> > ugly. Another solution I was hoping for was that I would factor out some
> > common bits of vm_area_struct (pgoff, rb_node, ..) into a structure common
> > for VMA and the locked range => doable but causes a lot of churn as VMAs
> > are accessed (and modified!) at hundreds of places in the kernel. Some
> > accessor functions would help to reduce the churn a bit but then stuff like
> > vma_set_pgoff(vma, pgoff) isn't exactly beautiful either.
> > 
> > 2) Some users of GUP (e.g. direct IO) get a block of pages and then put
> > references to these pages at different times and in random order -
> > basically when IO for given page is completed, reference is dropped and one
> > GUP call can acquire page references for pages which end up in multiple
> > different bios (we don't know in advance). This makes is difficult to
> > implement counterpart to GUP to 'unpin' a range of pages - we'd either have
> > to support partial unpins (and splitting of pinned ranges and all such fun)
> > or just have to track internally in how many pages are still pinned in the
> > originally pinned range and release the pin once all individual pages are
> > unpinned but then it's difficult to e.g. get to this internal structure
> > from IO completion callback where we only have the bio.
> >
> > So I think the Matthew's idea of removing pinned pages from LRU is
> > definitely worth trying to see how complex that would end up being. Did you
> > get to looking into it? If not, I can probably find some time to try that
> > out.
> > 
> 
> OK. Even if we remove the pages from the LRU, we still have to insert a
> "put_gup_page" or similarly named call. But it could be a simple
> replacement for put_page, with that approach, so that does make it much
> much easier.

Yes, that's exactly what I thought about as well.

> I was (and still am) planning on tackling this today, so let me see how
> far I get before yelling for help. :)

OK, good.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

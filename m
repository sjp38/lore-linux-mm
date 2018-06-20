Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40FF86B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:08:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g5-v6so1216230pgv.12
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 05:08:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i26-v6si1962290pgn.433.2018.06.20.05.08.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 05:08:28 -0700 (PDT)
Date: Wed, 20 Jun 2018 14:08:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180620120824.bghoklv7qu2z5wgy@quack2.suse.cz>
References: <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Tue 19-06-18 11:11:48, John Hubbard wrote:
> On 06/19/2018 03:41 AM, Jan Kara wrote:
> > On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
> >> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
> >>> And for record, the problem with page cache pages is not only that
> >>> try_to_unmap() may unmap them. It is also that page_mkclean() can
> >>> write-protect them. And once PTEs are write-protected filesystems may end
> >>> up doing bad things if DMA then modifies the page contents (DIF/DIX
> >>> failures, data corruption, oopses). As such I don't think that solutions
> >>> based on page reference count have a big chance of dealing with the
> >>> problem.
> >>>
> >>> And your page flag approach would also need to take page_mkclean() into
> >>> account. And there the issue is that until the flag is cleared (i.e., we
> >>> are sure there are no writers using references from GUP) you cannot
> >>> writeback the page safely which does not work well with your idea of
> >>> clearing the flag only once the page is evicted from page cache (hint, page
> >>> cache page cannot get evicted until it is written back).
> >>>
> >>> So as sad as it is, I don't see an easy solution here.
> >>
> >> Pages which are "got" don't need to be on the LRU list.  They'll be
> >> marked dirty when they're put, so we can use page->lru for fun things
> >> like a "got" refcount.  If we use bit 1 of page->lru for PageGot, we've
> >> got 30/62 bits in the first word and a full 64 bits in the second word.
> > 
> > Interesting idea! It would destroy the aging information for the page but
> > for pages accessed through GUP references that is very much vague concept
> > anyway. It might be a bit tricky as pulling a page out of LRU requires page
> > lock but I don't think that's a huge problem. And page cache pages not on
> > LRU exist even currently when they are under reclaim so hopefully there
> > won't be too many places in MM that would need fixing up for such pages.
> 
> This sound promising, I'll try it out!
> 
> > 
> > I'm also still pondering the idea of inserting a "virtual" VMA into vma
> > interval tree in the inode - as the GUP references are IMHO closest to an
> > mlocked mapping - and that would achieve all the functionality we need as
> > well. I just didn't have time to experiment with it.
> 
> How would this work? Would it have the same virtual address range? And how
> does it avoid the problems we've been discussing? Sorry to be a bit slow
> here. :)

The range covered by the virtual mapping would be the one sent to
get_user_pages() to get page references. And then we would need to teach
page_mkclean() to check for these virtual VMAs and block / skip / report
(different situations would need different behavior) such page. But this
second part is the same regardless how we identify a page that is pinned by
get_user_pages().

> > And then there's the aspect that both these approaches are a bit too
> > heavyweight for some get_user_pages_fast() users (e.g. direct IO) - Al Viro
> > had an idea to use page lock for that path but e.g. fs/direct-io.c would have
> > problems due to lock ordering constraints (filesystem ->get_block would
> > suddently get called with the page lock held). But we can probably leave
> > performance optimizations for phase two.
> 
>  
> So I assume that phase one would be to apply this approach only to
> get_user_pages_longterm. (Please let me know if that's wrong.)

No, I meant phase 1 would be to apply this to all get_user_pages() flavors.
Then phase 2 is to try to find a way to make get_user_pages_fast() fast
again. And then in parallel to that, we also need to find a way for
get_user_pages_longterm() to signal to the user pinned pages must be
released soon. Because after phase 1 pinned pages will block page
writeback and such system won't oops but will become unusable
sooner rather than later. And again this problem needs to be solved
regardless of a mechanism of identifying pinned pages.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

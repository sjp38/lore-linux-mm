Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E95C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 12:30:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so2174627wmh.0
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 09:30:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32-v6si2322899edr.363.2018.06.21.09.30.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 09:30:39 -0700 (PDT)
Date: Thu, 21 Jun 2018 18:30:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180621163036.jvdbsv3t2lu34pdl@quack2.suse.cz>
References: <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
 <20180620120824.bghoklv7qu2z5wgy@quack2.suse.cz>
 <151edbf3-66ff-df0c-c1cc-5998de50111e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151edbf3-66ff-df0c-c1cc-5998de50111e@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Wed 20-06-18 15:55:41, John Hubbard wrote:
> On 06/20/2018 05:08 AM, Jan Kara wrote:
> > On Tue 19-06-18 11:11:48, John Hubbard wrote:
> >> On 06/19/2018 03:41 AM, Jan Kara wrote:
> >>> On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
> >>>> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
> [...]
> >>> I'm also still pondering the idea of inserting a "virtual" VMA into vma
> >>> interval tree in the inode - as the GUP references are IMHO closest to an
> >>> mlocked mapping - and that would achieve all the functionality we need as
> >>> well. I just didn't have time to experiment with it.
> >>
> >> How would this work? Would it have the same virtual address range? And how
> >> does it avoid the problems we've been discussing? Sorry to be a bit slow
> >> here. :)
> > 
> > The range covered by the virtual mapping would be the one sent to
> > get_user_pages() to get page references. And then we would need to teach
> > page_mkclean() to check for these virtual VMAs and block / skip / report
> > (different situations would need different behavior) such page. But this
> > second part is the same regardless how we identify a page that is pinned by
> > get_user_pages().
> 
> 
> OK. That neatly avoids the need a new page flag, I think. But of course it is 
> somewhat more extensive to implement. Sounds like something to keep in mind,
> in case it has better tradeoffs than the direction I'm heading so far.

Yes, the changes needed are somewhat more intrusive. I'm looking into this
approach now to see how the result will look like...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

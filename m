Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF5326B0008
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 12:48:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l23-v6so611128edr.1
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 09:48:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y25-v6si941803edq.145.2018.06.26.09.48.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 09:48:27 -0700 (PDT)
Date: Tue, 26 Jun 2018 18:48:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
References: <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <20180626134757.GY28965@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626134757.GY28965@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Tue 26-06-18 15:47:57, Michal Hocko wrote:
> On Mon 18-06-18 12:21:46, Dan Williams wrote:
> [...]
> > I do think we should explore a page flag for pages that are "long
> > term" pinned. Michal asked for something along these lines at LSF / MM
> > so that the core-mm can give up on pages that the kernel has lost
> > lifetime control. Michal, did I capture your ask correctly?
> 
> I am sorry to be late. I didn't ask for a page flag exactly. I've asked
> for a way to query for the pin to be temporal or permanent. How that is
> achieved is another question. Maybe we have some more spare room after
> recent struct page reorganization but I dunno, to be honest. Maybe we
> can have an _count offset for these longterm pins. It is not like we are
> using the whole ref count space, right?

Matthew had an interesting idea to pull pinned pages completely out from
any LRU and reuse that space in struct page for pinned refcounts. From some
initial investigation (read on elsewhere in this thread) it looks doable. I
was considering offsetting in refcount as well but on 32-bit architectures
there's not that many bits that I'd be really comfortable with that
solution...
 
> Another thing I was asking for is to actually account those longterm
> pinned pages and apply some control over those. They are basically mlock
> like and so their usage should better not be unbound.

Agreed here but I'd prefer to keep this discussion separate from 'how to
identify pinned pages'.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

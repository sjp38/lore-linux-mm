Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46DED6B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 05:03:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so11670164pld.23
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:03:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g15-v6si13923049pgf.249.2018.06.19.02.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 02:03:00 -0700 (PDT)
Date: Tue, 19 Jun 2018 02:02:55 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180619090255.GA25522@bombadil.infradead.org>
References: <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
> And for record, the problem with page cache pages is not only that
> try_to_unmap() may unmap them. It is also that page_mkclean() can
> write-protect them. And once PTEs are write-protected filesystems may end
> up doing bad things if DMA then modifies the page contents (DIF/DIX
> failures, data corruption, oopses). As such I don't think that solutions
> based on page reference count have a big chance of dealing with the
> problem.
> 
> And your page flag approach would also need to take page_mkclean() into
> account. And there the issue is that until the flag is cleared (i.e., we
> are sure there are no writers using references from GUP) you cannot
> writeback the page safely which does not work well with your idea of
> clearing the flag only once the page is evicted from page cache (hint, page
> cache page cannot get evicted until it is written back).
> 
> So as sad as it is, I don't see an easy solution here.

Pages which are "got" don't need to be on the LRU list.  They'll be
marked dirty when they're put, so we can use page->lru for fun things
like a "got" refcount.  If we use bit 1 of page->lru for PageGot, we've
got 30/62 bits in the first word and a full 64 bits in the second word.

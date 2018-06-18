Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF6A76B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 03:57:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11-v6so8293958pfn.1
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 00:57:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z11-v6si14232714pfd.357.2018.06.18.00.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 00:57:00 -0700 (PDT)
Date: Mon, 18 Jun 2018 00:56:50 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180618075650.GA7300@infradead.org>
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180617012510.20139-3-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

On Sat, Jun 16, 2018 at 06:25:10PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> This fixes a few problems that come up when using devices (NICs, GPUs,
> for example) that want to have direct access to a chunk of system (CPU)
> memory, so that they can DMA to/from that memory. Problems [1] come up
> if that memory is backed by persistence storage; for example, an ext4
> file system. I've been working on several customer bugs that are hitting
> this, and this patchset fixes those bugs.

What happens if we do get_user_page from two different threads or even
processes on the same page?  As far as I can tell from your patch
the first one finishing the page will clear the bit and then we are
back to no protection.

Note that you can reproduce such a condition trivially using direct
I/O reads or writes.

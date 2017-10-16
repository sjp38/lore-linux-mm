Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 706146B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:30:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so8430991wmd.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 00:30:14 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m21si4663036wma.151.2017.10.16.00.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 00:30:13 -0700 (PDT)
Date: Mon, 16 Oct 2017 09:30:12 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171016073012.GC28270@lst.de>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com> <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com> <20171013065716.GB26461@lst.de> <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com> <20171013163822.GA17411@obsidianresearch.com> <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com> <20171013173145.GA18702@obsidianresearch.com> <CAPcyv4jZJRto1jwmNU--pqH_6dOVMyj=68ZwEjAmmkgX=mRk7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jZJRto1jwmNU--pqH_6dOVMyj=68ZwEjAmmkgX=mRk7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 11:22:21AM -0700, Dan Williams wrote:
> So, here's a strawman can ibv_poll_cq() start returning ibv_wc_status
> == IBV_WC_LOC_PROT_ERR when file coherency is lost. This would make
> the solution generic across DAX and non-DAX. What's you're feeling for
> how well applications are prepared to deal with that status return?

The problem aren't local protection errors, but remote protection errors
when we modify a MR with an rkey that the remote side accesses.

> >  - How lease break can be done hitlessly, so the library user never
> >    needs to know it is happening or see failed/missed transfers
> 
> iommu redirect should be hit less and behave like the page cache case
> where RDMA targets pages that are no longer part of the file.

But systems that care about performance (e.g. the usual RDMA users) usually
don't use an IOMMU due to the performance impact.  Especially as HCAs
already have their own built-in iommus (aka the MR mechanism).

Note that file systems already have a mechanism like you mention above
to keep extents that are busy from being reallocated.  E.g. take a look at
fs/xfs/xfs_extent_busy.c.  The downside is that this could lock down
a massive amount of space in the busy list if we for example have a MR
covering a huge file that is truncated down.  So even if we'd want that
scheme we'd need some sort of ulmit for the amount of DAX pages locked
down in get_user_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

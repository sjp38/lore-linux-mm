Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0189831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 10:43:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o52so1953888wrb.10
        for <linux-mm@kvack.org>; Thu, 04 May 2017 07:43:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si2684651wrc.30.2017.05.04.07.43.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 07:43:47 -0700 (PDT)
Date: Thu, 4 May 2017 11:12:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] dax: fix data corruption due to stale mmap reads
Message-ID: <20170504091233.GA808@quack2.suse.cz>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170421034437.4359-2-ross.zwisler@linux.intel.com>
 <20170425111043.GH2793@quack2.suse.cz>
 <20170425225936.GA29655@linux.intel.com>
 <20170426085235.GA21738@quack2.suse.cz>
 <20170426225236.GA25838@linux.intel.com>
 <20170427072659.GA29789@quack2.suse.cz>
 <20170501223855.GA25862@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501223855.GA25862@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

On Mon 01-05-17 16:38:55, Ross Zwisler wrote:
> > So for now I'm still more inclined to just stay with the radix tree lock as
> > is and just fix up the locking as I suggest and go for larger rewrite only
> > if we can demonstrate further performance wins.
> 
> Sounds good.
> 
> > WRT your second patch, if we go with the locking as I suggest, it is enough
> > to unmap the whole range after invalidate_inode_pages2() has cleared radix
> > tree entries (*) which will be much cheaper (for large writes) than doing
> > unmapping entry by entry.
> 
> I'm still not convinced that it is safe to do the unmap in a separate step.  I
> see your point about it being expensive to do a rmap walk to unmap each entry
> in __dax_invalidate_mapping_entry(), but I think we might need to because the
> unmap is part of the contract imposed by invalidate_inode_pages2_range() and
> invalidate_inode_pages2().  This exists in the header comment above each:
> 
>  * Any pages which are found to be mapped into pagetables are unmapped prior
>  * to invalidation.
> 
> If you look at the usage of invalidate_inode_pages2_range() in
> generic_file_direct_write() for example (which I realize we won't call for a
> DAX inode, but still), I think that it really does rely on the fact that
> invalidated pages are unmapped, right?  If it didn't, and hole pages were
> mapped, the hole pages could remain mapped while a direct I/O write allocated
> blocks and then wrote real data.
> 
> If we really want to unmap the entire range at once, maybe it would have to be
> done in invalidate_inode_pages2_range(), after the loop?  My hesitation about
> this is that we'd be leaking yet more DAX special casing up into the
> mm/truncate.c code.
> 
> Or am I missing something?

No, my thinking was to put the invalidation at the end of
invalidate_inode_pages2_range(). I agree it means more special-casing for
DAX in mm/truncate.c.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

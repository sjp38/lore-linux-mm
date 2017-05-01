Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B90806B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 12:54:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p2so45922880pge.7
        for <linux-mm@kvack.org>; Mon, 01 May 2017 09:54:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v71si3303132pgd.186.2017.05.01.09.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 09:54:54 -0700 (PDT)
Date: Mon, 1 May 2017 10:54:51 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] dax: prevent invalidation of mapped DAX entries
Message-ID: <20170501165451.GB14837@linux.intel.com>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170425101041.GG2793@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425101041.GG2793@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

On Tue, Apr 25, 2017 at 12:10:41PM +0200, Jan Kara wrote:
> On Thu 20-04-17 21:44:36, Ross Zwisler wrote:
> > dax_invalidate_mapping_entry() currently removes DAX exceptional entries
> > only if they are clean and unlocked.  This is done via:
> > 
> > invalidate_mapping_pages()
> >   invalidate_exceptional_entry()
> >     dax_invalidate_mapping_entry()
> > 
> > However, for page cache pages removed in invalidate_mapping_pages() there
> > is an additional criteria which is that the page must not be mapped.  This
> > is noted in the comments above invalidate_mapping_pages() and is checked in
> > invalidate_inode_page().
> > 
> > For DAX entries this means that we can can end up in a situation where a
> > DAX exceptional entry, either a huge zero page or a regular DAX entry,
> > could end up mapped but without an associated radix tree entry. This is
> > inconsistent with the rest of the DAX code and with what happens in the
> > page cache case.
> > 
> > We aren't able to unmap the DAX exceptional entry because according to its
> > comments invalidate_mapping_pages() isn't allowed to block, and
> > unmap_mapping_range() takes a write lock on the mapping->i_mmap_rwsem.
> > 
> > Since we essentially never have unmapped DAX entries to evict from the
> > radix tree, just remove dax_invalidate_mapping_entry().
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Fixes: c6dcf52c23d2 ("mm: Invalidate DAX radix tree entries only if appropriate")
> > Reported-by: Jan Kara <jack@suse.cz>
> > Cc: <stable@vger.kernel.org>    [4.10+]
> 
> Just as a side note - we wouldn't really have to unmap the mapping range
> covered by the DAX exceptional entry. It would be enough to find out
> whether such range is mapped and bail out in that case. But that would
> still be pretty expensive for DAX - we'd have to do rmap walk similar as in
> dax_mapping_entry_mkclean() and IMHO it is not worth it. So I agree with
> what you did. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Yep, that makes sense.  Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

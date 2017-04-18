Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 050136B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:38:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d3so1468749pfj.5
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 12:38:21 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t26si80092pfk.332.2017.04.18.12.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 12:38:21 -0700 (PDT)
Date: Tue, 18 Apr 2017 13:38:08 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/4] fs: fix data invalidation in the cleancache during
 direct IO
Message-ID: <20170418193808.GA16667@linux.intel.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170414140753.16108-2-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 14, 2017 at 05:07:50PM +0300, Andrey Ryabinin wrote:
> Some direct write fs hooks call invalidate_inode_pages2[_range]()
> conditionally iff mapping->nrpages is not zero. If page cache is empty,
> buffered read following after direct IO write would get stale data from
> the cleancache.
> 
> Also it doesn't feel right to check only for ->nrpages because
> invalidate_inode_pages2[_range] invalidates exceptional entries as well.
> 
> Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
> state.
> 
> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
<>
> diff --git a/fs/dax.c b/fs/dax.c
> index 2e382fe..1e8cca0 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1047,7 +1047,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	 * into page tables. We have to tear down these mappings so that data
>  	 * written by write(2) is visible in mmap.
>  	 */
> -	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
> +	if ((iomap->flags & IOMAP_F_NEW)) {
>  		invalidate_inode_pages2_range(inode->i_mapping,
>  					      pos >> PAGE_SHIFT,
>  					      (end - 1) >> PAGE_SHIFT);

tl;dr: I think the old code is correct, and that you don't need this change.

This should be harmless, but could slow us down a little if we keep
calling invalidate_inode_pages2_range() without really needing to.  Really for
DAX I think we need to call invalidate_inode_page2_range() only if we have
zero pages mapped over the place where we are doing I/O, which is why we check
nrpages.

Is DAX even allowed to be used at the same time as cleancache?  From a brief
look at Documentation/vm/cleancache.txt, it seems like these two features are
incompatible.  With DAX we already are avoiding the page cache completely.

Anyway, I don't see how this change in DAX can save us from a data corruption
(which is what you're seeing, right?), and I think it could slow us down, so
I'd prefer to leave things as they are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

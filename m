Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61EF56B039F
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:28:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h72so30687186iod.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 12:28:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n5si3674989pgk.367.2017.04.19.12.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 12:28:38 -0700 (PDT)
Date: Wed, 19 Apr 2017 13:28:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/4] fs: fix data invalidation in the cleancache during
 direct IO
Message-ID: <20170419192836.GA6364@linux.intel.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-2-aryabinin@virtuozzo.com>
 <20170418193808.GA16667@linux.intel.com>
 <ac3b6a27-4345-53cf-04b5-c1f74e680695@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ac3b6a27-4345-53cf-04b5-c1f74e680695@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 19, 2017 at 06:11:31PM +0300, Andrey Ryabinin wrote:
> On 04/18/2017 10:38 PM, Ross Zwisler wrote:
> > On Fri, Apr 14, 2017 at 05:07:50PM +0300, Andrey Ryabinin wrote:
> >> Some direct write fs hooks call invalidate_inode_pages2[_range]()
> >> conditionally iff mapping->nrpages is not zero. If page cache is empty,
> >> buffered read following after direct IO write would get stale data from
> >> the cleancache.
> >>
> >> Also it doesn't feel right to check only for ->nrpages because
> >> invalidate_inode_pages2[_range] invalidates exceptional entries as well.
> >>
> >> Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
> >> state.
> >>
> >> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
> >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> ---
> > <>
> >> diff --git a/fs/dax.c b/fs/dax.c
> >> index 2e382fe..1e8cca0 100644
> >> --- a/fs/dax.c
> >> +++ b/fs/dax.c
> >> @@ -1047,7 +1047,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
> >>  	 * into page tables. We have to tear down these mappings so that data
> >>  	 * written by write(2) is visible in mmap.
> >>  	 */
> >> -	if ((iomap->flags & IOMAP_F_NEW) && inode->i_mapping->nrpages) {
> >> +	if ((iomap->flags & IOMAP_F_NEW)) {
> >>  		invalidate_inode_pages2_range(inode->i_mapping,
> >>  					      pos >> PAGE_SHIFT,
> >>  					      (end - 1) >> PAGE_SHIFT);
> > 
> > tl;dr: I think the old code is correct, and that you don't need this change.
> > 
> > This should be harmless, but could slow us down a little if we keep
> > calling invalidate_inode_pages2_range() without really needing to.  Really for
> > DAX I think we need to call invalidate_inode_page2_range() only if we have
> > zero pages mapped over the place where we are doing I/O, which is why we check
> > nrpages.
> > 
> 
> Check for ->nrpages only looks strange, because invalidate_inode_pages2_range() also
> invalidates exceptional radix tree entries. Is that correct that we invalidate
> exceptional entries only if ->nrpages > 0 and skip invalidation otherwise?

For DAX we only invalidate clean DAX exceptional entries so that we can keep
dirty entries around for writeback, but yes you're correct that we only do the
invalidation if nrpages > 0.  And yes, it does seem a bit weird. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

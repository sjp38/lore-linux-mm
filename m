Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B2CF36B00E8
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 16:26:34 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so6252497pbc.14
        for <linux-mm@kvack.org>; Sun, 25 Mar 2012 13:26:34 -0700 (PDT)
Date: Sun, 25 Mar 2012 13:26:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
In-Reply-To: <20120323155950.f9bfb097.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1203251254570.1505@eggly.anvils>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils> <20120323140120.11f95cd5.akpm@linux-foundation.org> <alpine.LSU.2.00.1203231406090.2207@eggly.anvils> <20120323155950.f9bfb097.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, Alex Elder <elder@kernel.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Ben Myers <bpm@sgi.com>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, Mark Fasheh <mfasheh@suse.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012, Andrew Morton wrote:
> On Fri, 23 Mar 2012 14:14:54 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > On Fri, 23 Mar 2012, Andrew Morton wrote:
> > > 
> > > --- a/mm/truncate.c~mm-for-fs-add-truncate_pagecache_range-fix
> > > +++ a/mm/truncate.c
> > > @@ -639,6 +639,9 @@ int vmtruncate_range(struct inode *inode
> > >   * with on-disk format, and the filesystem would not have to deal with
> > >   * situations such as writepage being called for a page that has already
> > >   * had its underlying blocks deallocated.
> > > + *
> > > + * Must be called with inode->i_mapping->i_mutex held.
> > 
> > You catch me offguard: I forget whether that's an absolute requirement or
> > just commonly the case.  What do the other interfaces in truncate.c say ?-)
> 
> i_mutex is generally required, to stabilise i_size.

Sorry for being quarrelsome, but I do want to Nak your followup "fix".

Building a test kernel quickly told me that inode->i_mapping->i_mutex
doesn't exist, of course it's inode->i_mutex.

Then running the test kernel quickly told me that neither ext4 nor xfs
(I didn't try ocfs2) holds inode->i_mutex where holepunching calls
truncate_inode_pages_range().

Now, there might or might not be reasons why ext4 or xfs ought to hold
i_mutex there for its own consistency, but it's beyond me to determine
that: let's assume they're correct without evidence to the contrary.

Stabilizing i_size is not a reason: holepunching does not affect i_size
and is not affected by i_size (okay, ext4 still has the bug I reported
a couple of months ago, whereby its holepunching stops at i_size,
forgetting blocks fallocated beyond; but no doubt that will get fixed).

And nothing that truncate_pagecache_range() does needs i_mutex:
neither the unmap_mapping_range() nor the truncate_inode_pages_range()
needs i_mutex.  A year ago, yes, Miklos showed how unmap_mapping_range()
was relying on mutex serialization, and added an additional mutex for
that, which Peter was able to remove once he mutified i_mmap_lock.

truncate_pagecache_range() is just a drop-in replacement for
truncate_inode_pages_range(), and has no different locking needs.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

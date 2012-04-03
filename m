Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 73F8E6B004D
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 01:45:55 -0400 (EDT)
Date: Mon, 2 Apr 2012 22:45:29 -0700
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
Message-ID: <20120403054528.GD15739@dhcp-172-17-9-228.mtv.corp.google.com>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
 <20120323140120.11f95cd5.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1203231406090.2207@eggly.anvils>
 <20120323155950.f9bfb097.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1203251254570.1505@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203251254570.1505@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, Alex Elder <elder@kernel.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Ben Myers <bpm@sgi.com>, Dave Chinner <david@fromorbit.com>, Mark Fasheh <mfasheh@suse.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 25, 2012 at 01:26:10PM -0700, Hugh Dickins wrote:
> On Fri, 23 Mar 2012, Andrew Morton wrote:
> > On Fri, 23 Mar 2012 14:14:54 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > > On Fri, 23 Mar 2012, Andrew Morton wrote:
> > > > 
> > > > --- a/mm/truncate.c~mm-for-fs-add-truncate_pagecache_range-fix
> > > > +++ a/mm/truncate.c
> > > > @@ -639,6 +639,9 @@ int vmtruncate_range(struct inode *inode
> > > >   * with on-disk format, and the filesystem would not have to deal with
> > > >   * situations such as writepage being called for a page that has already
> > > >   * had its underlying blocks deallocated.
> > > > + *
> > > > + * Must be called with inode->i_mapping->i_mutex held.
> > > 
> > > You catch me offguard: I forget whether that's an absolute requirement or
> > > just commonly the case.  What do the other interfaces in truncate.c say ?-)
> > 
> > i_mutex is generally required, to stabilise i_size.
> 
> Sorry for being quarrelsome, but I do want to Nak your followup "fix".
> 
> Building a test kernel quickly told me that inode->i_mapping->i_mutex
> doesn't exist, of course it's inode->i_mutex.
> 
> Then running the test kernel quickly told me that neither ext4 nor xfs
> (I didn't try ocfs2) holds inode->i_mutex where holepunching calls
> truncate_inode_pages_range().

Just for completeness:

ocfs2 holds i_mutex around the entire ocfs2_change_file_space() call,
which can do hole punching and unwritten extent allocation (it is a
clone of xfs_change_file_space()).  xfs itself seems hold its own idea
of a shared lock while doing the work and an exclusive lock around the
transaction join.  I'm not clear enough about xfs to say how this
compares or even if I read it right.

But ocfs2 uses an allocation sem to protect allocation changes,
including i_size, so perhaps i_mutex isn't strictly necessary.  I don't
think we contend enough here to try hard to remove it :-)

Joel

-- 

"The question of whether computers can think is just like the question
 of whether submarines can swim."
	- Edsger W. Dijkstra

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

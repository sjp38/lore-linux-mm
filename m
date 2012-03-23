Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3DD4C6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:53 -0400 (EDT)
Date: Fri, 23 Mar 2012 15:59:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
Message-Id: <20120323155950.f9bfb097.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203231406090.2207@eggly.anvils>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
	<20120323140120.11f95cd5.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1203231406090.2207@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012 14:14:54 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Fri, 23 Mar 2012, Andrew Morton wrote:
> > 
> > --- a/mm/truncate.c~mm-for-fs-add-truncate_pagecache_range-fix
> > +++ a/mm/truncate.c
> > @@ -639,6 +639,9 @@ int vmtruncate_range(struct inode *inode
> >   * with on-disk format, and the filesystem would not have to deal with
> >   * situations such as writepage being called for a page that has already
> >   * had its underlying blocks deallocated.
> > + *
> > + * Must be called with inode->i_mapping->i_mutex held.
> 
> You catch me offguard: I forget whether that's an absolute requirement or
> just commonly the case.  What do the other interfaces in truncate.c say ?-)

i_mutex is generally required, to stabilise i_size.

> > + * Takes inode->i_mapping->i_mmap_mutex.
> 
> Yes, and inode->i_mapping->tree_lock.

I don't think it's necessary to get into the spinning locks for a
high-level function which clearly does sleeping things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

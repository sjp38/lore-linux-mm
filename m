Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 882896B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:37:42 -0400 (EDT)
Date: Wed, 11 Mar 2009 23:36:15 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may get wrongly discarded
Message-ID: <20090311223615.GA3284@cmpxchg.org>
References: <20090311153034.9389.19938.stgit@warthog.procyon.org.uk> <20090311150302.0ae76cf1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311150302.0ae76cf1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 03:03:02PM -0700, Andrew Morton wrote:
> On Wed, 11 Mar 2009 15:30:35 +0000
> David Howells <dhowells@redhat.com> wrote:
> 
> > From: Enrik Berkhan <Enrik.Berkhan@ge.com>
> > 
> > The pages attached to a ramfs inode's pagecache by truncation from nothing - as
> > done by SYSV SHM for example - may get discarded under memory pressure.
> 
> Something has gone wrong in core VM.
> 
> > The problem is that the pages are not marked dirty.  Anything that creates data
> > in an MMU-based ramfs will cause the pages holding that data will cause the
> > set_page_dirty() aop to be called.
> > 
> > For the NOMMU-based mmap, set_page_dirty() may be called by write(), but it
> > won't be called by page-writing faults on writable mmaps, and it isn't called
> > by ramfs_nommu_expand_for_mapping() when a file is being truncated from nothing
> > to allocate a contiguous run.
> > 
> > The solution is to mark the pages dirty at the point of allocation by
> > the truncation code.
> 
> Page reclaim shouldn't be even attempting to reclaim or write back
> ramfs pagecache pages - reclaim can't possibly do anything with these
> pages!
> 
> Arguably those pages shouldn't be on the LRU at all, but we haven't
> done that yet.
> 
> Now, my problem is that I can't 100% be sure that we _ever_ implemented
> this properly.  I _think_ we did, in which case we later broke it.  If
> we've always been (stupidly) trying to pageout these pages then OK, I
> guess your patch is a suitable 2.6.29 stopgap.
> 
> If, however, we broke it then we've probably broken other filesystems
> and we should fix the regression instead.
> 
> Running bdi_cap_writeback_dirty() in may_write_to_queue() might be the
> way to fix all this.

The pages are not dirty, so no pageout() which says PAGE_KEEP.  It
will just go through and reclaim the clean, unmapped pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

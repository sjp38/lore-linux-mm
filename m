Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4B46B004F
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:05:56 -0400 (EDT)
Date: Wed, 11 Mar 2009 17:02:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may
 get wrongly discarded
Message-Id: <20090311170207.1795cad9.akpm@linux-foundation.org>
In-Reply-To: <20090311150302.0ae76cf1.akpm@linux-foundation.org>
References: <20090311153034.9389.19938.stgit@warthog.procyon.org.uk>
	<20090311150302.0ae76cf1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 2009 15:03:02 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

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

OK, I can't find any code anywhere in which we excluded ramfs pages
from consideration by page reclaim.  How dumb.

So I guess that for now the proposed patch is suitable.  Longer-term we
should bale early in shrink_page_list(), or not add these pages to the
LRU at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F47B6001DA
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 22:22:01 -0400 (EDT)
Date: Tue, 16 Mar 2010 13:21:53 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: lockdep page lock
Message-ID: <20100316022153.GJ2869@laptop>
References: <20100315155859.GE2869@laptop>
 <20100315180759.GA7744@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100315180759.GA7744@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 07:08:00PM +0100, Jan Kara wrote:
>   Hi,
> 
> On Tue 16-03-10 02:58:59, Nick Piggin wrote:
> > This patch isn't totally complete. Needs some nesting annotations for
> > filesystems like ntfs, and some async lock release annotations for other
> > end-io handlers, also page migration code needs to set the page lock
> > class. But the core of it is working nicely and is a pretty small patch.
> > 
> > It is a bit different to one Peter posted a while back, with differences.
> > I don't care so much about bloating struct page with a few more bytes.
> > lockdep can't run on a production kernel so I think it's preferable to be
> > catching more complex errors than avoiding overhead. I also set the page
> > lock class at the time it is added to pagecache when we have the mapping
> > pinned to the page.
> > 
> > One issue I wonder about is if the lock class is changed while some other
> > page locker is waiting to get the lock but has already called
> > lock_acquire for the old class. Possibly it could be solved if lockdep
> > has different primitives to say the caller is contending for a lock
> > versus if it has been granted the lock?
> > 
> > Do you think it would be useful?  --
> > 
> > Page lock has very complex dependencies, so it would be really nice to
> > add lockdep support for it.
> > 
> > For example: add_to_page_cache_locked(GFP_KERNEL) (called with page
> > locked) -> page reclaim performs a trylock_page -> page reclaim performs
> > a writepage -> writepage performs a get_block -> get_block reads
> > buffercache -> buffercache read requires grow_dev_page -> grow_dev_page
> > locks buffercache page -> if writepage fails, page reclaim calls
> > handle_write_error -> handle_write_error performs a lock_page
> > 
> > So before even considering any other locks or more complex nested
> > filesystems, we can hold at least 3 different page locks at once. Should
> > be safe because we have an fs->bdev page lock ordering, and because
> > add_to_page_cache* tend to be called on new (non-LRU) pages that can't be
> > locked elsewhere, however a notable exception is tmpfs which moves live
> > pages in and out of pagecache.
> > 
> > So lockdepify the page lock. Each filesystem type gets a unique key, to
> > handle inter-filesystem nesting (like regular filesystem -> buffercache,
> > or ecryptfs -> lower). Newly allocated pages get a default lock class,
> > and it is reassigned to their filesystem type when being added to page
> > cache.
>   You'll probably soon notice that quite some filesystems (ext4, xfs,
> ocfs2, ...) lock several pages at once in their writepages function. The

Yes indeed. This is what I had meant about nesting with NTFS, but I
understand that others do it too.


> locking rule here is that we always lock pages in index increasing order. I
> don't think lockdep will be able to handle something like that. Probably we
> can just avoid lockdep checking in these functions (or just acquire the
> page lock class for the first page) but definitely there will be some

You are right, I don't think lockdep would work with that, so just
checking the lock for the first page should be better than nothing.
It might require some lockdep support in order to add context so it
doesn't go mad when unlock_page is called (would rather not add any
page flags to track that).

If we were really clever and able to get back to the address of
struct page that _is_ holding the lock, we could just do a simple
check to ensure its index is < the index of the page we are trying
to take.

That would give reasonable nesting checking without requiring lockdep
to track new chains for every page (obviously not feasible).


> filesystem work needed. So it would be useful to allow filesystems to
> opt-out from page lock checking (until fs maintainers are able to audit
> their page locking) so that people can still use lockdep to verify other
> things (when lockdep detects some issue, it turns itself off so if people
> would hit pagelock problems with their fs, they'd be basically unable to
> use lockdep for anything).

Agreed (btw. Peter is there any way to turn lock debugging back on?
it's annoying when cpufreq hotplug code or something early breaks and
you have to reboot in order to do any testing).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

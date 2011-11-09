Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEF56B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 11:45:42 -0500 (EST)
Date: Wed, 9 Nov 2011 17:45:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: write_cache_pages inefficiency
Message-ID: <20111109164537.GA7495@quack.suse.cz>
References: <4EB700B1.3050205@cfl.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EB700B1.3050205@cfl.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@cfl.rr.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 06-11-11 16:48:33, Phillip Susi wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> I've read over write_cache_pages() in page-writeback.c, and related
> writepages() functions, and it seems to me that it suffers from a
> performance problem whenever an fsync is done on a file and some of
> its pages have already begun writeback.  The comment in the code says:
> 
>  * If a page is already under I/O, write_cache_pages() skips it, even
>  * if it's dirty.  This is desirable behaviour for memory-cleaning
> writeback,
>  * but it is INCORRECT for data-integrity system calls such as
> fsync().  fsync()
>  * and msync() need to guarantee that all the data which was dirty at
> the time
>  * the call was made get new I/O started against them.  If
> wbc->sync_mode is
>  * WB_SYNC_ALL then we were called for data integrity and we must wait for
>  * existing IO to complete.
> 
> Based on this, I would expect the function to wait for an existing
> write to complete only if the page is also dirty.  Instead, it waits
> for existing page writes to complete regardless of the dirty bit.
  Are you sure? I can see in the code:
                        lock_page(page);
                        if (unlikely(page->mapping != mapping)) {
continue_unlock:
                                unlock_page(page);
                                continue;
                        }
                        if (!PageDirty(page)) {
                                /* someone wrote it for us */
                                goto continue_unlock;
                        }
                        if (PageWriteback(page)) {
                                if (wbc->sync_mode != WB_SYNC_NONE)
                                        wait_on_page_writeback(page);
                                else
                                        goto continue_unlock;
                        }
  So we skip clean pages...

> Additionally, it does each wait serially, so if you are trying to
> fsync 1000 dirty pages, and the first 10 are already being written
> out, the thread will block on each of those 10 pages write completion
> before it begins queuing any new writes.
  Yes, this is correct.

> Instead, shouldn't it go ahead and initiate pagewrite on all pages not
> already being written, and then come back and wait on those that were
> already in flight to complete, then initiate a second write on them if
> they are dirty?
  Well, if you can *demonstrate* with real numbers it has performance benefit
we could do it. But it's not clear there will be any benefit - skipping
pages which need writing can introduce additional seeks to the IO stream
and that is costly - sometimes much more costly than just waiting for IO to
complete...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

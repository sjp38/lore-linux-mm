Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 88F606B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 15:29:27 -0500 (EST)
Date: Fri, 22 Feb 2013 15:29:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: POSIX_FADV_DONTNEED implemented wrong
Message-ID: <20130222202921.GB4824@cmpxchg.org>
References: <5127CD9B.7050406@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5127CD9B.7050406@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On Fri, Feb 22, 2013 at 02:57:15PM -0500, Phillip Susi wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> I believe the current implementation for this is wrong.  For clean
> pages, it immediately discards them from the cache, and for dirty
> ones, it immediately tries to initiate writeout if the bdi is not
> congested.  I believe this is wrong for three reasons:
> 
> 1)  It is completely useless for writing files.  This hint should
> allow a program generating lots of writes to files that will not
> likely be read again to reduce the cache pressure that causes.

Wouldn't direct IO make more sense in that case?

> 2)  When there is little to no cache pressure, this hint should not
> cause the disk to spin up.

It's a hard problem to link memory pressure to writeback in a smart
way, we haven't been all too successful with it.  But maybe it makes
sense to remove the writeout in fadvise, since the user can do that up
front if the user is willing to give up throughput and energy for
memory.

> 3)  This is supposed to be a hint that caching this data is unlikely
> to do any good, so the cache should favor other data instead.  Just
> because one process does not think it will be used again does not mean
> it won't be, so when there is little to no cache pressure, we
> shouldn't go discarding potentially useful data.
> 
> I'd like to change this to simply force the pages to the inactive
> list, so they will be reclaimed sooner than other pages, but not
> immediately discarded, or written out.

Minchan worked on deactivating pages on truncation.  Maybe all it
takes is to implement deactivate_mapping_range() or something to
combine a page cache walk with deactivate_page().

While you are at it, madvise(MADV_DONTNEED) does not do anything to
the page cache, but it probably should.  :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

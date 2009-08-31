Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A17A6B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:37:12 -0400 (EDT)
Date: Mon, 31 Aug 2009 08:37:10 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831123710.GH20822@mit.edu>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu> <20090831102909.GS12579@kernel.dk> <20090831104748.GT12579@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831104748.GT12579@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 12:47:49PM +0200, Jens Axboe wrote:
> It's because ext4 writepages sets ->range_start and wb_writeback() is
> range cyclic, then the next iteration will have the previous end point
> as the starting point. Looks like we need to clear ->range_start in
> wb_writeback(), the better place is probably to do that in
> fs/fs-writeback.c:generic_sync_wb_inodes() right after the
> writeback_single_inode() call. This, btw, should be no different than
> the current code, weird/correct or not :-)

Hmm, or we could have ext4_da_writepages save and restore
->range_start.  One of the things that's never been well documented is
exactly what the semantics are of the various fields in the wbc
struct, and who is allowed to modify which fields when.

If you have some time, it would be great if you could document the
rules filesystems should be following with respect to the wbc struct,
and then we can audit each filesystem to make sure they follow those
rules.  One of the things which is a bit scary about how the many wbc
flags work is that each time a filesystem wants some particular
behavior, it seems like we need to dive into writeback code, and
figure out some combination of flags/settings that make the page
writeback code do what we wants, and sometimes it's not clear whether
that was a designed-in semantic of the interface, or just something
that happened to work given the current implementation.

In any case, if one of the rules is that the filesystems' writepages
command shouldn't be modifying range_start, we can fix this problem up
by saving and restore range_start inside ext4_da_writepages().

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

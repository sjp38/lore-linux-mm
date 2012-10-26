Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D8AFF6B0080
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 14:50:18 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Date: Fri, 26 Oct 2012 14:50:04 -0400
Message-Id: <1351277405-9072-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121026061206.GA31139@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>Andi Kleen <andi.kleen@intel.com>Tony Luck <tony.luck@intel.com>Wu Fengguang <fengguang.wu@intel.com>Andrew Morton <akpm@linux-foundation.org>Jan Kara <jack@suse.cz>Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

On Fri, Oct 26, 2012 at 02:12:06AM -0400, Theodore Ts'o wrote:
> On Thu, Oct 25, 2012 at 11:12:48AM -0400, Naoya Horiguchi wrote:
> > +	/* Lost data. Handle as critical fs error. */
> > +	bh = head = page_buffers(page);
> > +	do {
> > +		if (buffer_dirty(bh) && !buffer_delay(bh)) {
> > +			block = bh->b_blocknr;
> > +			EXT4_ERROR_INODE_BLOCK(inode, block,
> > +						"Removing dirty pagecache page");
> > +		} else
> > +			EXT4_ERROR_INODE(inode,
> > +					"Removing dirty pagecache page");
> 
> One of the side effects of calling EXT4_ERROR_INODE (or ext3_error in
> your ext3 patch), it sets the "file system is corrupt" bit which
> forces the file system to be fsck'ed at the next boot.
> 
> If this is just a memory error, it's not clear that this is the right
> thing to have happen.  It's also not clear what the benefit would be
> is of forcing a reboot in the errors=panic case.  If the file system
> is corrupt, forcing a panic and reboot is useful because it allows a
> file system to get checked instead of allowing the system to continue
> on and perhaps cause more data loss.

Let me explain what I'm worry about.
Once memory error hits a dirty pagecache page, the page itself is
removed from pagecache tree and will never be accessed later.
But the problem is that after memory error handling is done,
not all processes can know about that error event.
As a result, a process which is not aware of the error tries to read
the old data for disk, and data corruption spreads by using wrong data.
I think that forcing rebooting is effective to prevent such spread of
data corruption.

> 
> But if what happened is that there was a hard ECC error on a page,
> we've already lost data.  Forcing a reboot isn't going to make things
> better; and if you force an e2fsck, it will just increase the system's
> downtime.  It's also not entirely clear that throwing away the page is
> the right thing to do, either, by the way.  If you have a hard ECC
> error, then there has might be a two or three bits that have gotten
> flipped on that page.  But by throwing the dirty page entirely, we're
> throwing away 4k worth of data.
> 
> If we go back to first principles, what do we want to do?  We want the
> system administrator to know that a file might be potentially
> corrupted.  And perhaps, if a program tries to read from that file, it
> should get an error.  If we have a program that has that file mmap'ed
> at the time of the error, perhaps we should kill the program with some
> kind of signal.  But to force a reboot of the entire system?  Or to
> remounte the file system read-only?  That seems to be completely
> disproportionate for what might be 2 or 3 bits getting flipped in a
> page cache for a file.

In order to completely solve this problem, I'm thinking about another
approach without rebooting. Roughly saying, it introduces additional
tag in pagecache tree to keep error-affected address of the error-affected
file untouchable until we 'recover' the address range (This is based
on the provious discussion in https://lkml.org/lkml/2012/9/2/194.)
But I should be careful for many details for the patch and will take
some time, so I want to start with a simpler approach.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

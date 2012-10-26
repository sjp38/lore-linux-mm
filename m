Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E799F6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 02:12:13 -0400 (EDT)
Date: Fri, 26 Oct 2012 02:12:06 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Message-ID: <20121026061206.GA31139@thunk.org>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu, Oct 25, 2012 at 11:12:48AM -0400, Naoya Horiguchi wrote:
> +	/* Lost data. Handle as critical fs error. */
> +	bh = head = page_buffers(page);
> +	do {
> +		if (buffer_dirty(bh) && !buffer_delay(bh)) {
> +			block = bh->b_blocknr;
> +			EXT4_ERROR_INODE_BLOCK(inode, block,
> +						"Removing dirty pagecache page");
> +		} else
> +			EXT4_ERROR_INODE(inode,
> +					"Removing dirty pagecache page");

One of the side effects of calling EXT4_ERROR_INODE (or ext3_error in
your ext3 patch), it sets the "file system is corrupt" bit which
forces the file system to be fsck'ed at the next boot.

If this is just a memory error, it's not clear that this is the right
thing to have happen.  It's also not clear what the benefit would be
is of forcing a reboot in the errors=panic case.  If the file system
is corrupt, forcing a panic and reboot is useful because it allows a
file system to get checked instead of allowing the system to continue
on and perhaps cause more data loss.

But if what happened is that there was a hard ECC error on a page,
we've already lost data.  Forcing a reboot isn't going to make things
better; and if you force an e2fsck, it will just increase the system's
downtime.  It's also not entirely clear that throwing away the page is
the right thing to do, either, by the way.  If you have a hard ECC
error, then there has might be a two or three bits that have gotten
flipped on that page.  But by throwing the dirty page entirely, we're
throwing away 4k worth of data.

If we go back to first principles, what do we want to do?  We want the
system administrator to know that a file might be potentially
corrupted.  And perhaps, if a program tries to read from that file, it
should get an error.  If we have a program that has that file mmap'ed
at the time of the error, perhaps we should kill the program with some
kind of signal.  But to force a reboot of the entire system?  Or to
remounte the file system read-only?  That seems to be completely
disproportionate for what might be 2 or 3 bits getting flipped in a
page cache for a file.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

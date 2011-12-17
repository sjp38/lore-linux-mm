Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B602E6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 17:10:37 -0500 (EST)
Date: Sat, 17 Dec 2011 22:10:28 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111217221028.GZ2203@ZenIV.linux.org.uk>
References: <20111216112534.GA13147@dztty>
 <20111216125556.db2bf308.akpm@linux-foundation.org>
 <20111217214137.GY2203@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111217214137.GY2203@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Djalal Harouni <tixxdz@opendz.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org

On Sat, Dec 17, 2011 at 09:41:37PM +0000, Al Viro wrote:

> xfs and ext4_ioctl() need to be fixed; XFS fix follows, ext4 I'd rather left
> to ext4 folks - I don't know how wide an area needs i_mutex there

Oh, for fsck sake...  People, this is *obviously* broken - if nothing else,
removing suid after modifying the file contents is too late.  Moreover,
this mext_inode_double_lock() thing is asking for trouble; it's deadlock-free
only because nothing else takes i_mutex on more than one non-directory inode
and does that as the innermost lock.  Start calling it for directories
(or have somebody cut'n'paste it and use it for directories) and you've got
a nice, shiny deadlock...  BTW, is ordering really needed in
double_down_write_data_sem()?  IOW, can we get contention between several
callers of that thing?

>From my reading of that code, all call chains leading to this sucker
are guaranteed to already hold i_mutex on both inodes.  If that is true,
we don't need any ordering in double_down_write_data_sem() at all...

AFAICS, the minimal fix is to move file_remove_suid() call into
ext4_move_extents(), just after we have acquired i_mutex in there.
Moreover, I think it should be done to *both* files, since both have
contents modified.  And I see no point in making that conditional...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

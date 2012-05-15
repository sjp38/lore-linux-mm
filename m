Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id CF4DE6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 18:48:23 -0400 (EDT)
Date: Wed, 16 May 2012 00:48:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Hole punching and mmap races
Message-ID: <20120515224805.GA25577@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

  Hello,

  Hugh pointed me to ext4 hole punching code which is clearly missing some
locking. But looking at the code more deeply I realized I don't see
anything preventing the following race in XFS or ext4:

TASK1				TASK2
				punch_hole(file, 0, 4096)
				  filemap_write_and_wait()
				  truncate_pagecache_range()
addr = mmap(file);
addr[0] = 1
  ^^ writeably fault a page
				  remove file blocks

						FLUSHER
						write out file
						  ^^ interesting things can
happen because we expect blocks under the first page to be allocated /
reserved but they are not...

I'm pretty sure ext4 has this problem, I'm not completely sure whether
XFS has something to protect against such race but I don't see anything.

It's not easy to protect against these races. For truncate, i_size protects
us against similar races but for hole punching we don't have any such
mechanism. One way to avoid the race would be to hold mmap_sem while we are
invalidating the page cache and punching hole but that sounds a bit ugly.
Alternatively we could just have some special lock (rwsem?) held during
page_mkwrite() (for reading) and during whole hole punching (for writing)
to serialize these two operations.

Another alternative, which doesn't really look more appealing, is to go
page-by-page and always free corresponding blocks under page lock.

Any other ideas or thoughts?

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

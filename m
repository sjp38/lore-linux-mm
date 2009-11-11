Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A02EF6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:19:41 -0500 (EST)
Date: Wed, 11 Nov 2009 16:19:37 +0100
From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: posix_fadvise/WILLNEED synchronous on fuse/sshfs instead of async?
Message-ID: <20091111151937.GC20655@yumi.tdiedrich.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While trying to use posix_fadvise(...POSIX_FADVISE_WILLNEED) to
implement userspace read-ahead (with a bigger read-ahead window than
the kernel default) I found that if the underlying filesystem is
fuse/sshfs posix_fadvise is no longer doing asynchronous reads:

strace -tt with mnt/testfile on sshfs and server with very slow
upstream (ADSL):
5345  00:00:17.334209 open("mnt/testfile", O_RDONLY|O_LARGEFILE) = 3
5345  00:00:18.011383 _llseek(3, 0, [3544379], SEEK_END) = 0
5345  00:00:18.011626 _llseek(3, 0, [0], SEEK_SET) = 0
5345  00:00:18.012393 fadvise64_64(3, 0, 1048576, POSIX_FADV_WILLNEED) = 0
5345  00:01:02.438097 write(1, "[file] File size is 3544379 byte"..., 34) = 34

Note that fadvise takes 40 seconds...
Is this expected behaviour?
I would have expected that fadvise is always asynchronous and I
could rely on the call to return almost immediately.

-- 
Tobias						PGP: http://8ef7ddba.uguu.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

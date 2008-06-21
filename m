Message-Id: <20080621154607.154640724@szeredi.hu>
Date: Sat, 21 Jun 2008 17:46:07 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [rfc patch 0/4] splice: cleanups and fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Brian Wang reported some problems with NFS export of fuse filesystems,
which turned out to be bad interaction between splice (used by nfsd)
and page cache invalidation.

I looked at the splice code, and found quite a bit of dead code,
duplication, and unnecessary complication.  This patchset attempts to
resolve those, in addition to fixing the invalidation issues.  Some
optimizations are lost in the process like the gang page lookup for
the fully cached case, and I can't really tell if these are important
enough to warrant the extra complexity.

I did minimal testing to verify that splice(2) on regular files still
works.  And since generic_file_splice_read() now shares most of its
code with generic_file_aio_read(), there's not much to go wrong in
there.  That said, it needs more testing...

Comments?

Thanks,
Miklos
--

 drivers/block/loop.c      |    5 
 fs/nfsd/vfs.c             |    9 -
 fs/pipe.c                 |   58 -------
 fs/splice.c               |  371 +++++-----------------------------------------
 include/linux/fs.h        |    2 
 include/linux/pipe_fs_i.h |   36 ----
 kernel/relay.c            |    2 
 mm/filemap.c              |    2 
 net/core/skbuff.c         |    9 -
 9 files changed, 47 insertions(+), 447 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

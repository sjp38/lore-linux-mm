Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 819B46B00E8
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:54:31 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/7 v3] Push file_update_time() into .page_mkwrite
Date: Mon,  5 Mar 2012 15:54:11 +0100
Message-Id: <1330959258-23211-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Jaya Kumar <jayalk@intworks.biz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

  Hello,

  to provide reliable support for filesystem freezing, filesystems need to have
complete control over when metadata is changed. In particular,
file_update_time() calls from page fault code make it impossible for
filesystems to prevent inodes from being dirtied while the filesystem is
frozen.

To fix the issue, this patch set changes page fault code to call
file_update_time() only when ->page_mkwrite() callback is not provided. If the
callback is provided, it is the responsibility of the filesystem to perform
update of i_mtime / i_ctime if needed. We also push file_update_time() call
to all existing ->page_mkwrite() implementations if the time update does not
obviously happen by other means. This is including __block_page_mkwrite() so
filesystems using it are handled. If you know your filesystem does not need
update of modification times in ->page_mkwrite() handler, please speak up and
I'll drop the patch for your filesystem.

As a side note, an alternative would be to remove calls of file_update_time()
from page fault code altogether and require all filesystems needing it to do
that in their ->page_mkwrite() implementation. That is certainly possible
although maybe slightly inefficient and would require auditting 100+
vm_operations_structs *shiver*.

Changes since v1:
* Dropped patches for filesystems which don't need them
* Added some acks
* Improved sysfs patch by Alex Elder's suggestion

Changes since v2:
* Dropped patches for more filesystems

Andrew, would you be willing to merge these patches via your tree? This seems
to be a final version.

								Honza

CC: Jaya Kumar <jayalk@intworks.biz>
CC: Sage Weil <sage@newdream.net>
CC: ceph-devel@vger.kernel.org
CC: Eric Van Hensbergen <ericvh@gmail.com>
CC: Ron Minnich <rminnich@sandia.gov>
CC: Latchesar Ionkov <lucho@ionkov.net>
CC: v9fs-developer@lists.sourceforge.net
CC: Steven Whitehouse <swhiteho@redhat.com>
CC: cluster-devel@redhat.com
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

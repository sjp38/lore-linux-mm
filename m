Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1AAFF6B00EC
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:41:58 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 00/11 v2] Push file_update_time() into .page_mkwrite
Date: Thu,  1 Mar 2012 12:41:34 +0100
Message-Id: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jan Kara <jack@suse.cz>, Jaya Kumar <jayalk@intworks.biz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
obviously happen by other means. If you know your filesystem does not need
update of modification times in ->page_mkwrite() handler, please speak up and
I'll drop the patch for your filesystem.

As a side note, an alternative would be to remove call of file_update_time()
from page fault code altogether and require all filesystems needing it to do
that in their ->page_mkwrite() implementation. That is certainly possible
although maybe slightly inefficient and would require auditting 100+
vm_operations_structs *shiver*.

Changes since v1:
* Dropped patches for filesystems which don't need them
* Added some acks
* Improved sysfs patch by Alex Elder's suggestion

Andrew, would you be willing to merge these patches via your tree?

								Honza

CC: Jaya Kumar <jayalk@intworks.biz>
CC: Sage Weil <sage@newdream.net>
CC: ceph-devel@vger.kernel.org
CC: Steve French <sfrench@samba.org>
CC: linux-cifs@vger.kernel.org
CC: Eric Van Hensbergen <ericvh@gmail.com>
CC: Ron Minnich <rminnich@sandia.gov>
CC: Latchesar Ionkov <lucho@ionkov.net>
CC: v9fs-developer@lists.sourceforge.net
CC: Miklos Szeredi <miklos@szeredi.hu>
CC: fuse-devel@lists.sourceforge.net
CC: Steven Whitehouse <swhiteho@redhat.com>
CC: cluster-devel@redhat.com
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

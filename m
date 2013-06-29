Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 208656B0032
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:42:05 -0400 (EDT)
Subject: [PATCH v5 00/16] fuse: An attempt to implement a write-back cache
 policy
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:41:45 +0400
Message-ID: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

Hi,

This is the fifth iteration of Pavel Emelyanov's patch-set implementing
write-back policy for FUSE page cache. Initial patch-set description was
the following:

One of the problems with the existing FUSE implementation is that it uses the
write-through cache policy which results in performance problems on certain
workloads. E.g. when copying a big file into a FUSE file the cp pushes every
128k to the userspace synchronously. This becomes a problem when the userspace
back-end uses networking for storing the data.

A good solution of this is switching the FUSE page cache into a write-back policy.
With this file data are pushed to the userspace with big chunks (depending on the
dirty memory limits, but this is much more than 128k) which lets the FUSE daemons
handle the size updates in a more efficient manner.

The writeback feature is per-connection and is explicitly configurable at the
init stage (is it worth making it CAP_SOMETHING protected?) When the writeback is
turned ON:

* still copy writeback pages to temporary buffer when sending a writeback request
  and finish the page writeback immediately

* make kernel maintain the inode's i_size to avoid frequent i_size synchronization
  with the user space

* take NR_WRITEBACK_TEMP into account when makeing balance_dirty_pages decision.
  This protects us from having too many dirty pages on FUSE

The provided patchset survives the fsx test. Performance measurements are not yet
all finished, but the mentioned copying of a huge file becomes noticeably faster
even on machines with few RAM and doesn't make the system stuck (the dirty pages
balancer does its work OK). Applies on top of v3.5-rc4.

We are currently exploring this with our own distributed storage implementation
which is heavily oriented on storing big blobs of data with extremely rare meta-data
updates (virtual machines' and containers' disk images). With the existing cache
policy a typical usage scenario -- copying a big VM disk into a cloud -- takes way
too much time to proceed, much longer than if it was simply scp-ed over the same
network. The write-back policy (as I mentioned) noticeably improves this scenario.
Kirill (in Cc) can share more details about the performance and the storage concepts
details if required.

Changed in v2:
 - numerous bugfixes:
   - fuse_write_begin and fuse_writepages_fill and fuse_writepage_locked must wait
     on page writeback because page writeback can extend beyond the lifetime of
     the page-cache page
   - fuse_send_writepages can end_page_writeback on original page only after adding
     request to fi->writepages list; otherwise another writeback may happen inside
     the gap between end_page_writeback and adding to the list
   - fuse_direct_io must wait on page writeback; otherwise data corruption is possible
     due to reordering requests
   - fuse_flush must flush dirty memory and wait for all writeback on given inode
     before sending FUSE_FLUSH to userspace; otherwise FUSE_FLUSH is not reliable
   - fuse_file_fallocate must hold i_mutex around FUSE_FALLOCATE and i_size update;
     otherwise a race with a writer extending i_size is possible
   - fix handling errors in fuse_writepages and fuse_send_writepages
 - handle i_mtime intelligently if writeback cache is on (see patch #7 (update i_mtime
   on buffered writes) for details.
 - put enabling writeback cache under fusermount control; (see mount option
   'allow_wbcache' introduced by patch #13 (turn writeback cache on))
 - rebased on v3.7-rc5

Changed in v3:
 - rebased on for-next branch of the fuse tree (fb05f41f5f96f7423c53da4d87913fb44fd0565d)

Changed in v4:
 - rebased on for-next branch of the fuse tree (634734b63ac39e137a1c623ba74f3e062b6577db)
 - fixed fuse_fillattr() for non-writeback_chace case
 - added comments explaining why we cannot trust size from server
 - rewrote patch handling i_mtime; it's titled Trust-kernel-i_mtime-only now
 - simplified patch titled Flush-files-on-wb-close
 - eliminated code duplications from fuse_readpage() ans fuse_prepare_write()
 - added comment about "disk full" errors to fuse_write_begin()

Changed in v5:
 - rebased on for-next branch of the fuse tree (e5c5f05dca0cf90f0f3bb1aea85dcf658baff185)
   with "hold i_mutex in fuse_file_fallocate() - v2" patch applied manually
 - updated patch descriptions according to Miklos' demand (using From: for
   patches initially developed by someone else)
 - moved ->writepages() to a separate patch and enabled it unconditionally
   for mmaped writeback
 - moved restructuring fuse_readpage to a separate patch
 - avoided use of union for fuse_fill_data
 - grabbed a ref to the request in fuse_send_writepages

Thanks,
Maxim

---

Maxim Patlasov (10):
      fuse: Connection bit for enabling writeback
      fuse: Trust kernel i_mtime only
      fuse: Flush files on wb close
      fuse: restructure fuse_readpage()
      fuse: Implement write_begin/write_end callbacks
      fuse: fuse_writepage_locked() should wait on writeback
      fuse: fuse_flush() should wait on writeback
      fuse: Fix O_DIRECT operations vs cached writeback misorder - v2
      fuse: Turn writeback cache on
      mm: strictlimit feature

Pavel Emelyanov (6):
      fuse: Linking file to inode helper
      fuse: Getting file for writeback helper
      fuse: Prepare to handle short reads
      fuse: Prepare to handle multiple pages in writeback
      fuse: Trust kernel i_size only - v4
      fuse: Implement writepages callback


 fs/fs-writeback.c           |    2 
 fs/fuse/cuse.c              |    5 
 fs/fuse/dir.c               |  127 +++++++++-
 fs/fuse/file.c              |  572 ++++++++++++++++++++++++++++++++++++++-----
 fs/fuse/fuse_i.h            |   26 ++
 fs/fuse/inode.c             |   38 ++-
 include/linux/backing-dev.h |    5 
 include/linux/pagemap.h     |    1 
 include/linux/writeback.h   |    3 
 include/uapi/linux/fuse.h   |    2 
 mm/backing-dev.c            |    3 
 mm/page-writeback.c         |  131 ++++++++--
 12 files changed, 794 insertions(+), 121 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

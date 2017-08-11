Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8683B6B03B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 02:45:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t80so29236591pgb.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 23:45:43 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u1si108204plk.956.2017.08.10.23.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 23:45:42 -0700 (PDT)
Subject: [PATCH v3 0/6] fs, xfs: block map immutable files
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Aug 2017 23:39:17 -0700
Message-ID: <150243355681.8777.14902834768886160223.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anna Schumaker <anna.schumaker@netapp.com>

Changes since v2 [1]:
* Rather than have an IS_IOMAP_IMMUTABLE() check in
  xfs_alloc_file_space(), place one centrally in xfs_bmapi_write() to
  catch all attempts to write the block allocation map. (Dave)

* Make sealing an already sealed file, or unsealing an already unsealed
  file return success (Darrick)

* Set S_IOMAP_IMMUTABLE along with the transaction that sets
  XFS_DIFLAG2_IOMAP_IMMUTABLE (Darrick)

* Round the range of the allocation and extent conversion performed by
  FALLOC_FL_SEAL_BLOCK_MAP up to the filesystem block size.

* Add a proof-of-concept patch for the use of immutable files with swap.

[1]: https://lkml.org/lkml/2017/8/3/996

---

The ability to make the physical block-allocation map of a file
immutable is a powerful mechanism that allows userspace to have
predictable dax-fault latencies, flush dax mappings to persistent memory
without a syscall, and otherwise enable access to storage directly
without ongoing mediation from the filesystem.

This last aspect of direct storage addressability has been called a
"horrible abuse" [2], but the reality is quite the reverse. Enabling
files to be block-map immutable allows applications that would otherwise
need to rely on dangerous raw device access to instead use a filesystem.
Security, naming, re-provisioning capacity between usages are all better
supported with safe semantics in a filesystem compared to a device file.

It is time to "give up the idea that only the filesystem can access the
storage underlying the filesystem" [3] to enable a better / safer
alternative to using a raw device for userpace block servers, dax
hypervisors, and peer-to-peer transfers to name a few use cases.

[2]: https://lkml.org/lkml/2017/8/5/56
[3]: https://lkml.org/lkml/2017/8/6/299

---

Dan Williams (6):
      fs, xfs: introduce S_IOMAP_IMMUTABLE
      fs, xfs: introduce FALLOC_FL_SEAL_BLOCK_MAP
      fs, xfs: introduce FALLOC_FL_UNSEAL_BLOCK_MAP
      xfs: introduce XFS_DIFLAG2_IOMAP_IMMUTABLE
      xfs: toggle XFS_DIFLAG2_IOMAP_IMMUTABLE in response to fallocate
      mm, xfs: protect swapfile contents with immutable + unwritten extents


 fs/attr.c                   |   10 +++
 fs/nfs/file.c               |    7 ++
 fs/open.c                   |   24 +++++++
 fs/read_write.c             |    3 +
 fs/xfs/libxfs/xfs_bmap.c    |    6 ++
 fs/xfs/libxfs/xfs_bmap.h    |   12 +++-
 fs/xfs/libxfs/xfs_format.h  |    5 +-
 fs/xfs/xfs_aops.c           |   54 ++++++++++++++++
 fs/xfs/xfs_bmap_util.c      |  142 +++++++++++++++++++++++++++++++++++++++++++
 fs/xfs/xfs_bmap_util.h      |    5 ++
 fs/xfs/xfs_file.c           |   16 ++++-
 fs/xfs/xfs_inode.c          |    2 +
 fs/xfs/xfs_ioctl.c          |    7 ++
 fs/xfs/xfs_iops.c           |    8 ++
 include/linux/falloc.h      |    4 +
 include/linux/fs.h          |    2 +
 include/uapi/linux/falloc.h |   18 +++++
 include/uapi/linux/fs.h     |    1 
 mm/filemap.c                |    5 ++
 mm/page_io.c                |    1 
 mm/swapfile.c               |   20 ++----
 21 files changed, 328 insertions(+), 24 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

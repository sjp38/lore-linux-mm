Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB736B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:45:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so327987076pfx.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:45:55 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n11si37788461plg.331.2016.11.30.15.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 15:45:54 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 0/6] introduce DAX tracepoint support
Date: Wed, 30 Nov 2016 16:45:27 -0700
Message-Id: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Tracepoints are the standard way to capture debugging and tracing
information in many parts of the kernel, including the XFS and ext4
filesystems.  This series creates a tracepoint header for FS DAX and add
the first few DAX tracepoints to the PMD fault handler.  This allows the
tracing for DAX to be done in the same way as the filesystem tracing so
that developers can look at them together and get a coherent idea of what
the system is doing.

I do intend to add tracepoints to the normal 4k DAX fault path and to the
DAX I/O path, but I wanted to get feedback on the PMD tracepoints before I
went any further.

This series is based on Jan Kara's "dax: Clear dirty bits after flushing
caches" series:

https://lists.01.org/pipermail/linux-nvdimm/2016-November/007864.html

I've pushed a git tree with this work here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_tracepoints_v2

Changes since v1:
 - Dropped the patch fixing the build issue between DAX, ext4 and FS_IOMAP.
   I'll resend an updated patch if needed once Jan's patches for this issue
   are applied.
 - Added incude/linux/dax.h to MAINTAINERS in patch 4. (Matthew)
 - Begin each DAX tracepoint with the device major/minor and the inode so
   that we are consistent with the XFS tracepoints. This will allow for
   easy grepping of the tracepoint output. (Dave)
 - Print all PMD fault flags, not just whether we are doing a read or a
   write. (Jan)
 - Added __print_flags_u64() and the necessary helpers to the tracing
   infrastructure.  These functions allow us to print symbols associated
   with flags that are 64 bits wide even on 32 bit machines.  We need this
   for the pfn_t flags.

Ross Zwisler (6):
  tracing: add __print_flags_u64()
  dax: remove leading space from labels
  dax: add tracepoint infrastructure, PMD tracing
  dax: update MAINTAINERS entries for FS DAX
  dax: add tracepoints to dax_pmd_load_hole()
  dax: add tracepoints to dax_pmd_insert_mapping()

 MAINTAINERS                   |   5 +-
 fs/dax.c                      |  80 +++++++++++++--------
 include/linux/mm.h            |  25 +++++++
 include/linux/pfn_t.h         |   6 ++
 include/linux/trace_events.h  |   4 ++
 include/trace/events/fs_dax.h | 161 ++++++++++++++++++++++++++++++++++++++++++
 include/trace/trace_events.h  |  11 +++
 kernel/trace/trace_output.c   |  38 ++++++++++
 8 files changed, 300 insertions(+), 30 deletions(-)
 create mode 100644 include/trace/events/fs_dax.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

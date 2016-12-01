Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4A8280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:38:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so105493740pgx.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:38:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 1si769098pll.154.2016.12.01.08.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:38:00 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 0/5] introduce DAX tracepoint support
Date: Thu,  1 Dec 2016 09:37:46 -0700
Message-Id: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
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

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_tracepoints_v3

Changes since v2:
 - Dropped "dax: remove leading space from labels" patch. (Jan)
 - Reordered TP_STRUCT__entry() fields so that all the 64 bit entries (for
   64 bit machines) come first, followed by the 32 bit entries.  This
   allows for optimal packing of the entires. (Steve)
 - Fixed 'mask' in trace_print_flags_seq_u64() to be an unsigned long long.
   (Steve)

Ross Zwisler (5):
  tracing: add __print_flags_u64()
  dax: add tracepoint infrastructure, PMD tracing
  dax: update MAINTAINERS entries for FS DAX
  dax: add tracepoints to dax_pmd_load_hole()
  dax: add tracepoints to dax_pmd_insert_mapping()

 MAINTAINERS                   |   5 +-
 fs/dax.c                      |  56 ++++++++++-----
 include/linux/mm.h            |  25 +++++++
 include/linux/pfn_t.h         |   6 ++
 include/linux/trace_events.h  |   4 ++
 include/trace/events/fs_dax.h | 161 ++++++++++++++++++++++++++++++++++++++++++
 include/trace/trace_events.h  |  11 +++
 kernel/trace/trace_output.c   |  38 ++++++++++
 8 files changed, 288 insertions(+), 18 deletions(-)
 create mode 100644 include/trace/events/fs_dax.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

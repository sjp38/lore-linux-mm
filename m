Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC6D6B02FA
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 21:21:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so51535878pfe.10
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 18:21:53 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t5si3174592pfe.291.2017.06.16.18.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 18:21:52 -0700 (PDT)
Subject: [RFC PATCH 0/2] daxfile: enable byte-addressable updates to pmem
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Jun 2017 18:15:24 -0700
Message-ID: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Quoting PATCH 2/2:

    To date, the full promise of byte-addressable access to persistent
    memory has only been half realized via the filesystem-dax interface. The
    current filesystem-dax mechanism allows an application to consume (read)
    data from persistent storage at byte-size granularity, bypassing the
    full page reads required by traditional storage devices.
    
    Now, for writes, applications still need to contend with
    page-granularity dirtying and flushing semantics as well as filesystem
    coordination for metadata updates after any mmap write. The current
    situation precludes use cases that leverage byte-granularity / in-place
    updates to persistent media.
    
    To get around this limitation there are some specialized applications
    that are using the device-dax interface to bypass the overhead and
    data-safety problems of the current filesystem-dax mmap-write path.
    QEMU-KVM is forced to use device-dax to safely pass through persistent
    memory to a guest [1]. Some specialized databases are using device-dax
    for byte-granularity writes. Outside of those cases, device-dax is
    difficult for general purpose persistent memory applications to consume.
    There is demand for access to pmem without needing to contend with
    special device configuration and other device-dax limitations.
    
    The 'daxfile' interface satisfies this demand and realizes one of Dave
    Chinner's ideas for allowing pmem applications to safely bypass
    fsync/msync requirements. The idea is to make the file immutable with
    respect to the offset-to-block mappings for every extent in the file
    [2]. It turns out that filesystems already need to make this guarantee
    today. This property is needed for files marked as swap files.
    
    The new daxctl() syscall manages setting a file into 'static-dax' mode
    whereby it arranges for the file to be treated as a swapfile as far as
    the filesystem is concerned, but not registered with the core-mm as
    swapfile space. A file in this mode is then safe to be mapped and
    written without the requirement to fsync/msync the writes.  The cpu
    cache management for flushing data to persistence can be handled
    completely in userspace.
   
As can be seen in the patches there are still some TODOs to resolve in
the code, but this otherwise appears to solve the problem of persistent
memory applications needing to coordinate any and all writes to a file
mapping with fsync/msync.

[1]: https://lists.gnu.org/archive/html/qemu-devel/2017-06/msg01207.html
[2]: https://lkml.org/lkml/2016/9/11/159

---

Dan Williams (2):
      mm: introduce bmap_walk()
      mm, fs: daxfile, an interface for byte-addressable updates to pmem


 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 include/linux/dax.h                    |    9 ++
 include/linux/fs.h                     |    3 +
 include/linux/syscalls.h               |    1 
 include/uapi/linux/dax.h               |    8 +
 mm/Kconfig                             |    5 +
 mm/Makefile                            |    1 
 mm/daxfile.c                           |  186 ++++++++++++++++++++++++++++++++
 mm/page_io.c                           |  117 +++++++++++++++++---
 9 files changed, 312 insertions(+), 19 deletions(-)
 create mode 100644 include/uapi/linux/dax.h
 create mode 100644 mm/daxfile.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

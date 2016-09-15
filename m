Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7537F6B0265
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 02:57:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu12so73855067pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 23:57:55 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 27si37778195pfn.124.2016.09.14.23.57.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 23:57:54 -0700 (PDT)
Subject: [PATCH v2 0/3] mm,
 dax: export dax capabilities and mapping size info to userspace
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Sep 2016 23:54:25 -0700
Message-ID: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, npiggin@gmail.com, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In the debate about how to support persistent memory applications that
want to use hardware-platform memory-media persistence
rules/cpu-instructions rather than filesystem data intergrity system
calls [1], one of the consistent requests is to move these applications
to use a device file rather than a filesystem file [2].

While there is still a desire to offer the same syscall overhead
avoidance in filesystem-dax as device-dax, there is performance
optimization work and analysis that still needs to be done.
Optimization/analysis to address filesystem-dax performance being slower
than the typical page-cache path on top of pmem [3], and whether the
performance gains are worth developing new filesytem data integrity
mechanisms.

In the meantime we have device-dax and are missing a way to identify its
capabilities compared to filesytem-dax.  Critically, we want a
persistent memory transaction library, that is handed an address range
to manage, to be able to determine if it is safe to forgo calling
fsync/msync to record newly allocated blocks after a write fault.  This
question is answered by the new VM_SYNC flag.

It is also important to know if the pages behind a mapping are backed by
page cache and need to be synced, or are referencing media directly.  We
have an XFS inode flag that can indicate the inode is DAX enabled, but
nothing for device-dax or other filesystems.  Yes, an application that
maps /dev/dax should assume the mapping is DAX, but it is useful to be
able to tell that from the address range directly, and a common
mechanism across filesystems.

Finally, while developing and debugging the filesystem-dax huge page
support it was frustrating that the only way to unit test and verify the
implementation was via debug print statements.  This series extends
mincore(2) to optionally provide an indication of the hardware mapping
size.  This is hopefully useful to other cases that want to evaluate
transparent-huge-page usage.


Changes since the RFC [4]:

1/ Drop DAX indication out of mincore.  It is a vma capability not a
   per-page property and fits better as a vma flag.  Multiple people
   indicated it would be better if the new syscall published the capability
   as an extent or aggregated over a range, and this facility is already
   provided by smaps.

2/ Add VM_SYNC to explicity disclaim a need to call fsync/msync

3/ Drop the syscall wire-up patch since it is trivial and can be revived
   if we decide to move forward with the new mincore syscall.


[1]: https://lwn.net/Articles/676737/
[2]: https://lists.01.org/pipermail/linux-nvdimm/2016-September/006893.html
[3]: https://lists.01.org/pipermail/linux-nvdimm/2016-August/006497.html
[4]: https://lists.01.org/pipermail/linux-nvdimm/2016-September/006875.html

---

Dan Williams (3):
      mm, dax: add VM_SYNC flag for device-dax VMAs
      mm, dax: add VM_DAX flag for DAX VMAs
      mm, mincore2(): retrieve tlb-size attributes of an address range


 drivers/dax/Kconfig                    |    1 
 drivers/dax/dax.c                      |    2 
 fs/Kconfig                             |    1 
 fs/ext2/file.c                         |    2 
 fs/ext4/file.c                         |    2 
 fs/proc/task_mmu.c                     |    4 +
 fs/xfs/xfs_file.c                      |    2 
 include/linux/mm.h                     |   31 +++++++-
 include/linux/syscalls.h               |    2 
 include/uapi/asm-generic/mman-common.h |    2 
 kernel/sys_ni.c                        |    1 
 mm/mincore.c                           |  130 ++++++++++++++++++++++++--------
 12 files changed, 141 insertions(+), 39 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

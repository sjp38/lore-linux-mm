Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 14465828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 14:42:04 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id e32so427548501qgf.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 11:42:04 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r16si14744662qhb.114.2016.01.15.11.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 11:42:03 -0800 (PST)
Date: Fri, 15 Jan 2016 11:41:50 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Message-ID: <20160115194150.GA5751@birch.djwong.org>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Fri, Jan 08, 2016 at 02:49:44PM -0500, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Andrew, I think this is ready for a spin in -mm.
> 
> v3: Rebased against current mmtom
> v2: Reduced churn in filesystems by switching to ->huge_fault interface
>     Addressed concerns from Kirill
> 
> We have customer demand to use 1GB pages to map DAX files.  Unlike the 2MB
> page support, the Linux MM does not currently support PUD pages, so I have
> attempted to add support for the necessary pieces for DAX huge PUD pages.
> 
> Filesystems still need work to allocate 1GB pages.  With ext4, I can
> only get 16MB of contiguous space, although it is aligned.  With XFS,
> I can get 80MB less than 1GB, and it's not aligned.  The XFS problem
> may be due to the small amount of RAM in my test machine.

"It's not aligned"... I don't know the details of what you're trying to do, but
are you trying to create a file where each GB of logical address space maps to
a contiguous GB of physical space, and both logical and physical offsets align
to a 1GB boundary?

If the XFS is formatted with stripe unit/width of 1G, an extent size hint of 1G
is put on the file, and the whole file is allocated in 1G chunks, I think
you're supposed to be able to make the above happen:

# mkfs.xfs /dev/mapper/moo -f -d su=1g,sw=1
meta-data=/dev/mapper/moo        isize=512    agcount=34, agsize=8126464 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=268435456, imaxpct=5
         =                       sunit=262144 swidth=262144 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=131072, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
# mount /dev/mapper/moo /mnt
# xfs_io -f -c 'extsize 1g' -c 'falloc 0 200g' /mnt/urk
# filefrag -v /mnt/urk
Filesystem type is: 58465342
File size of /mnt/urk is 214748364800 (52428800 blocks of 4096 bytes)
 ext:     logical_offset:        physical_offset: length:   expected: flags:
   0:        0.. 7340031:     524288..   7864319: 7340032:             unwritten
   1:  7340032..14680063:    8388608..  15728639: 7340032:    7864320: unwritten
   2: 14680064..22020095:   16515072..  23855103: 7340032:   15728640: unwritten
   3: 22020096..29360127:   24641536..  31981567: 7340032:   23855104: unwritten
   4: 29360128..36700159:   32768000..  40108031: 7340032:   31981568: unwritten
   5: 36700160..40370175:   40894464..  44564479: 3670016:   40108032: unwritten
   6: 40370176..44040191:   44826624..  48496639: 3670016:   44564480: unwritten
   7: 44040192..51380223:   49020928..  56360959: 7340032:   48496640: unwritten
   8: 51380224..52428799:   57147392..  58195967: 1048576:   56360960: last,unwritten,eof
/mnt/urk: 9 extents found

AFAICT each extent's logical and physical offsets are aligned to a 1G boundary.

<shrug> Just a shot in the dark.

(This VM has 2G of memory and 1T of fake disk.)

--D

> 
> This patch set is against something approximately current -mm.  I'd like
> to thank Dave Chinner & Kirill Shutemov for their reviews of v1.
> The conversion of pmd_fault & pud_fault to huge_fault is thanks to
> Dave's poking, and Kirill spotted a couple of problems in the MM code.
> Version 2 of the patch set is about 200 lines smaller (1016 insertions,
> 23 deletions in v1).
> 
> I've done some light testing using a program to mmap a block device
> with DAX enabled, calling mincore() and examining /proc/smaps and
> /proc/pagemap.
> 
> Matthew Wilcox (8):
>   mm: Convert an open-coded VM_BUG_ON_VMA
>   mm,fs,dax: Change ->pmd_fault to ->huge_fault
>   mm: Add support for PUD-sized transparent hugepages
>   mincore: Add support for PUDs
>   procfs: Add support for PUDs to smaps, clear_refs and pagemap
>   x86: Add support for PUD-sized transparent hugepages
>   dax: Support for transparent PUD pages
>   ext4: Support for PUD-sized transparent huge pages
> 
>  Documentation/filesystems/dax.txt     |  12 +-
>  arch/Kconfig                          |   3 +
>  arch/x86/Kconfig                      |   1 +
>  arch/x86/include/asm/paravirt.h       |  11 ++
>  arch/x86/include/asm/paravirt_types.h |   2 +
>  arch/x86/include/asm/pgtable.h        |  94 ++++++++++++
>  arch/x86/include/asm/pgtable_64.h     |  13 ++
>  arch/x86/kernel/paravirt.c            |   1 +
>  arch/x86/mm/pgtable.c                 |  31 ++++
>  fs/block_dev.c                        |  10 +-
>  fs/dax.c                              | 272 +++++++++++++++++++++++++---------
>  fs/ext2/file.c                        |  27 +---
>  fs/ext4/file.c                        |  60 +++-----
>  fs/proc/task_mmu.c                    | 109 ++++++++++++++
>  fs/xfs/xfs_file.c                     |  25 ++--
>  fs/xfs/xfs_trace.h                    |   2 +-
>  include/asm-generic/pgtable.h         |  62 +++++++-
>  include/asm-generic/tlb.h             |  14 ++
>  include/linux/dax.h                   |  17 ---
>  include/linux/huge_mm.h               |  50 +++++++
>  include/linux/mm.h                    |  43 +++++-
>  include/linux/mmu_notifier.h          |  13 ++
>  include/linux/pfn_t.h                 |   8 +
>  mm/huge_memory.c                      | 151 +++++++++++++++++++
>  mm/memory.c                           | 101 +++++++++++--
>  mm/mincore.c                          |  13 ++
>  mm/pagewalk.c                         |  19 ++-
>  mm/pgtable-generic.c                  |  14 ++
>  28 files changed, 980 insertions(+), 198 deletions(-)
> 
> -- 
> 2.6.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

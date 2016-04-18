Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE5B6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 18:55:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so254306815pac.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 15:55:47 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id u128si775858pfb.89.2016.04.18.15.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 15:55:46 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id c20so85207323pfc.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 15:55:45 -0700 (PDT)
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <571565F0.9070203@linaro.org>
Date: Mon, 18 Apr 2016 15:55:44 -0700
MIME-Version: 1.0
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hi Kirill,

Finally, I got some time to look into and try yours and Hugh's patches, 
got two problems.

1. A quick boot up test on my ARM64 machine with your v7 tree shows some 
unexpected error:

systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:16863: No space left on device
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:16865: No space left on device
          Starting DNS forwarder and DHCP server.systemd-journald[285]: 
Failed to save stream data /run/systemd/journal/streams/8:16867: No 
space left on device
..
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:16869: No space left on device
          Starting Postfix Mail Transport Agent...
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:16871: No space left on device
          Starting Berkeley Internet Name Domain (DNS)...
          Starting Wait for Network to be Configured...
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:2422: No space left on device
[  OK  ] Started /etc/rc.local Compatibility.
[FAILED] Failed to start DNS forwarder and DHCP server.
See 'systemctl status dnsmasq.service' for details.
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:2425: No space left on device
[  OK  ] Started Serial Getty on ttyS1.
[  OK  ] Started Serial Getty on ttyS0.
[  OK  ] Started Getty on tty1.
systemd-journald[285]: Failed to save stream data 
/run/systemd/journal/streams/8:2433: No space left on device
[FAILED] Failed to start Berkeley Internet Name Domain (DNS).
See 'systemctl status named.service' for details.


The /run dir is mounted as tmpfs.

x86 boot doesn't get such error. And, Hugh's patches don't have such 
problem.

2. I ran my THP test (generated a program with 4MB text section) on both 
x86-64 and ARM64 with yours and Hugh's patches (linux-next tree), I got 
the program execution time reduced by ~12% on x86-64, it looks very 
impressive.

But, on ARM64, there is just ~3% change, and sometimes huge tmpfs may 
show even worse data than non-hugepage.

Both yours and Hugh's patches has the same behavior.

Any idea?

Thanks,
Yang


On 4/15/2016 5:23 PM, Kirill A. Shutemov wrote:
> This is probably the last update before the mm summit. Main forcus is on
> khugepaged stability.
>
> khugepaged is in more reasonable shape now. I missed quite a few corner
> cases on first try. I run this version via LTP, trinity and syzkaller
> without crashes so far.
>
> The patchset is on top of v4.6-rc3 plus Hugh's "easy preliminaries to
> THPagecache" and Ebru's khugepaged swapin patches form -mm tree.
>
> Git tree:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v7
>
> == Changelog ==
>
> v7:
>    - khugepaged updates:
>      + fix page leak/page cache corruption on collapse fail;
>      + filter out VMAs not suitable for huge pages due misaligned vm_pgoff;
>      + fix build without CONFIG_SHMEM;
>      + drop few over-protective checks;
>    - fix bogus VM_BUG_ON() in __delete_from_page_cache();
>
> v6:
>    - experimental collapse support;
>    - fix swapout mapped huge pages;
>    - fix page leak in faularound code;
>    - fix exessive huge page allocation with huge=within_size;
>    - rename VM_NO_THP to VM_NO_KHUGEPAGED;
>    - fix condition in hugepage_madvise();
>    - accounting reworked again;
>
> v5:
>    - add FileHugeMapped to /proc/PID/smaps;
>    - make FileHugeMapped in meminfo aligned with other fields;
>    - Documentation/vm/transhuge.txt updated;
>
> v4:
>    - first four patch were applied to -mm tree;
>    - drop pages beyond i_size on split_huge_pages;
>    - few small random bugfixes;
>
> v3:
>    - huge= mountoption now can have values always, within_size, advice and
>      never;
>    - sysctl handle is replaced with sysfs knob;
>    - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation via
>      page fault;
>    - mlock() handling had been fixed;
>    - bunch of smaller bugfixes and cleanups.
>
> == Design overview ==
>
> Huge pages are allocated by shmem when it's allowed (by mount option) and
> there's no entries for the range in radix-tree. Huge page is represented by
> HPAGE_PMD_NR entries in radix-tree.
>
> MM core maps a page with PMD if ->fault() returns huge page and the VMA is
> suitable for huge pages (size, alignment). There's no need into two
> requests to file system: filesystem returns huge page if it can,
> graceful fallback to small pages otherwise.
>
> As with DAX, split_huge_pmd() is implemented by unmapping the PMD: we can
> re-fault the page with PTEs later.
>
> Basic scheme for split_huge_page() is the same as for anon-THP.
> Few differences:
>
>    - File pages are on radix-tree, so we have head->_count offset by
>      HPAGE_PMD_NR. The count got distributed to small pages during split.
>
>    - mapping->tree_lock prevents non-lockless access to pages under split
>      over radix-tree;
>
>    - Lockless access is prevented by setting the head->_count to 0 during
>      split, so get_page_unless_zero() would fail;
>
>    - After split, some pages can be beyond i_size. We drop them from
>      radix-tree.
>
>    - We don't setup migration entries. Just unmap pages. It helps
>      handling cases when i_size is in the middle of the page: no need
>      handle unmap pages beyond i_size manually.
>
> COW mapping handled on PTE-level. It's not clear how beneficial would be
> allocation of huge pages on COW faults. And it would require some code to
> make them work.
>
> I think at some point we can consider teaching khugepaged to collapse
> pages in COW mappings, but allocating huge on fault is probably overkill.
>
> As with anon THP, we mlock file huge page only if it mapped with PMD.
> PTE-mapped THPs are never mlocked. This way we can avoid all sorts of
> scenarios when we can leak mlocked page.
>
> As with anon THP, we split huge page on swap out.
>
> Truncate and punch hole that only cover part of THP range is implemented
> by zero out this part of THP.
>
> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> inconsistent results depending what pages happened to be allocated.
> I don't think this will be a problem.
>
> == Patchset overview ==
>
> [01/29]
> 	Update documentation on THP vs. mlock. I've posted it separately
> 	before. It can go in.
>
> [02-04/29]
>          Rework fault path and rmap to handle file pmd. Unlike DAX with
>          vm_ops->pmd_fault, we don't need to ask filesystem twice -- first
>          for huge page and then for small. If ->fault happened to return
>          huge page and VMA is suitable for mapping it as huge, we would
> 	do so.
> [05/29]
> 	Add support for huge file pages in rmap;
>
> [06-15/29]
>          Various preparation of THP core for file pages.
>
> [16-20/29]
>          Various preparation of MM core for file pages.
>
> [21-24/29]
>          And finally, bring huge pages into tmpfs/shmem.
>
> [25/29]
> 	Wire up madvise() existing hints for file THP.
> 	We can implement fadvise() later.
>
> [26/29]
> 	Documentation update.
>
> [27-29/29]
> 	Extend khugepaged to support shmem/tmpfs.
> Hugh Dickins (1):
>    shmem: get_unmapped_area align huge page
>
> Kirill A. Shutemov (28):
>    thp, mlock: update unevictable-lru.txt
>    mm: do not pass mm_struct into handle_mm_fault
>    mm: introduce fault_env
>    mm: postpone page table allocation until we have page to map
>    rmap: support file thp
>    mm: introduce do_set_pmd()
>    thp, vmstats: add counters for huge file pages
>    thp: support file pages in zap_huge_pmd()
>    thp: handle file pages in split_huge_pmd()
>    thp: handle file COW faults
>    thp: skip file huge pmd on copy_huge_pmd()
>    thp: prepare change_huge_pmd() for file thp
>    thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
>    thp: file pages support for split_huge_page()
>    thp, mlock: do not mlock PTE-mapped file huge pages
>    vmscan: split file huge pages before paging them out
>    page-flags: relax policy for PG_mappedtodisk and PG_reclaim
>    radix-tree: implement radix_tree_maybe_preload_order()
>    filemap: prepare find and delete operations for huge pages
>    truncate: handle file thp
>    mm, rmap: account shmem thp pages
>    shmem: prepare huge= mount option and sysfs knob
>    shmem: add huge pages support
>    shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
>    thp: update Documentation/vm/transhuge.txt
>    thp: extract khugepaged from mm/huge_memory.c
>    khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
>    khugepaged: add support of collapse for tmpfs/shmem pages
>
>   Documentation/filesystems/Locking    |   10 +-
>   Documentation/vm/transhuge.txt       |  130 ++-
>   Documentation/vm/unevictable-lru.txt |   21 +
>   arch/alpha/mm/fault.c                |    2 +-
>   arch/arc/mm/fault.c                  |    2 +-
>   arch/arm/mm/fault.c                  |    2 +-
>   arch/arm64/mm/fault.c                |    2 +-
>   arch/avr32/mm/fault.c                |    2 +-
>   arch/cris/mm/fault.c                 |    2 +-
>   arch/frv/mm/fault.c                  |    2 +-
>   arch/hexagon/mm/vm_fault.c           |    2 +-
>   arch/ia64/mm/fault.c                 |    2 +-
>   arch/m32r/mm/fault.c                 |    2 +-
>   arch/m68k/mm/fault.c                 |    2 +-
>   arch/metag/mm/fault.c                |    2 +-
>   arch/microblaze/mm/fault.c           |    2 +-
>   arch/mips/mm/fault.c                 |    2 +-
>   arch/mn10300/mm/fault.c              |    2 +-
>   arch/nios2/mm/fault.c                |    2 +-
>   arch/openrisc/mm/fault.c             |    2 +-
>   arch/parisc/mm/fault.c               |    2 +-
>   arch/powerpc/mm/copro_fault.c        |    2 +-
>   arch/powerpc/mm/fault.c              |    2 +-
>   arch/s390/mm/fault.c                 |    2 +-
>   arch/score/mm/fault.c                |    2 +-
>   arch/sh/mm/fault.c                   |    2 +-
>   arch/sparc/mm/fault_32.c             |    4 +-
>   arch/sparc/mm/fault_64.c             |    2 +-
>   arch/tile/mm/fault.c                 |    2 +-
>   arch/um/kernel/trap.c                |    2 +-
>   arch/unicore32/mm/fault.c            |    2 +-
>   arch/x86/mm/fault.c                  |    2 +-
>   arch/xtensa/mm/fault.c               |    2 +-
>   drivers/base/node.c                  |   13 +-
>   drivers/char/mem.c                   |   24 +
>   drivers/iommu/amd_iommu_v2.c         |    3 +-
>   drivers/iommu/intel-svm.c            |    2 +-
>   fs/proc/meminfo.c                    |    7 +-
>   fs/proc/task_mmu.c                   |   10 +-
>   fs/userfaultfd.c                     |   22 +-
>   include/linux/huge_mm.h              |   36 +-
>   include/linux/khugepaged.h           |    6 +
>   include/linux/mm.h                   |   51 +-
>   include/linux/mmzone.h               |    4 +-
>   include/linux/page-flags.h           |   19 +-
>   include/linux/radix-tree.h           |    1 +
>   include/linux/rmap.h                 |    2 +-
>   include/linux/shmem_fs.h             |   29 +-
>   include/linux/userfaultfd_k.h        |    8 +-
>   include/linux/vm_event_item.h        |    7 +
>   include/trace/events/huge_memory.h   |    3 +-
>   ipc/shm.c                            |    6 +-
>   lib/radix-tree.c                     |   68 +-
>   mm/Makefile                          |    2 +-
>   mm/filemap.c                         |  226 ++--
>   mm/gup.c                             |    7 +-
>   mm/huge_memory.c                     | 2028 ++++++----------------------------
>   mm/internal.h                        |    4 +-
>   mm/khugepaged.c                      | 1772 +++++++++++++++++++++++++++++
>   mm/ksm.c                             |    5 +-
>   mm/memory.c                          |  859 +++++++-------
>   mm/mempolicy.c                       |    4 +-
>   mm/migrate.c                         |    5 +-
>   mm/mmap.c                            |   26 +-
>   mm/nommu.c                           |    3 +-
>   mm/page-writeback.c                  |    1 +
>   mm/page_alloc.c                      |   21 +
>   mm/rmap.c                            |   78 +-
>   mm/shmem.c                           |  689 ++++++++++--
>   mm/swap.c                            |    2 +
>   mm/truncate.c                        |   22 +-
>   mm/util.c                            |    6 +
>   mm/vmscan.c                          |    6 +
>   mm/vmstat.c                          |    4 +
>   74 files changed, 3919 insertions(+), 2395 deletions(-)
>   create mode 100644 mm/khugepaged.c
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

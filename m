Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33D526B0262
	for <linux-mm@kvack.org>; Wed, 25 May 2016 16:10:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g83so90016423oib.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:10:05 -0700 (PDT)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id e20si9108506iod.157.2016.05.25.13.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 13:10:03 -0700 (PDT)
Received: by mail-lb0-x244.google.com with SMTP id r5so3265212lbj.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:10:03 -0700 (PDT)
Date: Wed, 25 May 2016 23:03:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Message-ID: <20160525200356.GA15857@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: neha agarwal <neha.agbk@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> Hi All,
> 
> I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> Cassandra (NoSQL database). I am seeing significant performance gap between
> these two implementations (~30%). Hugh's implementation performs better
> than Kirill's implementation. I am surprised why I am seeing this
> performance gap. Following is my test setup.

Thanks for the report. I'll look into it.

> Patchsets
> ========
> - For Hugh's:
> I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied the
> THP patches posted on April 16 (01 to 29 patches).
> 
> - For Kirill's:
> I am using his branch  "git://
> git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8", which
> is based off of 4.6-rc3, posted on May 12.
> 
> 
> Khugepaged settings
> ================
> cd /sys/kernel/mm/transparent_hugepage
> echo 10 >khugepaged/alloc_sleep_millisecs
> echo 10 >khugepaged/scan_sleep_millisecs
> echo 511 >khugepaged/max_ptes_none

Do you make this for both setup?

It's not really nessesary for Hugh's, but it makes sense to have this
idenatical for testing.

Do you have swap in the system. Is it in use during testing?

> Mount options
> ===========
> - For Hugh's:
> sudo sysctl -w vm/shmem_huge=2
> sudo mount -o remount,huge=1 /hugetmpfs
> 
> - For Kirill's:
> sudo mount -o remount,huge=always /hugetmpfs
> echo force > /sys/kernel/mm/transparent_hugepage/shmem_enabled
> echo 511 >khugepaged/max_ptes_swap
> 
> 
> Workload Setting
> =============
> Please look at the attached setup document for Cassandra (NoSQL database):
> cassandra-setup.txt
> 
> 
> Machine setup
> ===========
> 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM running
> Ubuntu. I use control groups for resource isolation. Server and client
> threads run on different sockets. Frequency governor set to "performance"
> to remove any performance fluctuations due to frequency variation.
> 
> 
> Throughput numbers
> ================
> Hugh's implementation: 74522.08 ops/sec
> Kirill's implementation: 54919.10 ops/sec
> 
> 
> I am not sure if something is fishy with my test environment or if there is
> actually a performance gap between the two implementations. I have run this
> test 5-6 times so I am certain that this experiment is repeatable. I will
> appreciate if someone can help me understand the reason for this
> performance gap.
> 
> On Thu, May 12, 2016 at 11:40 AM, Kirill A. Shutemov <
> kirill.shutemov@linux.intel.com> wrote:
> 
> > This update aimed to address my todo list from lsf/mm summit:
> >
> >  - we now able to recovery memory by splitting huge pages partly beyond
> >    i_size. This should address concern about small files.
> >
> >  - bunch of bug fixes for khugepaged, including fix for data corruption
> >    reported by Hugh.
> >
> >  - Disabled for Power as it requires deposited page table to get THP
> >    mapped and we don't do deposit/withdraw for file THP.
> >
> > The main part of patchset (up to khugepaged stuff) is relatively stable --
> > I fixed few minor bugs there, but nothing major.
> >
> > I would appreciate rigorous review of khugepaged and code to split huge
> > pages under memory pressure.
> >
> > The patchset is on top of v4.6-rc3 plus Hugh's "easy preliminaries to
> > THPagecache" and Ebru's khugepaged swapin patches form -mm tree.
> >
> > Git tree:
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8
> >
> > == Changelog ==
> >
> > v8:
> >   - khugepaged updates:
> >     + mark collapsed page dirty, otherwise vmscan would discard it;
> >     + account pages to mapping->nrpages on shmem_charge;
> >     + fix a situation when not all tail pages put on radix tree on
> > collapse;
> >     + fix off-by-one in loop-exit condition in khugepaged_scan_shmem();
> >     + use radix_tree_iter_next/radix_tree_iter_retry instead of gotos;
> >     + fix build withount CONFIG_SHMEM (again);
> >   - split huge pages beyond i_size under memory pressure;
> >   - disable huge tmpfs on Power, as it makes use of deposited page tables,
> >     we don't have;
> >   - fix filesystem size limit accouting;
> >   - mark page referenced on split_huge_pmd() if the pmd is young;
> >   - uncharge pages from shmem, removed during split_huge_page();
> >   - make shmem_inode_info::lock irq-safe -- required by khugepaged;
> >
> > v7:
> >   - khugepaged updates:
> >     + fix page leak/page cache corruption on collapse fail;
> >     + filter out VMAs not suitable for huge pages due misaligned vm_pgoff;
> >     + fix build without CONFIG_SHMEM;
> >     + drop few over-protective checks;
> >   - fix bogus VM_BUG_ON() in __delete_from_page_cache();
> >
> > v6:
> >   - experimental collapse support;
> >   - fix swapout mapped huge pages;
> >   - fix page leak in faularound code;
> >   - fix exessive huge page allocation with huge=within_size;
> >   - rename VM_NO_THP to VM_NO_KHUGEPAGED;
> >   - fix condition in hugepage_madvise();
> >   - accounting reworked again;
> >
> > v5:
> >   - add FileHugeMapped to /proc/PID/smaps;
> >   - make FileHugeMapped in meminfo aligned with other fields;
> >   - Documentation/vm/transhuge.txt updated;
> >
> > v4:
> >   - first four patch were applied to -mm tree;
> >   - drop pages beyond i_size on split_huge_pages;
> >   - few small random bugfixes;
> >
> > v3:
> >   - huge= mountoption now can have values always, within_size, advice and
> >     never;
> >   - sysctl handle is replaced with sysfs knob;
> >   - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation via
> >     page fault;
> >   - mlock() handling had been fixed;
> >   - bunch of smaller bugfixes and cleanups.
> >
> > == Design overview ==
> >
> > Huge pages are allocated by shmem when it's allowed (by mount option) and
> > there's no entries for the range in radix-tree. Huge page is represented by
> > HPAGE_PMD_NR entries in radix-tree.
> >
> > MM core maps a page with PMD if ->fault() returns huge page and the VMA is
> > suitable for huge pages (size, alignment). There's no need into two
> > requests to file system: filesystem returns huge page if it can,
> > graceful fallback to small pages otherwise.
> >
> > As with DAX, split_huge_pmd() is implemented by unmapping the PMD: we can
> > re-fault the page with PTEs later.
> >
> > Basic scheme for split_huge_page() is the same as for anon-THP.
> > Few differences:
> >
> >   - File pages are on radix-tree, so we have head->_count offset by
> >     HPAGE_PMD_NR. The count got distributed to small pages during split.
> >
> >   - mapping->tree_lock prevents non-lockless access to pages under split
> >     over radix-tree;
> >
> >   - Lockless access is prevented by setting the head->_count to 0 during
> >     split, so get_page_unless_zero() would fail;
> >
> >   - After split, some pages can be beyond i_size. We drop them from
> >     radix-tree.
> >
> >   - We don't setup migration entries. Just unmap pages. It helps
> >     handling cases when i_size is in the middle of the page: no need
> >     handle unmap pages beyond i_size manually.
> >
> > COW mapping handled on PTE-level. It's not clear how beneficial would be
> > allocation of huge pages on COW faults. And it would require some code to
> > make them work.
> >
> > I think at some point we can consider teaching khugepaged to collapse
> > pages in COW mappings, but allocating huge on fault is probably overkill.
> >
> > As with anon THP, we mlock file huge page only if it mapped with PMD.
> > PTE-mapped THPs are never mlocked. This way we can avoid all sorts of
> > scenarios when we can leak mlocked page.
> >
> > As with anon THP, we split huge page on swap out.
> >
> > Truncate and punch hole that only cover part of THP range is implemented
> > by zero out this part of THP.
> >
> > This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> > As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> > inconsistent results depending what pages happened to be allocated.
> > I don't think this will be a problem.
> >
> > We track per-super_block list of inodes which potentially have huge page
> > partly beyond i_size. Under memory pressure or if we hit -ENOSPC, we split
> > such pages in order to recovery memory.
> >
> > The list is per-sb, as we need to split a page from our filesystem if hit
> > -ENOSPC (-o size= limit) during shmem_getpage_gfp() to free some space.
> >
> > Hugh Dickins (1):
> >   shmem: get_unmapped_area align huge page
> >
> > Kirill A. Shutemov (31):
> >   thp, mlock: update unevictable-lru.txt
> >   mm: do not pass mm_struct into handle_mm_fault
> >   mm: introduce fault_env
> >   mm: postpone page table allocation until we have page to map
> >   rmap: support file thp
> >   mm: introduce do_set_pmd()
> >   thp, vmstats: add counters for huge file pages
> >   thp: support file pages in zap_huge_pmd()
> >   thp: handle file pages in split_huge_pmd()
> >   thp: handle file COW faults
> >   thp: skip file huge pmd on copy_huge_pmd()
> >   thp: prepare change_huge_pmd() for file thp
> >   thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
> >   thp: file pages support for split_huge_page()
> >   thp, mlock: do not mlock PTE-mapped file huge pages
> >   vmscan: split file huge pages before paging them out
> >   page-flags: relax policy for PG_mappedtodisk and PG_reclaim
> >   radix-tree: implement radix_tree_maybe_preload_order()
> >   filemap: prepare find and delete operations for huge pages
> >   truncate: handle file thp
> >   mm, rmap: account shmem thp pages
> >   shmem: prepare huge= mount option and sysfs knob
> >   shmem: add huge pages support
> >   shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
> >   thp: update Documentation/vm/transhuge.txt
> >   thp: extract khugepaged from mm/huge_memory.c
> >   khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
> >   shmem: make shmem_inode_info::lock irq-safe
> >   khugepaged: add support of collapse for tmpfs/shmem pages
> >   thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
> >   shmem: split huge pages beyond i_size under memory pressure
> >
> >  Documentation/filesystems/Locking    |   10 +-
> >  Documentation/vm/transhuge.txt       |  130 ++-
> >  Documentation/vm/unevictable-lru.txt |   21 +
> >  arch/alpha/mm/fault.c                |    2 +-
> >  arch/arc/mm/fault.c                  |    2 +-
> >  arch/arm/mm/fault.c                  |    2 +-
> >  arch/arm64/mm/fault.c                |    2 +-
> >  arch/avr32/mm/fault.c                |    2 +-
> >  arch/cris/mm/fault.c                 |    2 +-
> >  arch/frv/mm/fault.c                  |    2 +-
> >  arch/hexagon/mm/vm_fault.c           |    2 +-
> >  arch/ia64/mm/fault.c                 |    2 +-
> >  arch/m32r/mm/fault.c                 |    2 +-
> >  arch/m68k/mm/fault.c                 |    2 +-
> >  arch/metag/mm/fault.c                |    2 +-
> >  arch/microblaze/mm/fault.c           |    2 +-
> >  arch/mips/mm/fault.c                 |    2 +-
> >  arch/mn10300/mm/fault.c              |    2 +-
> >  arch/nios2/mm/fault.c                |    2 +-
> >  arch/openrisc/mm/fault.c             |    2 +-
> >  arch/parisc/mm/fault.c               |    2 +-
> >  arch/powerpc/mm/copro_fault.c        |    2 +-
> >  arch/powerpc/mm/fault.c              |    2 +-
> >  arch/s390/mm/fault.c                 |    2 +-
> >  arch/score/mm/fault.c                |    2 +-
> >  arch/sh/mm/fault.c                   |    2 +-
> >  arch/sparc/mm/fault_32.c             |    4 +-
> >  arch/sparc/mm/fault_64.c             |    2 +-
> >  arch/tile/mm/fault.c                 |    2 +-
> >  arch/um/kernel/trap.c                |    2 +-
> >  arch/unicore32/mm/fault.c            |    2 +-
> >  arch/x86/mm/fault.c                  |    2 +-
> >  arch/xtensa/mm/fault.c               |    2 +-
> >  drivers/base/node.c                  |   13 +-
> >  drivers/char/mem.c                   |   24 +
> >  drivers/iommu/amd_iommu_v2.c         |    3 +-
> >  drivers/iommu/intel-svm.c            |    2 +-
> >  fs/proc/meminfo.c                    |    7 +-
> >  fs/proc/task_mmu.c                   |   10 +-
> >  fs/userfaultfd.c                     |   22 +-
> >  include/linux/huge_mm.h              |   36 +-
> >  include/linux/khugepaged.h           |    6 +
> >  include/linux/mm.h                   |   51 +-
> >  include/linux/mmzone.h               |    4 +-
> >  include/linux/page-flags.h           |   19 +-
> >  include/linux/radix-tree.h           |    1 +
> >  include/linux/rmap.h                 |    2 +-
> >  include/linux/shmem_fs.h             |   45 +-
> >  include/linux/userfaultfd_k.h        |    8 +-
> >  include/linux/vm_event_item.h        |    7 +
> >  include/trace/events/huge_memory.h   |    3 +-
> >  ipc/shm.c                            |   10 +-
> >  lib/radix-tree.c                     |   68 +-
> >  mm/Kconfig                           |    8 +
> >  mm/Makefile                          |    2 +-
> >  mm/filemap.c                         |  226 ++--
> >  mm/gup.c                             |    7 +-
> >  mm/huge_memory.c                     | 2032
> > ++++++----------------------------
> >  mm/internal.h                        |    4 +-
> >  mm/khugepaged.c                      | 1851
> > +++++++++++++++++++++++++++++++
> >  mm/ksm.c                             |    5 +-
> >  mm/memory.c                          |  860 +++++++-------
> >  mm/mempolicy.c                       |    4 +-
> >  mm/migrate.c                         |    5 +-
> >  mm/mmap.c                            |   26 +-
> >  mm/nommu.c                           |    3 +-
> >  mm/page-writeback.c                  |    1 +
> >  mm/page_alloc.c                      |   21 +
> >  mm/rmap.c                            |   78 +-
> >  mm/shmem.c                           |  918 +++++++++++++--
> >  mm/swap.c                            |    2 +
> >  mm/truncate.c                        |   22 +-
> >  mm/util.c                            |    6 +
> >  mm/vmscan.c                          |    6 +
> >  mm/vmstat.c                          |    4 +
> >  75 files changed, 4240 insertions(+), 2415 deletions(-)
> >  create mode 100644 mm/khugepaged.c
> >
> > --
> > 2.8.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> 
> 
> -- 
> Thanks and Regards,
> Neha Agarwal
> University of Michigan

> 1. Download and extract Cassandra
> http://archive.apache.org/dist/cassandra/2.0.16/apache-cassandra-2.0.16-bin.tar.gz
> 
> Note that my test version is Cassandra-2.0.16.
> We will denote the path to which the file is extracted as CASSANDRA_BIN
> 
> 2. Setup environment for cassandra
> mkdir -p run_cassandra/cassandra_conf/triggers
> 
> - Download cassandra-env.sh, cassandra.yaml, log4j-server.properties from my mail
> attachement and then copy those files in run_cassandra/cassandra_conf
> - Search for /home/nehaag/hugetmpfs in these files and change this to a local
> directory mounted as tmpfs. Leta??s say that is CASSANDRA_DATA.  A folder named
> "cassandra" will be automatically created (For example:
> CASSANDRA_DATA/cassandra) when running Cassandra.
> - Please note that these scripts will need modifications if you use Cassandra
> version other that 2.0.16
> 
> - Download create-ycsb-table.cql.j2 from my email attachment and copy it in
> run_cassandra/
> 
> 3. JAVA setup, get JRE: openjdk v1.7.0_101 (sudo apt-get install openjdk-7-jre
> for Ubuntu)
> 
> 4. Setup YCSB Load generator:
> - Clone ycsb from: https://github.com/brianfrankcooper/YCSB.git. Leta??s say this is
> downloaded to YCSB_ROOT
> - You need to have maven 3 installed (`sudo apt-get install mavena?? in ubuntu)
> - Create a script (say run-cassandra.sh) in run_cassandra as follows:
> 
> input_file=run_cassandra/create-ycsb-table.cql.j2
> cassandra_cli=${CASSANDRA_BIN}/bin/cassandra-cli
> host=a??127.0.0.1a?? #Ip address of the machine running cassasndra server
> $cassandra_cli -h $host --jmxport 7199 -f create-ycsb-table.cql
> cd ${YCSB_ROOT}
> 
> # Load dataset
> ${YCSB_ROOT}/bin/ycsb -cp ${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar:${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar load cassandra-10 -p hosts=$host -threads  20 -p fieldcount=20 -p recordcount=5000000 -P ${YCSB_ROOT}/workloads/workloadb -s
> 
> # Run benchmark
> ${YCSB_ROOT}/bin/ycsb -cp ${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar:${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar run cassandra-10 -p hosts=$host -threads  20 -p fieldcount=20 -p operationcount=50000000 -p recordcount=5000000 -p readproportion=0.05 -p updateproportion=0.95 -P ${YCSB_ROOT}/workloads/workloadb -s
> 
> 5. Run the cassandra server on host machine:
> rm -r ${CASSANDRA_DATA}/cassandra && CASSANDRA_CONF=run_cassandra/cassandra_conf JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre ${CASSANDRA_BIN}/bin/cassandra -f
> 
> 6. Run load generator on same/some other machine:
> ./run-cassandra.sh
> 
> YCSB periodcally spits out the throughput and latency number
> At the end overall throughput and latency will be printed out






-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

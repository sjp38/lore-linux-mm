Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44A726B0268
	for <linux-mm@kvack.org>; Wed, 25 May 2016 17:13:09 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id r185so139201170ywf.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:13:09 -0700 (PDT)
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com. [209.85.161.178])
        by mx.google.com with ESMTPS id z68si470584ywe.406.2016.05.25.14.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 14:13:08 -0700 (PDT)
Received: by mail-yw0-f178.google.com with SMTP id c127so59738665ywb.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:13:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160525200356.GA15857@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com> <20160525200356.GA15857@node.shutemov.name>
From: neha agarwal <neha.agbk@gmail.com>
Date: Wed, 25 May 2016 17:11:03 -0400
Message-ID: <CADf8yx+_EEwys7mip0HspKGMGpacws93afX1zKtHLOmF6-Lj1g@mail.gmail.com>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Content-Type: multipart/alternative; boundary=001a113e76b8d4a55c0533b11e1c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--001a113e76b8d4a55c0533b11e1c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 25, 2016 at 4:03 PM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> > Hi All,
> >
> > I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> > Cassandra (NoSQL database). I am seeing significant performance gap
> between
> > these two implementations (~30%). Hugh's implementation performs better
> > than Kirill's implementation. I am surprised why I am seeing this
> > performance gap. Following is my test setup.
>
> Thanks for the report. I'll look into it.
>

Thanks Kirill for looking into it.


> > Patchsets
> > =3D=3D=3D=3D=3D=3D=3D=3D
> > - For Hugh's:
> > I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> > patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied
> the
> > THP patches posted on April 16 (01 to 29 patches).
> >
> > - For Kirill's:
> > I am using his branch  "git://
> > git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8",
> which
> > is based off of 4.6-rc3, posted on May 12.
> >
> >
> > Khugepaged settings
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > cd /sys/kernel/mm/transparent_hugepage
> > echo 10 >khugepaged/alloc_sleep_millisecs
> > echo 10 >khugepaged/scan_sleep_millisecs
> > echo 511 >khugepaged/max_ptes_none
>
> Do you make this for both setup?
>
> It's not really nessesary for Hugh's, but it makes sense to have this
> idenatical for testing.
>

Yeah right, Hugh's will not be impacted by these settings but for identical
testing I did that.


> Do you have swap in the system. Is it in use during testing?
>

I do not have swap in the system.


> > Mount options
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > - For Hugh's:
> > sudo sysctl -w vm/shmem_huge=3D2
> > sudo mount -o remount,huge=3D1 /hugetmpfs
> >
> > - For Kirill's:
> > sudo mount -o remount,huge=3Dalways /hugetmpfs
> > echo force > /sys/kernel/mm/transparent_hugepage/shmem_enabled
> > echo 511 >khugepaged/max_ptes_swap
> >
> >
> > Workload Setting
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > Please look at the attached setup document for Cassandra (NoSQL
> database):
> > cassandra-setup.txt
> >
> >
> > Machine setup
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM
> running
> > Ubuntu. I use control groups for resource isolation. Server and client
> > threads run on different sockets. Frequency governor set to "performanc=
e"
> > to remove any performance fluctuations due to frequency variation.
> >
> >
> > Throughput numbers
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > Hugh's implementation: 74522.08 ops/sec
> > Kirill's implementation: 54919.10 ops/sec
> >
> >
> > I am not sure if something is fishy with my test environment or if ther=
e
> is
> > actually a performance gap between the two implementations. I have run
> this
> > test 5-6 times so I am certain that this experiment is repeatable. I wi=
ll
> > appreciate if someone can help me understand the reason for this
> > performance gap.
> >
> > On Thu, May 12, 2016 at 11:40 AM, Kirill A. Shutemov <
> > kirill.shutemov@linux.intel.com> wrote:
> >
> > > This update aimed to address my todo list from lsf/mm summit:
> > >
> > >  - we now able to recovery memory by splitting huge pages partly beyo=
nd
> > >    i_size. This should address concern about small files.
> > >
> > >  - bunch of bug fixes for khugepaged, including fix for data corrupti=
on
> > >    reported by Hugh.
> > >
> > >  - Disabled for Power as it requires deposited page table to get THP
> > >    mapped and we don't do deposit/withdraw for file THP.
> > >
> > > The main part of patchset (up to khugepaged stuff) is relatively
> stable --
> > > I fixed few minor bugs there, but nothing major.
> > >
> > > I would appreciate rigorous review of khugepaged and code to split hu=
ge
> > > pages under memory pressure.
> > >
> > > The patchset is on top of v4.6-rc3 plus Hugh's "easy preliminaries to
> > > THPagecache" and Ebru's khugepaged swapin patches form -mm tree.
> > >
> > > Git tree:
> > >
> > > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
> hugetmpfs/v8
> > >
> > > =3D=3D Changelog =3D=3D
> > >
> > > v8:
> > >   - khugepaged updates:
> > >     + mark collapsed page dirty, otherwise vmscan would discard it;
> > >     + account pages to mapping->nrpages on shmem_charge;
> > >     + fix a situation when not all tail pages put on radix tree on
> > > collapse;
> > >     + fix off-by-one in loop-exit condition in khugepaged_scan_shmem(=
);
> > >     + use radix_tree_iter_next/radix_tree_iter_retry instead of gotos=
;
> > >     + fix build withount CONFIG_SHMEM (again);
> > >   - split huge pages beyond i_size under memory pressure;
> > >   - disable huge tmpfs on Power, as it makes use of deposited page
> tables,
> > >     we don't have;
> > >   - fix filesystem size limit accouting;
> > >   - mark page referenced on split_huge_pmd() if the pmd is young;
> > >   - uncharge pages from shmem, removed during split_huge_page();
> > >   - make shmem_inode_info::lock irq-safe -- required by khugepaged;
> > >
> > > v7:
> > >   - khugepaged updates:
> > >     + fix page leak/page cache corruption on collapse fail;
> > >     + filter out VMAs not suitable for huge pages due misaligned
> vm_pgoff;
> > >     + fix build without CONFIG_SHMEM;
> > >     + drop few over-protective checks;
> > >   - fix bogus VM_BUG_ON() in __delete_from_page_cache();
> > >
> > > v6:
> > >   - experimental collapse support;
> > >   - fix swapout mapped huge pages;
> > >   - fix page leak in faularound code;
> > >   - fix exessive huge page allocation with huge=3Dwithin_size;
> > >   - rename VM_NO_THP to VM_NO_KHUGEPAGED;
> > >   - fix condition in hugepage_madvise();
> > >   - accounting reworked again;
> > >
> > > v5:
> > >   - add FileHugeMapped to /proc/PID/smaps;
> > >   - make FileHugeMapped in meminfo aligned with other fields;
> > >   - Documentation/vm/transhuge.txt updated;
> > >
> > > v4:
> > >   - first four patch were applied to -mm tree;
> > >   - drop pages beyond i_size on split_huge_pages;
> > >   - few small random bugfixes;
> > >
> > > v3:
> > >   - huge=3D mountoption now can have values always, within_size, advi=
ce
> and
> > >     never;
> > >   - sysctl handle is replaced with sysfs knob;
> > >   - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation
> via
> > >     page fault;
> > >   - mlock() handling had been fixed;
> > >   - bunch of smaller bugfixes and cleanups.
> > >
> > > =3D=3D Design overview =3D=3D
> > >
> > > Huge pages are allocated by shmem when it's allowed (by mount option)
> and
> > > there's no entries for the range in radix-tree. Huge page is
> represented by
> > > HPAGE_PMD_NR entries in radix-tree.
> > >
> > > MM core maps a page with PMD if ->fault() returns huge page and the
> VMA is
> > > suitable for huge pages (size, alignment). There's no need into two
> > > requests to file system: filesystem returns huge page if it can,
> > > graceful fallback to small pages otherwise.
> > >
> > > As with DAX, split_huge_pmd() is implemented by unmapping the PMD: we
> can
> > > re-fault the page with PTEs later.
> > >
> > > Basic scheme for split_huge_page() is the same as for anon-THP.
> > > Few differences:
> > >
> > >   - File pages are on radix-tree, so we have head->_count offset by
> > >     HPAGE_PMD_NR. The count got distributed to small pages during
> split.
> > >
> > >   - mapping->tree_lock prevents non-lockless access to pages under
> split
> > >     over radix-tree;
> > >
> > >   - Lockless access is prevented by setting the head->_count to 0
> during
> > >     split, so get_page_unless_zero() would fail;
> > >
> > >   - After split, some pages can be beyond i_size. We drop them from
> > >     radix-tree.
> > >
> > >   - We don't setup migration entries. Just unmap pages. It helps
> > >     handling cases when i_size is in the middle of the page: no need
> > >     handle unmap pages beyond i_size manually.
> > >
> > > COW mapping handled on PTE-level. It's not clear how beneficial would
> be
> > > allocation of huge pages on COW faults. And it would require some cod=
e
> to
> > > make them work.
> > >
> > > I think at some point we can consider teaching khugepaged to collapse
> > > pages in COW mappings, but allocating huge on fault is probably
> overkill.
> > >
> > > As with anon THP, we mlock file huge page only if it mapped with PMD.
> > > PTE-mapped THPs are never mlocked. This way we can avoid all sorts of
> > > scenarios when we can leak mlocked page.
> > >
> > > As with anon THP, we split huge page on swap out.
> > >
> > > Truncate and punch hole that only cover part of THP range is
> implemented
> > > by zero out this part of THP.
> > >
> > > This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour=
.
> > > As we don't really create hole in this case, lseek(SEEK_HOLE) may hav=
e
> > > inconsistent results depending what pages happened to be allocated.
> > > I don't think this will be a problem.
> > >
> > > We track per-super_block list of inodes which potentially have huge
> page
> > > partly beyond i_size. Under memory pressure or if we hit -ENOSPC, we
> split
> > > such pages in order to recovery memory.
> > >
> > > The list is per-sb, as we need to split a page from our filesystem if
> hit
> > > -ENOSPC (-o size=3D limit) during shmem_getpage_gfp() to free some sp=
ace.
> > >
> > > Hugh Dickins (1):
> > >   shmem: get_unmapped_area align huge page
> > >
> > > Kirill A. Shutemov (31):
> > >   thp, mlock: update unevictable-lru.txt
> > >   mm: do not pass mm_struct into handle_mm_fault
> > >   mm: introduce fault_env
> > >   mm: postpone page table allocation until we have page to map
> > >   rmap: support file thp
> > >   mm: introduce do_set_pmd()
> > >   thp, vmstats: add counters for huge file pages
> > >   thp: support file pages in zap_huge_pmd()
> > >   thp: handle file pages in split_huge_pmd()
> > >   thp: handle file COW faults
> > >   thp: skip file huge pmd on copy_huge_pmd()
> > >   thp: prepare change_huge_pmd() for file thp
> > >   thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
> > >   thp: file pages support for split_huge_page()
> > >   thp, mlock: do not mlock PTE-mapped file huge pages
> > >   vmscan: split file huge pages before paging them out
> > >   page-flags: relax policy for PG_mappedtodisk and PG_reclaim
> > >   radix-tree: implement radix_tree_maybe_preload_order()
> > >   filemap: prepare find and delete operations for huge pages
> > >   truncate: handle file thp
> > >   mm, rmap: account shmem thp pages
> > >   shmem: prepare huge=3D mount option and sysfs knob
> > >   shmem: add huge pages support
> > >   shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
> > >   thp: update Documentation/vm/transhuge.txt
> > >   thp: extract khugepaged from mm/huge_memory.c
> > >   khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
> > >   shmem: make shmem_inode_info::lock irq-safe
> > >   khugepaged: add support of collapse for tmpfs/shmem pages
> > >   thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
> > >   shmem: split huge pages beyond i_size under memory pressure
> > >
> > >  Documentation/filesystems/Locking    |   10 +-
> > >  Documentation/vm/transhuge.txt       |  130 ++-
> > >  Documentation/vm/unevictable-lru.txt |   21 +
> > >  arch/alpha/mm/fault.c                |    2 +-
> > >  arch/arc/mm/fault.c                  |    2 +-
> > >  arch/arm/mm/fault.c                  |    2 +-
> > >  arch/arm64/mm/fault.c                |    2 +-
> > >  arch/avr32/mm/fault.c                |    2 +-
> > >  arch/cris/mm/fault.c                 |    2 +-
> > >  arch/frv/mm/fault.c                  |    2 +-
> > >  arch/hexagon/mm/vm_fault.c           |    2 +-
> > >  arch/ia64/mm/fault.c                 |    2 +-
> > >  arch/m32r/mm/fault.c                 |    2 +-
> > >  arch/m68k/mm/fault.c                 |    2 +-
> > >  arch/metag/mm/fault.c                |    2 +-
> > >  arch/microblaze/mm/fault.c           |    2 +-
> > >  arch/mips/mm/fault.c                 |    2 +-
> > >  arch/mn10300/mm/fault.c              |    2 +-
> > >  arch/nios2/mm/fault.c                |    2 +-
> > >  arch/openrisc/mm/fault.c             |    2 +-
> > >  arch/parisc/mm/fault.c               |    2 +-
> > >  arch/powerpc/mm/copro_fault.c        |    2 +-
> > >  arch/powerpc/mm/fault.c              |    2 +-
> > >  arch/s390/mm/fault.c                 |    2 +-
> > >  arch/score/mm/fault.c                |    2 +-
> > >  arch/sh/mm/fault.c                   |    2 +-
> > >  arch/sparc/mm/fault_32.c             |    4 +-
> > >  arch/sparc/mm/fault_64.c             |    2 +-
> > >  arch/tile/mm/fault.c                 |    2 +-
> > >  arch/um/kernel/trap.c                |    2 +-
> > >  arch/unicore32/mm/fault.c            |    2 +-
> > >  arch/x86/mm/fault.c                  |    2 +-
> > >  arch/xtensa/mm/fault.c               |    2 +-
> > >  drivers/base/node.c                  |   13 +-
> > >  drivers/char/mem.c                   |   24 +
> > >  drivers/iommu/amd_iommu_v2.c         |    3 +-
> > >  drivers/iommu/intel-svm.c            |    2 +-
> > >  fs/proc/meminfo.c                    |    7 +-
> > >  fs/proc/task_mmu.c                   |   10 +-
> > >  fs/userfaultfd.c                     |   22 +-
> > >  include/linux/huge_mm.h              |   36 +-
> > >  include/linux/khugepaged.h           |    6 +
> > >  include/linux/mm.h                   |   51 +-
> > >  include/linux/mmzone.h               |    4 +-
> > >  include/linux/page-flags.h           |   19 +-
> > >  include/linux/radix-tree.h           |    1 +
> > >  include/linux/rmap.h                 |    2 +-
> > >  include/linux/shmem_fs.h             |   45 +-
> > >  include/linux/userfaultfd_k.h        |    8 +-
> > >  include/linux/vm_event_item.h        |    7 +
> > >  include/trace/events/huge_memory.h   |    3 +-
> > >  ipc/shm.c                            |   10 +-
> > >  lib/radix-tree.c                     |   68 +-
> > >  mm/Kconfig                           |    8 +
> > >  mm/Makefile                          |    2 +-
> > >  mm/filemap.c                         |  226 ++--
> > >  mm/gup.c                             |    7 +-
> > >  mm/huge_memory.c                     | 2032
> > > ++++++----------------------------
> > >  mm/internal.h                        |    4 +-
> > >  mm/khugepaged.c                      | 1851
> > > +++++++++++++++++++++++++++++++
> > >  mm/ksm.c                             |    5 +-
> > >  mm/memory.c                          |  860 +++++++-------
> > >  mm/mempolicy.c                       |    4 +-
> > >  mm/migrate.c                         |    5 +-
> > >  mm/mmap.c                            |   26 +-
> > >  mm/nommu.c                           |    3 +-
> > >  mm/page-writeback.c                  |    1 +
> > >  mm/page_alloc.c                      |   21 +
> > >  mm/rmap.c                            |   78 +-
> > >  mm/shmem.c                           |  918 +++++++++++++--
> > >  mm/swap.c                            |    2 +
> > >  mm/truncate.c                        |   22 +-
> > >  mm/util.c                            |    6 +
> > >  mm/vmscan.c                          |    6 +
> > >  mm/vmstat.c                          |    4 +
> > >  75 files changed, 4240 insertions(+), 2415 deletions(-)
> > >  create mode 100644 mm/khugepaged.c
> > >
> > > --
> > > 2.8.1
> > >
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
> > >
> >
> >
> >
> > --
> > Thanks and Regards,
> > Neha Agarwal
> > University of Michigan
>
> > 1. Download and extract Cassandra
> >
> http://archive.apache.org/dist/cassandra/2.0.16/apache-cassandra-2.0.16-b=
in.tar.gz
> >
> > Note that my test version is Cassandra-2.0.16.
> > We will denote the path to which the file is extracted as CASSANDRA_BIN
> >
> > 2. Setup environment for cassandra
> > mkdir -p run_cassandra/cassandra_conf/triggers
> >
> > - Download cassandra-env.sh, cassandra.yaml, log4j-server.properties
> from my mail
> > attachement and then copy those files in run_cassandra/cassandra_conf
> > - Search for /home/nehaag/hugetmpfs in these files and change this to a
> local
> > directory mounted as tmpfs. Let=E2=80=99s say that is CASSANDRA_DATA.  =
A folder
> named
> > "cassandra" will be automatically created (For example:
> > CASSANDRA_DATA/cassandra) when running Cassandra.
> > - Please note that these scripts will need modifications if you use
> Cassandra
> > version other that 2.0.16
> >
> > - Download create-ycsb-table.cql.j2 from my email attachment and copy i=
t
> in
> > run_cassandra/
> >
> > 3. JAVA setup, get JRE: openjdk v1.7.0_101 (sudo apt-get install
> openjdk-7-jre
> > for Ubuntu)
> >
> > 4. Setup YCSB Load generator:
> > - Clone ycsb from: https://github.com/brianfrankcooper/YCSB.git. Let=E2=
=80=99s
> say this is
> > downloaded to YCSB_ROOT
> > - You need to have maven 3 installed (`sudo apt-get install maven=E2=80=
=99 in
> ubuntu)
> > - Create a script (say run-cassandra.sh) in run_cassandra as follows:
> >
> > input_file=3Drun_cassandra/create-ycsb-table.cql.j2
> > cassandra_cli=3D${CASSANDRA_BIN}/bin/cassandra-cli
> > host=3D=E2=80=9D127.0.0.1=E2=80=9D #Ip address of the machine running c=
assasndra server
> > $cassandra_cli -h $host --jmxport 7199 -f create-ycsb-table.cql
> > cd ${YCSB_ROOT}
> >
> > # Load dataset
> > ${YCSB_ROOT}/bin/ycsb -cp
> ${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar:${YCSB_R=
OOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar
> load cassandra-10 -p hosts=3D$host -threads  20 -p fieldcount=3D20 -p
> recordcount=3D5000000 -P ${YCSB_ROOT}/workloads/workloadb -s
> >
> > # Run benchmark
> > ${YCSB_ROOT}/bin/ycsb -cp
> ${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar:${YCSB_R=
OOT}/cassandra/target/dependency/slf4j-simple-1.7.12.jar
> run cassandra-10 -p hosts=3D$host -threads  20 -p fieldcount=3D20 -p
> operationcount=3D50000000 -p recordcount=3D5000000 -p readproportion=3D0.=
05 -p
> updateproportion=3D0.95 -P ${YCSB_ROOT}/workloads/workloadb -s
> >
> > 5. Run the cassandra server on host machine:
> > rm -r ${CASSANDRA_DATA}/cassandra &&
> CASSANDRA_CONF=3Drun_cassandra/cassandra_conf
> JRE_HOME=3D/usr/lib/jvm/java-7-openjdk-amd64/jre
> ${CASSANDRA_BIN}/bin/cassandra -f
> >
> > 6. Run load generator on same/some other machine:
> > ./run-cassandra.sh
> >
> > YCSB periodcally spits out the throughput and latency number
> > At the end overall throughput and latency will be printed out
>
>
>
>
>
>
> --
>  Kirill A. Shutemov
>



--=20
Thanks and Regards,
Neha

--001a113e76b8d4a55c0533b11e1c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On W=
ed, May 25, 2016 at 4:03 PM, Kirill A. Shutemov <span dir=3D"ltr">&lt;<a hr=
ef=3D"mailto:kirill@shutemov.name" target=3D"_blank">kirill@shutemov.name</=
a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On =
Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:<br>
&gt; Hi All,<br>
&gt;<br>
&gt; I have been testing Hugh&#39;s and Kirill&#39;s huge tmpfs patch sets =
with<br>
&gt; Cassandra (NoSQL database). I am seeing significant performance gap be=
tween<br>
&gt; these two implementations (~30%). Hugh&#39;s implementation performs b=
etter<br>
&gt; than Kirill&#39;s implementation. I am surprised why I am seeing this<=
br>
&gt; performance gap. Following is my test setup.<br>
<br>
</span>Thanks for the report. I&#39;ll look into it.<br></blockquote><div>=
=C2=A0</div><div>Thanks Kirill for looking into it.=C2=A0</div><div><br></d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex">
<span class=3D""><br>
&gt; Patchsets<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; - For Hugh&#39;s:<br>
&gt; I checked out 4.6-rc3, applied Hugh&#39;s preliminary patches (01 to 1=
0<br>
&gt; patches) from here: <a href=3D"https://lkml.org/lkml/2016/4/5/792" rel=
=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2016/4/5/792</a> an=
d then applied the<br>
&gt; THP patches posted on April 16 (01 to 29 patches).<br>
&gt;<br>
&gt; - For Kirill&#39;s:<br>
&gt; I am using his branch=C2=A0 &quot;git://<br>
</span>&gt; <a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/kas/l=
inux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/linux=
/kernel/git/kas/linux.git</a> hugetmpfs/v8&quot;, which<br>
<span class=3D"">&gt; is based off of 4.6-rc3, posted on May 12.<br>
&gt;<br>
&gt;<br>
&gt; Khugepaged settings<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; cd /sys/kernel/mm/transparent_hugepage<br>
&gt; echo 10 &gt;khugepaged/alloc_sleep_millisecs<br>
&gt; echo 10 &gt;khugepaged/scan_sleep_millisecs<br>
&gt; echo 511 &gt;khugepaged/max_ptes_none<br>
<br>
</span>Do you make this for both setup?<br>
<br>
It&#39;s not really nessesary for Hugh&#39;s, but it makes sense to have th=
is<br>
idenatical for testing.<br></blockquote><div>=C2=A0</div><div>Yeah right, H=
ugh&#39;s will not be impacted by these settings but for identical testing =
I did that.=C2=A0</div><div><br></div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Do you have swap in the system. Is it in use during testing?<br></blockquot=
e><div>=C2=A0</div><div>I do not have swap in the system.</div><div><br></d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex">
<div><div class=3D"h5"><br>
&gt; Mount options<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; - For Hugh&#39;s:<br>
&gt; sudo sysctl -w vm/shmem_huge=3D2<br>
&gt; sudo mount -o remount,huge=3D1 /hugetmpfs<br>
&gt;<br>
&gt; - For Kirill&#39;s:<br>
&gt; sudo mount -o remount,huge=3Dalways /hugetmpfs<br>
&gt; echo force &gt; /sys/kernel/mm/transparent_hugepage/shmem_enabled<br>
&gt; echo 511 &gt;khugepaged/max_ptes_swap<br>
&gt;<br>
&gt;<br>
&gt; Workload Setting<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; Please look at the attached setup document for Cassandra (NoSQL databa=
se):<br>
&gt; cassandra-setup.txt<br>
&gt;<br>
&gt;<br>
&gt; Machine setup<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM ru=
nning<br>
&gt; Ubuntu. I use control groups for resource isolation. Server and client=
<br>
&gt; threads run on different sockets. Frequency governor set to &quot;perf=
ormance&quot;<br>
&gt; to remove any performance fluctuations due to frequency variation.<br>
&gt;<br>
&gt;<br>
&gt; Throughput numbers<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; Hugh&#39;s implementation: 74522.08 ops/sec<br>
&gt; Kirill&#39;s implementation: 54919.10 ops/sec<br>
&gt;<br>
&gt;<br>
&gt; I am not sure if something is fishy with my test environment or if the=
re is<br>
&gt; actually a performance gap between the two implementations. I have run=
 this<br>
&gt; test 5-6 times so I am certain that this experiment is repeatable. I w=
ill<br>
&gt; appreciate if someone can help me understand the reason for this<br>
&gt; performance gap.<br>
&gt;<br>
&gt; On Thu, May 12, 2016 at 11:40 AM, Kirill A. Shutemov &lt;<br>
&gt; <a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@lin=
ux.intel.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; This update aimed to address my todo list from lsf/mm summit:<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 - we now able to recovery memory by splitting huge pages pa=
rtly beyond<br>
&gt; &gt;=C2=A0 =C2=A0 i_size. This should address concern about small file=
s.<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 - bunch of bug fixes for khugepaged, including fix for data=
 corruption<br>
&gt; &gt;=C2=A0 =C2=A0 reported by Hugh.<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 - Disabled for Power as it requires deposited page table to=
 get THP<br>
&gt; &gt;=C2=A0 =C2=A0 mapped and we don&#39;t do deposit/withdraw for file=
 THP.<br>
&gt; &gt;<br>
&gt; &gt; The main part of patchset (up to khugepaged stuff) is relatively =
stable --<br>
&gt; &gt; I fixed few minor bugs there, but nothing major.<br>
&gt; &gt;<br>
&gt; &gt; I would appreciate rigorous review of khugepaged and code to spli=
t huge<br>
&gt; &gt; pages under memory pressure.<br>
&gt; &gt;<br>
&gt; &gt; The patchset is on top of v4.6-rc3 plus Hugh&#39;s &quot;easy pre=
liminaries to<br>
&gt; &gt; THPagecache&quot; and Ebru&#39;s khugepaged swapin patches form -=
mm tree.<br>
&gt; &gt;<br>
&gt; &gt; Git tree:<br>
&gt; &gt;<br>
&gt; &gt; git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/k=
as/linux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/l=
inux/kernel/git/kas/linux.git</a> hugetmpfs/v8<br>
&gt; &gt;<br>
&gt; &gt; =3D=3D Changelog =3D=3D<br>
&gt; &gt;<br>
&gt; &gt; v8:<br>
&gt; &gt;=C2=A0 =C2=A0- khugepaged updates:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ mark collapsed page dirty, otherwise vmscan =
would discard it;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ account pages to mapping-&gt;nrpages on shme=
m_charge;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ fix a situation when not all tail pages put =
on radix tree on<br>
&gt; &gt; collapse;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ fix off-by-one in loop-exit condition in khu=
gepaged_scan_shmem();<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ use radix_tree_iter_next/radix_tree_iter_ret=
ry instead of gotos;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ fix build withount CONFIG_SHMEM (again);<br>
&gt; &gt;=C2=A0 =C2=A0- split huge pages beyond i_size under memory pressur=
e;<br>
&gt; &gt;=C2=A0 =C2=A0- disable huge tmpfs on Power, as it makes use of dep=
osited page tables,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0we don&#39;t have;<br>
&gt; &gt;=C2=A0 =C2=A0- fix filesystem size limit accouting;<br>
&gt; &gt;=C2=A0 =C2=A0- mark page referenced on split_huge_pmd() if the pmd=
 is young;<br>
&gt; &gt;=C2=A0 =C2=A0- uncharge pages from shmem, removed during split_hug=
e_page();<br>
&gt; &gt;=C2=A0 =C2=A0- make shmem_inode_info::lock irq-safe -- required by=
 khugepaged;<br>
&gt; &gt;<br>
&gt; &gt; v7:<br>
&gt; &gt;=C2=A0 =C2=A0- khugepaged updates:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ fix page leak/page cache corruption on colla=
pse fail;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ filter out VMAs not suitable for huge pages =
due misaligned vm_pgoff;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ fix build without CONFIG_SHMEM;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0+ drop few over-protective checks;<br>
&gt; &gt;=C2=A0 =C2=A0- fix bogus VM_BUG_ON() in __delete_from_page_cache()=
;<br>
&gt; &gt;<br>
&gt; &gt; v6:<br>
&gt; &gt;=C2=A0 =C2=A0- experimental collapse support;<br>
&gt; &gt;=C2=A0 =C2=A0- fix swapout mapped huge pages;<br>
&gt; &gt;=C2=A0 =C2=A0- fix page leak in faularound code;<br>
&gt; &gt;=C2=A0 =C2=A0- fix exessive huge page allocation with huge=3Dwithi=
n_size;<br>
&gt; &gt;=C2=A0 =C2=A0- rename VM_NO_THP to VM_NO_KHUGEPAGED;<br>
&gt; &gt;=C2=A0 =C2=A0- fix condition in hugepage_madvise();<br>
&gt; &gt;=C2=A0 =C2=A0- accounting reworked again;<br>
&gt; &gt;<br>
&gt; &gt; v5:<br>
&gt; &gt;=C2=A0 =C2=A0- add FileHugeMapped to /proc/PID/smaps;<br>
&gt; &gt;=C2=A0 =C2=A0- make FileHugeMapped in meminfo aligned with other f=
ields;<br>
&gt; &gt;=C2=A0 =C2=A0- Documentation/vm/transhuge.txt updated;<br>
&gt; &gt;<br>
&gt; &gt; v4:<br>
&gt; &gt;=C2=A0 =C2=A0- first four patch were applied to -mm tree;<br>
&gt; &gt;=C2=A0 =C2=A0- drop pages beyond i_size on split_huge_pages;<br>
&gt; &gt;=C2=A0 =C2=A0- few small random bugfixes;<br>
&gt; &gt;<br>
&gt; &gt; v3:<br>
&gt; &gt;=C2=A0 =C2=A0- huge=3D mountoption now can have values always, wit=
hin_size, advice and<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0never;<br>
&gt; &gt;=C2=A0 =C2=A0- sysctl handle is replaced with sysfs knob;<br>
&gt; &gt;=C2=A0 =C2=A0- MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on p=
age allocation via<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0page fault;<br>
&gt; &gt;=C2=A0 =C2=A0- mlock() handling had been fixed;<br>
&gt; &gt;=C2=A0 =C2=A0- bunch of smaller bugfixes and cleanups.<br>
&gt; &gt;<br>
&gt; &gt; =3D=3D Design overview =3D=3D<br>
&gt; &gt;<br>
&gt; &gt; Huge pages are allocated by shmem when it&#39;s allowed (by mount=
 option) and<br>
&gt; &gt; there&#39;s no entries for the range in radix-tree. Huge page is =
represented by<br>
&gt; &gt; HPAGE_PMD_NR entries in radix-tree.<br>
&gt; &gt;<br>
&gt; &gt; MM core maps a page with PMD if -&gt;fault() returns huge page an=
d the VMA is<br>
&gt; &gt; suitable for huge pages (size, alignment). There&#39;s no need in=
to two<br>
&gt; &gt; requests to file system: filesystem returns huge page if it can,<=
br>
&gt; &gt; graceful fallback to small pages otherwise.<br>
&gt; &gt;<br>
&gt; &gt; As with DAX, split_huge_pmd() is implemented by unmapping the PMD=
: we can<br>
&gt; &gt; re-fault the page with PTEs later.<br>
&gt; &gt;<br>
&gt; &gt; Basic scheme for split_huge_page() is the same as for anon-THP.<b=
r>
&gt; &gt; Few differences:<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0- File pages are on radix-tree, so we have head-&gt;_=
count offset by<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0HPAGE_PMD_NR. The count got distributed to sma=
ll pages during split.<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0- mapping-&gt;tree_lock prevents non-lockless access =
to pages under split<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0over radix-tree;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0- Lockless access is prevented by setting the head-&g=
t;_count to 0 during<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0split, so get_page_unless_zero() would fail;<b=
r>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0- After split, some pages can be beyond i_size. We dr=
op them from<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0radix-tree.<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0- We don&#39;t setup migration entries. Just unmap pa=
ges. It helps<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0handling cases when i_size is in the middle of=
 the page: no need<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0handle unmap pages beyond i_size manually.<br>
&gt; &gt;<br>
&gt; &gt; COW mapping handled on PTE-level. It&#39;s not clear how benefici=
al would be<br>
&gt; &gt; allocation of huge pages on COW faults. And it would require some=
 code to<br>
&gt; &gt; make them work.<br>
&gt; &gt;<br>
&gt; &gt; I think at some point we can consider teaching khugepaged to coll=
apse<br>
&gt; &gt; pages in COW mappings, but allocating huge on fault is probably o=
verkill.<br>
&gt; &gt;<br>
&gt; &gt; As with anon THP, we mlock file huge page only if it mapped with =
PMD.<br>
&gt; &gt; PTE-mapped THPs are never mlocked. This way we can avoid all sort=
s of<br>
&gt; &gt; scenarios when we can leak mlocked page.<br>
&gt; &gt;<br>
&gt; &gt; As with anon THP, we split huge page on swap out.<br>
&gt; &gt;<br>
&gt; &gt; Truncate and punch hole that only cover part of THP range is impl=
emented<br>
&gt; &gt; by zero out this part of THP.<br>
&gt; &gt;<br>
&gt; &gt; This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behav=
iour.<br>
&gt; &gt; As we don&#39;t really create hole in this case, lseek(SEEK_HOLE)=
 may have<br>
&gt; &gt; inconsistent results depending what pages happened to be allocate=
d.<br>
&gt; &gt; I don&#39;t think this will be a problem.<br>
&gt; &gt;<br>
&gt; &gt; We track per-super_block list of inodes which potentially have hu=
ge page<br>
&gt; &gt; partly beyond i_size. Under memory pressure or if we hit -ENOSPC,=
 we split<br>
&gt; &gt; such pages in order to recovery memory.<br>
&gt; &gt;<br>
&gt; &gt; The list is per-sb, as we need to split a page from our filesyste=
m if hit<br>
&gt; &gt; -ENOSPC (-o size=3D limit) during shmem_getpage_gfp() to free som=
e space.<br>
&gt; &gt;<br>
&gt; &gt; Hugh Dickins (1):<br>
&gt; &gt;=C2=A0 =C2=A0shmem: get_unmapped_area align huge page<br>
&gt; &gt;<br>
&gt; &gt; Kirill A. Shutemov (31):<br>
&gt; &gt;=C2=A0 =C2=A0thp, mlock: update unevictable-lru.txt<br>
&gt; &gt;=C2=A0 =C2=A0mm: do not pass mm_struct into handle_mm_fault<br>
&gt; &gt;=C2=A0 =C2=A0mm: introduce fault_env<br>
&gt; &gt;=C2=A0 =C2=A0mm: postpone page table allocation until we have page=
 to map<br>
&gt; &gt;=C2=A0 =C2=A0rmap: support file thp<br>
&gt; &gt;=C2=A0 =C2=A0mm: introduce do_set_pmd()<br>
&gt; &gt;=C2=A0 =C2=A0thp, vmstats: add counters for huge file pages<br>
&gt; &gt;=C2=A0 =C2=A0thp: support file pages in zap_huge_pmd()<br>
&gt; &gt;=C2=A0 =C2=A0thp: handle file pages in split_huge_pmd()<br>
&gt; &gt;=C2=A0 =C2=A0thp: handle file COW faults<br>
&gt; &gt;=C2=A0 =C2=A0thp: skip file huge pmd on copy_huge_pmd()<br>
&gt; &gt;=C2=A0 =C2=A0thp: prepare change_huge_pmd() for file thp<br>
&gt; &gt;=C2=A0 =C2=A0thp: run vma_adjust_trans_huge() outside i_mmap_rwsem=
<br>
&gt; &gt;=C2=A0 =C2=A0thp: file pages support for split_huge_page()<br>
&gt; &gt;=C2=A0 =C2=A0thp, mlock: do not mlock PTE-mapped file huge pages<b=
r>
&gt; &gt;=C2=A0 =C2=A0vmscan: split file huge pages before paging them out<=
br>
&gt; &gt;=C2=A0 =C2=A0page-flags: relax policy for PG_mappedtodisk and PG_r=
eclaim<br>
&gt; &gt;=C2=A0 =C2=A0radix-tree: implement radix_tree_maybe_preload_order(=
)<br>
&gt; &gt;=C2=A0 =C2=A0filemap: prepare find and delete operations for huge =
pages<br>
&gt; &gt;=C2=A0 =C2=A0truncate: handle file thp<br>
&gt; &gt;=C2=A0 =C2=A0mm, rmap: account shmem thp pages<br>
&gt; &gt;=C2=A0 =C2=A0shmem: prepare huge=3D mount option and sysfs knob<br=
>
&gt; &gt;=C2=A0 =C2=A0shmem: add huge pages support<br>
&gt; &gt;=C2=A0 =C2=A0shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappi=
ngs<br>
&gt; &gt;=C2=A0 =C2=A0thp: update Documentation/vm/transhuge.txt<br>
&gt; &gt;=C2=A0 =C2=A0thp: extract khugepaged from mm/huge_memory.c<br>
&gt; &gt;=C2=A0 =C2=A0khugepaged: move up_read(mmap_sem) out of khugepaged_=
alloc_page()<br>
&gt; &gt;=C2=A0 =C2=A0shmem: make shmem_inode_info::lock irq-safe<br>
&gt; &gt;=C2=A0 =C2=A0khugepaged: add support of collapse for tmpfs/shmem p=
ages<br>
&gt; &gt;=C2=A0 =C2=A0thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE<br>
&gt; &gt;=C2=A0 =C2=A0shmem: split huge pages beyond i_size under memory pr=
essure<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 Documentation/filesystems/Locking=C2=A0 =C2=A0 |=C2=A0 =C2=
=A010 +-<br>
&gt; &gt;=C2=A0 Documentation/vm/transhuge.txt=C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 130 ++-<br>
&gt; &gt;=C2=A0 Documentation/vm/unevictable-lru.txt |=C2=A0 =C2=A021 +<br>
&gt; &gt;=C2=A0 arch/alpha/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/arc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/arm/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/arm64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/avr32/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/cris/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/frv/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/hexagon/mm/vm_fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/ia64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/m32r/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/m68k/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/metag/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/microblaze/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/mips/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/mn10300/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/nios2/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/openrisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/parisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/powerpc/mm/copro_fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/powerpc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/s390/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/score/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/sh/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/sparc/mm/fault_32.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 4 +-<br>
&gt; &gt;=C2=A0 arch/sparc/mm/fault_64.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/tile/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/um/kernel/trap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/unicore32/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/x86/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 arch/xtensa/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 drivers/base/node.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A013 +-<br>
&gt; &gt;=C2=A0 drivers/char/mem.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A024 +<br>
&gt; &gt;=C2=A0 drivers/iommu/amd_iommu_v2.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A0 3 +-<br>
&gt; &gt;=C2=A0 drivers/iommu/intel-svm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 fs/proc/meminfo.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 7 +-<br>
&gt; &gt;=C2=A0 fs/proc/task_mmu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A010 +-<br>
&gt; &gt;=C2=A0 fs/userfaultfd.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A022 +-<br>
&gt; &gt;=C2=A0 include/linux/huge_mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A036 +-<br>
&gt; &gt;=C2=A0 include/linux/khugepaged.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 6 +<br>
&gt; &gt;=C2=A0 include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A051 +-<br>
&gt; &gt;=C2=A0 include/linux/mmzone.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 4 +-<br>
&gt; &gt;=C2=A0 include/linux/page-flags.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A019 +-<br>
&gt; &gt;=C2=A0 include/linux/radix-tree.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 1 +<br>
&gt; &gt;=C2=A0 include/linux/rmap.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 include/linux/shmem_fs.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A045 +-<br>
&gt; &gt;=C2=A0 include/linux/userfaultfd_k.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A0 8 +-<br>
&gt; &gt;=C2=A0 include/linux/vm_event_item.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A0 7 +<br>
&gt; &gt;=C2=A0 include/trace/events/huge_memory.h=C2=A0 =C2=A0|=C2=A0 =C2=
=A0 3 +-<br>
&gt; &gt;=C2=A0 ipc/shm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A010 +-<br>
&gt; &gt;=C2=A0 lib/radix-tree.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A068 +-<br>
&gt; &gt;=C2=A0 mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 8 +<br>
&gt; &gt;=C2=A0 mm/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
&gt; &gt;=C2=A0 mm/filemap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 226 ++--<br>
&gt; &gt;=C2=A0 mm/gup.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 7 +-<=
br>
&gt; &gt;=C2=A0 mm/huge_memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 2032<br>
&gt; &gt; ++++++----------------------------<br>
&gt; &gt;=C2=A0 mm/internal.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 4 +-<br>
&gt; &gt;=C2=A0 mm/khugepaged.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1851<br>
&gt; &gt; +++++++++++++++++++++++++++++++<br>
&gt; &gt;=C2=A0 mm/ksm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 5 +-<=
br>
&gt; &gt;=C2=A0 mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 860 +++++++-------<br>
&gt; &gt;=C2=A0 mm/mempolicy.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 4 +-<br>
&gt; &gt;=C2=A0 mm/migrate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 5 +-<br>
&gt; &gt;=C2=A0 mm/mmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A026 +-<br>
&gt; &gt;=C2=A0 mm/nommu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 3 +-<br>
&gt; &gt;=C2=A0 mm/page-writeback.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 1 +<br>
&gt; &gt;=C2=A0 mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A021 +<br>
&gt; &gt;=C2=A0 mm/rmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A078 +-<br>
&gt; &gt;=C2=A0 mm/shmem.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 918 +++++++++++++--=
<br>
&gt; &gt;=C2=A0 mm/swap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +<br>
&gt; &gt;=C2=A0 mm/truncate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A022 +-<br>
&gt; &gt;=C2=A0 mm/util.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 6 +<br>
&gt; &gt;=C2=A0 mm/vmscan.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 6 +<br>
&gt; &gt;=C2=A0 mm/vmstat.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 4 +<br>
&gt; &gt;=C2=A0 75 files changed, 4240 insertions(+), 2415 deletions(-)<br>
&gt; &gt;=C2=A0 create mode 100644 mm/khugepaged.c<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; 2.8.1<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39=
; in<br>
&gt; &gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvac=
k.org</a>.=C2=A0 For more info on Linux MM,<br>
&gt; &gt; see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" targ=
et=3D"_blank">http://www.linux-mm.org/</a> .<br>
&gt; &gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont=
@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org"=
>email@kvack.org</a> &lt;/a&gt;<br>
&gt; &gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; --<br>
&gt; Thanks and Regards,<br>
&gt; Neha Agarwal<br>
&gt; University of Michigan<br>
<br>
</div></div>&gt; 1. Download and extract Cassandra<br>
&gt; <a href=3D"http://archive.apache.org/dist/cassandra/2.0.16/apache-cass=
andra-2.0.16-bin.tar.gz" rel=3D"noreferrer" target=3D"_blank">http://archiv=
e.apache.org/dist/cassandra/2.0.16/apache-cassandra-2.0.16-bin.tar.gz</a><b=
r>
&gt;<br>
&gt; Note that my test version is Cassandra-2.0.16.<br>
&gt; We will denote the path to which the file is extracted as CASSANDRA_BI=
N<br>
&gt;<br>
&gt; 2. Setup environment for cassandra<br>
&gt; mkdir -p run_cassandra/cassandra_conf/triggers<br>
&gt;<br>
&gt; - Download cassandra-env.sh, cassandra.yaml, log4j-server.properties f=
rom my mail<br>
&gt; attachement and then copy those files in run_cassandra/cassandra_conf<=
br>
&gt; - Search for /home/nehaag/hugetmpfs in these files and change this to =
a local<br>
&gt; directory mounted as tmpfs. Let=E2=80=99s say that is CASSANDRA_DATA.=
=C2=A0 A folder named<br>
&gt; &quot;cassandra&quot; will be automatically created (For example:<br>
&gt; CASSANDRA_DATA/cassandra) when running Cassandra.<br>
&gt; - Please note that these scripts will need modifications if you use Ca=
ssandra<br>
&gt; version other that 2.0.16<br>
&gt;<br>
&gt; - Download create-ycsb-table.cql.j2 from my email attachment and copy =
it in<br>
&gt; run_cassandra/<br>
&gt;<br>
&gt; 3. JAVA setup, get JRE: openjdk v1.7.0_101 (sudo apt-get install openj=
dk-7-jre<br>
&gt; for Ubuntu)<br>
&gt;<br>
&gt; 4. Setup YCSB Load generator:<br>
&gt; - Clone ycsb from: <a href=3D"https://github.com/brianfrankcooper/YCSB=
.git" rel=3D"noreferrer" target=3D"_blank">https://github.com/brianfrankcoo=
per/YCSB.git</a>. Let=E2=80=99s say this is<br>
&gt; downloaded to YCSB_ROOT<br>
&gt; - You need to have maven 3 installed (`sudo apt-get install maven=E2=
=80=99 in ubuntu)<br>
&gt; - Create a script (say run-cassandra.sh) in run_cassandra as follows:<=
br>
&gt;<br>
&gt; input_file=3Drun_cassandra/create-ycsb-table.cql.j2<br>
&gt; cassandra_cli=3D${CASSANDRA_BIN}/bin/cassandra-cli<br>
&gt; host=3D=E2=80=9D127.0.0.1=E2=80=9D #Ip address of the machine running =
cassasndra server<br>
&gt; $cassandra_cli -h $host --jmxport 7199 -f create-ycsb-table.cql<br>
&gt; cd ${YCSB_ROOT}<br>
&gt;<br>
&gt; # Load dataset<br>
&gt; ${YCSB_ROOT}/bin/ycsb -cp ${YCSB_ROOT}/cassandra/target/dependency/slf=
4j-simple-1.7.12.jar:${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-=
1.7.12.jar load cassandra-10 -p hosts=3D$host -threads=C2=A0 20 -p fieldcou=
nt=3D20 -p recordcount=3D5000000 -P ${YCSB_ROOT}/workloads/workloadb -s<br>
&gt;<br>
&gt; # Run benchmark<br>
&gt; ${YCSB_ROOT}/bin/ycsb -cp ${YCSB_ROOT}/cassandra/target/dependency/slf=
4j-simple-1.7.12.jar:${YCSB_ROOT}/cassandra/target/dependency/slf4j-simple-=
1.7.12.jar run cassandra-10 -p hosts=3D$host -threads=C2=A0 20 -p fieldcoun=
t=3D20 -p operationcount=3D50000000 -p recordcount=3D5000000 -p readproport=
ion=3D0.05 -p updateproportion=3D0.95 -P ${YCSB_ROOT}/workloads/workloadb -=
s<br>
&gt;<br>
&gt; 5. Run the cassandra server on host machine:<br>
&gt; rm -r ${CASSANDRA_DATA}/cassandra &amp;&amp; CASSANDRA_CONF=3Drun_cass=
andra/cassandra_conf JRE_HOME=3D/usr/lib/jvm/java-7-openjdk-amd64/jre ${CAS=
SANDRA_BIN}/bin/cassandra -f<br>
&gt;<br>
&gt; 6. Run load generator on same/some other machine:<br>
&gt; ./run-cassandra.sh<br>
&gt;<br>
&gt; YCSB periodcally spits out the throughput and latency number<br>
&gt; At the end overall throughput and latency will be printed out<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
<br>
<br>
<br>
<br>
<br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"gmail_signature"><div dir=3D"ltr">Thanks and Regards,<div>N=
eha</div></div></div>
</div></div>

--001a113e76b8d4a55c0533b11e1c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

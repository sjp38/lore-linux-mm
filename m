Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37CCB6B025E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 15:27:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d7so143179829qkf.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 12:27:16 -0700 (PDT)
Received: from mail-qg0-x243.google.com (mail-qg0-x243.google.com. [2607:f8b0:400d:c04::243])
        by mx.google.com with ESMTPS id y16si9498191qky.115.2016.05.25.12.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 12:27:14 -0700 (PDT)
Received: by mail-qg0-x243.google.com with SMTP id e35so4585687qge.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 12:27:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
From: neha agarwal <neha.agbk@gmail.com>
Date: Wed, 25 May 2016 15:11:55 -0400
Message-ID: <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Content-Type: multipart/mixed; boundary=001a1135dfa2ccf3060533af741b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--001a1135dfa2ccf3060533af741b
Content-Type: multipart/alternative; boundary=001a1135dfa2ccf3030533af7419

--001a1135dfa2ccf3030533af7419
Content-Type: text/plain; charset=UTF-8

Hi All,

I have been testing Hugh's and Kirill's huge tmpfs patch sets with
Cassandra (NoSQL database). I am seeing significant performance gap between
these two implementations (~30%). Hugh's implementation performs better
than Kirill's implementation. I am surprised why I am seeing this
performance gap. Following is my test setup.

Patchsets
========
- For Hugh's:
I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied the
THP patches posted on April 16 (01 to 29 patches).

- For Kirill's:
I am using his branch  "git://
git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8", which
is based off of 4.6-rc3, posted on May 12.


Khugepaged settings
================
cd /sys/kernel/mm/transparent_hugepage
echo 10 >khugepaged/alloc_sleep_millisecs
echo 10 >khugepaged/scan_sleep_millisecs
echo 511 >khugepaged/max_ptes_none


Mount options
===========
- For Hugh's:
sudo sysctl -w vm/shmem_huge=2
sudo mount -o remount,huge=1 /hugetmpfs

- For Kirill's:
sudo mount -o remount,huge=always /hugetmpfs
echo force > /sys/kernel/mm/transparent_hugepage/shmem_enabled
echo 511 >khugepaged/max_ptes_swap


Workload Setting
=============
Please look at the attached setup document for Cassandra (NoSQL database):
cassandra-setup.txt


Machine setup
===========
36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM running
Ubuntu. I use control groups for resource isolation. Server and client
threads run on different sockets. Frequency governor set to "performance"
to remove any performance fluctuations due to frequency variation.


Throughput numbers
================
Hugh's implementation: 74522.08 ops/sec
Kirill's implementation: 54919.10 ops/sec


I am not sure if something is fishy with my test environment or if there is
actually a performance gap between the two implementations. I have run this
test 5-6 times so I am certain that this experiment is repeatable. I will
appreciate if someone can help me understand the reason for this
performance gap.

On Thu, May 12, 2016 at 11:40 AM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> This update aimed to address my todo list from lsf/mm summit:
>
>  - we now able to recovery memory by splitting huge pages partly beyond
>    i_size. This should address concern about small files.
>
>  - bunch of bug fixes for khugepaged, including fix for data corruption
>    reported by Hugh.
>
>  - Disabled for Power as it requires deposited page table to get THP
>    mapped and we don't do deposit/withdraw for file THP.
>
> The main part of patchset (up to khugepaged stuff) is relatively stable --
> I fixed few minor bugs there, but nothing major.
>
> I would appreciate rigorous review of khugepaged and code to split huge
> pages under memory pressure.
>
> The patchset is on top of v4.6-rc3 plus Hugh's "easy preliminaries to
> THPagecache" and Ebru's khugepaged swapin patches form -mm tree.
>
> Git tree:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8
>
> == Changelog ==
>
> v8:
>   - khugepaged updates:
>     + mark collapsed page dirty, otherwise vmscan would discard it;
>     + account pages to mapping->nrpages on shmem_charge;
>     + fix a situation when not all tail pages put on radix tree on
> collapse;
>     + fix off-by-one in loop-exit condition in khugepaged_scan_shmem();
>     + use radix_tree_iter_next/radix_tree_iter_retry instead of gotos;
>     + fix build withount CONFIG_SHMEM (again);
>   - split huge pages beyond i_size under memory pressure;
>   - disable huge tmpfs on Power, as it makes use of deposited page tables,
>     we don't have;
>   - fix filesystem size limit accouting;
>   - mark page referenced on split_huge_pmd() if the pmd is young;
>   - uncharge pages from shmem, removed during split_huge_page();
>   - make shmem_inode_info::lock irq-safe -- required by khugepaged;
>
> v7:
>   - khugepaged updates:
>     + fix page leak/page cache corruption on collapse fail;
>     + filter out VMAs not suitable for huge pages due misaligned vm_pgoff;
>     + fix build without CONFIG_SHMEM;
>     + drop few over-protective checks;
>   - fix bogus VM_BUG_ON() in __delete_from_page_cache();
>
> v6:
>   - experimental collapse support;
>   - fix swapout mapped huge pages;
>   - fix page leak in faularound code;
>   - fix exessive huge page allocation with huge=within_size;
>   - rename VM_NO_THP to VM_NO_KHUGEPAGED;
>   - fix condition in hugepage_madvise();
>   - accounting reworked again;
>
> v5:
>   - add FileHugeMapped to /proc/PID/smaps;
>   - make FileHugeMapped in meminfo aligned with other fields;
>   - Documentation/vm/transhuge.txt updated;
>
> v4:
>   - first four patch were applied to -mm tree;
>   - drop pages beyond i_size on split_huge_pages;
>   - few small random bugfixes;
>
> v3:
>   - huge= mountoption now can have values always, within_size, advice and
>     never;
>   - sysctl handle is replaced with sysfs knob;
>   - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation via
>     page fault;
>   - mlock() handling had been fixed;
>   - bunch of smaller bugfixes and cleanups.
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
>   - File pages are on radix-tree, so we have head->_count offset by
>     HPAGE_PMD_NR. The count got distributed to small pages during split.
>
>   - mapping->tree_lock prevents non-lockless access to pages under split
>     over radix-tree;
>
>   - Lockless access is prevented by setting the head->_count to 0 during
>     split, so get_page_unless_zero() would fail;
>
>   - After split, some pages can be beyond i_size. We drop them from
>     radix-tree.
>
>   - We don't setup migration entries. Just unmap pages. It helps
>     handling cases when i_size is in the middle of the page: no need
>     handle unmap pages beyond i_size manually.
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
> We track per-super_block list of inodes which potentially have huge page
> partly beyond i_size. Under memory pressure or if we hit -ENOSPC, we split
> such pages in order to recovery memory.
>
> The list is per-sb, as we need to split a page from our filesystem if hit
> -ENOSPC (-o size= limit) during shmem_getpage_gfp() to free some space.
>
> Hugh Dickins (1):
>   shmem: get_unmapped_area align huge page
>
> Kirill A. Shutemov (31):
>   thp, mlock: update unevictable-lru.txt
>   mm: do not pass mm_struct into handle_mm_fault
>   mm: introduce fault_env
>   mm: postpone page table allocation until we have page to map
>   rmap: support file thp
>   mm: introduce do_set_pmd()
>   thp, vmstats: add counters for huge file pages
>   thp: support file pages in zap_huge_pmd()
>   thp: handle file pages in split_huge_pmd()
>   thp: handle file COW faults
>   thp: skip file huge pmd on copy_huge_pmd()
>   thp: prepare change_huge_pmd() for file thp
>   thp: run vma_adjust_trans_huge() outside i_mmap_rwsem
>   thp: file pages support for split_huge_page()
>   thp, mlock: do not mlock PTE-mapped file huge pages
>   vmscan: split file huge pages before paging them out
>   page-flags: relax policy for PG_mappedtodisk and PG_reclaim
>   radix-tree: implement radix_tree_maybe_preload_order()
>   filemap: prepare find and delete operations for huge pages
>   truncate: handle file thp
>   mm, rmap: account shmem thp pages
>   shmem: prepare huge= mount option and sysfs knob
>   shmem: add huge pages support
>   shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
>   thp: update Documentation/vm/transhuge.txt
>   thp: extract khugepaged from mm/huge_memory.c
>   khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
>   shmem: make shmem_inode_info::lock irq-safe
>   khugepaged: add support of collapse for tmpfs/shmem pages
>   thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
>   shmem: split huge pages beyond i_size under memory pressure
>
>  Documentation/filesystems/Locking    |   10 +-
>  Documentation/vm/transhuge.txt       |  130 ++-
>  Documentation/vm/unevictable-lru.txt |   21 +
>  arch/alpha/mm/fault.c                |    2 +-
>  arch/arc/mm/fault.c                  |    2 +-
>  arch/arm/mm/fault.c                  |    2 +-
>  arch/arm64/mm/fault.c                |    2 +-
>  arch/avr32/mm/fault.c                |    2 +-
>  arch/cris/mm/fault.c                 |    2 +-
>  arch/frv/mm/fault.c                  |    2 +-
>  arch/hexagon/mm/vm_fault.c           |    2 +-
>  arch/ia64/mm/fault.c                 |    2 +-
>  arch/m32r/mm/fault.c                 |    2 +-
>  arch/m68k/mm/fault.c                 |    2 +-
>  arch/metag/mm/fault.c                |    2 +-
>  arch/microblaze/mm/fault.c           |    2 +-
>  arch/mips/mm/fault.c                 |    2 +-
>  arch/mn10300/mm/fault.c              |    2 +-
>  arch/nios2/mm/fault.c                |    2 +-
>  arch/openrisc/mm/fault.c             |    2 +-
>  arch/parisc/mm/fault.c               |    2 +-
>  arch/powerpc/mm/copro_fault.c        |    2 +-
>  arch/powerpc/mm/fault.c              |    2 +-
>  arch/s390/mm/fault.c                 |    2 +-
>  arch/score/mm/fault.c                |    2 +-
>  arch/sh/mm/fault.c                   |    2 +-
>  arch/sparc/mm/fault_32.c             |    4 +-
>  arch/sparc/mm/fault_64.c             |    2 +-
>  arch/tile/mm/fault.c                 |    2 +-
>  arch/um/kernel/trap.c                |    2 +-
>  arch/unicore32/mm/fault.c            |    2 +-
>  arch/x86/mm/fault.c                  |    2 +-
>  arch/xtensa/mm/fault.c               |    2 +-
>  drivers/base/node.c                  |   13 +-
>  drivers/char/mem.c                   |   24 +
>  drivers/iommu/amd_iommu_v2.c         |    3 +-
>  drivers/iommu/intel-svm.c            |    2 +-
>  fs/proc/meminfo.c                    |    7 +-
>  fs/proc/task_mmu.c                   |   10 +-
>  fs/userfaultfd.c                     |   22 +-
>  include/linux/huge_mm.h              |   36 +-
>  include/linux/khugepaged.h           |    6 +
>  include/linux/mm.h                   |   51 +-
>  include/linux/mmzone.h               |    4 +-
>  include/linux/page-flags.h           |   19 +-
>  include/linux/radix-tree.h           |    1 +
>  include/linux/rmap.h                 |    2 +-
>  include/linux/shmem_fs.h             |   45 +-
>  include/linux/userfaultfd_k.h        |    8 +-
>  include/linux/vm_event_item.h        |    7 +
>  include/trace/events/huge_memory.h   |    3 +-
>  ipc/shm.c                            |   10 +-
>  lib/radix-tree.c                     |   68 +-
>  mm/Kconfig                           |    8 +
>  mm/Makefile                          |    2 +-
>  mm/filemap.c                         |  226 ++--
>  mm/gup.c                             |    7 +-
>  mm/huge_memory.c                     | 2032
> ++++++----------------------------
>  mm/internal.h                        |    4 +-
>  mm/khugepaged.c                      | 1851
> +++++++++++++++++++++++++++++++
>  mm/ksm.c                             |    5 +-
>  mm/memory.c                          |  860 +++++++-------
>  mm/mempolicy.c                       |    4 +-
>  mm/migrate.c                         |    5 +-
>  mm/mmap.c                            |   26 +-
>  mm/nommu.c                           |    3 +-
>  mm/page-writeback.c                  |    1 +
>  mm/page_alloc.c                      |   21 +
>  mm/rmap.c                            |   78 +-
>  mm/shmem.c                           |  918 +++++++++++++--
>  mm/swap.c                            |    2 +
>  mm/truncate.c                        |   22 +-
>  mm/util.c                            |    6 +
>  mm/vmscan.c                          |    6 +
>  mm/vmstat.c                          |    4 +
>  75 files changed, 4240 insertions(+), 2415 deletions(-)
>  create mode 100644 mm/khugepaged.c
>
> --
> 2.8.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Thanks and Regards,
Neha Agarwal
University of Michigan

--001a1135dfa2ccf3030533af7419
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"font-size:12.8px">Hi All,</span><br style=
=3D"font-size:12.8px"><br style=3D"font-size:12.8px"><span style=3D"font-si=
ze:12.8px">I have been testing Hugh&#39;s and Kirill&#39;s huge tmpfs patch=
 sets with Cassandra (NoSQL database). I am seeing significant performance =
gap between these two implementations (~30%). Hugh&#39;s implementation per=
forms better than Kirill&#39;s implementation. I am surprised why I am seei=
ng this performance gap. Following is my test setup.</span><br style=3D"fon=
t-size:12.8px"><br style=3D"font-size:12.8px"><span style=3D"font-size:12.8=
px">Patchsets</span><div style=3D"font-size:12.8px">=3D=3D=3D=3D=3D=3D=3D=
=3D<br>- For Hugh&#39;s:=C2=A0<br>I checked out 4.6-rc3, applied Hugh&#39;s=
 preliminary patches (01 to 10 patches) from here:=C2=A0<a href=3D"https://=
lkml.org/lkml/2016/4/5/792" target=3D"_blank">https://lkml.org/lkml/2016/4/=
5/792</a>=C2=A0and then applied the THP patches posted on=C2=A0<span class=
=3D"" tabindex=3D"0"><span class=3D"">April 16</span></span>=C2=A0(01 to 29=
 patches).<br><br>- For Kirill&#39;s:=C2=A0<br>I am using his branch =C2=A0=
&quot;git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/kas/l=
inux.git" target=3D"_blank">git.kernel.org/pub/scm/linux/kernel/git/kas/lin=
ux.git</a>=C2=A0hugetmpfs/v8&quot;, which is based off of 4.6-rc3, posted o=
n May 12.<br><br><br><div>Khugepaged settings</div><div>=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>cd /sys/kernel/mm/transparent_hugepage<br=
>echo 10 &gt;khugepaged/alloc_sleep_millisecs<br>echo 10 &gt;khugepaged/sca=
n_sleep_millisecs<br>echo 511 &gt;khugepaged/max_ptes_none<br><br><br>Mount=
 options</div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>- For Hugh&#39;s:<b=
r>sudo sysctl -w vm/shmem_huge=3D2<br>sudo mount -o remount,huge=3D1 /huget=
mpfs<br><br>- For Kirill&#39;s:<br>sudo mount -o remount,huge=3Dalways /hug=
etmpfs<br>echo force &gt; /sys/kernel/mm/transparent_hugepage/shmem_enabled=
<br>echo 511 &gt;khugepaged/max_ptes_swap<br><br><br>Workload Setting</div>=
<div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>Please look at the attached=
 setup document for Cassandra (NoSQL database): cassandra-setup.txt<br><br>=
<br>Machine setup</div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>36-core (7=
2 hardware thread) dual-socket x86 server with 512 GB RAM running Ubuntu. I=
 use control groups for resource isolation. Server and client threads run o=
n different sockets. Frequency governor set to &quot;performance&quot; to r=
emove any performance fluctuations due to frequency variation.<br><br><br>T=
hroughput numbers</div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D<br>Hugh&#39;s implementation: 74522.08 ops/sec<br>Kirill&#39;s implemen=
tation: 54919.10 ops/sec<br><br><br>I am not sure if something is fishy wit=
h my test environment or if there is actually a performance gap between the=
 two implementations. I have run this test 5-6 times so I am certain that t=
his experiment is repeatable. I will appreciate if someone can help me unde=
rstand the reason for this performance gap.</div><div><br></div></div><div =
class=3D"gmail_extra"><div class=3D"gmail_quote">On Thu, May 12, 2016 at 11=
:40 AM, Kirill A. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.s=
hutemov@linux.intel.com" target=3D"_blank">kirill.shutemov@linux.intel.com<=
/a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">This update aimed t=
o address my todo list from lsf/mm summit:<br>
<br>
=C2=A0- we now able to recovery memory by splitting huge pages partly beyon=
d<br>
=C2=A0 =C2=A0i_size. This should address concern about small files.<br>
<br>
=C2=A0- bunch of bug fixes for khugepaged, including fix for data corruptio=
n<br>
=C2=A0 =C2=A0reported by Hugh.<br>
<br>
=C2=A0- Disabled for Power as it requires deposited page table to get THP<b=
r>
=C2=A0 =C2=A0mapped and we don&#39;t do deposit/withdraw for file THP.<br>
<br>
The main part of patchset (up to khugepaged stuff) is relatively stable --<=
br>
I fixed few minor bugs there, but nothing major.<br>
<br>
I would appreciate rigorous review of khugepaged and code to split huge<br>
pages under memory pressure.<br>
<br>
The patchset is on top of v4.6-rc3 plus Hugh&#39;s &quot;easy preliminaries=
 to<br>
THPagecache&quot; and Ebru&#39;s khugepaged swapin patches form -mm tree.<b=
r>
<br>
Git tree:<br>
<br>
git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.g=
it" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/linux/kerne=
l/git/kas/linux.git</a> hugetmpfs/v8<br>
<br>
=3D=3D Changelog =3D=3D<br>
<br>
v8:<br>
=C2=A0 - khugepaged updates:<br>
=C2=A0 =C2=A0 + mark collapsed page dirty, otherwise vmscan would discard i=
t;<br>
=C2=A0 =C2=A0 + account pages to mapping-&gt;nrpages on shmem_charge;<br>
=C2=A0 =C2=A0 + fix a situation when not all tail pages put on radix tree o=
n collapse;<br>
=C2=A0 =C2=A0 + fix off-by-one in loop-exit condition in khugepaged_scan_sh=
mem();<br>
=C2=A0 =C2=A0 + use radix_tree_iter_next/radix_tree_iter_retry instead of g=
otos;<br>
=C2=A0 =C2=A0 + fix build withount CONFIG_SHMEM (again);<br>
=C2=A0 - split huge pages beyond i_size under memory pressure;<br>
=C2=A0 - disable huge tmpfs on Power, as it makes use of deposited page tab=
les,<br>
=C2=A0 =C2=A0 we don&#39;t have;<br>
=C2=A0 - fix filesystem size limit accouting;<br>
=C2=A0 - mark page referenced on split_huge_pmd() if the pmd is young;<br>
=C2=A0 - uncharge pages from shmem, removed during split_huge_page();<br>
=C2=A0 - make shmem_inode_info::lock irq-safe -- required by khugepaged;<br=
>
<br>
v7:<br>
=C2=A0 - khugepaged updates:<br>
=C2=A0 =C2=A0 + fix page leak/page cache corruption on collapse fail;<br>
=C2=A0 =C2=A0 + filter out VMAs not suitable for huge pages due misaligned =
vm_pgoff;<br>
=C2=A0 =C2=A0 + fix build without CONFIG_SHMEM;<br>
=C2=A0 =C2=A0 + drop few over-protective checks;<br>
=C2=A0 - fix bogus VM_BUG_ON() in __delete_from_page_cache();<br>
<br>
v6:<br>
=C2=A0 - experimental collapse support;<br>
=C2=A0 - fix swapout mapped huge pages;<br>
=C2=A0 - fix page leak in faularound code;<br>
=C2=A0 - fix exessive huge page allocation with huge=3Dwithin_size;<br>
=C2=A0 - rename VM_NO_THP to VM_NO_KHUGEPAGED;<br>
=C2=A0 - fix condition in hugepage_madvise();<br>
=C2=A0 - accounting reworked again;<br>
<br>
v5:<br>
=C2=A0 - add FileHugeMapped to /proc/PID/smaps;<br>
=C2=A0 - make FileHugeMapped in meminfo aligned with other fields;<br>
=C2=A0 - Documentation/vm/transhuge.txt updated;<br>
<br>
v4:<br>
=C2=A0 - first four patch were applied to -mm tree;<br>
=C2=A0 - drop pages beyond i_size on split_huge_pages;<br>
=C2=A0 - few small random bugfixes;<br>
<br>
v3:<br>
=C2=A0 - huge=3D mountoption now can have values always, within_size, advic=
e and<br>
=C2=A0 =C2=A0 never;<br>
=C2=A0 - sysctl handle is replaced with sysfs knob;<br>
=C2=A0 - MADV_HUGEPAGE/MADV_NOHUGEPAGE is now respected on page allocation =
via<br>
=C2=A0 =C2=A0 page fault;<br>
=C2=A0 - mlock() handling had been fixed;<br>
=C2=A0 - bunch of smaller bugfixes and cleanups.<br>
<br>
=3D=3D Design overview =3D=3D<br>
<br>
Huge pages are allocated by shmem when it&#39;s allowed (by mount option) a=
nd<br>
there&#39;s no entries for the range in radix-tree. Huge page is represente=
d by<br>
HPAGE_PMD_NR entries in radix-tree.<br>
<br>
MM core maps a page with PMD if -&gt;fault() returns huge page and the VMA =
is<br>
suitable for huge pages (size, alignment). There&#39;s no need into two<br>
requests to file system: filesystem returns huge page if it can,<br>
graceful fallback to small pages otherwise.<br>
<br>
As with DAX, split_huge_pmd() is implemented by unmapping the PMD: we can<b=
r>
re-fault the page with PTEs later.<br>
<br>
Basic scheme for split_huge_page() is the same as for anon-THP.<br>
Few differences:<br>
<br>
=C2=A0 - File pages are on radix-tree, so we have head-&gt;_count offset by=
<br>
=C2=A0 =C2=A0 HPAGE_PMD_NR. The count got distributed to small pages during=
 split.<br>
<br>
=C2=A0 - mapping-&gt;tree_lock prevents non-lockless access to pages under =
split<br>
=C2=A0 =C2=A0 over radix-tree;<br>
<br>
=C2=A0 - Lockless access is prevented by setting the head-&gt;_count to 0 d=
uring<br>
=C2=A0 =C2=A0 split, so get_page_unless_zero() would fail;<br>
<br>
=C2=A0 - After split, some pages can be beyond i_size. We drop them from<br=
>
=C2=A0 =C2=A0 radix-tree.<br>
<br>
=C2=A0 - We don&#39;t setup migration entries. Just unmap pages. It helps<b=
r>
=C2=A0 =C2=A0 handling cases when i_size is in the middle of the page: no n=
eed<br>
=C2=A0 =C2=A0 handle unmap pages beyond i_size manually.<br>
<br>
COW mapping handled on PTE-level. It&#39;s not clear how beneficial would b=
e<br>
allocation of huge pages on COW faults. And it would require some code to<b=
r>
make them work.<br>
<br>
I think at some point we can consider teaching khugepaged to collapse<br>
pages in COW mappings, but allocating huge on fault is probably overkill.<b=
r>
<br>
As with anon THP, we mlock file huge page only if it mapped with PMD.<br>
PTE-mapped THPs are never mlocked. This way we can avoid all sorts of<br>
scenarios when we can leak mlocked page.<br>
<br>
As with anon THP, we split huge page on swap out.<br>
<br>
Truncate and punch hole that only cover part of THP range is implemented<br=
>
by zero out this part of THP.<br>
<br>
This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.<br>
As we don&#39;t really create hole in this case, lseek(SEEK_HOLE) may have<=
br>
inconsistent results depending what pages happened to be allocated.<br>
I don&#39;t think this will be a problem.<br>
<br>
We track per-super_block list of inodes which potentially have huge page<br=
>
partly beyond i_size. Under memory pressure or if we hit -ENOSPC, we split<=
br>
such pages in order to recovery memory.<br>
<br>
The list is per-sb, as we need to split a page from our filesystem if hit<b=
r>
-ENOSPC (-o size=3D limit) during shmem_getpage_gfp() to free some space.<b=
r>
<br>
Hugh Dickins (1):<br>
=C2=A0 shmem: get_unmapped_area align huge page<br>
<br>
Kirill A. Shutemov (31):<br>
=C2=A0 thp, mlock: update unevictable-lru.txt<br>
=C2=A0 mm: do not pass mm_struct into handle_mm_fault<br>
=C2=A0 mm: introduce fault_env<br>
=C2=A0 mm: postpone page table allocation until we have page to map<br>
=C2=A0 rmap: support file thp<br>
=C2=A0 mm: introduce do_set_pmd()<br>
=C2=A0 thp, vmstats: add counters for huge file pages<br>
=C2=A0 thp: support file pages in zap_huge_pmd()<br>
=C2=A0 thp: handle file pages in split_huge_pmd()<br>
=C2=A0 thp: handle file COW faults<br>
=C2=A0 thp: skip file huge pmd on copy_huge_pmd()<br>
=C2=A0 thp: prepare change_huge_pmd() for file thp<br>
=C2=A0 thp: run vma_adjust_trans_huge() outside i_mmap_rwsem<br>
=C2=A0 thp: file pages support for split_huge_page()<br>
=C2=A0 thp, mlock: do not mlock PTE-mapped file huge pages<br>
=C2=A0 vmscan: split file huge pages before paging them out<br>
=C2=A0 page-flags: relax policy for PG_mappedtodisk and PG_reclaim<br>
=C2=A0 radix-tree: implement radix_tree_maybe_preload_order()<br>
=C2=A0 filemap: prepare find and delete operations for huge pages<br>
=C2=A0 truncate: handle file thp<br>
=C2=A0 mm, rmap: account shmem thp pages<br>
=C2=A0 shmem: prepare huge=3D mount option and sysfs knob<br>
=C2=A0 shmem: add huge pages support<br>
=C2=A0 shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings<br>
=C2=A0 thp: update Documentation/vm/transhuge.txt<br>
=C2=A0 thp: extract khugepaged from mm/huge_memory.c<br>
=C2=A0 khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()<br=
>
=C2=A0 shmem: make shmem_inode_info::lock irq-safe<br>
=C2=A0 khugepaged: add support of collapse for tmpfs/shmem pages<br>
=C2=A0 thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE<br>
=C2=A0 shmem: split huge pages beyond i_size under memory pressure<br>
<br>
=C2=A0Documentation/filesystems/Locking=C2=A0 =C2=A0 |=C2=A0 =C2=A010 +-<br=
>
=C2=A0Documentation/vm/transhuge.txt=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 130 =
++-<br>
=C2=A0Documentation/vm/unevictable-lru.txt |=C2=A0 =C2=A021 +<br>
=C2=A0arch/alpha/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/arc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/arm/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/arm64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/avr32/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/cris/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/frv/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/hexagon/mm/vm_fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/ia64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/m32r/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/m68k/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/metag/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/microblaze/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/mips/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/mn10300/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/nios2/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/openrisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/parisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/powerpc/mm/copro_fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 2 +-<br>
=C2=A0arch/powerpc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/s390/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/score/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/sh/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/sparc/mm/fault_32.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A0 4 +-<br>
=C2=A0arch/sparc/mm/fault_64.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/tile/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/um/kernel/trap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/unicore32/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/x86/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0arch/xtensa/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0drivers/base/node.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A013 +-<br>
=C2=A0drivers/char/mem.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A024 +<br>
=C2=A0drivers/iommu/amd_iommu_v2.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0=
 =C2=A0 3 +-<br>
=C2=A0drivers/iommu/intel-svm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A0 2 +-<br>
=C2=A0fs/proc/meminfo.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 7 +-<br>
=C2=A0fs/proc/task_mmu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A010 +-<br>
=C2=A0fs/userfaultfd.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A022 +-<br>
=C2=A0include/linux/huge_mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A036 +-<br>
=C2=A0include/linux/khugepaged.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 6 +<br>
=C2=A0include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A051 +-<br>
=C2=A0include/linux/mmzone.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0|=C2=A0 =C2=A0 4 +-<br>
=C2=A0include/linux/page-flags.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A019 +-<br>
=C2=A0include/linux/radix-tree.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 1 +<br>
=C2=A0include/linux/rmap.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0include/linux/shmem_fs.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A045 +-<br>
=C2=A0include/linux/userfaultfd_k.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 8 +-<br>
=C2=A0include/linux/vm_event_item.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 7 +<br>
=C2=A0include/trace/events/huge_memory.h=C2=A0 =C2=A0|=C2=A0 =C2=A0 3 +-<br=
>
=C2=A0ipc/shm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A010 +-<br>
=C2=A0lib/radix-tree.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A068 +-<br>
=C2=A0mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 8 +<br>
=C2=A0mm/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0mm/filemap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 226 ++--<br>
=C2=A0mm/gup.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 7 +-<br>
=C2=A0mm/huge_memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| 2032 ++++++----------------------------<br>
=C2=A0mm/internal.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 4 +-<br>
=C2=A0mm/khugepaged.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | 1851 +++++++++++++++++++++++++++++++<br>
=C2=A0mm/ksm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 5 +-<br>
=C2=A0mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 860 +++++++-------<br>
=C2=A0mm/mempolicy.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 4 +-<br>
=C2=A0mm/migrate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 5 +-<br>
=C2=A0mm/mmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A026 +-<br>
=C2=A0mm/nommu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 3 +-<br>
=C2=A0mm/page-writeback.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 1 +<br>
=C2=A0mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A021 +<br>
=C2=A0mm/rmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A078 +-<br>
=C2=A0mm/shmem.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 918 +++++++++++++--<br>
=C2=A0mm/swap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +<br>
=C2=A0mm/truncate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A022 +-<br>
=C2=A0mm/util.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 6 +<br>
=C2=A0mm/vmscan.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 6 +<br>
=C2=A0mm/vmstat.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 4 +<br>
=C2=A075 files changed, 4240 insertions(+), 2415 deletions(-)<br>
=C2=A0create mode 100644 mm/khugepaged.c<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
2.8.1<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"gmail_signature"><div dir=3D"ltr">Thanks and Regards,<div>N=
eha Agarwal</div><div>University of Michigan</div><div><br></div></div></di=
v>
</div></div>

--001a1135dfa2ccf3030533af7419--

--001a1135dfa2ccf3060533af741b
Content-Type: text/plain; charset=UTF-8; name="cassandra-setup.txt"
Content-Disposition: attachment; filename="cassandra-setup.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ion8rbx70

MS4gRG93bmxvYWQgYW5kIGV4dHJhY3QgQ2Fzc2FuZHJhCmh0dHA6Ly9hcmNoaXZlLmFwYWNoZS5v
cmcvZGlzdC9jYXNzYW5kcmEvMi4wLjE2L2FwYWNoZS1jYXNzYW5kcmEtMi4wLjE2LWJpbi50YXIu
Z3oKCk5vdGUgdGhhdCBteSB0ZXN0IHZlcnNpb24gaXMgQ2Fzc2FuZHJhLTIuMC4xNi4KV2Ugd2ls
bCBkZW5vdGUgdGhlIHBhdGggdG8gd2hpY2ggdGhlIGZpbGUgaXMgZXh0cmFjdGVkIGFzIENBU1NB
TkRSQV9CSU4KCjIuIFNldHVwIGVudmlyb25tZW50IGZvciBjYXNzYW5kcmEKbWtkaXIgLXAgcnVu
X2Nhc3NhbmRyYS9jYXNzYW5kcmFfY29uZi90cmlnZ2VycwoKLSBEb3dubG9hZCBjYXNzYW5kcmEt
ZW52LnNoLCBjYXNzYW5kcmEueWFtbCwgbG9nNGotc2VydmVyLnByb3BlcnRpZXMgZnJvbSBteSBt
YWlsCmF0dGFjaGVtZW50IGFuZCB0aGVuIGNvcHkgdGhvc2UgZmlsZXMgaW4gcnVuX2Nhc3NhbmRy
YS9jYXNzYW5kcmFfY29uZgotIFNlYXJjaCBmb3IgL2hvbWUvbmVoYWFnL2h1Z2V0bXBmcyBpbiB0
aGVzZSBmaWxlcyBhbmQgY2hhbmdlIHRoaXMgdG8gYSBsb2NhbApkaXJlY3RvcnkgbW91bnRlZCBh
cyB0bXBmcy4gTGV04oCZcyBzYXkgdGhhdCBpcyBDQVNTQU5EUkFfREFUQS4gIEEgZm9sZGVyIG5h
bWVkCiJjYXNzYW5kcmEiIHdpbGwgYmUgYXV0b21hdGljYWxseSBjcmVhdGVkIChGb3IgZXhhbXBs
ZToKQ0FTU0FORFJBX0RBVEEvY2Fzc2FuZHJhKSB3aGVuIHJ1bm5pbmcgQ2Fzc2FuZHJhLgotIFBs
ZWFzZSBub3RlIHRoYXQgdGhlc2Ugc2NyaXB0cyB3aWxsIG5lZWQgbW9kaWZpY2F0aW9ucyBpZiB5
b3UgdXNlIENhc3NhbmRyYQp2ZXJzaW9uIG90aGVyIHRoYXQgMi4wLjE2CgotIERvd25sb2FkIGNy
ZWF0ZS15Y3NiLXRhYmxlLmNxbC5qMiBmcm9tIG15IGVtYWlsIGF0dGFjaG1lbnQgYW5kIGNvcHkg
aXQgaW4KcnVuX2Nhc3NhbmRyYS8KCjMuIEpBVkEgc2V0dXAsIGdldCBKUkU6IG9wZW5qZGsgdjEu
Ny4wXzEwMSAoc3VkbyBhcHQtZ2V0IGluc3RhbGwgb3Blbmpkay03LWpyZQpmb3IgVWJ1bnR1KQoK
NC4gU2V0dXAgWUNTQiBMb2FkIGdlbmVyYXRvcjoKLSBDbG9uZSB5Y3NiIGZyb206IGh0dHBzOi8v
Z2l0aHViLmNvbS9icmlhbmZyYW5rY29vcGVyL1lDU0IuZ2l0LiBMZXTigJlzIHNheSB0aGlzIGlz
CmRvd25sb2FkZWQgdG8gWUNTQl9ST09UCi0gWW91IG5lZWQgdG8gaGF2ZSBtYXZlbiAzIGluc3Rh
bGxlZCAoYHN1ZG8gYXB0LWdldCBpbnN0YWxsIG1hdmVu4oCZIGluIHVidW50dSkKLSBDcmVhdGUg
YSBzY3JpcHQgKHNheSBydW4tY2Fzc2FuZHJhLnNoKSBpbiBydW5fY2Fzc2FuZHJhIGFzIGZvbGxv
d3M6CgppbnB1dF9maWxlPXJ1bl9jYXNzYW5kcmEvY3JlYXRlLXljc2ItdGFibGUuY3FsLmoyCmNh
c3NhbmRyYV9jbGk9JHtDQVNTQU5EUkFfQklOfS9iaW4vY2Fzc2FuZHJhLWNsaQpob3N0PeKAnTEy
Ny4wLjAuMeKAnSAjSXAgYWRkcmVzcyBvZiB0aGUgbWFjaGluZSBydW5uaW5nIGNhc3Nhc25kcmEg
c2VydmVyCiRjYXNzYW5kcmFfY2xpIC1oICRob3N0IC0tam14cG9ydCA3MTk5IC1mIGNyZWF0ZS15
Y3NiLXRhYmxlLmNxbApjZCAke1lDU0JfUk9PVH0KCiMgTG9hZCBkYXRhc2V0CiR7WUNTQl9ST09U
fS9iaW4veWNzYiAtY3AgJHtZQ1NCX1JPT1R9L2Nhc3NhbmRyYS90YXJnZXQvZGVwZW5kZW5jeS9z
bGY0ai1zaW1wbGUtMS43LjEyLmphcjoke1lDU0JfUk9PVH0vY2Fzc2FuZHJhL3RhcmdldC9kZXBl
bmRlbmN5L3NsZjRqLXNpbXBsZS0xLjcuMTIuamFyIGxvYWQgY2Fzc2FuZHJhLTEwIC1wIGhvc3Rz
PSRob3N0IC10aHJlYWRzICAyMCAtcCBmaWVsZGNvdW50PTIwIC1wIHJlY29yZGNvdW50PTUwMDAw
MDAgLVAgJHtZQ1NCX1JPT1R9L3dvcmtsb2Fkcy93b3JrbG9hZGIgLXMKCiMgUnVuIGJlbmNobWFy
awoke1lDU0JfUk9PVH0vYmluL3ljc2IgLWNwICR7WUNTQl9ST09UfS9jYXNzYW5kcmEvdGFyZ2V0
L2RlcGVuZGVuY3kvc2xmNGotc2ltcGxlLTEuNy4xMi5qYXI6JHtZQ1NCX1JPT1R9L2Nhc3NhbmRy
YS90YXJnZXQvZGVwZW5kZW5jeS9zbGY0ai1zaW1wbGUtMS43LjEyLmphciBydW4gY2Fzc2FuZHJh
LTEwIC1wIGhvc3RzPSRob3N0IC10aHJlYWRzICAyMCAtcCBmaWVsZGNvdW50PTIwIC1wIG9wZXJh
dGlvbmNvdW50PTUwMDAwMDAwIC1wIHJlY29yZGNvdW50PTUwMDAwMDAgLXAgcmVhZHByb3BvcnRp
b249MC4wNSAtcCB1cGRhdGVwcm9wb3J0aW9uPTAuOTUgLVAgJHtZQ1NCX1JPT1R9L3dvcmtsb2Fk
cy93b3JrbG9hZGIgLXMKCjUuIFJ1biB0aGUgY2Fzc2FuZHJhIHNlcnZlciBvbiBob3N0IG1hY2hp
bmU6CnJtIC1yICR7Q0FTU0FORFJBX0RBVEF9L2Nhc3NhbmRyYSAmJiBDQVNTQU5EUkFfQ09ORj1y
dW5fY2Fzc2FuZHJhL2Nhc3NhbmRyYV9jb25mIEpSRV9IT01FPS91c3IvbGliL2p2bS9qYXZhLTct
b3Blbmpkay1hbWQ2NC9qcmUgJHtDQVNTQU5EUkFfQklOfS9iaW4vY2Fzc2FuZHJhIC1mCgo2LiBS
dW4gbG9hZCBnZW5lcmF0b3Igb24gc2FtZS9zb21lIG90aGVyIG1hY2hpbmU6Ci4vcnVuLWNhc3Nh
bmRyYS5zaAoKWUNTQiBwZXJpb2RjYWxseSBzcGl0cyBvdXQgdGhlIHRocm91Z2hwdXQgYW5kIGxh
dGVuY3kgbnVtYmVyCkF0IHRoZSBlbmQgb3ZlcmFsbCB0aHJvdWdocHV0IGFuZCBsYXRlbmN5IHdp
bGwgYmUgcHJpbnRlZCBvdXQK
--001a1135dfa2ccf3060533af741b
Content-Type: application/x-sh; name="cassandra-env.sh"
Content-Disposition: attachment; filename="cassandra-env.sh"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ion8rby01

IyBMaWNlbnNlZCB0byB0aGUgQXBhY2hlIFNvZnR3YXJlIEZvdW5kYXRpb24gKEFTRikgdW5kZXIg
b25lCiMgb3IgbW9yZSBjb250cmlidXRvciBsaWNlbnNlIGFncmVlbWVudHMuICBTZWUgdGhlIE5P
VElDRSBmaWxlCiMgZGlzdHJpYnV0ZWQgd2l0aCB0aGlzIHdvcmsgZm9yIGFkZGl0aW9uYWwgaW5m
b3JtYXRpb24KIyByZWdhcmRpbmcgY29weXJpZ2h0IG93bmVyc2hpcC4gIFRoZSBBU0YgbGljZW5z
ZXMgdGhpcyBmaWxlCiMgdG8geW91IHVuZGVyIHRoZSBBcGFjaGUgTGljZW5zZSwgVmVyc2lvbiAy
LjAgKHRoZQojICJMaWNlbnNlIik7IHlvdSBtYXkgbm90IHVzZSB0aGlzIGZpbGUgZXhjZXB0IGlu
IGNvbXBsaWFuY2UKIyB3aXRoIHRoZSBMaWNlbnNlLiAgWW91IG1heSBvYnRhaW4gYSBjb3B5IG9m
IHRoZSBMaWNlbnNlIGF0CiMKIyAgIGh0dHA6Ly93d3cuYXBhY2hlLm9yZy9saWNlbnNlcy9MSUNF
TlNFLTIuMAojCiMgVW5sZXNzIHJlcXVpcmVkIGJ5IGFwcGxpY2FibGUgbGF3IG9yIGFncmVlZCB0
byBpbiB3cml0aW5nLCBzb2Z0d2FyZQojIGRpc3RyaWJ1dGVkIHVuZGVyIHRoZSBMaWNlbnNlIGlz
IGRpc3RyaWJ1dGVkIG9uIGFuICJBUyBJUyIgQkFTSVMsCiMgV0lUSE9VVCBXQVJSQU5USUVTIE9S
IENPTkRJVElPTlMgT0YgQU5ZIEtJTkQsIGVpdGhlciBleHByZXNzIG9yIGltcGxpZWQuCiMgU2Vl
IHRoZSBMaWNlbnNlIGZvciB0aGUgc3BlY2lmaWMgbGFuZ3VhZ2UgZ292ZXJuaW5nIHBlcm1pc3Np
b25zIGFuZAojIGxpbWl0YXRpb25zIHVuZGVyIHRoZSBMaWNlbnNlLgoKY2FsY3VsYXRlX2hlYXBf
c2l6ZXMoKQp7CiAgICBjYXNlICJgdW5hbWVgIiBpbgogICAgICAgIExpbnV4KQogICAgICAgICAg
ICBzeXN0ZW1fbWVtb3J5X2luX21iPWBmcmVlIC1tIHwgYXdrICcvTWVtOi8ge3ByaW50ICQyfSdg
CiAgICAgICAgICAgIHN5c3RlbV9jcHVfY29yZXM9YGVncmVwIC1jICdwcm9jZXNzb3IoW1s6c3Bh
Y2U6XV0rKTouKicgL3Byb2MvY3B1aW5mb2AKICAgICAgICA7OwogICAgICAgIEZyZWVCU0QpCiAg
ICAgICAgICAgIHN5c3RlbV9tZW1vcnlfaW5fYnl0ZXM9YHN5c2N0bCBody5waHlzbWVtIHwgYXdr
ICd7cHJpbnQgJDJ9J2AKICAgICAgICAgICAgc3lzdGVtX21lbW9yeV9pbl9tYj1gZXhwciAkc3lz
dGVtX21lbW9yeV9pbl9ieXRlcyAvIDEwMjQgLyAxMDI0YAogICAgICAgICAgICBzeXN0ZW1fY3B1
X2NvcmVzPWBzeXNjdGwgaHcubmNwdSB8IGF3ayAne3ByaW50ICQyfSdgCiAgICAgICAgOzsKICAg
ICAgICBTdW5PUykKICAgICAgICAgICAgc3lzdGVtX21lbW9yeV9pbl9tYj1gcHJ0Y29uZiB8IGF3
ayAnL01lbW9yeSBzaXplOi8ge3ByaW50ICQzfSdgCiAgICAgICAgICAgIHN5c3RlbV9jcHVfY29y
ZXM9YHBzcmluZm8gfCB3YyAtbGAKICAgICAgICA7OwogICAgICAgIERhcndpbikKICAgICAgICAg
ICAgc3lzdGVtX21lbW9yeV9pbl9ieXRlcz1gc3lzY3RsIGh3Lm1lbXNpemUgfCBhd2sgJ3twcmlu
dCAkMn0nYAogICAgICAgICAgICBzeXN0ZW1fbWVtb3J5X2luX21iPWBleHByICRzeXN0ZW1fbWVt
b3J5X2luX2J5dGVzIC8gMTAyNCAvIDEwMjRgCiAgICAgICAgICAgIHN5c3RlbV9jcHVfY29yZXM9
YHN5c2N0bCBody5uY3B1IHwgYXdrICd7cHJpbnQgJDJ9J2AKICAgICAgICA7OwogICAgICAgICop
CiAgICAgICAgICAgICMgYXNzdW1lIHJlYXNvbmFibGUgZGVmYXVsdHMgZm9yIGUuZy4gYSBtb2Rl
cm4gZGVza3RvcCBvcgogICAgICAgICAgICAjIGNoZWFwIHNlcnZlcgogICAgICAgICAgICBzeXN0
ZW1fbWVtb3J5X2luX21iPSIyMDQ4IgogICAgICAgICAgICBzeXN0ZW1fY3B1X2NvcmVzPSIyIgog
ICAgICAgIDs7CiAgICBlc2FjCgogICAgIyBzb21lIHN5c3RlbXMgbGlrZSB0aGUgcmFzcGJlcnJ5
IHBpIGRvbid0IHJlcG9ydCBjb3JlcywgdXNlIGF0IGxlYXN0IDEKICAgIGlmIFsgIiRzeXN0ZW1f
Y3B1X2NvcmVzIiAtbHQgIjEiIF0KICAgIHRoZW4KICAgICAgICBzeXN0ZW1fY3B1X2NvcmVzPSIx
IgogICAgZmkKCiAgICAjIHNldCBtYXggaGVhcCBzaXplIGJhc2VkIG9uIHRoZSBmb2xsb3dpbmcK
ICAgICMgbWF4KG1pbigxLzIgcmFtLCAxMDI0TUIpLCBtaW4oMS80IHJhbSwgOEdCKSkKICAgICMg
Y2FsY3VsYXRlIDEvMiByYW0gYW5kIGNhcCB0byAxMDI0TUIKICAgICMgY2FsY3VsYXRlIDEvNCBy
YW0gYW5kIGNhcCB0byA4MTkyTUIKICAgICMgcGljayB0aGUgbWF4CiAgICBoYWxmX3N5c3RlbV9t
ZW1vcnlfaW5fbWI9YGV4cHIgJHN5c3RlbV9tZW1vcnlfaW5fbWIgLyAyYAogICAgcXVhcnRlcl9z
eXN0ZW1fbWVtb3J5X2luX21iPWBleHByICRoYWxmX3N5c3RlbV9tZW1vcnlfaW5fbWIgLyAyYAog
ICAgaWYgWyAiJGhhbGZfc3lzdGVtX21lbW9yeV9pbl9tYiIgLWd0ICIxMDI0IiBdCiAgICB0aGVu
CiAgICAgICAgaGFsZl9zeXN0ZW1fbWVtb3J5X2luX21iPSIxMDI0IgogICAgZmkKICAgIGlmIFsg
IiRxdWFydGVyX3N5c3RlbV9tZW1vcnlfaW5fbWIiIC1ndCAiODE5MiIgXQogICAgdGhlbgogICAg
ICAgIHF1YXJ0ZXJfc3lzdGVtX21lbW9yeV9pbl9tYj0iODE5MiIKICAgIGZpCiAgICBpZiBbICIk
aGFsZl9zeXN0ZW1fbWVtb3J5X2luX21iIiAtZ3QgIiRxdWFydGVyX3N5c3RlbV9tZW1vcnlfaW5f
bWIiIF0KICAgIHRoZW4KICAgICAgICBtYXhfaGVhcF9zaXplX2luX21iPSIkaGFsZl9zeXN0ZW1f
bWVtb3J5X2luX21iIgogICAgZWxzZQogICAgICAgIG1heF9oZWFwX3NpemVfaW5fbWI9IiRxdWFy
dGVyX3N5c3RlbV9tZW1vcnlfaW5fbWIiCiAgICBmaQogICAgTUFYX0hFQVBfU0laRT0iJHttYXhf
aGVhcF9zaXplX2luX21ifU0iCgogICAgIyBZb3VuZyBnZW46IG1pbihtYXhfc2Vuc2libGVfcGVy
X21vZGVybl9jcHVfY29yZSAqIG51bV9jb3JlcywgMS80ICogaGVhcCBzaXplKQogICAgbWF4X3Nl
bnNpYmxlX3lnX3Blcl9jb3JlX2luX21iPSIxMDAiCiAgICBtYXhfc2Vuc2libGVfeWdfaW5fbWI9
YGV4cHIgJG1heF9zZW5zaWJsZV95Z19wZXJfY29yZV9pbl9tYiAiKiIgJHN5c3RlbV9jcHVfY29y
ZXNgCgogICAgZGVzaXJlZF95Z19pbl9tYj1gZXhwciAkbWF4X2hlYXBfc2l6ZV9pbl9tYiAvIDRg
CgogICAgaWYgWyAiJGRlc2lyZWRfeWdfaW5fbWIiIC1ndCAiJG1heF9zZW5zaWJsZV95Z19pbl9t
YiIgXQogICAgdGhlbgogICAgICAgIEhFQVBfTkVXU0laRT0iJHttYXhfc2Vuc2libGVfeWdfaW5f
bWJ9TSIKICAgIGVsc2UKICAgICAgICBIRUFQX05FV1NJWkU9IiR7ZGVzaXJlZF95Z19pbl9tYn1N
IgogICAgZmkKfQoKIyBEZXRlcm1pbmUgdGhlIHNvcnQgb2YgSlZNIHdlJ2xsIGJlIHJ1bm5pbmcg
b24uCgpqYXZhX3Zlcl9vdXRwdXQ9YCIke0pBVkE6LWphdmF9IiAtdmVyc2lvbiAyPiYxYAoKanZt
dmVyPWBlY2hvICIkamF2YV92ZXJfb3V0cHV0IiB8IGF3ayAtRiciJyAnTlI9PTEge3ByaW50ICQy
fSdgCkpWTV9WRVJTSU9OPSR7anZtdmVyJV8qfQpKVk1fUEFUQ0hfVkVSU0lPTj0ke2p2bXZlciMq
X30KCmp2bT1gZWNobyAiJGphdmFfdmVyX291dHB1dCIgfCBhd2sgJ05SPT0yIHtwcmludCAkMX0n
YApjYXNlICIkanZtIiBpbgogICAgT3BlbkpESykKICAgICAgICBKVk1fVkVORE9SPU9wZW5KREsK
ICAgICAgICAjIHRoaXMgd2lsbCBiZSAiNjQtQml0IiBvciAiMzItQml0IgogICAgICAgIEpWTV9B
UkNIPWBlY2hvICIkamF2YV92ZXJfb3V0cHV0IiB8IGF3ayAnTlI9PTMge3ByaW50ICQyfSdgCiAg
ICAgICAgOzsKICAgICJKYXZhKFRNKSIpCiAgICAgICAgSlZNX1ZFTkRPUj1PcmFjbGUKICAgICAg
ICAjIHRoaXMgd2lsbCBiZSAiNjQtQml0IiBvciAiMzItQml0IgogICAgICAgIEpWTV9BUkNIPWBl
Y2hvICIkamF2YV92ZXJfb3V0cHV0IiB8IGF3ayAnTlI9PTMge3ByaW50ICQzfSdgCiAgICAgICAg
OzsKICAgICopCiAgICAgICAgIyBIZWxwIGZpbGwgaW4gb3RoZXIgSlZNIHZhbHVlcwogICAgICAg
IEpWTV9WRU5ET1I9b3RoZXIKICAgICAgICBKVk1fQVJDSD11bmtub3duCiAgICAgICAgOzsKZXNh
YwoKCiMgT3ZlcnJpZGUgdGhlc2UgdG8gc2V0IHRoZSBhbW91bnQgb2YgbWVtb3J5IHRvIGFsbG9j
YXRlIHRvIHRoZSBKVk0gYXQKIyBzdGFydC11cC4gRm9yIHByb2R1Y3Rpb24gdXNlIHlvdSBtYXkg
d2lzaCB0byBhZGp1c3QgdGhpcyBmb3IgeW91cgojIGVudmlyb25tZW50LiBNQVhfSEVBUF9TSVpF
IGlzIHRoZSB0b3RhbCBhbW91bnQgb2YgbWVtb3J5IGRlZGljYXRlZAojIHRvIHRoZSBKYXZhIGhl
YXA7IEhFQVBfTkVXU0laRSByZWZlcnMgdG8gdGhlIHNpemUgb2YgdGhlIHlvdW5nCiMgZ2VuZXJh
dGlvbi4gQm90aCBNQVhfSEVBUF9TSVpFIGFuZCBIRUFQX05FV1NJWkUgc2hvdWxkIGJlIGVpdGhl
ciBzZXQKIyBvciBub3QgKGlmIHlvdSBzZXQgb25lLCBzZXQgdGhlIG90aGVyKS4KIwojIFRoZSBt
YWluIHRyYWRlLW9mZiBmb3IgdGhlIHlvdW5nIGdlbmVyYXRpb24gaXMgdGhhdCB0aGUgbGFyZ2Vy
IGl0CiMgaXMsIHRoZSBsb25nZXIgR0MgcGF1c2UgdGltZXMgd2lsbCBiZS4gVGhlIHNob3J0ZXIg
aXQgaXMsIHRoZSBtb3JlCiMgZXhwZW5zaXZlIEdDIHdpbGwgYmUgKHVzdWFsbHkpLgojCiMgVGhl
IGV4YW1wbGUgSEVBUF9ORVdTSVpFIGFzc3VtZXMgYSBtb2Rlcm4gOC1jb3JlKyBtYWNoaW5lIGZv
ciBkZWNlbnQgcGF1c2UKIyB0aW1lcy4gSWYgaW4gZG91YnQsIGFuZCBpZiB5b3UgZG8gbm90IHBh
cnRpY3VsYXJseSB3YW50IHRvIHR3ZWFrLCBnbyB3aXRoCiMgMTAwIE1CIHBlciBwaHlzaWNhbCBD
UFUgY29yZS4KCiMgTUFYX0hFQVBfU0laRT0iMjRHIgojIEhFQVBfTkVXU0laRT0iNjAwTSIKCmlm
IFsgIngkTUFYX0hFQVBfU0laRSIgPSAieCIgXSAmJiBbICJ4JEhFQVBfTkVXU0laRSIgPSAieCIg
XTsgdGhlbgogICAgY2FsY3VsYXRlX2hlYXBfc2l6ZXMKZWxzZQogICAgaWYgWyAieCRNQVhfSEVB
UF9TSVpFIiA9ICJ4IiBdIHx8ICBbICJ4JEhFQVBfTkVXU0laRSIgPSAieCIgXTsgdGhlbgogICAg
ICAgIGVjaG8gInBsZWFzZSBzZXQgb3IgdW5zZXQgTUFYX0hFQVBfU0laRSBhbmQgSEVBUF9ORVdT
SVpFIGluIHBhaXJzIChzZWUgY2Fzc2FuZHJhLWVudi5zaCkiCiAgICAgICAgZXhpdCAxCiAgICBm
aQpmaQoKIyBTcGVjaWZpZXMgdGhlIGRlZmF1bHQgcG9ydCBvdmVyIHdoaWNoIENhc3NhbmRyYSB3
aWxsIGJlIGF2YWlsYWJsZSBmb3IKIyBKTVggY29ubmVjdGlvbnMuCkpNWF9QT1JUPSI3MTk5IgoK
CiMgSGVyZSB3ZSBjcmVhdGUgdGhlIGFyZ3VtZW50cyB0aGF0IHdpbGwgZ2V0IHBhc3NlZCB0byB0
aGUganZtIHdoZW4KIyBzdGFydGluZyBjYXNzYW5kcmEuCgojIGVuYWJsZSBhc3NlcnRpb25zLiAg
ZGlzYWJsaW5nIHRoaXMgaW4gcHJvZHVjdGlvbiB3aWxsIGdpdmUgYSBtb2Rlc3QKIyBwZXJmb3Jt
YW5jZSBiZW5lZml0IChhcm91bmQgNSUpLgojSlZNX09QVFM9IiRKVk1fT1BUUyAtZWEiCgojIGFk
ZCB0aGUgamFtbSBqYXZhYWdlbnQKaWYgWyAiJEpWTV9WRU5ET1IiICE9ICJPcGVuSkRLIiAtbyAi
JEpWTV9WRVJTSU9OIiBcPiAiMS42LjAiIF0gXAogICAgICB8fCBbICIkSlZNX1ZFUlNJT04iID0g
IjEuNi4wIiAtYSAiJEpWTV9QQVRDSF9WRVJTSU9OIiAtZ2UgMjMgXQp0aGVuCiAgICBKVk1fT1BU
Uz0iJEpWTV9PUFRTIC1qYXZhYWdlbnQ6JENBU1NBTkRSQV9IT01FL2xpYi9qYW1tLTAuMi41Lmph
ciIKZmkKCiMgZW5hYmxlIHRocmVhZCBwcmlvcml0aWVzLCBwcmltYXJpbHkgc28gd2UgY2FuIGdp
dmUgcGVyaW9kaWMgdGFza3MKIyBhIGxvd2VyIHByaW9yaXR5IHRvIGF2b2lkIGludGVyZmVyaW5n
IHdpdGggY2xpZW50IHdvcmtsb2FkCkpWTV9PUFRTPSIkSlZNX09QVFMgLVhYOitVc2VUaHJlYWRQ
cmlvcml0aWVzIgojIGFsbG93cyBsb3dlcmluZyB0aHJlYWQgcHJpb3JpdHkgd2l0aG91dCBiZWlu
ZyByb290LiAgc2VlCiMgaHR0cDovL3RlY2guc3RvbHN2aWsuY29tLzIwMTAvMDEvbGludXgtamF2
YS10aHJlYWQtcHJpb3JpdGllcy13b3JrYXJvdW5kLmh0bWwKSlZNX09QVFM9IiRKVk1fT1BUUyAt
WFg6VGhyZWFkUHJpb3JpdHlQb2xpY3k9NDIiCgojIG1pbiBhbmQgbWF4IGhlYXAgc2l6ZXMgc2hv
dWxkIGJlIHNldCB0byB0aGUgc2FtZSB2YWx1ZSB0byBhdm9pZAojIHN0b3AtdGhlLXdvcmxkIEdD
IHBhdXNlcyBkdXJpbmcgcmVzaXplLCBhbmQgc28gdGhhdCB3ZSBjYW4gbG9jayB0aGUKIyBoZWFw
IGluIG1lbW9yeSBvbiBzdGFydHVwIHRvIHByZXZlbnQgYW55IG9mIGl0IGZyb20gYmVpbmcgc3dh
cHBlZAojIG91dC4KSlZNX09QVFM9IiRKVk1fT1BUUyAtWG1zJHtNQVhfSEVBUF9TSVpFfSIKSlZN
X09QVFM9IiRKVk1fT1BUUyAtWG14JHtNQVhfSEVBUF9TSVpFfSIKSlZNX09QVFM9IiRKVk1fT1BU
UyAtWG1uJHtIRUFQX05FV1NJWkV9IgpKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDorSGVhcER1bXBP
bk91dE9mTWVtb3J5RXJyb3IiCgojIHNldCBqdm0gSGVhcER1bXBQYXRoIHdpdGggQ0FTU0FORFJB
X0hFQVBEVU1QX0RJUgppZiBbICJ4JENBU1NBTkRSQV9IRUFQRFVNUF9ESVIiICE9ICJ4IiBdOyB0
aGVuCiAgICBKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDpIZWFwRHVtcFBhdGg9JENBU1NBTkRSQV9I
RUFQRFVNUF9ESVIvY2Fzc2FuZHJhLWBkYXRlICslc2AtcGlkJCQuaHByb2YiCmZpCgoKc3RhcnRz
d2l0aCgpIHsgWyAiJHsxIyQyfSIgIT0gIiQxIiBdOyB9CgppZiBbICJgdW5hbWVgIiA9ICJMaW51
eCIgXSA7IHRoZW4KICAgICMgcmVkdWNlIHRoZSBwZXItdGhyZWFkIHN0YWNrIHNpemUgdG8gbWlu
aW1pemUgdGhlIGltcGFjdCBvZiBUaHJpZnQKICAgICMgdGhyZWFkLXBlci1jbGllbnQuICAoQmVz
dCBwcmFjdGljZSBpcyBmb3IgY2xpZW50IGNvbm5lY3Rpb25zIHRvCiAgICAjIGJlIHBvb2xlZCBh
bnl3YXkuKSBPbmx5IGRvIHNvIG9uIExpbnV4IHdoZXJlIGl0IGlzIGtub3duIHRvIGJlCiAgICAj
IHN1cHBvcnRlZC4KICAgICMgdTM0IGFuZCBncmVhdGVyIG5lZWQgMTgwawogICAgSlZNX09QVFM9
IiRKVk1fT1BUUyAtWHNzMjU2ayIKZmkKZWNobyAieHNzID0gJEpWTV9PUFRTIgoKIyBHQyB0dW5p
bmcgb3B0aW9ucwpKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDorVXNlUGFyTmV3R0MiCkpWTV9PUFRT
PSIkSlZNX09QVFMgLVhYOitVc2VDb25jTWFya1N3ZWVwR0MiCkpWTV9PUFRTPSIkSlZNX09QVFMg
LVhYOitDTVNQYXJhbGxlbFJlbWFya0VuYWJsZWQiCkpWTV9PUFRTPSIkSlZNX09QVFMgLVhYOlN1
cnZpdm9yUmF0aW89NCIKSlZNX09QVFM9IiRKVk1fT1BUUyAtWFg6TWF4VGVudXJpbmdUaHJlc2hv
bGQ9MSIKSlZNX09QVFM9IiRKVk1fT1BUUyAtWFg6Q01TSW5pdGlhdGluZ09jY3VwYW5jeUZyYWN0
aW9uPTcwIgpKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDorVXNlQ01TSW5pdGlhdGluZ09jY3VwYW5j
eU9ubHkiCkpWTV9PUFRTPSIkSlZNX09QVFMgLVhYOitVc2VUTEFCIgojIG5vdGU6IGJhc2ggZXZh
bHMgJzEuNy54JyBhcyA+ICcxLjcnIHNvIHRoaXMgaXMgcmVhbGx5IGEgPj0gMS43IGp2bSBjaGVj
awppZiBbICIkSlZNX1ZFUlNJT04iIFw+ICIxLjciIF0gOyB0aGVuCiAgICBKVk1fT1BUUz0iJEpW
TV9PUFRTIC1YWDorVXNlQ29uZENhcmRNYXJrIgpmaQoKIyBHQyBsb2dnaW5nIG9wdGlvbnMgLS0g
dW5jb21tZW50IHRvIGVuYWJsZQojIEpWTV9PUFRTPSIkSlZNX09QVFMgLVhYOitQcmludEdDRGV0
YWlscyIKIyBKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDorUHJpbnRHQ0RhdGVTdGFtcHMiCiMgSlZN
X09QVFM9IiRKVk1fT1BUUyAtWFg6K1ByaW50SGVhcEF0R0MiCiMgSlZNX09QVFM9IiRKVk1fT1BU
UyAtWFg6K1ByaW50VGVudXJpbmdEaXN0cmlidXRpb24iCiMgSlZNX09QVFM9IiRKVk1fT1BUUyAt
WFg6K1ByaW50R0NBcHBsaWNhdGlvblN0b3BwZWRUaW1lIgojIEpWTV9PUFRTPSIkSlZNX09QVFMg
LVhYOitQcmludFByb21vdGlvbkZhaWx1cmUiCiMgSlZNX09QVFM9IiRKVk1fT1BUUyAtWFg6UHJp
bnRGTFNTdGF0aXN0aWNzPTEiCiMgSlZNX09QVFM9IiRKVk1fT1BUUyAtWGxvZ2djOi92YXIvbG9n
L2Nhc3NhbmRyYS9nYy1gZGF0ZSArJXNgLmxvZyIKIyBJZiB5b3UgYXJlIHVzaW5nIEpESyA2dTM0
IDd1MiBvciBsYXRlciB5b3UgY2FuIGVuYWJsZSBHQyBsb2cgcm90YXRpb24KIyBkb24ndCBzdGlj
ayB0aGUgZGF0ZSBpbiB0aGUgbG9nIG5hbWUgaWYgcm90YXRpb24gaXMgb24uCiMgSlZNX09QVFM9
IiRKVk1fT1BUUyAtWGxvZ2djOi92YXIvbG9nL2Nhc3NhbmRyYS9nYy5sb2ciCiMgSlZNX09QVFM9
IiRKVk1fT1BUUyAtWFg6K1VzZUdDTG9nRmlsZVJvdGF0aW9uIgojIEpWTV9PUFRTPSIkSlZNX09Q
VFMgLVhYOk51bWJlck9mR0NMb2dGaWxlcz0xMCIKIyBKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDpH
Q0xvZ0ZpbGVTaXplPTEwTSIKCiMgQ29uZmlndXJlIHRoZSBmb2xsb3dpbmcgZm9yIEpFTWFsbG9j
QWxsb2NhdG9yIGFuZCBpZiBqZW1hbGxvYyBpcyBub3QgYXZhaWxhYmxlIGluIHRoZSBzeXN0ZW0K
IyBsaWJyYXJ5IHBhdGggKEV4YW1wbGU6IC91c3IvbG9jYWwvbGliLykuIFVzdWFsbHkgIm1ha2Ug
aW5zdGFsbCIgd2lsbCBkbyB0aGUgcmlnaHQgdGhpbmcuCiMgZXhwb3J0IExEX0xJQlJBUllfUEFU
SD08SkVNQUxMT0NfSE9NRT4vbGliLwojIEpWTV9PUFRTPSItRGphdmEubGlicmFyeS5wYXRoPTxK
RU1BTExPQ19IT01FPi9saWIvIgoKIyB1bmNvbW1lbnQgdG8gaGF2ZSBDYXNzYW5kcmEgSlZNIGxp
c3RlbiBmb3IgcmVtb3RlIGRlYnVnZ2Vycy9wcm9maWxlcnMgb24gcG9ydCAxNDE0CiMgSlZNX09Q
VFM9IiRKVk1fT1BUUyAtWGRlYnVnIC1Ybm9hZ2VudCAtWHJ1bmpkd3A6dHJhbnNwb3J0PWR0X3Nv
Y2tldCxzZXJ2ZXI9eSxzdXNwZW5kPW4sYWRkcmVzcz0xNDE0IgoKIyBQcmVmZXIgYmluZGluZyB0
byBJUHY0IG5ldHdvcmsgaW50ZWZhY2VzICh3aGVuIG5ldC5pcHY2LmJpbmR2Nm9ubHk9MSkuIFNl
ZQojIGh0dHA6Ly9idWdzLnN1bi5jb20vYnVnZGF0YWJhc2Uvdmlld19idWcuZG8/YnVnX2lkPTYz
NDI1NjEgKHNob3J0IHZlcnNpb246CiMgY29tbWVudCBvdXQgdGhpcyBlbnRyeSB0byBlbmFibGUg
SVB2NiBzdXBwb3J0KS4KSlZNX09QVFM9IiRKVk1fT1BUUyAtRGphdmEubmV0LnByZWZlcklQdjRT
dGFjaz10cnVlIgoKIyBqbXg6IG1ldHJpY3MgYW5kIGFkbWluaXN0cmF0aW9uIGludGVyZmFjZQoj
CiMgYWRkIHRoaXMgaWYgeW91J3JlIGhhdmluZyB0cm91YmxlIGNvbm5lY3Rpbmc6CiMgSlZNX09Q
VFM9IiRKVk1fT1BUUyAtRGphdmEucm1pLnNlcnZlci5ob3N0bmFtZT08cHVibGljIG5hbWU+Igoj
CiMgc2VlCiMgaHR0cHM6Ly9ibG9ncy5vcmFjbGUuY29tL2pteGV0Yy9lbnRyeS90cm91Ymxlc2hv
b3RpbmdfY29ubmVjdGlvbl9wcm9ibGVtc19pbl9qY29uc29sZQojIGZvciBtb3JlIG9uIGNvbmZp
Z3VyaW5nIEpNWCB0aHJvdWdoIGZpcmV3YWxscywgZXRjLiAoU2hvcnQgdmVyc2lvbjoKIyBnZXQg
aXQgd29ya2luZyB3aXRoIG5vIGZpcmV3YWxsIGZpcnN0LikKSlZNX09QVFM9IiRKVk1fT1BUUyAt
RGNvbS5zdW4ubWFuYWdlbWVudC5qbXhyZW1vdGUucG9ydD0kSk1YX1BPUlQiCkpWTV9PUFRTPSIk
SlZNX09QVFMgLURjb20uc3VuLm1hbmFnZW1lbnQuam14cmVtb3RlLnNzbD1mYWxzZSIKSlZNX09Q
VFM9IiRKVk1fT1BUUyAtRGNvbS5zdW4ubWFuYWdlbWVudC5qbXhyZW1vdGUuYXV0aGVudGljYXRl
PWZhbHNlIgpKVk1fT1BUUz0iJEpWTV9PUFRTICRKVk1fRVhUUkFfT1BUUyIKCiMgQWRkaXRpb25z
CkpWTV9PUFRTPSIkSlZNX09QVFMgLVhYOitBZ2dyZXNzaXZlT3B0cyIKSlZNX09QVFM9IiRKVk1f
T1BUUyAtWFg6TWF4RGlyZWN0TWVtb3J5U2l6ZT01ZyIKI0pWTV9PUFRTPSIkSlZNX09QVFMgLVhY
OitVc2VMYXJnZVBhZ2VzIgpKVk1fT1BUUz0iJEpWTV9PUFRTIC1YWDpUYXJnZXRTdXJ2aXZvclJh
dGlvPTUwIgpKVk1fT1BUUz0iJEpWTV9PUFRTIC1EamF2YS5ybWkuc2VydmVyLmhvc3RuYW1lPTEy
Ny4wLjAuMSIK
--001a1135dfa2ccf3060533af741b
Content-Type: application/octet-stream; name="cassandra.yaml"
Content-Disposition: attachment; filename="cassandra.yaml"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ion8rby52

CiMgU2VlIGh0dHA6Ly93aWtpLmFwYWNoZS5vcmcvY2Fzc2FuZHJhL1N0b3JhZ2VDb25maWd1cmF0
aW9uCmNsdXN0ZXJfbmFtZTogJ0hvc3RDYXMnCm51bV90b2tlbnM6IDI1NgpoaW50ZWRfaGFuZG9m
Zl9lbmFibGVkOiB0cnVlCm1heF9oaW50X3dpbmRvd19pbl9tczogMTA4MDAwMDAgIyAzIGhvdXJz
CmhpbnRlZF9oYW5kb2ZmX3Rocm90dGxlX2luX2tiOiAxMDI0Cm1heF9oaW50c19kZWxpdmVyeV90
aHJlYWRzOiAyCmF1dGhlbnRpY2F0b3I6IEFsbG93QWxsQXV0aGVudGljYXRvcgphdXRob3JpemVy
OiBBbGxvd0FsbEF1dGhvcml6ZXIKcGVybWlzc2lvbnNfdmFsaWRpdHlfaW5fbXM6IDIwMDAKcGFy
dGl0aW9uZXI6IG9yZy5hcGFjaGUuY2Fzc2FuZHJhLmRodC5NdXJtdXIzUGFydGl0aW9uZXIKZGF0
YV9maWxlX2RpcmVjdG9yaWVzOgogICAgLSAvaHVnZXRtcGZzL2Nhc3NhbmRyYQpjb21taXRsb2df
ZGlyZWN0b3J5OiAvaHVnZXRtcGZzL2Nhc3NhbmRyYS9jb21taXRsb2cKZGlza19mYWlsdXJlX3Bv
bGljeTogc3RvcAprZXlfY2FjaGVfc2l6ZV9pbl9tYjoKa2V5X2NhY2hlX3NhdmVfcGVyaW9kOiAx
NDQwMApyb3dfY2FjaGVfc2l6ZV9pbl9tYjogMApyb3dfY2FjaGVfc2F2ZV9wZXJpb2Q6IDAKc2F2
ZWRfY2FjaGVzX2RpcmVjdG9yeTogL2h1Z2V0bXBmcy9jYXNzYW5kcmEvc2F2ZWRfY2FjaGVzCmNv
bW1pdGxvZ19zeW5jOiBwZXJpb2RpYwpjb21taXRsb2dfc3luY19wZXJpb2RfaW5fbXM6IDEwMDAw
CmNvbW1pdGxvZ19zZWdtZW50X3NpemVfaW5fbWI6IDMyCnNlZWRfcHJvdmlkZXI6CiAgICAtIGNs
YXNzX25hbWU6IG9yZy5hcGFjaGUuY2Fzc2FuZHJhLmxvY2F0b3IuU2ltcGxlU2VlZFByb3ZpZGVy
CiAgICAgIHBhcmFtZXRlcnM6CiAgICAgICAgICAtIHNlZWRzOiAiMTI3LjAuMC4xIgpjb25jdXJy
ZW50X3JlYWRzOiAzMgojIHNob3VsZCBiZSBudW1fY3B1cyAqIDgKY29uY3VycmVudF93cml0ZXM6
IDY0CmNvbW1pdGxvZ190b3RhbF9zcGFjZV9pbl9tYjogNDA5NgptZW10YWJsZV9mbHVzaF93cml0
ZXJzOiA0Cm1lbXRhYmxlX2ZsdXNoX3F1ZXVlX3NpemU6IDQKdHJpY2tsZV9mc3luYzogdHJ1ZQp0
cmlja2xlX2ZzeW5jX2ludGVydmFsX2luX2tiOiAxMDI0MApzdG9yYWdlX3BvcnQ6IDcwMDAKc3Ns
X3N0b3JhZ2VfcG9ydDogNzAwMQpsaXN0ZW5fYWRkcmVzczogMTI3LjAuMC4xIApzdGFydF9uYXRp
dmVfdHJhbnNwb3J0OiB0cnVlCm5hdGl2ZV90cmFuc3BvcnRfcG9ydDogOTA0MgpzdGFydF9ycGM6
IHRydWUKcnBjX2FkZHJlc3M6IDEyNy4wLjAuMQpycGNfcG9ydDogOTE2MApycGNfa2VlcGFsaXZl
OiB0cnVlCnJwY19zZXJ2ZXJfdHlwZTogc3luYwp0aHJpZnRfZnJhbWVkX3RyYW5zcG9ydF9zaXpl
X2luX21iOiAxNQppbmNyZW1lbnRhbF9iYWNrdXBzOiBmYWxzZQpzbmFwc2hvdF9iZWZvcmVfY29t
cGFjdGlvbjogZmFsc2UKYXV0b19zbmFwc2hvdDogdHJ1ZQpjb2x1bW5faW5kZXhfc2l6ZV9pbl9r
YjogNjQKaW5fbWVtb3J5X2NvbXBhY3Rpb25fbGltaXRfaW5fbWI6IDY0Cm11bHRpdGhyZWFkZWRf
Y29tcGFjdGlvbjogZmFsc2UKY29tcGFjdGlvbl90aHJvdWdocHV0X21iX3Blcl9zZWM6IDE2CmNv
bXBhY3Rpb25fcHJlaGVhdF9rZXlfY2FjaGU6IHRydWUKcmVhZF9yZXF1ZXN0X3RpbWVvdXRfaW5f
bXM6IDEwMDAwCnJhbmdlX3JlcXVlc3RfdGltZW91dF9pbl9tczogMTAwMDAKd3JpdGVfcmVxdWVz
dF90aW1lb3V0X2luX21zOiAxMDAwMApjYXNfY29udGVudGlvbl90aW1lb3V0X2luX21zOiAxMDAw
CnRydW5jYXRlX3JlcXVlc3RfdGltZW91dF9pbl9tczogNjAwMDAKcmVxdWVzdF90aW1lb3V0X2lu
X21zOiAxMDAwMApjcm9zc19ub2RlX3RpbWVvdXQ6IGZhbHNlCmVuZHBvaW50X3NuaXRjaDogU2lt
cGxlU25pdGNoCmR5bmFtaWNfc25pdGNoX3VwZGF0ZV9pbnRlcnZhbF9pbl9tczogMTAwCmR5bmFt
aWNfc25pdGNoX3Jlc2V0X2ludGVydmFsX2luX21zOiA2MDAwMDAKZHluYW1pY19zbml0Y2hfYmFk
bmVzc190aHJlc2hvbGQ6IDAuMQpyZXF1ZXN0X3NjaGVkdWxlcjogb3JnLmFwYWNoZS5jYXNzYW5k
cmEuc2NoZWR1bGVyLk5vU2NoZWR1bGVyCnNlcnZlcl9lbmNyeXB0aW9uX29wdGlvbnM6CiAgICBp
bnRlcm5vZGVfZW5jcnlwdGlvbjogbm9uZQogICAga2V5c3RvcmU6IGNvbmYvLmtleXN0b3JlCiAg
ICBrZXlzdG9yZV9wYXNzd29yZDogY2Fzc2FuZHJhCiAgICB0cnVzdHN0b3JlOiBjb25mLy50cnVz
dHN0b3JlCiAgICB0cnVzdHN0b3JlX3Bhc3N3b3JkOiBjYXNzYW5kcmEKY2xpZW50X2VuY3J5cHRp
b25fb3B0aW9uczoKICAgIGVuYWJsZWQ6IGZhbHNlCiAgICBrZXlzdG9yZTogY29uZi8ua2V5c3Rv
cmUKICAgIGtleXN0b3JlX3Bhc3N3b3JkOiBjYXNzYW5kcmEKaW50ZXJub2RlX2NvbXByZXNzaW9u
OiBhbGwKaW50ZXJfZGNfdGNwX25vZGVsYXk6IGZhbHNlCnByZWhlYXRfa2VybmVsX3BhZ2VfY2Fj
aGU6IGZhbHNlCgo=
--001a1135dfa2ccf3060533af741b
Content-Type: application/octet-stream; name="create-ycsb-table.cql.j2"
Content-Disposition: attachment; filename="create-ycsb-table.cql.j2"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ion8rby93

eyMgQ29weXJpZ2h0IDIwMTUgUGVyZktpdEJlbmNobWFya2VyIEF1dGhvcnMuIEFsbCByaWdodHMg
cmVzZXJ2ZWQuCiAjCiAjIExpY2Vuc2VkIHVuZGVyIHRoZSBBcGFjaGUgTGljZW5zZSwgVmVyc2lv
biAyLjAgKHRoZSAiTGljZW5zZSIpOwogIyB5b3UgbWF5IG5vdCB1c2UgdGhpcyBmaWxlIGV4Y2Vw
dCBpbiBjb21wbGlhbmNlIHdpdGggdGhlIExpY2Vuc2UuCiAjIFlvdSBtYXkgb2J0YWluIGEgY29w
eSBvZiB0aGUgTGljZW5zZSBhdAogIwogIyAgIGh0dHA6Ly93d3cuYXBhY2hlLm9yZy9saWNlbnNl
cy9MSUNFTlNFLTIuMAogIwogIyBVbmxlc3MgcmVxdWlyZWQgYnkgYXBwbGljYWJsZSBsYXcgb3Ig
YWdyZWVkIHRvIGluIHdyaXRpbmcsIHNvZnR3YXJlCiAjIGRpc3RyaWJ1dGVkIHVuZGVyIHRoZSBM
aWNlbnNlIGlzIGRpc3RyaWJ1dGVkIG9uIGFuICJBUyBJUyIgQkFTSVMsCiAjIFdJVEhPVVQgV0FS
UkFOVElFUyBPUiBDT05ESVRJT05TIE9GIEFOWSBLSU5ELCBlaXRoZXIgZXhwcmVzcyBvciBpbXBs
aWVkLgogIyBTZWUgdGhlIExpY2Vuc2UgZm9yIHRoZSBzcGVjaWZpYyBsYW5ndWFnZSBnb3Zlcm5p
bmcgcGVybWlzc2lvbnMgYW5kCiAjIGxpbWl0YXRpb25zIHVuZGVyIHRoZSBMaWNlbnNlLiAjfQp7
IyBDcmVhdGUgYSB0YWJsZSBmb3IgWUNTQiBiZW5jaG1hcmsuICN9CmNyZWF0ZSBrZXlzcGFjZSB7
eyBrZXlzcGFjZSB9fQogIHdpdGggcGxhY2VtZW50X3N0cmF0ZWd5ID0gJ1NpbXBsZVN0cmF0ZWd5
JwogIGFuZCBzdHJhdGVneV9vcHRpb25zID0ge3JlcGxpY2F0aW9uX2ZhY3Rvcjoge3sgcmVwbGlj
YXRpb25fZmFjdG9yIH19IH07Cgp1c2Uge3sga2V5c3BhY2UgfX07CgpjcmVhdGUgY29sdW1uIGZh
bWlseSB7eyBjb2x1bW5fZmFtaWx5IH19Owo=
--001a1135dfa2ccf3060533af741b
Content-Type: application/octet-stream; name="log4j-server.properties"
Content-Disposition: attachment; filename="log4j-server.properties"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ion8rbyd4

IyBMaWNlbnNlZCB0byB0aGUgQXBhY2hlIFNvZnR3YXJlIEZvdW5kYXRpb24gKEFTRikgdW5kZXIg
b25lCiMgb3IgbW9yZSBjb250cmlidXRvciBsaWNlbnNlIGFncmVlbWVudHMuICBTZWUgdGhlIE5P
VElDRSBmaWxlCiMgZGlzdHJpYnV0ZWQgd2l0aCB0aGlzIHdvcmsgZm9yIGFkZGl0aW9uYWwgaW5m
b3JtYXRpb24KIyByZWdhcmRpbmcgY29weXJpZ2h0IG93bmVyc2hpcC4gIFRoZSBBU0YgbGljZW5z
ZXMgdGhpcyBmaWxlCiMgdG8geW91IHVuZGVyIHRoZSBBcGFjaGUgTGljZW5zZSwgVmVyc2lvbiAy
LjAgKHRoZQojICJMaWNlbnNlIik7IHlvdSBtYXkgbm90IHVzZSB0aGlzIGZpbGUgZXhjZXB0IGlu
IGNvbXBsaWFuY2UKIyB3aXRoIHRoZSBMaWNlbnNlLiAgWW91IG1heSBvYnRhaW4gYSBjb3B5IG9m
IHRoZSBMaWNlbnNlIGF0CiMKIyAgICAgaHR0cDovL3d3dy5hcGFjaGUub3JnL2xpY2Vuc2VzL0xJ
Q0VOU0UtMi4wCiMKIyBVbmxlc3MgcmVxdWlyZWQgYnkgYXBwbGljYWJsZSBsYXcgb3IgYWdyZWVk
IHRvIGluIHdyaXRpbmcsIHNvZnR3YXJlCiMgZGlzdHJpYnV0ZWQgdW5kZXIgdGhlIExpY2Vuc2Ug
aXMgZGlzdHJpYnV0ZWQgb24gYW4gIkFTIElTIiBCQVNJUywKIyBXSVRIT1VUIFdBUlJBTlRJRVMg
T1IgQ09ORElUSU9OUyBPRiBBTlkgS0lORCwgZWl0aGVyIGV4cHJlc3Mgb3IgaW1wbGllZC4KIyBT
ZWUgdGhlIExpY2Vuc2UgZm9yIHRoZSBzcGVjaWZpYyBsYW5ndWFnZSBnb3Zlcm5pbmcgcGVybWlz
c2lvbnMgYW5kCiMgbGltaXRhdGlvbnMgdW5kZXIgdGhlIExpY2Vuc2UuCgojIGZvciBwcm9kdWN0
aW9uLCB5b3Ugc2hvdWxkIHByb2JhYmx5IHNldCBwYXR0ZXJuIHRvICVjIGluc3RlYWQgb2YgJWwu
ICAKIyAoJWwgaXMgc2xvd2VyLikKCiMgb3V0cHV0IG1lc3NhZ2VzIGludG8gYSByb2xsaW5nIGxv
ZyBmaWxlIGFzIHdlbGwgYXMgc3Rkb3V0CmxvZzRqLnJvb3RMb2dnZXI9SU5GTyxzdGRvdXQsUgoK
IyBzdGRvdXQKbG9nNGouYXBwZW5kZXIuc3Rkb3V0PW9yZy5hcGFjaGUubG9nNGouQ29uc29sZUFw
cGVuZGVyCmxvZzRqLmFwcGVuZGVyLnN0ZG91dC5sYXlvdXQ9b3JnLmFwYWNoZS5sb2c0ai5QYXR0
ZXJuTGF5b3V0CmxvZzRqLmFwcGVuZGVyLnN0ZG91dC5sYXlvdXQuQ29udmVyc2lvblBhdHRlcm49
JTVwICVke0hIOm1tOnNzLFNTU30gJW0lbgoKIyByb2xsaW5nIGxvZyBmaWxlCmxvZzRqLmFwcGVu
ZGVyLlI9b3JnLmFwYWNoZS5sb2c0ai5Sb2xsaW5nRmlsZUFwcGVuZGVyCmxvZzRqLmFwcGVuZGVy
LlIubWF4RmlsZVNpemU9MjBNQgpsb2c0ai5hcHBlbmRlci5SLm1heEJhY2t1cEluZGV4PTUwCmxv
ZzRqLmFwcGVuZGVyLlIubGF5b3V0PW9yZy5hcGFjaGUubG9nNGouUGF0dGVybkxheW91dApsb2c0
ai5hcHBlbmRlci5SLmxheW91dC5Db252ZXJzaW9uUGF0dGVybj0lNXAgWyV0XSAlZHtJU084NjAx
fSAlRiAobGluZSAlTCkgJW0lbgojIEVkaXQgdGhlIG5leHQgbGluZSB0byBwb2ludCB0byB5b3Vy
IGxvZ3MgZGlyZWN0b3J5CmxvZzRqLmFwcGVuZGVyLlIuRmlsZT0vaHVnZXRtcGZzL2Nhc3NhbmRy
YS9sb2dzL3N5c3RlbS5sb2cKCiMgQXBwbGljYXRpb24gbG9nZ2luZyBvcHRpb25zCiNsb2c0ai5s
b2dnZXIub3JnLmFwYWNoZS5jYXNzYW5kcmE9REVCVUcKI2xvZzRqLmxvZ2dlci5vcmcuYXBhY2hl
LmNhc3NhbmRyYS5kYj1ERUJVRwojbG9nNGoubG9nZ2VyLm9yZy5hcGFjaGUuY2Fzc2FuZHJhLnNl
cnZpY2UuU3RvcmFnZVByb3h5PURFQlVHCgojIEFkZGluZyB0aGlzIHRvIGF2b2lkIHRocmlmdCBs
b2dnaW5nIGRpc2Nvbm5lY3QgZXJyb3JzLgpsb2c0ai5sb2dnZXIub3JnLmFwYWNoZS50aHJpZnQu
c2VydmVyLlROb25ibG9ja2luZ1NlcnZlcj1FUlJPUgoK
--001a1135dfa2ccf3060533af741b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

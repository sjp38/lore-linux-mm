Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 166F46B0034
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:30 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/39] Transparent huge page cache
Date: Sun, 12 May 2013 04:22:57 +0300
Message-Id: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's version 4. You can also use git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git

branch thp/pagecache.

If you want to check changes since v3 you can look at diff between tags
thp/pagecache/v3 and thp/pagecache/v4-prerebase.

Intro
-----

The goal of the project is preparing kernel infrastructure to handle huge
pages in page cache.

To proof that the proposed changes are functional we enable the feature
for the most simple file system -- ramfs. ramfs is not that useful by
itself, but it's good pilot project. It provides information on what
performance boost we should expect on other files systems.

Design overview
---------------

Every huge page is represented in page cache radix-tree by HPAGE_PMD_NR
(512 on x86-64) entries: one entry for head page and HPAGE_PMD_NR-1 entries
for tail pages.

Radix tree manipulations are implemented in batched way: we add and remove
whole huge page at once, under one tree_lock. To make it possible, we
extended radix-tree interface to be able to pre-allocate memory enough to
insert a number of *contiguous* elements (kudos to Matthew Wilcox).

Huge pages can be added to page cache two ways: write(2) to file or page
fault sparse file. Potentially, third way is collapsing small page, but
it's outside initial implementation.

[ While preparing the patchset I've found one more place where we could
  alocate huge page: read(2) on sparse file. With current code we will get
  4k pages. It's okay, but not optimal. Will be fixed later. ]

File systems are decision makers on allocation huge or small pages: they
should have better visibility if it's useful in every particular case.

For write(2) the decision point is mapping_ops->write_begin(). For ramfs
it's simple_write_begin.

For page fault, it's vm_ops->fault(): mm core will call ->fault() with
FAULT_FLAG_TRANSHUGE if huge page is appropriate. ->fault can return
VM_FAULT_FALLBACK if it wants small page instead. For ramfs ->fault() is
filemap_fault().

Performance
-----------

Numbers I posted with v3 were too good to be true. I forgot to
disable debug options in kernel config :-P

The test machine is 4s Westmere - 4x10 cores + HT.

I've used IOzone for benchmarking. Base command is:

iozone -s 8g/$threads -t $threads -r 4 -i 0 -i 1 -i 2 -i 3

Units are KB/s. I've used "Children see throughput" field from iozone
report.

Using mmap (-B option):

** Initial writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1444052    3010882    6055090   11746060   14404889   25109004   28310733   29044218   29619191   29618651   29514987   29348440   29315639   29326998   29410809
patched:	    2207350    4707001    9642674   18356751   21399813   27011674   26775610   24088924   18549342   15453297   13876530   13358992   13166737   13095453   13111227
speed-up(times):       1.53       1.56       1.59       1.56       1.49       1.08       0.95       0.83       0.63       0.52       0.47       0.46       0.45       0.45       0.45

** Rewriters **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    2012192    3941325    7179208   13093224   13978721   19120624   14938912   16672082   16430882   14384357   12311291   16421748   13485785   10642142   11461610
patched:	    3106380    5822011   11657398   17109111   15498272   18507004   16960717   14877209   17498172   15317104   15470030   19190455   14758974    9242583   10548081
speed-up(times):       1.54       1.48       1.62       1.31       1.11       0.97       1.14       0.89       1.06       1.06       1.26       1.17       1.09       0.87       0.92

** Readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1541551    3301643    5624206   11672717   16145085   27885416   38730976   42438132   47526802   48077097   47126201   45950491   45108567   45011088   46310317
patched:	    1800898    3582243    8062851   14418948   17587027   34938636   46653133   46561002   50396044   49525385   47731629   46594399   46424568   45357496   45258561
speed-up(times):       1.17       1.08       1.43       1.24       1.09       1.25       1.20       1.10       1.06       1.03       1.01       1.01       1.03       1.01       0.98

** Re-readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1407462    3022304    5944814   12290200   15700871   27452022   38785250   45720460   47958008   48616065   47805237   45933767   45139644   44752527   45324330
patched:	    1880030    4265188    7406094   15220592   19781387   33994635   43689297   47557123   51175499   50607686   48695647   46799726   46250685   46108964   45180965
speed-up(times):       1.34       1.41       1.25       1.24       1.26       1.24       1.13       1.04       1.07       1.04       1.02       1.02       1.02       1.03       1.00

** Reverse readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1790475    3547606    6639853   14323339   17029576   30420579   39954056   44082873   45397731   45956797   46861276   46149824   44356709   43789684   44961204
patched:	    1848356    3470499    7270728   15685450   19329038   33186403   43574373   48972628   47398951   48588366   48233477   46959725   46383543   43998385   45272745
speed-up(times):       1.03       0.98       1.10       1.10       1.14       1.09       1.09       1.11       1.04       1.06       1.03       1.02       1.05       1.00       1.01

** Random_readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1098140    2549558    4625359    9248630   11764863   22648276   32809857   37617500   39028665   41283083   41886214   44448720   43535904   43481063   44041363
patched:	    1893732    4034810    8218138   15051324   24400039   35208044   41339655   48233519   51046118   47613022   46427129   45893974   45190367   45158010   45944107
speed-up(times):       1.72       1.58       1.78       1.63       2.07       1.55       1.26       1.28       1.31       1.15       1.11       1.03       1.04       1.04       1.04

** Random_writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1366232    2863721    5714268   10615938   12711800   18768227   19430964   19895410   19108420   19666818   19189895   19666578   18953431   18712664   18676119
patched:	    3308906    6093588   11885456   21035728   21744093   21940402   20155000   20800063   21107088   20821950   21369886   21324576   21019851   20418478   20547713
speed-up(times):       2.42       2.13       2.08       1.98       1.71       1.17       1.04       1.05       1.10       1.06       1.11       1.08       1.11       1.09       1.10

****************************

Using syscall (no -B option):

** Initial writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1786744    3693529    7600563   14594702   17645248   26197482   28938801   29700591   29858369   29831816   29730708   29606829   29621126   29538778   29589533
patched:	    1817240    3732281    7598178   14578689   17824204   27186214   29552434   26634121   22304410   18631185   16485981   15801835   15590995   15514384   15483872
speed-up(times):       1.02       1.01       1.00       1.00       1.01       1.04       1.02       0.90       0.75       0.62       0.55       0.53       0.53       0.53       0.52

** Rewriters **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    2025119    3891368    8662423   14477011   17815278   20618509   18330301   14184305   14421901   12488145   12329534   12285723   12049399   12101321   12017546
patched:	    2071648    4106464    8915170   15475594   18461212   23360704   25107019   26244308   26634094   27680123   27342845   27006682   26239505   25881556   26030227
speed-up(times):       1.02       1.06       1.03       1.07       1.04       1.13       1.37       1.85       1.85       2.22       2.22       2.20       2.18       2.14       2.17

** Readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    2414037    5609352    9326943   20594508   22135032   37437276   35593047   41574568   45919334   45903379   45680066   45703659   42766312   42265067   44491712
patched:	    2388758    4573606    9867239   18485205   22269461   36172618   46830113   45828302   45974984   48244870   45334303   45395237   44213071   44418922   44881804
speed-up(times):       0.99       0.82       1.06       0.90       1.01       0.97       1.32       1.10       1.00       1.05       0.99       0.99       1.03       1.05       1.01

** Re-readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    2410474    5006316    9620458   19420701   24929010   37301471   37897701   48067032   46620958   44619322   45474645   45627080   38448032   44844358   44529239
patched:	    2210495    4588974    9330074   18237863   23200139   36691762   43412170   48349035   46607100   47318490   45429944   45285141   44631543   44601157   44913130
speed-up(times):       0.92       0.92       0.97       0.94       0.93       0.98       1.15       1.01       1.00       1.06       1.00       0.99       1.16       0.99       1.01

** Reverse readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    2383446    4633256    9572545   18500373   21489130   36958118   31747157   39855519   31440942   32131944   37714689   42428280   17402480   14893057   16207342
patched:	    2240576    4847211    8373112   17181179   20205163   35186361   42922118   45388409   46244837   47153867   45257508   45476325   43479030   43613958   43296206
speed-up(times):       0.94       1.05       0.87       0.93       0.94       0.95       1.35       1.14       1.47       1.47       1.20       1.07       2.50       2.93       2.67

** Random_readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1821175    3575869    8742168   13764493   20136443   30901949   37823254   43994032   41037782   43925224   41853227   42095250   39393426   33851319   41424361
patched:	    1458968    3169634    6244046   12271864   15474602   29337377   35430875   39734695   41587609   42676631   42077827   41473062   40933033   40944148   41846858
speed-up(times):       0.80       0.89       0.71       0.89       0.77       0.95       0.94       0.90       1.01       0.97       1.01       0.99       1.04       1.21       1.01

** Random_writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80        120        160        200
baseline:	    1556393    3063377    6014016   12199163   16187258   24737005   27293400   27678633   26549637   26963066   26202907   26090764   26159003   25842459   26009927
patched:	    1642937    3461512    6405111   12425923   16990495   25404113   27340882   27467380   27057498   27297246   26627644   26733315   26624258   26787503   26603172
speed-up(times):       1.06       1.13       1.07       1.02       1.05       1.03       1.00       0.99       1.02       1.01       1.02       1.02       1.02       1.04       1.02

I haven't yet analyzed why it behaves poorly on high number of processes,
but I will.

Changelog
---------

v4:
 - Drop RFC tag;
 - Consolidate code thp and non-thp code (net diff to v3 is -177 lines);
 - Compile time and sysfs knob for the feature;
 - Rework zone_stat for huge pages;
 - x86-64 only for now;
 - ...
v3:
 - set RADIX_TREE_PRELOAD_NR to 512 only if we build with THP;
 - rewrite lru_add_page_tail() to address few bags;
 - memcg accounting;
 - represent file thp pages in meminfo and friends;
 - dump page order in filemap trace;
 - add missed flush_dcache_page() in zero_huge_user_segment;
 - random cleanups based on feedback.
v2:
 - mmap();
 - fix add_to_page_cache_locked() and delete_from_page_cache();
 - introduce mapping_can_have_hugepages();
 - call split_huge_page() only for head page in filemap_fault();
 - wait_split_huge_page(): serialize over i_mmap_mutex too;
 - lru_add_page_tail: avoid PageUnevictable on active/inactive lru lists;
 - fix off-by-one in zero_huge_user_segment();
 - THP_WRITE_ALLOC/THP_WRITE_FAILED counters;

Kirill A. Shutemov (39):
  mm: drop actor argument of do_generic_file_read()
  block: implement add_bdi_stat()
  mm: implement zero_huge_user_segment and friends
  radix-tree: implement preload for multiple contiguous elements
  memcg, thp: charge huge cache pages
  thp, mm: avoid PageUnevictable on active/inactive lru lists
  thp, mm: basic defines for transparent huge page cache
  thp: compile-time and sysfs knob for thp pagecache
  thp, mm: introduce mapping_can_have_hugepages() predicate
  thp: account anon transparent huge pages into NR_ANON_PAGES
  thp: represent file thp pages in meminfo and friends
  thp, mm: rewrite add_to_page_cache_locked() to support huge pages
  mm: trace filemap: dump page order
  thp, mm: rewrite delete_from_page_cache() to support huge pages
  thp, mm: trigger bug in replace_page_cache_page() on THP
  thp, mm: locking tail page is a bug
  thp, mm: handle tail pages in page_cache_get_speculative()
  thp, mm: add event counters for huge page alloc on write to a file
  thp, mm: allocate huge pages in grab_cache_page_write_begin()
  thp, mm: naive support of thp in generic read/write routines
  thp, libfs: initial support of thp in
    simple_read/write_begin/write_end
  thp: handle file pages in split_huge_page()
  thp: wait_split_huge_page(): serialize over i_mmap_mutex too
  thp, mm: truncate support for transparent huge page cache
  thp, mm: split huge page on mmap file page
  ramfs: enable transparent huge page cache
  x86-64, mm: proper alignment mappings with hugepages
  thp: prepare zap_huge_pmd() to uncharge file pages
  thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
  thp: do_huge_pmd_anonymous_page() cleanup
  thp: consolidate code between handle_mm_fault() and
    do_huge_pmd_anonymous_page()
  mm: cleanup __do_fault() implementation
  thp, mm: implement do_huge_linear_fault()
  thp, mm: handle huge pages in filemap_fault()
  mm: decomposite do_wp_page() and get rid of some 'goto' logic
  mm: do_wp_page(): extract VM_WRITE|VM_SHARED case to separate
    function
  thp: handle write-protect exception to file-backed huge pages
  thp: vma_adjust_trans_huge(): adjust file-backed VMA too
  thp: map file-backed huge pages on fault

 arch/x86/kernel/sys_x86_64.c   |   12 +-
 drivers/base/node.c            |   10 +-
 fs/libfs.c                     |   50 +++-
 fs/proc/meminfo.c              |    9 +-
 fs/ramfs/inode.c               |    6 +-
 include/linux/backing-dev.h    |   10 +
 include/linux/fs.h             |    1 +
 include/linux/huge_mm.h        |   92 +++++--
 include/linux/mm.h             |   19 +-
 include/linux/mmzone.h         |    1 +
 include/linux/pagemap.h        |   33 ++-
 include/linux/radix-tree.h     |   11 +
 include/linux/vm_event_item.h  |    2 +
 include/trace/events/filemap.h |    7 +-
 lib/radix-tree.c               |   33 ++-
 mm/Kconfig                     |   10 +
 mm/filemap.c                   |  216 +++++++++++----
 mm/huge_memory.c               |  257 +++++++++--------
 mm/memcontrol.c                |    2 -
 mm/memory.c                    |  597 ++++++++++++++++++++++++++--------------
 mm/rmap.c                      |   18 +-
 mm/swap.c                      |   20 +-
 mm/truncate.c                  |   13 +
 mm/vmstat.c                    |    3 +
 24 files changed, 988 insertions(+), 444 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

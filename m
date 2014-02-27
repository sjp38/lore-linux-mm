Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6D10E6B0074
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:54:18 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1194906pbb.26
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 11:54:18 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id hh1si294985pac.303.2014.02.27.11.54.16
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 11:54:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/2] mm: map few pages around fault address if they are in page cache
Date: Thu, 27 Feb 2014 21:53:45 +0200
Message-Id: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's new version of faultaround patchset. It took a while to tune it and
collect performance data.

First patch adds new callback ->map_pages to vm_operations_struct.

->map_pages() is called when VM asks to map easy accessible pages.
Filesystem should find and map pages associated with offsets from "pgoff"
till "max_pgoff". ->map_pages() is called with page table locked and must
not block.  If it's not possible to reach a page without blocking,
filesystem should skip it. Filesystem should use do_set_pte() to setup
page table entry. Pointer to entry associated with offset "pgoff" is
passed in "pte" field in vm_fault structure. Pointers to entries for other
offsets should be calculated relative to "pte".

Currently VM use ->map_pages only on read page fault path. We try to map
FAULT_AROUND_PAGES a time. FAULT_AROUND_PAGES is 16 for now. Performance
data for different FAULT_AROUND_ORDER is below.

TODO:
 - implement ->map_pages() for shmem/tmpfs;
 - modify get_user_pages() to be able to use ->map_pages() and implement
   mmap(MAP_POPULATE|MAP_NONBLOCK) on top.

Please consider applying.

=========================================================================
Tested on 4-socket machine (120 threads) with 128GiB of RAM.

Few real-world workloads. The sweet spot for FAULT_AROUND_ORDER here is
somewhere between 3 and 5. Let's say 4 :)

Linux build (make -j60)
FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
	minor-faults		283,301,572	247,151,987	212,215,789	204,772,882	199,568,944	194,703,779	193,381,485
	time, seconds		151.227629483	153.920996480	151.356125472	150.863792049	150.879207877	151.150764954	151.450962358
Linux rebuild (make -j60)
FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
	minor-faults		5,396,854	4,148,444	2,855,286	2,577,282	2,361,957	2,169,573	2,112,643
	time, seconds		27.404543757	27.559725591	27.030057426	26.855045126	26.678618635	26.974523490	26.761320095
Git test suite (make -j60 test)
FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
	minor-faults		129,591,823	99,200,751	66,106,718	57,606,410	51,510,808	45,776,813	44,085,515
	time, seconds		66.087215026	64.784546905	64.401156567	65.282708668	66.034016829	66.793780811	67.237810413

Two synthetic tests: access every word in file in sequential/random order.
It doesn't improve much after FAULT_AROUND_ORDER == 4.

Sequential access 16GiB file
FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
 1 thread
	minor-faults		4,195,437	2,098,275	525,068		262,251		131,170		32,856		8,282
	time, seconds		7.250461742	6.461711074	5.493859139	5.488488147	5.707213983	5.898510832	5.109232856
 8 threads
	minor-faults		33,557,540	16,892,728	4,515,848	2,366,999	1,423,382	442,732		142,339
	time, seconds		16.649304881	9.312555263	6.612490639	6.394316732	6.669827501	6.75078944	6.371900528
 32 threads
	minor-faults		134,228,222	67,526,810	17,725,386	9,716,537	4,763,731	1,668,921	537,200
	time, seconds		49.164430543	29.712060103	12.938649729	10.175151004	11.840094583	9.594081325	9.928461797
 60 threads
	minor-faults		251,687,988	126,146,952	32,919,406	18,208,804	10,458,947	2,733,907	928,217
	time, seconds		86.260656897	49.626551828	22.335007632	17.608243696	16.523119035	16.339489186	16.326390902
 120 threads
	minor-faults		503,352,863	252,939,677	67,039,168	35,191,827	19,170,091	4,688,357	1,471,862
	time, seconds		124.589206333	79.757867787	39.508707872	32.167281632	29.972989292	28.729834575	28.042251622
Random access 1GiB file
 1 thread
	minor-faults		262,636		132,743		34,369		17,299		8,527		3,451		1,222
	time, seconds		15.351890914	16.613802482	16.569227308	15.179220992	16.557356122	16.578247824	15.365266994
 8 threads
	minor-faults		2,098,948	1,061,871	273,690		154,501		87,110		25,663		7,384
	time, seconds		15.040026343	15.096933500	14.474757288	14.289129964	14.411537468	14.296316837	14.395635804
 32 threads
	minor-faults		8,390,734	4,231,023	1,054,432	528,847		269,242		97,746		26,881
	time, seconds		20.430433109	21.585235358	22.115062928	14.872878951	14.880856305	14.883370649	14.821261690
 60 threads
	minor-faults		15,733,258	7,892,809	1,973,393	988,266		594,789		164,994		51,691
	time, seconds		26.577302548	25.692397770	18.728863715	20.153026398	21.619101933	17.745086260	17.613215273
 120 threads
	minor-faults		31,471,111	15,816,616	3,959,209	1,978,685	1,008,299	264,635		96,010
	time, seconds		41.835322703	40.459786095	36.085306105	35.313894834	35.814445675	36.552633793	34.289210594

Worst case scenario: we touch one page every 2M, so faultaround is useless
here. Just to demonstrate how much overhead we add.

Touch only one page in page table in 16GiB file
FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
 1 thread
	minor-faults		8,372		8,324		8,270		8,260		8,249		8,239		8,237
	time, seconds		0.039892712	0.045369149	0.051846126	0.063681685	0.079095975	0.17652406	0.541213386
 8 threads
	minor-faults		65,731		65,681		65,628		65,620		65,608		65,599		65,596
	time, seconds		0.124159196	0.488600638	0.156854426	0.191901957	0.242631486	0.543569456	1.677303984
 32 threads
	minor-faults		262,388		262,341		262,285		262,276		262,266		262,257		263,183
	time, seconds		0.452421421	0.488600638	0.565020946	0.648229739	0.789850823	1.651584361	5.000361559
 60 threads
	minor-faults		491,822		491,792		491,723		491,711		491,701		491,691		491,825
	time, seconds		0.763288616	0.869620515	0.980727360	1.161732354	1.466915814	3.04041448	9.308612938
 120 threads
	minor-faults		983,466		983,655		983,366		983,372		983,363		984,083		984,164
	time, seconds		1.595846553	1.667902182	2.008959376	2.425380942	2.941368804	5.977807890	18.401846125

Kirill A. Shutemov (2):
  mm: introduce vm_ops->map_pages()
  mm: implement ->map_pages for page cache

 Documentation/filesystems/Locking | 10 ++++++
 fs/9p/vfs_file.c                  |  2 ++
 fs/btrfs/file.c                   |  1 +
 fs/cifs/file.c                    |  1 +
 fs/ext4/file.c                    |  1 +
 fs/f2fs/file.c                    |  1 +
 fs/fuse/file.c                    |  1 +
 fs/gfs2/file.c                    |  1 +
 fs/nfs/file.c                     |  1 +
 fs/nilfs2/file.c                  |  1 +
 fs/ubifs/file.c                   |  1 +
 fs/xfs/xfs_file.c                 |  1 +
 include/linux/mm.h                |  9 +++++
 mm/filemap.c                      | 72 +++++++++++++++++++++++++++++++++++++++
 mm/memory.c                       | 67 ++++++++++++++++++++++++++++++++++--
 mm/nommu.c                        |  6 ++++
 16 files changed, 173 insertions(+), 3 deletions(-)

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

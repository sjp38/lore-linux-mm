From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/8] export more page flags in /proc/kpageflags (take 6)
Date: Fri, 08 May 2009 18:53:20 +0800
Message-ID: <20090508105320.316173813@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1AFF16B005A
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:12:38 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Andrew,

Can you merge this patchset? There should be no more concerns :-)
The last patch may be delayed to the hwpoison merge time.

take 6:

- show more help text in page-types
- separate out PG_hwpoison
- comment on KPF_MMAP

take 5:

- add page-types tool for querying the exported page flags.
- export all page flags unconditionally and faithfully, and offload
  complicated filtering works to the user space tool.

This patchset:

Export 10 more flags to end users (and more for kernel developers):

        11. KPF_MMAP            (pseudo flag) memory mapped page
        12. KPF_ANON            (pseudo flag) memory mapped page (anonymous)
        13. KPF_SWAPCACHE       page is in swap cache
        14. KPF_SWAPBACKED      page is swap/RAM backed
        15. KPF_COMPOUND_HEAD   (*)
        16. KPF_COMPOUND_TAIL   (*)
        17. KPF_HUGE		hugeTLB pages
        18. KPF_UNEVICTABLE     page is in the unevictable LRU list
        19. KPF_HWPOISON        hardware detected corruption
        20. KPF_NOPAGE          (pseudo flag) no page frame at the address

        (*) For compound pages, exporting _both_ head/tail info enables
            users to tell where a compound page starts/ends, and its order.

Patches:

[PATCH 1/8] mm: introduce PageHuge() for testing huge/gigantic pages
[PATCH 2/8] slob: use PG_slab for identifying SLOB pages
[PATCH 3/8] proc: kpagecount/kpageflags code cleanup
[PATCH 4/8] proc: export more page flags in /proc/kpageflags
[PATCH 5/8] pagemap: document clarifications
[PATCH 6/8] pagemap: document 9 more exported page flags
[PATCH 7/8] pagemap: add page-types tool
[PATCH 7/8] pagemap: export PG_hwpoison

 Documentation/vm/Makefile     |    2 
 Documentation/vm/page-types.c |  700 ++++++++++++++++++++++++++++++++
 Documentation/vm/pagemap.txt  |   72 +++
 fs/proc/page.c                |  166 ++++++-
 include/linux/mm.h            |   24 +
 include/linux/page-flags.h    |    2 
 mm/hugetlb.c                  |    2 
 mm/page_alloc.c               |   11 
 mm/slob.c                     |    6 
 9 files changed, 940 insertions(+), 45 deletions(-)

Thanks,
Fengguang
--

a simple demo of the page-types tool

# ./page-types -h
page-types [options]
            -r|--raw                  Raw mode, for kernel developers
            -a|--addr    addr-spec    Walk a range of pages
            -b|--bits    bits-spec    Walk pages with specified bits
            -l|--list                 Show page details in ranges
            -L|--list-each            Show page details one by one
            -N|--no-summary           Don't show summay info
            -h|--help                 Show this usage message
addr-spec:
            N                         one page at offset N (unit: pages)
            N+M                       pages range from N to N+M-1
            N,M                       pages range from N to M-1
            N,                        pages range from N to end
            ,M                        pages range from 0 to M
bits-spec:
            bit1,bit2                 (flags & (bit1|bit2)) != 0
            bit1,bit2=bit1            (flags & (bit1|bit2)) == bit1
            bit1,~bit2                (flags & (bit1|bit2)) == bit1
            =bit1,bit2                flags == (bit1|bit2)
bit-names:
          locked              error         referenced           uptodate   
           dirty                lru             active               slab   
       writeback            reclaim              buddy               mmap   
       anonymous          swapcache         swapbacked      compound_head   
   compound_tail               huge        unevictable           hwpoison   
          nopage           reserved(r)         mlocked(r)    mappedtodisk(r)
         private(r)       private_2(r)   owner_private(r)            arch(r)
        uncached(r)       readahead(o)       slob_free(o)     slub_frozen(o)
      slub_debug(o)
                                   (r) raw mode bits  (o) overloaded bits


# ./page-types
             flags      page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000          487369     1903  _________________________________
0x0000000000000014               5        0  __R_D____________________________  referenced,dirty
0x0000000000000020               1        0  _____l___________________________  lru
0x0000000000000024              34        0  __R__l___________________________  referenced,lru
0x0000000000000028            3838       14  ___U_l___________________________  uptodate,lru
0x0001000000000028              48        0  ___U_l_______________________I___  uptodate,lru,readahead
0x000000000000002c            6478       25  __RU_l___________________________  referenced,uptodate,lru
0x000100000000002c              47        0  __RU_l_______________________I___  referenced,uptodate,lru,readahead
0x0000000000000040            8344       32  ______A__________________________  active
0x0000000000000060               1        0  _____lA__________________________  lru,active
0x0000000000000068             348        1  ___U_lA__________________________  uptodate,lru,active
0x0001000000000068              12        0  ___U_lA______________________I___  uptodate,lru,active,readahead
0x000000000000006c             988        3  __RU_lA__________________________  referenced,uptodate,lru,active
0x000100000000006c              48        0  __RU_lA______________________I___  referenced,uptodate,lru,active,readahead
0x0000000000004078               1        0  ___UDlA_______b__________________  uptodate,dirty,lru,active,swapbacked
0x000000000000407c              34        0  __RUDlA_______b__________________  referenced,uptodate,dirty,lru,active,swapbacked
0x0000000000000400             503        1  __________B______________________  buddy
0x0000000000000804               1        0  __R________M_____________________  referenced,mmap
0x0000000000000828            1029        4  ___U_l_____M_____________________  uptodate,lru,mmap
0x0001000000000828              43        0  ___U_l_____M_________________I___  uptodate,lru,mmap,readahead
0x000000000000082c             382        1  __RU_l_____M_____________________  referenced,uptodate,lru,mmap
0x000100000000082c              12        0  __RU_l_____M_________________I___  referenced,uptodate,lru,mmap,readahead
0x0000000000000868             192        0  ___U_lA____M_____________________  uptodate,lru,active,mmap
0x0001000000000868              12        0  ___U_lA____M_________________I___  uptodate,lru,active,mmap,readahead
0x000000000000086c             800        3  __RU_lA____M_____________________  referenced,uptodate,lru,active,mmap
0x000100000000086c              31        0  __RU_lA____M_________________I___  referenced,uptodate,lru,active,mmap,readahead
0x0000000000004878               2        0  ___UDlA____M__b__________________  uptodate,dirty,lru,active,mmap,swapbacked
0x0000000000001000             492        1  ____________a____________________  anonymous
0x0000000000005808               4        0  ___U_______Ma_b__________________  uptodate,mmap,anonymous,swapbacked
0x0000000000005868            2839       11  ___U_lA____Ma_b__________________  uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c              30        0  __RU_lA____Ma_b__________________  referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total          513968     2007


# ./page-types -r
             flags      page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000          468002     1828  _________________________________
0x0000000100000000           19102       74  _____________________r___________  reserved
0x0000000000008000              41        0  _______________H_________________  compound_head
0x0000000000010000             188        0  ________________T________________  compound_tail
0x0000000000008014               1        0  __R_D__________H_________________  referenced,dirty,compound_head
0x0000000000010014               4        0  __R_D___________T________________  referenced,dirty,compound_tail
0x0000000000000020               1        0  _____l___________________________  lru
0x0000000800000024              34        0  __R__l__________________P________  referenced,lru,private
0x0000000000000028            3794       14  ___U_l___________________________  uptodate,lru
0x0001000000000028              46        0  ___U_l_______________________I___  uptodate,lru,readahead
0x0000000400000028              44        0  ___U_l_________________d_________  uptodate,lru,mappedtodisk
0x0001000400000028               2        0  ___U_l_________________d_____I___  uptodate,lru,mappedtodisk,readahead
0x000000000000002c            6434       25  __RU_l___________________________  referenced,uptodate,lru
0x000100000000002c              47        0  __RU_l_______________________I___  referenced,uptodate,lru,readahead
0x000000040000002c              14        0  __RU_l_________________d_________  referenced,uptodate,lru,mappedtodisk
0x000000080000002c              30        0  __RU_l__________________P________  referenced,uptodate,lru,private
0x0000000800000040            8124       31  ______A_________________P________  active,private
0x0000000000000040             219        0  ______A__________________________  active
0x0000000800000060               1        0  _____lA_________________P________  lru,active,private
0x0000000000000068             322        1  ___U_lA__________________________  uptodate,lru,active
0x0001000000000068              12        0  ___U_lA______________________I___  uptodate,lru,active,readahead
0x0000000400000068              13        0  ___U_lA________________d_________  uptodate,lru,active,mappedtodisk
0x0000000800000068              12        0  ___U_lA_________________P________  uptodate,lru,active,private
0x000000000000006c             977        3  __RU_lA__________________________  referenced,uptodate,lru,active
0x000100000000006c              48        0  __RU_lA______________________I___  referenced,uptodate,lru,active,readahead
0x000000040000006c               5        0  __RU_lA________________d_________  referenced,uptodate,lru,active,mappedtodisk
0x000000080000006c               3        0  __RU_lA_________________P________  referenced,uptodate,lru,active,private
0x0000000c0000006c               3        0  __RU_lA________________dP________  referenced,uptodate,lru,active,mappedtodisk,private
0x0000000c00000068               1        0  ___U_lA________________dP________  uptodate,lru,active,mappedtodisk,private
0x0000000000004078               1        0  ___UDlA_______b__________________  uptodate,dirty,lru,active,swapbacked
0x000000000000407c              34        0  __RUDlA_______b__________________  referenced,uptodate,dirty,lru,active,swapbacked
0x0000000000000400             538        2  __________B______________________  buddy
0x0000000000000804               1        0  __R________M_____________________  referenced,mmap
0x0000000000000828            1029        4  ___U_l_____M_____________________  uptodate,lru,mmap
0x0001000000000828              43        0  ___U_l_____M_________________I___  uptodate,lru,mmap,readahead
0x000000000000082c             382        1  __RU_l_____M_____________________  referenced,uptodate,lru,mmap
0x000100000000082c              12        0  __RU_l_____M_________________I___  referenced,uptodate,lru,mmap,readahead
0x0000000000000868             192        0  ___U_lA____M_____________________  uptodate,lru,active,mmap
0x0001000000000868              12        0  ___U_lA____M_________________I___  uptodate,lru,active,mmap,readahead
0x000000000000086c             800        3  __RU_lA____M_____________________  referenced,uptodate,lru,active,mmap
0x000100000000086c              31        0  __RU_lA____M_________________I___  referenced,uptodate,lru,active,mmap,readahead
0x0000000000004878               2        0  ___UDlA____M__b__________________  uptodate,dirty,lru,active,mmap,swapbacked
0x0000000000001000             492        1  ____________a____________________  anonymous
0x0000000000005008               2        0  ___U________a_b__________________  uptodate,anonymous,swapbacked
0x0000000000005808               4        0  ___U_______Ma_b__________________  uptodate,mmap,anonymous,swapbacked
0x000000000000580c               1        0  __RU_______Ma_b__________________  referenced,uptodate,mmap,anonymous,swapbacked
0x0000000000005868            2839       11  ___U_lA____Ma_b__________________  uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c              29        0  __RU_lA____Ma_b__________________  referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total          513968     2007


# ./page-types --raw --list --no-summary --bits reserved
offset  count   flags
0       15      _____________________r___________
31      4       _____________________r___________
159     97      _____________________r___________
4096    2067    _____________________r___________
6752    2390    _____________________r___________
9355    3       _____________________r___________
9728    14526   _____________________r___________


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

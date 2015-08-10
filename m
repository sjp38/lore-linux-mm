Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3C78F6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 03:12:35 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so50270408pdr.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 00:12:35 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id nh9si31777100pdb.77.2015.08.10.00.12.32
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 00:12:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC zsmalloc 0/4] meta diet
Date: Mon, 10 Aug 2015 16:12:19 +0900
Message-Id: <1439190743-13933-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Recently, Gioh worked to support non-LRU page migration[1].
zRAM is one of customer to use that feature.

For working with that, drivers have to register own address_space
via page->mapping and mark the page->_mapcount as MOBILE page.

Unfortunately, zram have been used those fields to keep own
metadata so there is no room in struct page, which makes hard
to work with the feature.

This patchset try to diet so the goal is to make page->mapping
and page->_mapcount empty.

Trade-off is CPU vs MEMORY so this patchset would make it slow
a bit. I did fio test with perf in my x86 mahchine.

before:

 Performance counter stats for './zram_fio.sh' (6 runs):

      11186.216003      task-clock (msec)         #    1.836 CPUs utilized          
             1,059      context-switches          #    0.098 K/sec                  
               299      cpu-migrations            #    0.028 K/sec                  
           159,221      page-faults               #    0.015 M/sec                  
    17,629,290,725      cycles                    #    1.627 GHz                      (83.56%)
    12,375,796,782      stalled-cycles-frontend   #   69.95% frontend cycles idle     (83.34%)
     8,566,377,800      stalled-cycles-backend    #   48.42% backend  cycles idle     (66.91%)
    12,828,697,359      instructions              #    0.73  insns per cycle        
                                                  #    0.96  stalled cycles per insn  (83.55%)
     2,099,817,436      branches                  #  193.734 M/sec                    (83.66%)
        20,327,794      branch-misses             #    0.96% of all branches          (83.89%)

       6.092967906 seconds time elapsed                                          ( +-  1.49% )

new:

 Performance counter stats for './zram_fio.sh' (6 runs):

      10574.201402      task-clock (msec)         #    1.724 CPUs utilized          
             1,157      context-switches          #    0.107 K/sec                  
               319      cpu-migrations            #    0.030 K/sec                  
           159,196      page-faults               #    0.015 M/sec                  
    17,825,134,600      cycles                    #    1.652 GHz                      (83.61%)
    12,462,671,915      stalled-cycles-frontend   #   69.98% frontend cycles idle     (83.18%)
     8,699,972,776      stalled-cycles-backend    #   48.85% backend  cycles idle     (66.81%)
    12,958,165,862      instructions              #    0.73  insns per cycle        
                                                  #    0.96  stalled cycles per insn  (83.55%)
     2,135,158,432      branches                  #  197.936 M/sec                    (83.80%)
        20,226,663      branch-misses             #    0.95% of all branches          (83.93%)

       6.133316214 seconds time elapsed                                          ( +-  1.80% )

There is a regression under about 1~2% so I think it's reasonable trade-off.

Notice: I marked it as RFC due to two things.

1. I didn't check ./script/checkpatch
2. If Gioh's work is dropped, there is no point to merge this patchset.

If there is no big problem found during review process and Gioh respins
new revision, I will implement migration functions based (this patchset +
Gioh's new).

Thanks.

[1] http://lwn.net/Articles/650917/

Minchan Kim (4):
  zsmalloc: keep max_object in size_class
  zsmalloc: squeeze inuse into page->mapping
  zsmalloc: squeeze freelist into page->mapping
  zsmalloc: move struct zs_meta from mapping to somewhere

 mm/zsmalloc.c | 346 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 197 insertions(+), 149 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

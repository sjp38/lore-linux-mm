Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB3A6B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 03:45:26 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id a3so6155874oib.8
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 00:45:26 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e9si4599644obr.50.2015.01.26.00.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 00:45:25 -0800 (PST)
Date: Mon, 26 Jan 2015 11:45:12 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [kbuild] [mmotm:master 169/385] mm/compaction.c:38:25: sparse:
 duplicate const
Message-ID: <20150126084512.GX6507@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   03586ad04b2170ee816e6936981cc7cd2aeba129
commit: a841a87a027a03b0615ffaac5a4b71223feaa5a6 [169/385] mm-compaction-enhance-tracepoint-output-for-compaction-begin-end-v4
reproduce:
  # apt-get install sparse
  git checkout a841a87a027a03b0615ffaac5a4b71223feaa5a6
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__

>> mm/compaction.c:38:25: sparse: duplicate const 
   mm/compaction.c:1363:37: sparse: incorrect type in initializer (different base types)
   mm/compaction.c:1363:37:    expected int [signed] may_enter_fs
   mm/compaction.c:1363:37:    got restricted gfp_t
   mm/compaction.c:1364:39: sparse: incorrect type in initializer (different base types)
   mm/compaction.c:1364:39:    expected int [signed] may_perform_io
   mm/compaction.c:1364:39:    got restricted gfp_t
   include/trace/events/compaction.h:87:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   include/trace/events/compaction.h:117:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   mm/compaction.c:241:13: sparse: context imbalance in 'compact_trylock_irqsave' - wrong count at exit
   include/linux/spinlock.h:364:9: sparse: context imbalance in 'compact_unlock_should_abort' - unexpected unlock
   mm/compaction.c:447:39: sparse: context imbalance in 'isolate_freepages_block' - unexpected unlock
   mm/compaction.c:744:39: sparse: context imbalance in 'isolate_migratepages_block' - unexpected unlock

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout a841a87a027a03b0615ffaac5a4b71223feaa5a6
vim +38 mm/compaction.c

010fc29a Minchan Kim       2012-12-20  22  static inline void count_compact_event(enum vm_event_item item)
010fc29a Minchan Kim       2012-12-20  23  {
010fc29a Minchan Kim       2012-12-20  24  	count_vm_event(item);
010fc29a Minchan Kim       2012-12-20  25  }
010fc29a Minchan Kim       2012-12-20  26  
010fc29a Minchan Kim       2012-12-20  27  static inline void count_compact_events(enum vm_event_item item, long delta)
010fc29a Minchan Kim       2012-12-20  28  {
010fc29a Minchan Kim       2012-12-20  29  	count_vm_events(item, delta);
010fc29a Minchan Kim       2012-12-20  30  }
010fc29a Minchan Kim       2012-12-20  31  #else
010fc29a Minchan Kim       2012-12-20  32  #define count_compact_event(item) do { } while (0)
010fc29a Minchan Kim       2012-12-20  33  #define count_compact_events(item, delta) do { } while (0)
010fc29a Minchan Kim       2012-12-20  34  #endif
010fc29a Minchan Kim       2012-12-20  35  
ff9543fd Michal Nazarewicz 2011-12-29  36  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
a841a87a Joonsoo Kim       2015-01-23  37  #ifdef CONFIG_TRACEPOINTS
a841a87a Joonsoo Kim       2015-01-23 @38  static const char const *compaction_status_string[] = {

Should be:

	static const char *const compaction_status_string[] = {

a841a87a Joonsoo Kim       2015-01-23  39  	"deferred",
a841a87a Joonsoo Kim       2015-01-23  40  	"skipped",
a841a87a Joonsoo Kim       2015-01-23  41  	"continue",
a841a87a Joonsoo Kim       2015-01-23  42  	"partial",
a841a87a Joonsoo Kim       2015-01-23  43  	"complete",
a841a87a Joonsoo Kim       2015-01-23  44  };
a841a87a Joonsoo Kim       2015-01-23  45  #endif
ff9543fd Michal Nazarewicz 2011-12-29  46  

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
_______________________________________________
kbuild mailing list
kbuild@lists.01.org
https://lists.01.org/mailman/listinfo/kbuild

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

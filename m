Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62103C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 13:10:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDEB321850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 13:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDEB321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E4938E0001; Fri,  5 Jul 2019 09:10:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794626B0005; Fri,  5 Jul 2019 09:10:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60FBF8E0001; Fri,  5 Jul 2019 09:10:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3BD6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 09:10:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so4988648plp.12
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 06:10:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=j3E4li3NGAhga6eHrU1JkSza29vX3R85wnwbKn5UMAM=;
        b=T4NS95SCoh7foNZQ8KUdk5zIJTupWPbCkwOndyqFoBKGqpVsyLw7hhaYauZMTPB89o
         tTxUrXnkxUu0IigGANpiCqkIVAbKR5n4ahRko5wJLTTlDWLaDNGvcJVEjfBGGtnFuxGA
         FjbvBncpZtmBaH3h8NTkW+nTRnGdhFgsIb6avHcNqEW0gPS33wtUCdzb767DT7JA2AvB
         ZdzcY9IdOXQgVgqE59Yx4BXe2ps2OQgu0vwKdI6ithuq43MNwZwdZ97JGTYnsIlDhkvf
         QsRoxEUMyDRQOXoGv+Phy5KvIPT7INWlV8sWnY1T6v/QkdrsjPJ8lQ4+tuH9EbZnQ3TG
         rZrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX47dxvnutFEzBYdZsoDPzuyDNl1QB699qjCGvVf3N4UIRX1KJb
	zJVwlDZ/RW/UIFIMNtko5Z++yaX0V6WIIhXuTpmYxTT5vKLHgmspdyArP/aaXyNqu5+mdBsQob+
	1iMMglKEZ2fW9coSg/9ST5ktuTFe8DqtiL3s6KGf9Psq/S4dZGxYL/cDi2iju2hHmXw==
X-Received: by 2002:a63:1645:: with SMTP id 5mr5444248pgw.175.1562332225438;
        Fri, 05 Jul 2019 06:10:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ5ZiFAJr08Q9gnAKOf2or89Cc4KJqbaaoZ5BD95uTuWk7cbaeOj6r3peiY9VAbXkb84ow
X-Received: by 2002:a63:1645:: with SMTP id 5mr5444029pgw.175.1562332223318;
        Fri, 05 Jul 2019 06:10:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562332223; cv=none;
        d=google.com; s=arc-20160816;
        b=S9fxEvi0LR4qz31CyrtT8BlwNvzbSYeLlZMN8RPqyqPAtoZIsONCqjGnBdL94OYjiV
         AYb/ufoEtaOC9g1zETuDFtuFP23ZgXh9ODd6phwcBs/8GSlw4kkUBiS/nMtZZqdhJef0
         W03rDryHJ72hTN4UrQXDUxdiRz5+rD+rTFmZRybaQ6d7JkdQfjjIqmqjciias7Ll1k6J
         dzUZcjjGo9iBpaLrUEb+4rtHeWEbq6XFa6Fy+cYQFdyELuidyDiFTgs2i7qwk/PVOamS
         txTGiZGJEFGZrvLuEhT88lf5BKJahyEEk8s+6hnv201ew0pbKLRaS7X7z4YOHJUb848f
         7rNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=j3E4li3NGAhga6eHrU1JkSza29vX3R85wnwbKn5UMAM=;
        b=QSXtOhN826oEkAE7TLi6SF9yGRGz1FuKjnVQBFuFXRB9TmU9bjfeEuJlgYZWz+U2gC
         HjZFP6BBWa8+fW0KSoptWXZjtgx3oRcpr35rQxp+jTC5Ng+lIUSWY9ZBjq9AEB/ob+Wn
         uBi1MIE7lRHnxCol/lVHd4EoVcNQQdvpTNDF+Zem7Ydkq75bjkkmHQbCw8/craTEM2QD
         OW4wWTof473/E26+7fTtXH2gxAyZLrPeYSYW4S8lIQzkjOG4l6NwPugQ3iFBgyV6BpPb
         ANhJgR26o7e1/LSA/XslBXFRFvFr95lBM0lV4WUO0v7EEVO3nPEzjxGCGeJBw3KZ26+y
         +2qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g94si8657772plb.142.2019.07.05.06.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 06:10:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jul 2019 06:10:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,455,1557212400"; 
   d="gz'50?scan'50,208,50";a="169672413"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga006.jf.intel.com with ESMTP; 05 Jul 2019 06:10:20 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hjNyl-000GJa-FO; Fri, 05 Jul 2019 21:10:19 +0800
Date: Fri, 5 Jul 2019 21:09:24 +0800
From: kbuild test robot <lkp@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:master 12342/12641] mm/vmscan.c:205:7: error: implicit
 declaration of function 'memcg_expand_shrinker_maps'; did you mean
 'memcg_set_shrinker_bit'?
Message-ID: <201907052120.OGYPhvno%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git master
head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
commit: 8236f517d69e2217f5200d7f700e8b18b01c94c8 [12342/12641] mm: shrinker: make shrinker not depend on memcg kmem
config: x86_64-randconfig-s2-07051907 (attached as .config)
compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
reproduce:
        git checkout 8236f517d69e2217f5200d7f700e8b18b01c94c8
        # save the attached .config to linux build tree
        make ARCH=x86_64 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All error/warnings (new ones prefixed by >>):

   mm/vmscan.c: In function 'prealloc_memcg_shrinker':
>> mm/vmscan.c:205:7: error: implicit declaration of function 'memcg_expand_shrinker_maps'; did you mean 'memcg_set_shrinker_bit'? [-Werror=implicit-function-declaration]
      if (memcg_expand_shrinker_maps(id)) {
          ^~~~~~~~~~~~~~~~~~~~~~~~~~
          memcg_set_shrinker_bit
   In file included from include/linux/rbtree.h:22:0,
                    from include/linux/mm_types.h:10,
                    from include/linux/mmzone.h:21,
                    from include/linux/gfp.h:6,
                    from include/linux/mm.h:10,
                    from mm/vmscan.c:17:
   mm/vmscan.c: In function 'shrink_slab_memcg':
>> mm/vmscan.c:593:54: error: 'struct mem_cgroup_per_node' has no member named 'shrinker_map'
     map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                                         ^
   include/linux/rcupdate.h:321:12: note: in definition of macro '__rcu_dereference_protected'
     ((typeof(*p) __force __kernel *)(p)); \
               ^
>> mm/vmscan.c:593:8: note: in expansion of macro 'rcu_dereference_protected'
     map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
           ^~~~~~~~~~~~~~~~~~~~~~~~~
>> mm/vmscan.c:593:54: error: 'struct mem_cgroup_per_node' has no member named 'shrinker_map'
     map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                                         ^
   include/linux/rcupdate.h:321:35: note: in definition of macro '__rcu_dereference_protected'
     ((typeof(*p) __force __kernel *)(p)); \
                                      ^
>> mm/vmscan.c:593:8: note: in expansion of macro 'rcu_dereference_protected'
     map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
           ^~~~~~~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +205 mm/vmscan.c

b1de0d139 Mitchel Humpherys     2014-06-06   16  
^1da177e4 Linus Torvalds        2005-04-16  @17  #include <linux/mm.h>
5b3cc15af Ingo Molnar           2017-02-02   18  #include <linux/sched/mm.h>
^1da177e4 Linus Torvalds        2005-04-16   19  #include <linux/module.h>
5a0e3ad6a Tejun Heo             2010-03-24   20  #include <linux/gfp.h>
^1da177e4 Linus Torvalds        2005-04-16   21  #include <linux/kernel_stat.h>
^1da177e4 Linus Torvalds        2005-04-16   22  #include <linux/swap.h>
^1da177e4 Linus Torvalds        2005-04-16   23  #include <linux/pagemap.h>
^1da177e4 Linus Torvalds        2005-04-16   24  #include <linux/init.h>
^1da177e4 Linus Torvalds        2005-04-16   25  #include <linux/highmem.h>
70ddf637e Anton Vorontsov       2013-04-29   26  #include <linux/vmpressure.h>
e129b5c23 Andrew Morton         2006-09-27   27  #include <linux/vmstat.h>
^1da177e4 Linus Torvalds        2005-04-16   28  #include <linux/file.h>
^1da177e4 Linus Torvalds        2005-04-16   29  #include <linux/writeback.h>
^1da177e4 Linus Torvalds        2005-04-16   30  #include <linux/blkdev.h>
^1da177e4 Linus Torvalds        2005-04-16   31  #include <linux/buffer_head.h>	/* for try_to_release_page(),
^1da177e4 Linus Torvalds        2005-04-16   32  					buffer_heads_over_limit */
^1da177e4 Linus Torvalds        2005-04-16   33  #include <linux/mm_inline.h>
^1da177e4 Linus Torvalds        2005-04-16   34  #include <linux/backing-dev.h>
^1da177e4 Linus Torvalds        2005-04-16   35  #include <linux/rmap.h>
^1da177e4 Linus Torvalds        2005-04-16   36  #include <linux/topology.h>
^1da177e4 Linus Torvalds        2005-04-16   37  #include <linux/cpu.h>
^1da177e4 Linus Torvalds        2005-04-16   38  #include <linux/cpuset.h>
3e7d34497 Mel Gorman            2011-01-13   39  #include <linux/compaction.h>
^1da177e4 Linus Torvalds        2005-04-16   40  #include <linux/notifier.h>
^1da177e4 Linus Torvalds        2005-04-16   41  #include <linux/rwsem.h>
248a0301e Rafael J. Wysocki     2006-03-22   42  #include <linux/delay.h>
3218ae14b Yasunori Goto         2006-06-27   43  #include <linux/kthread.h>
7dfb71030 Nigel Cunningham      2006-12-06   44  #include <linux/freezer.h>
66e1707bc Balbir Singh          2008-02-07   45  #include <linux/memcontrol.h>
873b47717 Keika Kobayashi       2008-07-25   46  #include <linux/delayacct.h>
af936a160 Lee Schermerhorn      2008-10-18   47  #include <linux/sysctl.h>
929bea7c7 KOSAKI Motohiro       2011-04-14   48  #include <linux/oom.h>
64e3d12f7 Kuo-Hsin Yang         2018-11-06   49  #include <linux/pagevec.h>
268bb0ce3 Linus Torvalds        2011-05-20   50  #include <linux/prefetch.h>
b1de0d139 Mitchel Humpherys     2014-06-06   51  #include <linux/printk.h>
f9fe48bec Ross Zwisler          2016-01-22   52  #include <linux/dax.h>
eb414681d Johannes Weiner       2018-10-26   53  #include <linux/psi.h>
^1da177e4 Linus Torvalds        2005-04-16   54  
^1da177e4 Linus Torvalds        2005-04-16   55  #include <asm/tlbflush.h>
^1da177e4 Linus Torvalds        2005-04-16   56  #include <asm/div64.h>
^1da177e4 Linus Torvalds        2005-04-16   57  
^1da177e4 Linus Torvalds        2005-04-16   58  #include <linux/swapops.h>
117aad1e9 Rafael Aquini         2013-09-30   59  #include <linux/balloon_compaction.h>
^1da177e4 Linus Torvalds        2005-04-16   60  
0f8053a50 Nick Piggin           2006-03-22   61  #include "internal.h"
0f8053a50 Nick Piggin           2006-03-22   62  
33906bc5c Mel Gorman            2010-08-09   63  #define CREATE_TRACE_POINTS
33906bc5c Mel Gorman            2010-08-09   64  #include <trace/events/vmscan.h>
33906bc5c Mel Gorman            2010-08-09   65  
^1da177e4 Linus Torvalds        2005-04-16   66  struct scan_control {
22fba3354 KOSAKI Motohiro       2009-12-14   67  	/* How many pages shrink_list() should reclaim */
22fba3354 KOSAKI Motohiro       2009-12-14   68  	unsigned long nr_to_reclaim;
22fba3354 KOSAKI Motohiro       2009-12-14   69  
ee814fe23 Johannes Weiner       2014-08-06   70  	/*
ee814fe23 Johannes Weiner       2014-08-06   71  	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
ee814fe23 Johannes Weiner       2014-08-06   72  	 * are scanned.
ee814fe23 Johannes Weiner       2014-08-06   73  	 */
ee814fe23 Johannes Weiner       2014-08-06   74  	nodemask_t	*nodemask;
9e3b2f8cd Konstantin Khlebnikov 2012-05-29   75  
5f53e7629 KOSAKI Motohiro       2010-05-24   76  	/*
f16015fbf Johannes Weiner       2012-01-12   77  	 * The memory cgroup that hit its limit and as a result is the
f16015fbf Johannes Weiner       2012-01-12   78  	 * primary target of this reclaim invocation.
f16015fbf Johannes Weiner       2012-01-12   79  	 */
f16015fbf Johannes Weiner       2012-01-12   80  	struct mem_cgroup *target_mem_cgroup;
66e1707bc Balbir Singh          2008-02-07   81  
1276ad68e Johannes Weiner       2017-02-24   82  	/* Writepage batching in laptop mode; RECLAIM_WRITE */
ee814fe23 Johannes Weiner       2014-08-06   83  	unsigned int may_writepage:1;
ee814fe23 Johannes Weiner       2014-08-06   84  
ee814fe23 Johannes Weiner       2014-08-06   85  	/* Can mapped pages be reclaimed? */
ee814fe23 Johannes Weiner       2014-08-06   86  	unsigned int may_unmap:1;
ee814fe23 Johannes Weiner       2014-08-06   87  
ee814fe23 Johannes Weiner       2014-08-06   88  	/* Can pages be swapped as part of reclaim? */
ee814fe23 Johannes Weiner       2014-08-06   89  	unsigned int may_swap:1;
ee814fe23 Johannes Weiner       2014-08-06   90  
1c30844d2 Mel Gorman            2018-12-28   91  	/* e.g. boosted watermark reclaim leaves slabs alone */
1c30844d2 Mel Gorman            2018-12-28   92  	unsigned int may_shrinkslab:1;
1c30844d2 Mel Gorman            2018-12-28   93  
d6622f636 Yisheng Xie           2017-05-03   94  	/*
d6622f636 Yisheng Xie           2017-05-03   95  	 * Cgroups are not reclaimed below their configured memory.low,
d6622f636 Yisheng Xie           2017-05-03   96  	 * unless we threaten to OOM. If any cgroups are skipped due to
d6622f636 Yisheng Xie           2017-05-03   97  	 * memory.low and nothing was reclaimed, go back for memory.low.
d6622f636 Yisheng Xie           2017-05-03   98  	 */
d6622f636 Yisheng Xie           2017-05-03   99  	unsigned int memcg_low_reclaim:1;
d6622f636 Yisheng Xie           2017-05-03  100  	unsigned int memcg_low_skipped:1;
241994ed8 Johannes Weiner       2015-02-11  101  
ee814fe23 Johannes Weiner       2014-08-06  102  	unsigned int hibernation_mode:1;
ee814fe23 Johannes Weiner       2014-08-06  103  
ee814fe23 Johannes Weiner       2014-08-06  104  	/* One of the zones is ready for compaction */
ee814fe23 Johannes Weiner       2014-08-06  105  	unsigned int compaction_ready:1;
ee814fe23 Johannes Weiner       2014-08-06  106  
bb451fdf3 Greg Thelen           2018-08-17  107  	/* Allocation order */
bb451fdf3 Greg Thelen           2018-08-17  108  	s8 order;
bb451fdf3 Greg Thelen           2018-08-17  109  
bb451fdf3 Greg Thelen           2018-08-17  110  	/* Scan (total_size >> priority) pages at once */
bb451fdf3 Greg Thelen           2018-08-17  111  	s8 priority;
bb451fdf3 Greg Thelen           2018-08-17  112  
bb451fdf3 Greg Thelen           2018-08-17  113  	/* The highest zone to isolate pages for reclaim from */
bb451fdf3 Greg Thelen           2018-08-17  114  	s8 reclaim_idx;
bb451fdf3 Greg Thelen           2018-08-17  115  
bb451fdf3 Greg Thelen           2018-08-17  116  	/* This context's GFP mask */
bb451fdf3 Greg Thelen           2018-08-17  117  	gfp_t gfp_mask;
bb451fdf3 Greg Thelen           2018-08-17  118  
ee814fe23 Johannes Weiner       2014-08-06  119  	/* Incremented by the number of inactive pages that were scanned */
ee814fe23 Johannes Weiner       2014-08-06  120  	unsigned long nr_scanned;
ee814fe23 Johannes Weiner       2014-08-06  121  
ee814fe23 Johannes Weiner       2014-08-06  122  	/* Number of pages freed so far during a call to shrink_zones() */
ee814fe23 Johannes Weiner       2014-08-06  123  	unsigned long nr_reclaimed;
d108c7721 Andrey Ryabinin       2018-04-10  124  
d108c7721 Andrey Ryabinin       2018-04-10  125  	struct {
d108c7721 Andrey Ryabinin       2018-04-10  126  		unsigned int dirty;
d108c7721 Andrey Ryabinin       2018-04-10  127  		unsigned int unqueued_dirty;
d108c7721 Andrey Ryabinin       2018-04-10  128  		unsigned int congested;
d108c7721 Andrey Ryabinin       2018-04-10  129  		unsigned int writeback;
d108c7721 Andrey Ryabinin       2018-04-10  130  		unsigned int immediate;
d108c7721 Andrey Ryabinin       2018-04-10  131  		unsigned int file_taken;
d108c7721 Andrey Ryabinin       2018-04-10  132  		unsigned int taken;
d108c7721 Andrey Ryabinin       2018-04-10  133  	} nr;
^1da177e4 Linus Torvalds        2005-04-16  134  };
^1da177e4 Linus Torvalds        2005-04-16  135  
^1da177e4 Linus Torvalds        2005-04-16  136  #ifdef ARCH_HAS_PREFETCH
^1da177e4 Linus Torvalds        2005-04-16  137  #define prefetch_prev_lru_page(_page, _base, _field)			\
^1da177e4 Linus Torvalds        2005-04-16  138  	do {								\
^1da177e4 Linus Torvalds        2005-04-16  139  		if ((_page)->lru.prev != _base) {			\
^1da177e4 Linus Torvalds        2005-04-16  140  			struct page *prev;				\
^1da177e4 Linus Torvalds        2005-04-16  141  									\
^1da177e4 Linus Torvalds        2005-04-16  142  			prev = lru_to_page(&(_page->lru));		\
^1da177e4 Linus Torvalds        2005-04-16  143  			prefetch(&prev->_field);			\
^1da177e4 Linus Torvalds        2005-04-16  144  		}							\
^1da177e4 Linus Torvalds        2005-04-16  145  	} while (0)
^1da177e4 Linus Torvalds        2005-04-16  146  #else
^1da177e4 Linus Torvalds        2005-04-16  147  #define prefetch_prev_lru_page(_page, _base, _field) do { } while (0)
^1da177e4 Linus Torvalds        2005-04-16  148  #endif
^1da177e4 Linus Torvalds        2005-04-16  149  
^1da177e4 Linus Torvalds        2005-04-16  150  #ifdef ARCH_HAS_PREFETCHW
^1da177e4 Linus Torvalds        2005-04-16  151  #define prefetchw_prev_lru_page(_page, _base, _field)			\
^1da177e4 Linus Torvalds        2005-04-16  152  	do {								\
^1da177e4 Linus Torvalds        2005-04-16  153  		if ((_page)->lru.prev != _base) {			\
^1da177e4 Linus Torvalds        2005-04-16  154  			struct page *prev;				\
^1da177e4 Linus Torvalds        2005-04-16  155  									\
^1da177e4 Linus Torvalds        2005-04-16  156  			prev = lru_to_page(&(_page->lru));		\
^1da177e4 Linus Torvalds        2005-04-16  157  			prefetchw(&prev->_field);			\
^1da177e4 Linus Torvalds        2005-04-16  158  		}							\
^1da177e4 Linus Torvalds        2005-04-16  159  	} while (0)
^1da177e4 Linus Torvalds        2005-04-16  160  #else
^1da177e4 Linus Torvalds        2005-04-16  161  #define prefetchw_prev_lru_page(_page, _base, _field) do { } while (0)
^1da177e4 Linus Torvalds        2005-04-16  162  #endif
^1da177e4 Linus Torvalds        2005-04-16  163  
^1da177e4 Linus Torvalds        2005-04-16  164  /*
^1da177e4 Linus Torvalds        2005-04-16  165   * From 0 .. 100.  Higher means more swappy.
^1da177e4 Linus Torvalds        2005-04-16  166   */
^1da177e4 Linus Torvalds        2005-04-16  167  int vm_swappiness = 60;
d0480be44 Wang Sheng-Hui        2014-08-06  168  /*
d0480be44 Wang Sheng-Hui        2014-08-06  169   * The total number of pages which are beyond the high watermark within all
d0480be44 Wang Sheng-Hui        2014-08-06  170   * zones.
d0480be44 Wang Sheng-Hui        2014-08-06  171   */
d0480be44 Wang Sheng-Hui        2014-08-06  172  unsigned long vm_total_pages;
^1da177e4 Linus Torvalds        2005-04-16  173  
^1da177e4 Linus Torvalds        2005-04-16  174  static LIST_HEAD(shrinker_list);
^1da177e4 Linus Torvalds        2005-04-16  175  static DECLARE_RWSEM(shrinker_rwsem);
^1da177e4 Linus Torvalds        2005-04-16  176  
8236f517d Yang Shi              2019-07-05  177  #ifdef CONFIG_MEMCG
7e010df53 Kirill Tkhai          2018-08-17  178  /*
7e010df53 Kirill Tkhai          2018-08-17  179   * We allow subsystems to populate their shrinker-related
7e010df53 Kirill Tkhai          2018-08-17  180   * LRU lists before register_shrinker_prepared() is called
7e010df53 Kirill Tkhai          2018-08-17  181   * for the shrinker, since we don't want to impose
7e010df53 Kirill Tkhai          2018-08-17  182   * restrictions on their internal registration order.
7e010df53 Kirill Tkhai          2018-08-17  183   * In this case shrink_slab_memcg() may find corresponding
7e010df53 Kirill Tkhai          2018-08-17  184   * bit is set in the shrinkers map.
7e010df53 Kirill Tkhai          2018-08-17  185   *
7e010df53 Kirill Tkhai          2018-08-17  186   * This value is used by the function to detect registering
7e010df53 Kirill Tkhai          2018-08-17  187   * shrinkers and to skip do_shrink_slab() calls for them.
7e010df53 Kirill Tkhai          2018-08-17  188   */
7e010df53 Kirill Tkhai          2018-08-17  189  #define SHRINKER_REGISTERING ((struct shrinker *)~0UL)
7e010df53 Kirill Tkhai          2018-08-17  190  
b4c2b231c Kirill Tkhai          2018-08-17  191  static DEFINE_IDR(shrinker_idr);
b4c2b231c Kirill Tkhai          2018-08-17  192  static int shrinker_nr_max;
b4c2b231c Kirill Tkhai          2018-08-17  193  
b4c2b231c Kirill Tkhai          2018-08-17  194  static int prealloc_memcg_shrinker(struct shrinker *shrinker)
b4c2b231c Kirill Tkhai          2018-08-17  195  {
b4c2b231c Kirill Tkhai          2018-08-17  196  	int id, ret = -ENOMEM;
b4c2b231c Kirill Tkhai          2018-08-17  197  
b4c2b231c Kirill Tkhai          2018-08-17  198  	down_write(&shrinker_rwsem);
b4c2b231c Kirill Tkhai          2018-08-17  199  	/* This may call shrinker, so it must use down_read_trylock() */
7e010df53 Kirill Tkhai          2018-08-17  200  	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
b4c2b231c Kirill Tkhai          2018-08-17  201  	if (id < 0)
b4c2b231c Kirill Tkhai          2018-08-17  202  		goto unlock;
b4c2b231c Kirill Tkhai          2018-08-17  203  
0a4465d34 Kirill Tkhai          2018-08-17  204  	if (id >= shrinker_nr_max) {
0a4465d34 Kirill Tkhai          2018-08-17 @205  		if (memcg_expand_shrinker_maps(id)) {
0a4465d34 Kirill Tkhai          2018-08-17  206  			idr_remove(&shrinker_idr, id);
0a4465d34 Kirill Tkhai          2018-08-17  207  			goto unlock;
0a4465d34 Kirill Tkhai          2018-08-17  208  		}
0a4465d34 Kirill Tkhai          2018-08-17  209  
b4c2b231c Kirill Tkhai          2018-08-17  210  		shrinker_nr_max = id + 1;
0a4465d34 Kirill Tkhai          2018-08-17  211  	}
b4c2b231c Kirill Tkhai          2018-08-17  212  	shrinker->id = id;
b4c2b231c Kirill Tkhai          2018-08-17  213  	ret = 0;
b4c2b231c Kirill Tkhai          2018-08-17  214  unlock:
b4c2b231c Kirill Tkhai          2018-08-17  215  	up_write(&shrinker_rwsem);
b4c2b231c Kirill Tkhai          2018-08-17  216  	return ret;
b4c2b231c Kirill Tkhai          2018-08-17  217  }
b4c2b231c Kirill Tkhai          2018-08-17  218  

:::::: The code at line 205 was first introduced by commit
:::::: 0a4465d340282f92719f4e3a56545a848e638d15 mm, memcg: assign memcg-aware shrinkers bitmap to memcg

:::::: TO: Kirill Tkhai <ktkhai@virtuozzo.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--IS0zKkzwUGydFO0o
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
mBkCuwEA

--IS0zKkzwUGydFO0o--


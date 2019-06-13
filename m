Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F388CC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A562220896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A562220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 532598E0007; Thu, 13 Jun 2019 19:30:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BC2E8E0002; Thu, 13 Jun 2019 19:30:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 310A28E0007; Thu, 13 Jun 2019 19:30:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC6948E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so424442pgb.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=w307HqUfLcFNhyk77hLrRhQJznASnW1ScdUKj5eM3wA=;
        b=FyWWNNv0mhr3AzDNdEwcwzUhFcVwj46hg3LdesgWkzZQjvO5vhAlCLqehZaFmA7Cr2
         8cHjaDTsoe4m9zCejA+Ca5vzPFyMYl/ujqOMbsJgOP6xoyaKxE6HoFGCv0XVh6XmS5yY
         +yDPvNnEY+EeH1Lr1/vx/KJIc5yaBuWa2KHjJs08LlsDuQ4K4leQ0grqMxOX3EE6cghj
         R4PXfwmIE2FtD7HOed7MD3ywii4q0AOJcoSipjWQeNPUTwkRQV033kYcey6W9XLxLHcj
         iw1JIaG2mV6lcDqE0YJwNePOAXdt9R83ISOZSbhlKpowU/rVMmB2HMhGyPun/bSHa+EY
         HONg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWqqIzoG+S7roaaHJ2FQ6zg+ZAcJLC4nRC3hVriJXAnLQHkZVAk
	IMruYn+F661SM43JMkSNkjJgYnj0JhI7vxrP8XCxh0XbaCA87BJ6oqbEpvvjcNtio35uJd1t7fN
	APd/opn89oDCCNbSCtOup1ktQoMqH5DAFmoFUVRGci75nI3tCibmiLDh1RrS1Vd9JlA==
X-Received: by 2002:a17:902:bb8f:: with SMTP id m15mr25251779pls.84.1560468622547;
        Thu, 13 Jun 2019 16:30:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiKu4hREr1hyNr6PdX0zN5m1v5LCU2tVIpHgAyzrGIYf2p8iZhr5N6LqOCSymez3qROWM4
X-Received: by 2002:a17:902:bb8f:: with SMTP id m15mr25251688pls.84.1560468621277;
        Thu, 13 Jun 2019 16:30:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468621; cv=none;
        d=google.com; s=arc-20160816;
        b=P5bTHaseC2HT5rfMyflka7QxfAwm0YLEvDTT/FuWlI5scY4+P9lXtE4cDkN0At8DAs
         PodC1HQUEcUaaFD+Y1J8vSYLU8Ddo1KquSJ9JT+PwEUeShbSSOW5v0ULP5hLftZ9sxyj
         D7MzoZYEGHzleIuwQWaar+UGVYowOz6npZlXCw83etlj0aB2vUpByKuApw3On23et20E
         pYXnzZQcQfcAe9c3Gaw9cwg5uqe0OT12yNitFaad1gsCsLD4hbKeByDykXPV6bXosJ26
         NGoXlHtxySUNBoOkJGSMp18lYArQksXX6JZZOGnZtHI/+Bxfysg9855j/QjQcWCMCFa1
         mL+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=w307HqUfLcFNhyk77hLrRhQJznASnW1ScdUKj5eM3wA=;
        b=NnxN3XqYmIXHvbt7/Et7xg08Mcig6Ifcg4kwxou4vSbLCmLX/JfZu24OiUjD7DF3SW
         cxsjzT3lSzXZQXaZd7rLhI8f3IZSMhbePHu+fentY0gciBSQIJosr3Lvt0nfzpH8+9O2
         LhbdCRgabj8uGn/P/0TgzxaUatrFETRetlNTZBmNcPWvzU968XdeToIRRjSF5aS1WAvY
         HdGFC5mnIQ8frnGZBCgXoO+soikvpIm9GocKaO6u7E7D6/1qCjwV87JxZXl/koMd7oxL
         F83QAtW21cxXU5md7WDOw+/4cIt9vugj4uOs2qxutrWNqiX3XP96J2FrZH0+o5Mmvnt1
         aYIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id o188si708147pfo.219.2019.06.13.16.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:29:58 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 RFC PATCH 0/9] Migrate mode for node reclaim with heterogeneous memory hierarchy
Date: Fri, 14 Jun 2019 07:29:28 +0800
Message-Id: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


With Dave Hansen's patches merged into Linus's tree

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4

PMEM could be hot plugged as NUMA node now.  But, how to use PMEM as NUMA
node effectively and efficiently is worth exploring. 

There have been a couple of proposals posted on the mailing list [1] [2] [3].

I already posted two versions of patchset for demoting/promoting memory pages
between DRAM and PMEM before this topic was discussed at LSF/MM 2019
(https://lwn.net/Articles/787418/).  I do appreciate all the great suggestions
from the community.  This updated version implemented the most discussion,
please see the below design section for the details.


Changelog
=========
v2 --> v3:
* Introduced "migrate mode" for node reclaim.  Just do demotion when
  "migrate mode" is specified per Michal Hocko and Mel Gorman.
* Introduced "migrate target" concept for VM per Mel Gorman.  The memory nodes
  which are under DRAM in the hierarchy (i.e. lower bandwidth, higher latency,
  larger capacity and cheaper than DRAM) are considered as "migrate target"
  nodes.  When "migrate mode" is on, memory reclaim would demote pages to
  the "migrate target" nodes.
* Dropped "twice access" promotion patch per Michal Hocko.
* Changed the subject for the patchset to reflect the update.
* Rebased to 5.2-rc1.

v1 --> v2:
* Dropped the default allocation node mask.  The memory placement restriction
  could be achieved by mempolicy or cpuset.
* Dropped the new mempolicy since its semantic is not that clear yet.
* Dropped PG_Promote flag.
* Defined N_CPU_MEM nodemask for the nodes which have both CPU and memory.
* Extended page_check_references() to implement "twice access" check for
  anonymous page in NUMA balancing path.
* Reworked the memory demotion code.

v2: https://lore.kernel.org/linux-mm/1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com/
v1: https://lore.kernel.org/linux-mm/1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com/


Design
======
With the development of new memory technology, we could have cheaper and
larger memory device on the system, which may have higher latency and lower
bandwidth than DRAM, i.e. PMEM.  It could be used as persistent storage or
volatile memory.

It fits into the memory hierarchy as a second tier memory.  The patchset
tries to explore an approach to utilize such memory to improve the memory
placement.  Basically, the patchset tries to achieve this goal by doing
memory promotion/demotion via NUMA balancing and memory reclaim.

Introduce a new "migrate" mode for node reclaim.  When DRAM has memory
pressure, demote pages to PMEM via node reclaim path if "migrate" mode is
on.  Then NUMA balancing will promote pages to DRAM as long as the page is
referenced again.  The memory pressure on PMEM node would push the inactive
pages of PMEM to disk via swap.

Introduce "primary" node and "migrate target" node concepts for VM (patch 1/9
and 2/9).  The "primary" node is the node which has both CPU and memory.  The
"migrate target" node is cpuless node and under DRAM in memory hierarchy
(i.e. PMEM may be a suitable one, which has lower bandwidth, higher latency,
larger capacity and is cheaper than DRAM).  The firmware is effectively going
to enforce "cpu-less" nodes for any memory range that has differentiated
performance from the conventional memory pool, or differentiated performance
for a specific initiator.

Defined "N_CPU_MEM" nodemask for the "primary" nodes in order to distinguish
with cpuless nodes (memory only, i.e. PMEM nodes) and memoryless nodes (some
architectures, i.e. Power, may have memoryless nodes).

It is a little bit hard to find out suitable "migrate target" node since this
needs firmware exposes the physical characteristics of the memory devices.
I'm not quite sure what should be the best way and if it is ready to use now
or not.  Since PMEM is the only available such device for now, so it sounds
retrieving the information from SRAT is the easiest way.  We may figure out a
better way in the future.

The promotion/demotion happens only between "primary" nodes and "migrate target"
nodes.  No promotion/demotion between "migrate target" nodes and promotion from
"primary" nodes to "migrate target" nodes and demotion from "primary" nodes to
"migrate target" nodes.  This guarantees there is no cycles for memory demotion
or promotion.

According to the discussion at LFS/MM 2019, "there should only be one node to
which pages could be migrated".   So reclaim code just tries to demote the pages
to the closest "migrate target" node and only tries once.  Otherwise "if all
nodes in the system were on a fallback list, a page would have to move through
every possible option - each RAM-based node and each persistent-memory node -
before actually being reclaimed. It would be necessary to maintain the history
of where each page has been, and would be likely to disrupt other workloads on
the system".  This is what v2 patchset does, so keep doing it in the same way
in v3.

The demotion code moves all the migration candidate pages into one single list,
then migrate them together (including THP).  This would improve the efficiency
of migration according to Zi Yan's research.  If the migration fails, the
unmigrated pages will be put back to LRU.

Use the most opotimistic GFP flags to allocate pages on the "migrate target"
node.
 
To reduce the failure rate of demotion, check if the "migrate target" node is
contended or not.  If the "migrate target" node is contended, just do swap
instead of migrate.  If migration is failed due to -ENOMEM, mark the node as
contended.  The contended flag will be cleared once the node get balanced.

For now "migrate" mode is not compatible with cpuset and mempolicy since it
is hard to get the process's task_struct from struct page.  The cpuset and
process's mempolicy are stored in task_struct instead of mm_struct.

Anonymous page only for the time being since NUMA balancing can't promote
unmapped page cache.  Page cache can be demoted easily, but promotion is a
question, may do it via mark_page_accessed().

Added vmstat counters for pgdemote_kswapd, pgdemote_direct and
numa_pages_promoted.

There are definitely still a lot of details need to be sorted out.  Any
comment is welcome.


Test
====
The stress test was done with mmtests + applications workload (i.e. sysbench,
grep, etc).

Generate memory pressure by running mmtest's usemem-stress-numa-compact,
then run other applications as workload to stress the promotion and demotion
path.  The machine was still alive after the stress test had been running for
~30 hours.  The /proc/vmstat also shows:

...
pgdemote_kswapd 3316563
pgdemote_direct 1930721
...
numa_pages_promoted 81838


[1]: https://lore.kernel.org/linux-mm/20181226131446.330864849@intel.com/
[2]: https://lore.kernel.org/linux-mm/20190321200157.29678-1-keith.busch@intel.com/
[3]: https://lore.kernel.org/linux-mm/20190404071312.GD12864@dhcp22.suse.cz/T/#me1c1ed102741ba945c57071de9749e16a76e9f3d


Yang Shi (9):
      mm: define N_CPU_MEM node states
      mm: Introduce migrate target nodemask
      mm: page_alloc: make find_next_best_node find return migration target node
      mm: migrate: make migrate_pages() return nr_succeeded
      mm: vmscan: demote anon DRAM pages to migration target node
      mm: vmscan: don't demote for memcg reclaim
      mm: vmscan: check if the demote target node is contended or not
      mm: vmscan: add page demotion counter
      mm: numa: add page promotion counter

 Documentation/sysctl/vm.txt    |   6 +++
 drivers/acpi/numa.c            |  12 +++++
 drivers/base/node.c            |   4 ++
 include/linux/gfp.h            |  12 +++++
 include/linux/migrate.h        |   6 ++-
 include/linux/mmzone.h         |   3 ++
 include/linux/nodemask.h       |   4 +-
 include/linux/vm_event_item.h  |   3 ++
 include/linux/vmstat.h         |   1 +
 include/trace/events/migrate.h |   3 +-
 mm/compaction.c                |   3 +-
 mm/debug.c                     |   1 +
 mm/gup.c                       |   4 +-
 mm/huge_memory.c               |   4 ++
 mm/internal.h                  |  23 ++++++++
 mm/memory-failure.c            |   7 ++-
 mm/memory.c                    |   4 ++
 mm/memory_hotplug.c            |  10 +++-
 mm/mempolicy.c                 |   7 ++-
 mm/migrate.c                   |  33 ++++++++----
 mm/page_alloc.c                |  20 +++++--
 mm/vmscan.c                    | 186 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c                    |  14 ++++-
 23 files changed, 323 insertions(+), 47 deletions(-)


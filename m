Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1830EC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49C38218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49C38218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE36D6B0005; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93306B0006; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A8376B0007; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5016B0005
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z26so4243582pfa.7
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=fbwI6VL7D0wXw1BUoD4i9NBDXURQf0tF/4DcHWBeBsI=;
        b=GMXKrUnadzAcTlcKlmxWKzWjULJz6XqL84Zy/EniHCJzhKflGOr6tfDuR78IvCciHn
         Tv8kC9ckm5mJ/T8y/q2VmjcoUQG15MxwEqZmthlQCFDDSbVo+VjvhvCb4kRTAIq/5ldO
         x7xDpB71k9KidOC2eLWRCamMZ5sQOkVIIj2QVm/uwN25mdCEE0GDGM9k75wcCD50BOM2
         838dhccEaGMPthTekk+zM2pRS1Ap3dXiASDTPa8Mk2Nf0BxRBzsHxYiRU+OJNediDqpW
         pyb7LWp94eEuc240mOJCqg958hoBRJ8wdPljE9jhG4q8zy626Z9eMH+9nk4bsZglC+zI
         87vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWEVWXcFt/LA1lueoVB6P9OrtKebY+aUlMakRuHpiDkY8yLFYTp
	Bsrj5QOVJa1rgFJtiBuMYYugXAcZPxKia8THKhz55QN8HCNeJFFgvoGDBQx1Yxt2f153gp/CfuN
	JHbt46/RlpoDF/naN/IPrxpGkZFimP7IguBMs3yPngk6Cpq3sAiSC5rVgF+YmvxD1aw==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr13283383plk.126.1553316304978;
        Fri, 22 Mar 2019 21:45:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBpFmWsh6ZfSdEW/7RPgP0IPatkVv/vDF/WP5A5ZKYnJ/BtdN+GaJRiUE9Eoc+6uVtOzVU
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr13283322plk.126.1553316303879;
        Fri, 22 Mar 2019 21:45:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316303; cv=none;
        d=google.com; s=arc-20160816;
        b=g9MEgzaka4tNhoBsqJqTofrR+VddNZ8aC60fEeUtsXilSX1reQX2rt/KMUrMC/8HFE
         8j3aV2QPmV5FHaJCJsE46G9fwQjBd3C3MbeVtYB0Gs9MKwBhWlrggyOsX21KQzS9Go+z
         eX+c8BQP6ByHqPK7PUo72ebY1hVMVbbgdidnfJpzzH42IcN2dMSeQZUfISR3vm67Kp14
         bPVxbHKlhz6clwx3WE6vn8f7VjBcl96yLUa/hw3kqvYcxM/Ynr55iHhxaJ6i65nSGtzu
         TAxYtLhGXwKA0QJUuBDIAdPyipa2Qn7+FxASdMr5LNW5n0bTF7Do2cyEGYGmr0PmNiT4
         dVDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=fbwI6VL7D0wXw1BUoD4i9NBDXURQf0tF/4DcHWBeBsI=;
        b=bAySg7He6vZGRrmXqM9DOpnvE8l7eKLrB1efkkTijM/GyVgB6mqOSsb7wD7mVJBxHE
         1l+1VhcgnPc0uw4NmNeAC+sPXjOgpnalfgATXH94Tp9RWJX2uuFfW6TOjSfWC2qnPGmL
         f26VyNbhkkqrkt0rdRvjn6KiU3GmIx5OnacICcIfkuF3Gij3ktmT7NIhG8//jlLtC3Jd
         JgR1IxKpd2q/BkUfFRmVi/tDXgybfASg2R/FGecUHME7O4lbkurdbDYo84YL16FFm6WB
         oOV3dBUDBKF7HfEtep6XiYKyk/crYIMbdoFQGpFh4kVFLfTWOOLg+ArW5S3Bnq+SrK32
         81Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id w69si3653369pgd.11.2019.03.22.21.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:01 +0800
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
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Date: Sat, 23 Mar 2019 12:44:25 +0800
Message-Id: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


With Dave Hansen's patches merged into Linus's tree

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4

PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
effectively and efficiently is still a question. 

There have been a couple of proposals posted on the mailing list [1] [2].

The patchset is aimed to try a different approach from this proposal [1]
to use PMEM as NUMA nodes.

The approach is designed to follow the below principles:

1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.

2. DRAM first/by default. No surprise to existing applications and default
running. PMEM will not be allocated unless its node is specified explicitly
by NUMA policy. Some applications may be not very sensitive to memory latency,
so they could be placed on PMEM nodes then have hot pages promote to DRAM
gradually.

3. Compatible with current NUMA policy semantics.

4. Don't assume hardware topology. But, the patchset still assumes two tier
heterogeneous memory system. I understood generalizing multi tier heterogeneous
memory had been discussed before. I do agree that is preferred eventually.
However, currently kernel doesn't have such capability yet. When HMAT is fully
ready we definitely could extract NUMA topology from it.

5. Control memory allocation and hot/cold pages promotion/demotion on per VMA
basis.

To achieve the above principles, the design can be summarized by the
following points:

1. Per node global fallback zonelists (include both DRAM and PMEM), use
def_alloc_nodemask to exclude non-DRAM nodes from default allocation unless
they are specified by mempolicy. Currently kernel just can distinguish volatile
and non-volatile memory. So, just build the nodemask by SRAT flag. In the
future it may be better to build the nodemask with more exposed hardware
information, i.e. HMAT attributes so that it could be extended to multi tier
memory system easily.

2. Introduce a new mempolicy, called MPOL_HYBRID to keep other mempolicy
semantics intact. We would like to have memory placement control on per process
or even per VMA granularity. So, mempolicy sounds more reasonable than madvise.
The new mempolicy is mainly used for launching processes on PMEM nodes then
migrate hot pages to DRAM nodes via NUMA balancing. MPOL_BIND could bind to
PMEM nodes too, but migrating to DRAM nodes would just break the semantic of
it. MPOL_PREFERRED can't constraint the allocation to PMEM nodes. So, it sounds
a new mempolicy is needed to fulfill the usecase.

3. The new mempolicy would promote pages to DRAM via NUMA balancing. IMHO, I
don't think kernel is a good place to implement sophisticated hot/cold page
distinguish algorithm due to the complexity and overhead. But, kernel should
have such capability. NUMA balancing sounds like a good start point.

4. Promote twice faulted page. Use PG_promote to track if a page is faulted
twice. This is an optimization to NUMA balancing to reduce the migration
thrashing and overhead for migrating from PMEM.

5. When DRAM has memory pressure, demote page to PMEM via page reclaim path.
This is quite similar to other proposals. Then NUMA balancing will promote
page to DRAM as long as the page is referenced again. But, the
promotion/demotion still assumes two tier main memory. And, the demotion may
break mempolicy.

6. Anonymous page only for the time being since NUMA balancing can't promote
unmapped page cache.

The patchset still misses a some pieces and is pre-mature, but I would like to
post to LKML to gather more feedback and comments and have more eyes on it to
make sure I'm on the right track.

Any comment is welcome.


TODO:

1. Promote page cache. There are a couple of ways to handle this in kernel,
i.e. promote via active LRU in reclaim path on PMEM node, or promote in
mark_page_accessed().

2. Promote/demote HugeTLB. Now HugeTLB is not on LRU and NUMA balancing just
skips it.

3. May place kernel pages (i.e. page table, slabs, etc) on DRAM only.

4. Support the new mempolicy in userspace tools, i.e. numactl.


[1]: https://lore.kernel.org/linux-mm/20181226131446.330864849@intel.com/
[2]: https://lore.kernel.org/linux-mm/20190321200157.29678-1-keith.busch@intel.com/


Yang Shi (10):
      mm: control memory placement by nodemask for two tier main memory
      mm: mempolicy: introduce MPOL_HYBRID policy
      mm: mempolicy: promote page to DRAM for MPOL_HYBRID
      mm: numa: promote pages to DRAM when it is accessed twice
      mm: page_alloc: make find_next_best_node could skip DRAM node
      mm: vmscan: demote anon DRAM pages to PMEM node
      mm: vmscan: add page demotion counter
      mm: numa: add page promotion counter
      doc: add description for MPOL_HYBRID mode
      doc: elaborate the PMEM allocation rule

 Documentation/admin-guide/mm/numa_memory_policy.rst |  10 ++++
 Documentation/vm/numa.rst                           |   7 ++-
 arch/x86/mm/numa.c                                  |   1 +
 drivers/acpi/numa.c                                 |   8 +++
 include/linux/migrate.h                             |   1 +
 include/linux/mmzone.h                              |   3 ++
 include/linux/page-flags.h                          |   4 ++
 include/linux/vm_event_item.h                       |   3 ++
 include/linux/vmstat.h                              |   1 +
 include/trace/events/migrate.h                      |   3 +-
 include/trace/events/mmflags.h                      |   3 +-
 include/uapi/linux/mempolicy.h                      |   1 +
 mm/debug.c                                          |   1 +
 mm/huge_memory.c                                    |  14 ++++++
 mm/internal.h                                       |  33 ++++++++++++
 mm/memory.c                                         |  12 +++++
 mm/mempolicy.c                                      |  74 ++++++++++++++++++++++++---
 mm/page_alloc.c                                     |  33 +++++++++---
 mm/vmscan.c                                         | 113 +++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c                                         |   3 ++
 20 files changed, 295 insertions(+), 33 deletions(-)


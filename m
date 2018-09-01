Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC4D6B5FDA
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r130-v6so6177500pgr.13
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d32-v6si13682201pla.93.2018.09.01.19.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:09 -0700 (PDT)
Message-Id: <20180901112818.126790961@intel.com>
Date: Sat, 01 Sep 2018 19:28:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 0/5] introduce /proc/PID/idle_bitmap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, Fengguang Wu <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

This new /proc/PID/idle_bitmap interface aims to complement the current global
/sys/kernel/mm/page_idle/bitmap. To enable efficient user space driven migrations.

The pros and cons will be discussed in changelog of "[PATCH] proc: introduce
/proc/PID/idle_bitmap". The driving force is to improve efficiency by 10+
times, so that hot/cold page tracking can be done in some regular intervals in
user space w/o too much overheads. Making it possible for some user space
daemon to do regular page migration between NUMA nodes of different speeds.

Note it's not about NUMA migration between local and remote nodes -- we already
have NUMA balancing for that. This interface and user space migration daemon
targets for NUMA nodes made of different mediums -- ie. DIMM and NVDIMM(*) --
with larger performance gaps. Basic policy will be "move hot pages to DIMM;
cold pages to NVDIMM".

Since NVDIMMs size can easily reach several Terabytes, working set tracking
efficiency will matter and be challeging.

(*) Here we use persistent memory (PMEM) w/o using its persistence.
Persistence is good to have, however it requires modifying applications.
Upcoming NVDIMM products like Intel Apache Pass (AEP) will be more cost and energy
effective than DRAM, but slower. Merely using it in form of NUMA memory node
could immediately benefit many workloads. For example, warm but not hot apps,
workloads with sharp hot/cold page distribution (good for migration), or relies
more on memory size than latency and bandwidth, and do more reads than writes.

This is an early RFC version to collect feedbacks. It's complete enough to demo
the basic ideas and performance, however not usable yet.

Regards,
Fengguang

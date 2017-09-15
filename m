Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEEF6B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:24:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so3490757pff.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 02:24:48 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o1si419828pll.166.2017.09.15.02.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 02:24:46 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 0/3] Handle zone statistics distinctively based-on
Date: Fri, 15 Sep 2017 17:23:23 +0800
Message-Id: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Kemi Wang <kemi.wang@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Each page allocation updates a set of per-zone statistics with a call to
zone_statistics(). As discussed in 2017 MM summit.
A link to the MM summit slides:
http://people.netfilter.org/hawk/presentations/MM-summit2017/MM-summit2017
-JesperBrouer.pdf

This is the second step for optimizing zone statistics, the first patch
introduces a tunable interface that allow VM statistics configurable(see
the first patch for details):
if vmstat_mode = auto, automatic detection of VM statistics
if vmstat_mode = strict, keep all the VM statistics
if vmstat_mode = coarse, ignore unimportant VM statistics
As suggested by Dave Hansen and Ying Huang.

With this interface, the second patch handles numa counters distinctively
according to different vmstat mode, and the test result shows about 4.8%
(185->176) drop of cpu cycles with single thread and 8.1% (343->315) drop
of of cpu cycles with 88 threads for single page allocation.

The third patch updates ABI document accordingly.

Kemi Wang (3):
  mm, sysctl: make VM stats configurable
  mm: Handle numa statistics distinctively based-on different VM stats
    modes
  sysctl/vm.txt: Update document

 Documentation/sysctl/vm.txt |  26 ++++++++++
 drivers/base/node.c         |   2 +
 include/linux/vmstat.h      |  20 +++++++
 kernel/sysctl.c             |   7 +++
 mm/page_alloc.c             |  13 +++++
 mm/vmstat.c                 | 124 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 192 insertions(+)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

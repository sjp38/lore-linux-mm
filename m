Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CB7256B007B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 22:59:24 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so11433125pdi.16
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:59:24 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sp5si3597024pbb.210.2014.04.16.19.59.22
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 19:59:23 -0700 (PDT)
Date: Thu, 17 Apr 2014 10:59:12 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/3] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v4
Message-ID: <20140417025912.GA7797@localhost>
References: <1397572876-1610-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397572876-1610-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 15, 2014 at 03:41:13PM +0100, Mel Gorman wrote:
> Fengguang Wu found that an earlier version crashed on his
> tests. This version passed tests running with DEBUG_VM and
> DEBUG_PAGEALLOC. Fengguang, another test would be appreciated and
> if it helps this series is the mm-numa-use-high-bit-v4r3 branch in
> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

Hi Mel,

We noticed the below changes. The last_state.is_incomplete_run 0=>1 change
means the test box failed to boot up. Unfortunately we don't have
serial console output of this testbox, it may be hard to check the
root cause. Anyway, I'll try to bisect it to make the debug easier.

Fengguang

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
    864.70 ~ 5%     -27.5%     627.28       snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqwr-sync
    178.20 ~104%     -99.9%       0.13       snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
   1042.90 ~22%     -39.8%     627.41       TOTAL fileio.request_latency_max_ms

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
         0           +Inf%          1 ~ 0%  lkp-a04/fake/boot/1
         0           +Inf%          1 ~ 0%  TOTAL last_state.is_incomplete_run

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
        10 ~10%   +1560.0%        166       lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
        10 ~10%   +1560.0%        166       TOTAL ftrace.writeback_single_inode.sdg.age

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
      9662 ~19%  +17955.3%    1744594       lkp-snb01/micro/hackbench/1600%-process-socket
      4235 ~22%   +6497.6%     279443       lkp-snb01/micro/hackbench/1600%-threads-socket
      3842 ~ 4%   +1468.7%      60278       lkp-snb01/micro/hackbench/50%-process-pipe
     17181 ~ 3%    +393.1%      84722       lkp-snb01/micro/hackbench/50%-process-socket
     34922 ~10%   +6111.0%    2169037       TOTAL cpuidle.POLL.time

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
        34 ~ 1%     +61.8%         56       lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
        34 ~ 1%     +61.8%         56       TOTAL ftrace.balance_dirty_pages.sdl.period

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       312 ~ 0%     -10.4%        280       snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
       312 ~ 0%     -10.4%        280       TOTAL vmstat.memory.buff

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       350 ~ 3%   +3056.4%      11057       lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-100dd
       340 ~ 2%   +1792.2%       6443       lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
       690 ~ 3%   +2433.3%      17500       TOTAL interrupts.125:PCI-MSI-edge.eth1-TxRx-4

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       310 ~ 1%   +2021.3%       6595       lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-1dd
       310 ~ 1%   +2021.3%       6595       TOTAL interrupts.127:PCI-MSI-edge.eth1-TxRx-6

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       157 ~ 4%    +118.4%        344       lkp-sb03/micro/nepim/300s-100%-udp
       157 ~ 4%    +118.4%        344       TOTAL interrupts.101:PCI-MSI-edge.eth1-TxRx-1

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
     40.55 ~ 0%     -50.6%      20.02       lkp-a05/fake/boot/1
     40.55 ~ 0%     -50.6%      20.02       TOTAL boottime.dhcp

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
     60.79 ~ 0%     -47.8%      31.74       lkp-a05/fake/boot/1
     60.79 ~ 0%     -47.8%      31.74       TOTAL boottime.boot

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       186 ~ 0%     -46.1%        100       lkp-a05/fake/boot/1
       186 ~ 0%     -46.1%        100       TOTAL boottime.idle

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       157 ~ 3%     +84.7%        290       lkp-a05/micro/iperf/300s-tcp
       157 ~ 3%     +84.7%        290       TOTAL interrupts.50:PCI-MSI-edge.eth0-tx-0

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
    212639 ~ 1%     +48.1%     314887       lkp-sb03/micro/nepim/300s-25%-udp
    212639 ~ 1%     +48.1%     314887       TOTAL interrupts.LOC

          v3.14  685561ea2d015cb90c45504ec  
---------------  -------------------------  
       207 ~ 2%     +35.8%        282       lkp-a05/micro/iperf/300s-tcp
       207 ~ 2%     +35.8%        282       TOTAL interrupts.47:PCI-MSI-edge.eth0-rx-1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

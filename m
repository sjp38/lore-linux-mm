Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7090A6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 02:47:07 -0500 (EST)
Received: by pasz6 with SMTP id z6so46397270pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 23:47:07 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id zj1si235430pbb.30.2015.11.03.23.47.06
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 23:47:06 -0800 (PST)
From: "Huang\, Ying" <ying.huang@linux.intel.com>
Subject: Re: [PATCH] tmpfs: avoid a little creat and stat slowdown
References: <alpine.LSU.2.11.1510291208000.3475@eggly.anvils>
Date: Wed, 04 Nov 2015 15:47:03 +0800
In-Reply-To: <alpine.LSU.2.11.1510291208000.3475@eggly.anvils> (Hugh Dickins's
	message of "Thu, 29 Oct 2015 12:13:35 -0700 (PDT)")
Message-ID: <87bnbagqa0.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, Yu Zhao <yuzhao@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> LKP reports that v4.2 commit afa2db2fb6f1 ("tmpfs: truncate prealloc
> blocks past i_size") causes a 14.5% slowdown in the AIM9 creat-clo
> benchmark.
>
> creat-clo does just what you'd expect from the name, and creat's O_TRUNC
> on 0-length file does indeed get into more overhead now shmem_setattr()
> tests "0 <= 0" instead of "0 < 0".
>
> I'm not sure how much we care, but I think it would not be too VW-like
> to add in a check for whether any pages (or swap) are allocated: if none
> are allocated, there's none to remove from the radix_tree.  At first I
> thought that check would be good enough for the unmaps too, but no: we
> should not skip the unlikely case of unmapping pages beyond the new EOF,
> which were COWed from holes which have now been reclaimed, leaving none.
>
> This gives me an 8.5% speedup: on Haswell instead of LKP's Westmere,
> and running a debug config before and after: I hope those account for
> the lesser speedup.
>
> And probably someone has a benchmark where a thousand threads keep on
> stat'ing the same file repeatedly: forestall that report by adjusting
> v4.3 commit 44a30220bc0a ("shmem: recalculate file inode when fstat")
> not to take the spinlock in shmem_getattr() when there's no work to do.
>
> Reported-by: Ying Huang <ying.huang@linux.intel.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Hi, Hugh,

Thanks a lot for your support!  The test on LKP shows that this patch
restores a big part of the regression!  In following list,

c435a390574d012f8d30074135d8fcc6f480b484: is parent commit
afa2db2fb6f15f860069de94a1257db57589fe95: is the first bad commit has
performance regression.
43819159da2b77fedcf7562134d6003dccd6a068: is the fixing patch

=========================================================================================
compiler/cpufreq_governor/kconfig/rootfs/tbox_group/test/testcase/testtime:
  gcc-4.9/performance/x86_64-rhel/debian-x86_64-2015-02-07.cgz/lkp-wsx02/creat-clo/aim9/300s

commit: 
  c435a390574d012f8d30074135d8fcc6f480b484
  afa2db2fb6f15f860069de94a1257db57589fe95
  43819159da2b77fedcf7562134d6003dccd6a068

c435a390574d012f afa2db2fb6f15f860069de94a1 43819159da2b77fedcf7562134 
---------------- -------------------------- -------------------------- 
         %stddev     %change         %stddev     %change         %stddev
             \          |                \          |                \  
    563556 A+-  1%     -12.5%     493033 A+-  5%      -5.6%     531968 A+-  1%  aim9.creat-clo.ops_per_sec
     11836 A+-  7%     +11.4%      13184 A+-  7%     +15.0%      13608 A+-  5%  numa-meminfo.node1.SReclaimable
  10121526 A+-  3%     -12.1%    8897097 A+-  5%      -4.1%    9707953 A+-  4%  proc-vmstat.pgalloc_normal
      9.34 A+-  4%     -11.4%       8.28 A+-  3%      -4.8%       8.88 A+-  2%  time.user_time
      3480 A+-  3%      -2.5%       3395 A+-  1%     -28.5%       2488 A+-  3%  vmstat.system.cs
    203275 A+- 17%      -6.8%     189453 A+-  5%     -34.4%     133352 A+- 11%  cpuidle.C1-NHM.usage
   8081280 A+-129%     -93.3%     538377 A+- 97%     +31.5%   10625496 A+-106%  cpuidle.C1E-NHM.time
      3144 A+- 58%    +619.0%      22606 A+- 56%    +903.9%      31563 A+-  0%  numa-vmstat.node0.numa_other
      2958 A+-  7%     +11.4%       3295 A+-  7%     +15.0%       3401 A+-  5%  numa-vmstat.node1.nr_slab_reclaimable
     45074 A+-  5%     -43.4%      25494 A+- 57%     -68.7%      14105 A+-  2%  numa-vmstat.node2.numa_other
     56140 A+-  0%      +0.0%      56158 A+-  0%     -94.4%       3120 A+-  0%  slabinfo.Acpi-ParseExt.active_objs
      1002 A+-  0%      +0.0%       1002 A+-  0%     -92.0%      80.00 A+-  0%  slabinfo.Acpi-ParseExt.active_slabs
     56140 A+-  0%      +0.0%      56158 A+-  0%     -94.4%       3120 A+-  0%  slabinfo.Acpi-ParseExt.num_objs
      1002 A+-  0%      +0.0%       1002 A+-  0%     -92.0%      80.00 A+-  0%  slabinfo.Acpi-ParseExt.num_slabs
      1079 A+-  5%     -10.8%     962.00 A+- 10%    -100.0%       0.00 A+- -1%  slabinfo.blkdev_ioc.active_objs
      1079 A+-  5%     -10.8%     962.00 A+- 10%    -100.0%       0.00 A+- -1%  slabinfo.blkdev_ioc.num_objs
    110.67 A+- 39%     +74.4%     193.00 A+- 46%    +317.5%     462.00 A+-  8%  slabinfo.blkdev_queue.active_objs
    189.33 A+- 23%     +43.7%     272.00 A+- 33%    +151.4%     476.00 A+- 10%  slabinfo.blkdev_queue.num_objs
      1129 A+- 10%      -1.9%       1107 A+-  7%     +20.8%       1364 A+-  6%  slabinfo.blkdev_requests.active_objs
      1129 A+- 10%      -1.9%       1107 A+-  7%     +20.8%       1364 A+-  6%  slabinfo.blkdev_requests.num_objs
      1058 A+-  3%     -10.3%     949.00 A+-  9%    -100.0%       0.00 A+- -1%  slabinfo.file_lock_ctx.active_objs
      1058 A+-  3%     -10.3%     949.00 A+-  9%    -100.0%       0.00 A+- -1%  slabinfo.file_lock_ctx.num_objs
      4060 A+-  1%      -2.1%       3973 A+-  1%     -10.5%       3632 A+-  1%  slabinfo.files_cache.active_objs
      4060 A+-  1%      -2.1%       3973 A+-  1%     -10.5%       3632 A+-  1%  slabinfo.files_cache.num_objs
     10001 A+-  0%      -0.3%       9973 A+-  0%     -61.1%       3888 A+-  0%  slabinfo.ftrace_event_field.active_objs
     10001 A+-  0%      -0.3%       9973 A+-  0%     -61.1%       3888 A+-  0%  slabinfo.ftrace_event_field.num_objs
      1832 A+-  0%      +0.4%       1840 A+-  0%    -100.0%       0.00 A+- -1%  slabinfo.ftrace_event_file.active_objs
      1832 A+-  0%      +0.4%       1840 A+-  0%    -100.0%       0.00 A+- -1%  slabinfo.ftrace_event_file.num_objs
      1491 A+-  5%      -2.3%       1456 A+-  6%     +12.0%       1669 A+-  4%  slabinfo.mnt_cache.active_objs
      1491 A+-  5%      -2.3%       1456 A+-  6%     +12.0%       1669 A+-  4%  slabinfo.mnt_cache.num_objs
    126.33 A+- 19%     +10.2%     139.17 A+-  9%    -100.0%       0.00 A+- -1%  slabinfo.nfs_commit_data.active_objs
    126.33 A+- 19%     +10.2%     139.17 A+-  9%    -100.0%       0.00 A+- -1%  slabinfo.nfs_commit_data.num_objs
     97.17 A+- 20%      -9.1%      88.33 A+- 28%    -100.0%       0.00 A+- -1%  slabinfo.user_namespace.active_objs
     97.17 A+- 20%      -9.1%      88.33 A+- 28%    -100.0%       0.00 A+- -1%  slabinfo.user_namespace.num_objs

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 749976B0288
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:42 -0400 (EDT)
Received: by qkx62 with SMTP id 62so23314081qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:42 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id 145si2502147qhu.43.2015.05.22.15.23.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:41 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so23414319qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:40 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET 2/3 v3 block/for-4.2/core] writeback: cgroup writeback backpressure propagation
Date: Fri, 22 May 2015 18:23:17 -0400
Message-Id: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

Changes from the last take[L] are

* Rebased on top of block/for-4.2/core.

While the previous patchset[1] implemented cgroup writeback support,
the IO back pressure propagation mechanism implemented in
balance_dirty_pages() and its subroutines isn't yet aware of cgroup
writeback.

Processes belonging to a memcg may have access to only subset of total
memory available in the system and not factoring this into dirty
throttling rendered it completely ineffective for processes under
memcg limits and memcg ended up building a separate ad-hoc degenerate
mechanism directly into vmscan code to limit page dirtying.

This patchset refactors the dirty throttling logic implemented in
balance_dirty_pages() and its subroutines os that it can handle both
global and memcg memory domains.  Dirty throttling mechanism is
applied against both the global and memcg constraints and the more
restricted of the two is used for actual throttling.

This makes the dirty throttling mechanism operational for memcg
domains including writeback-bandwidth-proportional dirty page
distribution inside them.

This patchset contains the following 19 patches.

 0001-memcg-make-mem_cgroup_read_-stat-event-iterate-possi.patch
 0002-writeback-clean-up-wb_dirty_limit.patch
 0003-writeback-reorganize-__-wb_update_bandwidth.patch
 0004-writeback-implement-wb_domain.patch
 0005-writeback-move-global_dirty_limit-into-wb_domain.patch
 0006-writeback-consolidate-dirty-throttle-parameters-into.patch
 0007-writeback-add-dirty_throttle_control-wb_bg_thresh.patch
 0008-writeback-make-__wb_calc_thresh-take-dirty_throttle_.patch
 0009-writeback-add-dirty_throttle_control-pos_ratio.patch
 0010-writeback-add-dirty_throttle_control-wb_completions.patch
 0011-writeback-add-dirty_throttle_control-dom.patch
 0012-writeback-make-__wb_writeout_inc-and-hard_dirty_limi.patch
 0013-writeback-separate-out-domain_dirty_limits.patch
 0014-writeback-move-over_bground_thresh-to-mm-page-writeb.patch
 0015-writeback-update-wb_over_bg_thresh-to-use-wb_domain-.patch
 0016-writeback-implement-memcg-wb_domain.patch
 0017-writeback-reset-wb_domain-dirty_limit-_tstmp-when-me.patch
 0018-writeback-implement-memcg-writeback-domain-based-thr.patch
 0019-mm-vmscan-disable-memcg-direct-reclaim-stalling-if-c.patch

0001-0003 are prep patches.

0004-0015 refactors dirty throttling logic so that it operates on
wb_domain.

0016-0019 implement memcg wb_domain.

This patchset is on top of

  block/for-4.2/core b04a5636a665 ("block: replace trylock with mutex_lock in blkdev_reread_part()")
+ [1] [PATCHSET 1/3 v4 block/for-4.2/core] writeback: cgroup writeback support

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-backpressure-20150522

diffstat follows.  Thanks.

 fs/fs-writeback.c                |   32 -
 include/linux/backing-dev-defs.h |    1 
 include/linux/memcontrol.h       |   21 +
 include/linux/writeback.h        |   84 +++-
 include/trace/events/writeback.h |    7 
 mm/backing-dev.c                 |   15 
 mm/memcontrol.c                  |  145 +++++--
 mm/page-writeback.c              |  744 +++++++++++++++++++++++++--------------
 mm/vmscan.c                      |   51 ++
 9 files changed, 739 insertions(+), 361 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/1428350674-8303-1-git-send-email-tj@kernel.org
[1] http://lkml.kernel.org/g/1432329245-5844-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

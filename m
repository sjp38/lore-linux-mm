Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2186B0071
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:04:39 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31105227qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:39 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id f6si5138553qga.113.2015.04.06.13.04.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:04:38 -0700 (PDT)
Received: by qkx62 with SMTP id 62so31168871qkx.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:04:37 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET 2/3 v2 block/for-4.1/core] writeback: cgroup writeback backpressure propagation
Date: Mon,  6 Apr 2015 16:04:15 -0400
Message-Id: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello,

Changes from the last take[L] are

* 0002-writeback-clean-up-wb_dirty_limit.patch added.

* 0008-writeback-make-__wb_calc_thresh-take-dirty_throttle_.patch was
  scaling the wrong parameter leading to weird throttling behavior.
  Fixed.

* 0019-mm-vmscan-disable-memcg-direct-reclaim-stalling-if-c.patch
  updated so that vmscan behavior when !CONFIG_CGROUP_WRITEBACK isn't
  affected.

While the previous patchset[2] implemented cgroup writeback support,
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

  block/for-4.1/core bfd343aa1718 ("blk-mq: don't wait in blk_mq_queue_enter() if __GFP_WAIT isn't set")
+ [1] [PATCH] writeback: fix possible underflow in write bandwidth calculation
+ [2] [PATCHSET 1/3 v3 block/for-4.1/core] writeback: cgroup writeback support

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-backpressure-20150322

diffstat follows.  Thanks.

 fs/fs-writeback.c                |   32 -
 include/linux/backing-dev-defs.h |    1 
 include/linux/memcontrol.h       |   21 +
 include/linux/writeback.h        |   82 +++-
 include/trace/events/writeback.h |    7 
 mm/backing-dev.c                 |    9 
 mm/memcontrol.c                  |  145 +++++--
 mm/page-writeback.c              |  722 +++++++++++++++++++++++++--------------
 mm/vmscan.c                      |  109 +----
 9 files changed, 716 insertions(+), 412 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/
[1] http://lkml.kernel.org/g/20150323041848.GA8991@htj.duckdns.org
[2] http://lkml.kernel.org/g/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

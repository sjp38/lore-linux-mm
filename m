Message-Id: <20070803123712.987126000@chello.nl>
Date: Fri, 03 Aug 2007 14:37:13 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/23] per device dirty throttling -v8
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Per device dirty throttling patches

These patches aim to improve balance_dirty_pages() and directly address three
issues:
  1) inter device starvation
  2) stacked device deadlocks
  3) inter process starvation

1 and 2 are a direct result from removing the global dirty limit and using
per device dirty limits. By giving each device its own dirty limit is will
no longer starve another device, and the cyclic dependancy on the dirty limit
is broken.

In order to efficiently distribute the dirty limit across the independant
devices a floating proportion is used, this will allocate a share of the total
limit proportional to the device's recent activity.

3 is done by also scaling the dirty limit proportional to the current task's
recent dirty rate.

Changes since -v7:
 - perpcu_counter renames (partially suggested by Linus)
 - percpu_counter error handling
 - bdi_init error handling
 - fwd port to .23-rc1-mm


---
#
# cleanups
#
nfs_congestion_fixup.patch
#
# percpu_counter rework
#
percpu_counter_add.patch
percpu_counter_batch.patch
percpu_counter_add64.patch
percpu_counter_set.patch
percpu_counter_sum_positive.patch
percpu_counter_sum.patch
percpu_counter_init.patch
percpu_counter_init_irq.patch
#
# per BDI dirty pages
#
bdi_init.patch
bdi_init_container.patch
bdi_init_mtd.patch
mtd-bdi-fixups.patch
bdi_mtdconcat.patch
bdi_stat.patch
bdi_stat_reclaimable.patch
bdi_stat_writeback.patch
bdi_stat_sysfs.patch
#
# floating proportions
#
proportions.patch
proportions_single.patch
#
# per BDI dirty
#
writeback-balance-per-backing_dev.patch
dirty_pages2.patch
#
# debug foo
#
bdi_stat_debug.patch


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

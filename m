Message-Id: <20070816074525.065850000@chello.nl>
Date: Thu, 16 Aug 2007 09:45:25 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/23] per device dirty throttling -v9
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

Changes since -v8:
 - cleanup of the proportion code
 - fix percpu_counter_add(&counter, -(unsigned long))
 - fix per task dirty rate code
 - fwd port to .23-rc2-mm2

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

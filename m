Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 86E946B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 00:39:40 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so2674842pbc.33
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 21:39:40 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id y3si8161098pbw.183.2014.06.19.21.39.39
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 21:39:39 -0700 (PDT)
Date: Fri, 20 Jun 2014 12:39:35 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 69/230] fs/ocfs2/dlm/dlmmaster.c:697:6: sparse: symbol
 'dlm_lockres_grab_inflight_worker' was not declared. Should it be static?
Message-ID: <20140620043935.GA26225@localhost>
References: <53a3b963.q9GAR9fXkW3Cu2/w%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a3b963.q9GAR9fXkW3Cu2/w%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xue jiufei <xuejiufei@huawei.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 1d26b017b74447dcc978ecb358fdc3a71887fc1c [69/230] ocfs2/dlm: do not purge lockres that is queued for assert master
reproduce: make C=1 CF=-D__CHECK_ENDIAN__

>> fs/ocfs2/dlm/dlmmaster.c:697:6: sparse: symbol 'dlm_lockres_grab_inflight_worker' was not declared. Should it be static?
>> fs/ocfs2/dlm/dlmmaster.c:705:6: sparse: symbol '__dlm_lockres_drop_inflight_worker' was not declared. Should it be static?
>> fs/ocfs2/dlm/dlmmaster.c:716:6: sparse: symbol 'dlm_lockres_drop_inflight_worker' was not declared. Should it be static?
   fs/ocfs2/dlm/dlmmaster.c:2690:20: sparse: context imbalance in 'dlm_empty_lockres' - unexpected unlock
   fs/ocfs2/dlm/dlmcommon.h:1137:9: sparse: context imbalance in 'dlm_reset_mleres_owner' - unexpected unlock
   fs/ocfs2/dlm/dlmmaster.c:3243:9: sparse: context imbalance in 'dlm_clean_master_list' - different lock contexts for basic block

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] ocfs2/dlm: dlm_lockres_grab_inflight_worker() can be static
TO: Xue jiufei <xuejiufei@huawei.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: ocfs2-devel@oss.oracle.com 
CC: linux-kernel@vger.kernel.org 

CC: Xue jiufei <xuejiufei@huawei.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 dlmmaster.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/ocfs2/dlm/dlmmaster.c b/fs/ocfs2/dlm/dlmmaster.c
index a302816..82abf0c 100644
--- a/fs/ocfs2/dlm/dlmmaster.c
+++ b/fs/ocfs2/dlm/dlmmaster.c
@@ -694,7 +694,7 @@ void __dlm_lockres_grab_inflight_worker(struct dlm_ctxt *dlm,
 			res->inflight_assert_workers);
 }
 
-void dlm_lockres_grab_inflight_worker(struct dlm_ctxt *dlm,
+static void dlm_lockres_grab_inflight_worker(struct dlm_ctxt *dlm,
 		struct dlm_lock_resource *res)
 {
 	spin_lock(&res->spinlock);
@@ -702,7 +702,7 @@ void dlm_lockres_grab_inflight_worker(struct dlm_ctxt *dlm,
 	spin_unlock(&res->spinlock);
 }
 
-void __dlm_lockres_drop_inflight_worker(struct dlm_ctxt *dlm,
+static void __dlm_lockres_drop_inflight_worker(struct dlm_ctxt *dlm,
 		struct dlm_lock_resource *res)
 {
 	assert_spin_locked(&res->spinlock);
@@ -713,7 +713,7 @@ void __dlm_lockres_drop_inflight_worker(struct dlm_ctxt *dlm,
 			res->inflight_assert_workers);
 }
 
-void dlm_lockres_drop_inflight_worker(struct dlm_ctxt *dlm,
+static void dlm_lockres_drop_inflight_worker(struct dlm_ctxt *dlm,
 		struct dlm_lock_resource *res)
 {
 	spin_lock(&res->spinlock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C40276B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:52:44 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t123so4617129wmt.2
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:52:44 -0800 (PST)
Received: from smtp.smtpout.orange.fr (smtp13.smtpout.orange.fr. [80.12.242.135])
        by mx.google.com with ESMTPS id 195si5035140wml.95.2018.03.05.11.52.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Mar 2018 11:52:43 -0800 (PST)
From: micky387 <mickaelsaibi@free.fr>
Subject: [PATCH 003/103] sched, treewide: Replace hardcoded nice values with MIN_NICE/MAX_NICE
Date: Mon,  5 Mar 2018 20:50:55 +0100
Message-Id: <1520279555-24656-3-git-send-email-mickaelsaibi@free.fr>
In-Reply-To: <1520279555-24656-1-git-send-email-mickaelsaibi@free.fr>
References: <commits for binder>
 <1520279555-24656-1-git-send-email-mickaelsaibi@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xda@vinschen.de
Cc: Dongsheng Yang <yangds.fnst@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, fcoe-devel@open-fcoe.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, nbd-general@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, openipmi-developer@lists.sourceforge.net, qla2xxx-upstream@qlogic.com, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

From: Dongsheng Yang <yangds.fnst@cn.fujitsu.com>

Replace various -20/+19 hardcoded nice values with MIN_NICE/MAX_NICE.

Signed-off-by: Dongsheng Yang <yangds.fnst@cn.fujitsu.com>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/r/ff13819fd09b7a5dba5ab5ae797f2e7019bdfa17.1394532288.git.yangds.fnst@cn.fujitsu.com
Cc: devel@driverdev.osuosl.org
Cc: devicetree@vger.kernel.org
Cc: fcoe-devel@open-fcoe.org
Cc: linux390@de.ibm.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-s390@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: nbd-general@lists.sourceforge.net
Cc: ocfs2-devel@oss.oracle.com
Cc: openipmi-developer@lists.sourceforge.net
Cc: qla2xxx-upstream@qlogic.com
Cc: linux-arch@vger.kernel.org
[ Consolidated the patches, twiddled the changelog. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>

Change-Id: I00a4ccd66fcc206211f462245d98d35a853f8264
---
 drivers/block/loop.c              | 2 +-
 drivers/block/nbd.c               | 2 +-
 drivers/block/pktcdvd.c           | 2 +-
 drivers/char/ipmi/ipmi_si_intf.c  | 2 +-
 drivers/s390/crypto/ap_bus.c      | 2 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c | 4 ++--
 drivers/scsi/bnx2i/bnx2i_hwi.c    | 2 +-
 drivers/scsi/fcoe/fcoe.c          | 2 +-
 drivers/scsi/ibmvscsi/ibmvfc.c    | 2 +-
 drivers/scsi/ibmvscsi/ibmvscsi.c  | 2 +-
 drivers/scsi/lpfc/lpfc_hbadisc.c  | 2 +-
 drivers/scsi/qla2xxx/qla_os.c     | 2 +-
 fs/ocfs2/cluster/heartbeat.c      | 2 +-
 kernel/workqueue.c                | 6 +++---
 mm/huge_memory.c                  | 2 +-
 15 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 333458c..029e43c 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -547,7 +547,7 @@ static int loop_thread(void *data)
 	struct loop_device *lo = data;
 	struct bio *bio;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	while (!kthread_should_stop() || !bio_list_empty(&lo->lo_bio_list)) {
 
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index d593fa5..f1a2da8 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -533,7 +533,7 @@ static int nbd_thread(void *data)
 	struct nbd_device *nbd = data;
 	struct request *req;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 	while (!kthread_should_stop() || !list_empty(&nbd->waiting_queue)) {
 		/* wait for something to do */
 		wait_event_interruptible(nbd->waiting_wq,
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index caddb5d..14a8075 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -1471,7 +1471,7 @@ static int kcdrwd(void *foobar)
 	struct packet_data *pkt;
 	long min_sleep_time, residue;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 	set_freezable();
 
 	for (;;) {
diff --git a/drivers/char/ipmi/ipmi_si_intf.c b/drivers/char/ipmi/ipmi_si_intf.c
index a67ac2a..fc22dec 100644
--- a/drivers/char/ipmi/ipmi_si_intf.c
+++ b/drivers/char/ipmi/ipmi_si_intf.c
@@ -992,7 +992,7 @@ static int ipmi_thread(void *data)
 	struct timespec busy_until;
 
 	ipmi_si_set_not_busy(&busy_until);
-	set_user_nice(current, 19);
+	set_user_nice(current, MAX_NICE);
 	while (!kthread_should_stop()) {
 		int busy_wait;
 
diff --git a/drivers/s390/crypto/ap_bus.c b/drivers/s390/crypto/ap_bus.c
index 6f512fa..b30ffb8 100644
--- a/drivers/s390/crypto/ap_bus.c
+++ b/drivers/s390/crypto/ap_bus.c
@@ -1755,7 +1755,7 @@ static int ap_poll_thread(void *data)
 	int requests;
 	struct ap_device *ap_dev;
 
-	set_user_nice(current, 19);
+	set_user_nice(current, MAX_NICE);
 	while (1) {
 		if (ap_suspend_flag)
 			return 0;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index aad5535..ff08516 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -471,7 +471,7 @@ static int bnx2fc_l2_rcv_thread(void *arg)
 	struct fcoe_percpu_s *bg = arg;
 	struct sk_buff *skb;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 	set_current_state(TASK_INTERRUPTIBLE);
 	while (!kthread_should_stop()) {
 		schedule();
@@ -610,7 +610,7 @@ int bnx2fc_percpu_io_thread(void *arg)
 	struct bnx2fc_work *work, *tmp;
 	LIST_HEAD(work_list);
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 	set_current_state(TASK_INTERRUPTIBLE);
 	while (!kthread_should_stop()) {
 		schedule();
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index a28b03e..a95ea80 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -1870,7 +1870,7 @@ int bnx2i_percpu_io_thread(void *arg)
 	struct bnx2i_work *work, *tmp;
 	LIST_HEAD(work_list);
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	while (!kthread_should_stop()) {
 		spin_lock_bh(&p->p_work_lock);
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 32ae6c6..7399981 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1861,7 +1861,7 @@ static int fcoe_percpu_receive_thread(void *arg)
 
 	skb_queue_head_init(&tmp);
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 retry:
 	while (!kthread_should_stop()) {
diff --git a/drivers/scsi/ibmvscsi/ibmvfc.c b/drivers/scsi/ibmvscsi/ibmvfc.c
index 9206861..ae1d783 100644
--- a/drivers/scsi/ibmvscsi/ibmvfc.c
+++ b/drivers/scsi/ibmvscsi/ibmvfc.c
@@ -4503,7 +4503,7 @@ static int ibmvfc_work(void *data)
 	struct ibmvfc_host *vhost = data;
 	int rc;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	while (1) {
 		rc = wait_event_interruptible(vhost->work_wait_q,
diff --git a/drivers/scsi/ibmvscsi/ibmvscsi.c b/drivers/scsi/ibmvscsi/ibmvscsi.c
index c62b3e5..67d840f 100644
--- a/drivers/scsi/ibmvscsi/ibmvscsi.c
+++ b/drivers/scsi/ibmvscsi/ibmvscsi.c
@@ -2206,7 +2206,7 @@ static int ibmvscsi_work(void *data)
 	struct ibmvscsi_host_data *hostdata = data;
 	int rc;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	while (1) {
 		rc = wait_event_interruptible(hostdata->work_wait_q,
diff --git a/drivers/scsi/lpfc/lpfc_hbadisc.c b/drivers/scsi/lpfc/lpfc_hbadisc.c
index 0f6e254..45aafeb 100644
--- a/drivers/scsi/lpfc/lpfc_hbadisc.c
+++ b/drivers/scsi/lpfc/lpfc_hbadisc.c
@@ -733,7 +733,7 @@ lpfc_do_work(void *p)
 	struct lpfc_hba *phba = p;
 	int rc;
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 	current->flags |= PF_NOFREEZE;
 	phba->data_flags = 0;
 
diff --git a/drivers/scsi/qla2xxx/qla_os.c b/drivers/scsi/qla2xxx/qla_os.c
index c11b82e..8a83cfc 100644
--- a/drivers/scsi/qla2xxx/qla_os.c
+++ b/drivers/scsi/qla2xxx/qla_os.c
@@ -4684,7 +4684,7 @@ qla2x00_do_dpc(void *data)
 	ha = (struct qla_hw_data *)data;
 	base_vha = pci_get_drvdata(ha->pdev);
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	set_current_state(TASK_INTERRUPTIBLE);
 	while (!kthread_should_stop()) {
diff --git a/fs/ocfs2/cluster/heartbeat.c b/fs/ocfs2/cluster/heartbeat.c
index 42252bf..3a62a21 100644
--- a/fs/ocfs2/cluster/heartbeat.c
+++ b/fs/ocfs2/cluster/heartbeat.c
@@ -1131,7 +1131,7 @@ static int o2hb_thread(void *data)
 
 	mlog(ML_HEARTBEAT|ML_KTHREAD, "hb thread running\n");
 
-	set_user_nice(current, -20);
+	set_user_nice(current, MIN_NICE);
 
 	/* Pin node */
 	o2nm_depend_this_node();
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 483f5cd..1bc95c8 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -103,10 +103,10 @@ enum {
 
 	/*
 	 * Rescue workers are used only on emergencies and shared by
-	 * all cpus.  Give -20.
+	 * all cpus.  Give MIN_NICE.
 	 */
-	RESCUER_NICE_LEVEL	= -20,
-	HIGHPRI_NICE_LEVEL	= -20,
+	RESCUER_NICE_LEVEL	= MIN_NICE,
+	HIGHPRI_NICE_LEVEL	= MIN_NICE,
 
 	WQ_NAME_LEN		= 24,
 };
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3877483..2353231 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2698,7 +2698,7 @@ static int khugepaged(void *none)
 	struct mm_slot *mm_slot;
 
 	set_freezable();
-	set_user_nice(current, 19);
+	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

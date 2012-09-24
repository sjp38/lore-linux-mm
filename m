Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3D68C6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 16:49:05 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 25 Sep 2012 06:46:47 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8OKdYDw17891412
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 06:39:34 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8OKmtOD006487
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 06:48:56 +1000
Message-ID: <5060C714.8030606@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2012 02:18:20 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] CPU hotplug, writeback: Don't call writeback_set_ratelimit()
 too often during hotplug
References: <20120924102324.GA22303@aftab.osrc.amd.com> <20120924142305.GD12264@quack.suse.cz> <20120924143609.GH22303@aftab.osrc.amd.com> <20120924201650.6574af64.conny.seidel@amd.com> <20120924181927.GA25762@aftab.osrc.amd.com> <5060AB0E.3070809@linux.vnet.ibm.com>
In-Reply-To: <5060AB0E.3070809@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Conny Seidel <conny.seidel@amd.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>


From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

The CPU hotplug callback related to writeback calls writeback_set_ratelimit()
during every state change in the hotplug sequence. This is unnecessary
since num_online_cpus() changes only once during the entire hotplug operation.

So invoke the function only once per hotplug, thereby avoiding the
unnecessary repetition of those costly calculations.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page-writeback.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 5ad5ce2..830893b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1602,10 +1602,18 @@ void writeback_set_ratelimit(void)
 }
 
 static int __cpuinit
-ratelimit_handler(struct notifier_block *self, unsigned long u, void *v)
+ratelimit_handler(struct notifier_block *self, unsigned long action,
+		  void *hcpu)
 {
-	writeback_set_ratelimit();
-	return NOTIFY_DONE;
+
+	switch (action & ~CPU_TASKS_FROZEN) {
+	case CPU_ONLINE:
+	case CPU_DEAD:
+		writeback_set_ratelimit();
+		return NOTIFY_OK;
+	default:
+		return NOTIFY_DONE;
+	}
 }
 
 static struct notifier_block __cpuinitdata ratelimit_nb = {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

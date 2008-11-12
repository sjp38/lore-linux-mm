Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC7XYjD002997
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 16:33:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E46045DD7D
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 16:33:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C3DF45DD7A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 16:33:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D4521DB803F
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 16:33:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B6BF21DB803A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 16:33:33 +0900 (JST)
Date: Wed, 12 Nov 2008 16:32:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [BUGFIX]cgroup: fix potential deadlock in pre_destroy (v2)
Message-Id: <20081112163256.b36d6952.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is fixed one. Thank you for all help.

Regards,
-Kame
==
As Balbir pointed out, memcg's pre_destroy handler has potential deadlock.

It has following lock sequence.

	cgroup_mutex (cgroup_rmdir)
	    -> pre_destroy -> mem_cgroup_pre_destroy-> force_empty
		-> cpu_hotplug.lock. (lru_add_drain_all->
				      schedule_work->
                                      get_online_cpus)

But, cpuset has following.
	cpu_hotplug.lock (call notifier)
		-> cgroup_mutex. (within notifier)

Then, this lock sequence should be fixed.

Considering how pre_destroy works, it's not necessary to holding
cgroup_mutex() while calling it. 

As side effect, we don't have to wait at this mutex while memcg's force_empty
works.(it can be long when there are tons of pages.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 kernel/cgroup.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

Index: mmotm-2.6.28-Nov10/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Nov10/kernel/cgroup.c
@@ -2475,10 +2475,7 @@ static int cgroup_rmdir(struct inode *un
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
-
-	parent = cgrp->parent;
-	root = cgrp->root;
-	sb = root->sb;
+	mutex_unlock(&cgroup_mutex);
 
 	/*
 	 * Call pre_destroy handlers of subsys. Notify subsystems
@@ -2486,7 +2483,14 @@ static int cgroup_rmdir(struct inode *un
 	 */
 	cgroup_call_pre_destroy(cgrp);
 
-	if (cgroup_has_css_refs(cgrp)) {
+	mutex_lock(&cgroup_mutex);
+	parent = cgrp->parent;
+	root = cgrp->root;
+	sb = root->sb;
+
+	if (atomic_read(&cgrp->count)
+	    || !list_empty(&cgrp->children)
+	    || cgroup_has_css_refs(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

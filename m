Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D30A2600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:58:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R7x873006924
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 16:59:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E034F45DE50
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:59:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 93D1345DD6E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:59:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 51E0F1DB8016
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:59:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F0EA61DB8014
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:59:06 +0900 (JST)
Date: Tue, 27 Jul 2010 16:54:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/7][memcg] cgroup arbitarary ID allocation
Message-Id: <20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When a subsystem want to make use of "id" more, it's necessary to
manage the id at cgroup subsystem creation time. But, now,
because of the order of cgroup creation callback, subsystem can't
declare the id it wants. This patch allows subsystem to use customized
ID for themselves.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |    9 +++++++++
 include/linux/cgroup.h            |    3 ++-
 kernel/cgroup.c                   |   17 ++++++++++++-----
 3 files changed, 23 insertions(+), 6 deletions(-)

Index: mmotm-2.6.35-0719/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.35-0719.orig/include/linux/cgroup.h
+++ mmotm-2.6.35-0719/include/linux/cgroup.h
@@ -475,7 +475,7 @@ struct cgroup_subsys {
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
-
+	int (*custom_id)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int subsys_id;
 	int active;
 	int disabled;
@@ -483,6 +483,7 @@ struct cgroup_subsys {
 	/*
 	 * True if this subsys uses ID. ID is not available before cgroup_init()
 	 * (not available in early_init time.)
+	 * You can detemine ID if you have custom_id() callback.
 	 */
 	bool use_id;
 #define MAX_CGROUP_TYPE_NAMELEN 32
Index: mmotm-2.6.35-0719/kernel/cgroup.c
===================================================================
--- mmotm-2.6.35-0719.orig/kernel/cgroup.c
+++ mmotm-2.6.35-0719/kernel/cgroup.c
@@ -4526,10 +4526,11 @@ EXPORT_SYMBOL_GPL(free_css_id);
  * always serialized (By cgroup_mutex() at create()).
  */
 
-static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
+static struct css_id *get_new_cssid(struct cgroup_subsys *ss,
+		int depth, struct cgroup *child)
 {
 	struct css_id *newid;
-	int myid, error, size;
+	int from_id, myid, error, size;
 
 	BUG_ON(!ss->use_id);
 
@@ -4542,9 +4543,13 @@ static struct css_id *get_new_cssid(stru
 		error = -ENOMEM;
 		goto err_out;
 	}
+	if (child && ss->custom_id)
+		from_id = ss->custom_id(ss, child);
+	else
+		from_id = 1;
 	spin_lock(&ss->id_lock);
 	/* Don't use 0. allocates an ID of 1-65535 */
-	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
+	error = idr_get_new_above(&ss->idr, newid, from_id, &myid);
 	spin_unlock(&ss->id_lock);
 
 	/* Returns error when there are no free spaces for new ID.*/
@@ -4552,6 +4557,8 @@ static struct css_id *get_new_cssid(stru
 		error = -ENOSPC;
 		goto err_out;
 	}
+	BUG_ON(ss->custom_id && from_id != myid);
+
 	if (myid > CSS_ID_MAX)
 		goto remove_idr;
 
@@ -4577,7 +4584,7 @@ static int __init_or_module cgroup_init_
 	spin_lock_init(&ss->id_lock);
 	idr_init(&ss->idr);
 
-	newid = get_new_cssid(ss, 0);
+	newid = get_new_cssid(ss, 0 ,NULL);
 	if (IS_ERR(newid))
 		return PTR_ERR(newid);
 
@@ -4600,7 +4607,7 @@ static int alloc_css_id(struct cgroup_su
 	parent_id = parent_css->id;
 	depth = parent_id->depth + 1;
 
-	child_id = get_new_cssid(ss, depth);
+	child_id = get_new_cssid(ss, depth, child);
 	if (IS_ERR(child_id))
 		return PTR_ERR(child_id);
 
Index: mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-2.6.35-0719.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
@@ -621,6 +621,15 @@ and root cgroup. Currently this will onl
 the default hierarchy (which never has sub-cgroups) and a hierarchy
 that is being created/destroyed (and hence has no sub-cgroups).
 
+void custom_id(struct cgroup_subsys *ss, struct cgroup *cgrp)
+
+Called at assigning a new ID to cgroup subsystem state struct. This
+is called when ss->use_id == true. If this function is not provided,
+a new ID is automatically assigned. If you enable ss->use_id,
+you can use css_lookup()  and css_get_next() to access "css" objects
+via IDs.
+
+
 4. Questions
 ============
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

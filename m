Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 65F626B0044
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 00:44:45 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0K5ihuK004513
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jan 2009 14:44:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25F5F45DD74
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 14:44:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED11945DD72
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 14:44:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF6811DB803E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 14:44:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75DB31DB8040
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 14:44:42 +0900 (JST)
Date: Tue, 20 Jan 2009 14:43:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1.5/4] cgroup: delay populate css id
Message-Id: <20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	<20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
	<20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jan 2009 11:58:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > +               if (ss->use_id)
> > +                       if (alloc_css_id(ss, parent, cgrp))
> > +                               goto err_destroy;
> > +               /* At error, ->destroy() callback has to free assigned ID. */
> >        }
> 
> Should I delay to set css_id->css pointer to valid value until the end of
> populate() ? (add populage_css_id() call after cgroup_populate_dir()).
> 
> I'd like to write add-on patch to the patch [1/4]. (or update it.)
> css_id->css == NULL case is handled now, anyway.
> 

How about this ?
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When CSS ID is attached, it's not guaranteed that the cgroup will
be finally populated out. (some failure in create())

But, scan by CSS ID can find CSS which is not fully initialized.
This patch tries to prevent that by delaying to fill id->css pointer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/cgroup.c |   22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

Index: mmotm-2.6.29-Jan16/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Jan16/kernel/cgroup.c
@@ -569,6 +569,7 @@ static struct backing_dev_info cgroup_ba
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 };
 
+static void populate_css_id(struct cgroup_subsys_state *id);
 static int alloc_css_id(struct cgroup_subsys *ss,
 			struct cgroup *parent, struct cgroup *child);
 
@@ -2329,6 +2330,12 @@ static int cgroup_populate_dir(struct cg
 		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
 			return err;
 	}
+	/* This cgroup is ready now */
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		if (ss->use_id)
+			populate_css_id(css);
+	}
 
 	return 0;
 }
@@ -3252,8 +3259,9 @@ __setup("cgroup_disable=", cgroup_disabl
  */
 struct css_id {
 	/*
-	 * The css to which this ID points. If cgroup is removed, this will
-	 * be NULL. This pointer is expected to be RCU-safe because destroy()
+	 * The css to which this ID points. This pointer is set to valid value
+	 * after cgroup is populated. If cgroup is removed, this will be NULL.
+	 * This pointer is expected to be RCU-safe because destroy()
 	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
 	 * css_tryget() should be used for avoiding race.
 	 */
@@ -3401,6 +3409,13 @@ static int __init cgroup_subsys_init_idr
 	return 0;
 }
 
+static void populate_css_id(struct cgroup_subsys_state *css)
+{
+	struct css_id *id = rcu_dereference(css->id);
+	if (id)
+		rcu_assign_pointer(id->css, css);
+}
+
 static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
 			struct cgroup *child)
 {
@@ -3421,8 +3436,7 @@ static int alloc_css_id(struct cgroup_su
 	for (i = 0; i < depth; i++)
 		child_id->stack[i] = parent_id->stack[i];
 	child_id->stack[depth] = child_id->id;
-
-	rcu_assign_pointer(child_id->css, child_css);
+	/* child_id->css pointer will be set after this cgroup is available */
 	rcu_assign_pointer(child_css->id, child_id);
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

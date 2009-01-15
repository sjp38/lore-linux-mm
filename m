Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 64DDA6B006A
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:28:23 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FASKSg000516
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 19:28:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA0145DE4F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:28:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB2D945DE4D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:28:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 92B701DB803F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:28:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E3771DB803C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:28:17 +0900 (JST)
Date: Thu, 15 Jan 2009 19:27:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/4] cgroup:add css_is_populated
Message-Id: <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

cgroup creation is done in several stages.
After allocated and linked to cgroup's hierarchy tree, all necessary
control files are created.

When using CSS_ID, scanning cgroups without cgrouo_lock(), status
of cgroup is important. At removal of cgroup/css, css_tryget() works fine
and we can write a safe code. At creation, we need some flag to show 
"This cgroup is not ready yet"

This patch adds CSS_POPULATED flag.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
Index: mmotm-2.6.29-Jan14/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Jan14.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Jan14/include/linux/cgroup.h
@@ -69,6 +69,7 @@ struct cgroup_subsys_state {
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
 	CSS_REMOVED, /* This CSS is dead */
+	CSS_POPULATED, /* This CSS finished all initialization */
 };
 
 /*
@@ -90,6 +91,11 @@ static inline bool css_is_removed(struct
 	return test_bit(CSS_REMOVED, &css->flags);
 }
 
+static inline bool css_is_populated(struct cgroup_subsys_state *css)
+{
+	return test_bit(CSS_POPULATED, &css->flags);
+}
+
 /*
  * Call css_tryget() to take a reference on a css if your existing
  * (known-valid) reference isn't already ref-counted. Returns false if
Index: mmotm-2.6.29-Jan14/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Jan14.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Jan14/kernel/cgroup.c
@@ -2326,8 +2326,10 @@ static int cgroup_populate_dir(struct cg
 	}
 
 	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
 			return err;
+		set_bit(CSS_POPULATED, &css->flags);
 	}
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

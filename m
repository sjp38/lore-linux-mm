Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9EF8D6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:04:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P189bK016788
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 10:08:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D708845DE55
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:08:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AA92045DE4F
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:08:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EB8B1DB805A
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:08:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C3C91DB803C
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:08:08 +0900 (JST)
Date: Wed, 25 Aug 2010 10:03:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
Message-Id: <20100825100310.ba3fd27e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
	<20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 17:46:03 -0700
Paul Menage <menage@google.com> wrote:

> On Tue, Aug 24, 2010 at 5:37 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > Ou...I'm sorry but I would like to use attach_id() for this time.
> > Forgive me, above seems a big change.
> > I'd like to write a series of patch to do above, later.
> > At least, to do a trial.
> >
> 
> Sure, for testing outside the tree. I don't think introducing new code
> into mainline that's intentionally ugly and cutting corners is a good
> idea.
> 

Hmm. How this pseudo code looks like ? This passes "new id" via
cgroup->subsys[array] at creation. (Using union will be better, maybe).

---
 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |   26 +++++++++++++++++++-------
 2 files changed, 20 insertions(+), 7 deletions(-)

Index: mmotm-0811/include/linux/cgroup.h
===================================================================
--- mmotm-0811.orig/include/linux/cgroup.h
+++ mmotm-0811/include/linux/cgroup.h
@@ -508,6 +508,7 @@ struct cgroup_subsys {
 	struct cgroupfs_root *root;
 	struct list_head sibling;
 	/* used when use_id == true */
+	int max_id;
 	struct idr idr;
 	spinlock_t id_lock;
 
Index: mmotm-0811/kernel/cgroup.c
===================================================================
--- mmotm-0811.orig/kernel/cgroup.c
+++ mmotm-0811/kernel/cgroup.c
@@ -3335,19 +3335,31 @@ static long cgroup_create(struct cgroup 
 		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 
 	for_each_subsys(root, ss) {
-		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
+		struct cgroup_subsys_state *css;
 
-		if (IS_ERR(css)) {
-			err = PTR_ERR(css);
-			goto err_destroy;
-		}
-		init_cgroup_css(css, ss, cgrp);
 		if (ss->use_id) {
 			err = alloc_css_id(ss, parent, cgrp);
 			if (err)
 				goto err_destroy;
+			/*
+ 			 * Here, created css_id is recorded into
+ 			 * cgrp->subsys[ss->subsys_id]
+			 * array and passed to subsystem.
+			 */
+		} else
+			cgrp->subsys[ss->subsys_id] = NULL;
+
+		css = ss->create(ss, cgrp);
+
+		if (IS_ERR(css)) {
+			/* forget preallocated id */
+			if (cgrp->subsys[ss->subsys_id])
+				free_css_id_direct((struct css_id *)
+					cgrp->subsys[ss->subsys_id]);
+			err = PTR_ERR(css);
+			goto err_destroy;
 		}
-		/* At error, ->destroy() callback has to free assigned ID. */
+		init_cgroup_css(css, ss, cgrp);
 	}
 
 	cgroup_lock_hierarchy(root);

	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

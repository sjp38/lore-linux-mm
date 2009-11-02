Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E27C6B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:31:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27VBLH005159
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:31:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5316545DE51
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:31:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 212D445DE57
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:31:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2C301DB8047
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:31:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 827E41DB8046
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:31:10 +0900 (JST)
Date: Mon, 2 Nov 2009 16:28:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 5/6] oom-killer: check last total_vm expansion
Message-Id: <20091102162837.405783f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At considering oom-kill algorithm, we can't avoid to take runtime
into account. But this can adds too big bonus to slow-memory-leaker.
For adding penalty to slow-memory-leaker, we record jiffies of
the last mm->hiwater_vm expansion. That catches processes which leak
memory periodically.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h |    2 ++
 include/linux/sched.h    |    4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -291,6 +291,8 @@ struct mm_struct {
 #endif
 	/* For OOM, fork-bomb detector */
 	unsigned long bomb_score;
+	/* set to jiffies at total_vm is finally expanded (see sched.h) */
+	unsigned long last_vm_expansion;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: mmotm-2.6.32-Nov2/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/sched.h
+++ mmotm-2.6.32-Nov2/include/linux/sched.h
@@ -422,8 +422,10 @@ extern void arch_unmap_area_topdown(stru
 		(mm)->hiwater_rss = _rss;		\
 } while (0)
 #define update_hiwater_vm(mm)	do {			\
-	if ((mm)->hiwater_vm < (mm)->total_vm)		\
+	if ((mm)->hiwater_vm < (mm)->total_vm) {	\
 		(mm)->hiwater_vm = (mm)->total_vm;	\
+		(mm)->last_vm_expansion = jiffies;	\
+	}\
 } while (0)
 
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

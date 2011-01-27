Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9ED008D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 20:49:47 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 831AA3EE0B6
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:49:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 600E345DE6F
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:49:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50CE245DE62
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:49:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 42D2BE18005
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:49:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C21A1DB803F
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 10:49:41 +0900 (JST)
Date: Thu, 27 Jan 2011 10:43:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX v2] memcg: fix res_counter_read_u64 lock aware (Was Re:
 [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-Id: <20110127104339.0f580bac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
	<20110126170713.GA2401@cmpxchg.org>
	<xr93y667lgdm.fsf@gthelen.mtv.corp.google.com>
	<20110126183023.GB2401@cmpxchg.org>
	<xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
	<20110126142909.0b710a0c.akpm@linux-foundation.org>
	<20110127092434.df18c7a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Thank you for advices. This version doesn't use inlined function
and adds no overhead in 64bit.

Info:
res_counter_read_u64 is not frequently called in memcontrol.c now.
It's called at user-interface and interaction with other components.
This addition of lock will not add any performance troubles.

==
res_counter_read_u64 reads u64 value without lock. It's dangerous
in 32bit environment. This patch adds lock.

Changelog:
 - handle 32/64 bit in other funciton
 - avoid unnecessary inlining.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/res_counter.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: mmotm-0125/kernel/res_counter.c
===================================================================
--- mmotm-0125.orig/kernel/res_counter.c
+++ mmotm-0125/kernel/res_counter.c
@@ -126,10 +126,24 @@ ssize_t res_counter_read(struct res_coun
 			pos, buf, s - buf);
 }
 
+#if BITS_PER_LONG == 32
+u64 res_counter_read_u64(struct res_counter *counter, int member)
+{
+	unsigned long flags;
+	u64 ret;
+
+	spin_lock_irqsave(&counter->lock, flags);
+	ret = *res_counter_member(counter, member);
+	spin_unlock_irqrestore(&counter->lock, flags);
+
+	return ret;
+}
+#else
 u64 res_counter_read_u64(struct res_counter *counter, int member)
 {
 	return *res_counter_member(counter, member);
 }
+#endif
 
 int res_counter_memparse_write_strategy(const char *buf,
 					unsigned long long *res)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

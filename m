Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1C5218D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 19:59:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 466F93EE0C0
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:59:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30F4545DE55
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:59:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAF8745DE57
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:59:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1BDE08002
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:59:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95AD01DB8038
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:59:49 +0900 (JST)
Date: Thu, 27 Jan 2011 09:53:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX] memcg: fix res_counter_read_u64 lock aware (Was Re:
 [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-Id: <20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110127092434.df18c7a6.kamezawa.hiroyu@jp.fujitsu.com>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
	<20110126170713.GA2401@cmpxchg.org>
	<xr93y667lgdm.fsf@gthelen.mtv.corp.google.com>
	<20110126183023.GB2401@cmpxchg.org>
	<xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
	<20110126142909.0b710a0c.akpm@linux-foundation.org>
	<20110127092434.df18c7a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 09:24:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote: > 
> 
> I'll review. Against the roll-over, I think we just need to take lock.
> So, res_counter_read_u64() implementation was wrong. It should take lock.
> Please give me time.
> 

As far as I can see usages of return value of res_counter_read_u64()
in memcontrol.c, all values are handle in u64 and no >> PAGE_SHIFT
to 'int' is not done. I'll see usage of u64 return value to
functions in other files from memcontrol.c

But, at least, this patch is required, I think. There are races.

==
res_counter_read_u64 reads u64 value without lock. It's dangerous
in 32bit environment. This patch adds lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |   13 ++++++++++++-
 kernel/res_counter.c        |    2 +-
 2 files changed, 13 insertions(+), 2 deletions(-)

Index: mmotm-0125/include/linux/res_counter.h
===================================================================
--- mmotm-0125.orig/include/linux/res_counter.h
+++ mmotm-0125/include/linux/res_counter.h
@@ -68,7 +68,18 @@ struct res_counter {
  * @pos:     and the offset.
  */
 
-u64 res_counter_read_u64(struct res_counter *counter, int member);
+u64 res_counter_read_u64_locked(struct res_counter *counter, int member);
+
+static inline u64 res_counter_read_u64(struct res_counter *counter, int member)
+{
+	unsigned long flags;
+	u64 ret;
+
+	spin_lock_irqsave(&counter->lock, flags);
+	ret = res_counter_read_u64_locked(counter, member);
+	spin_unlock_irqrestore(&counter->lock, flags);
+	return ret;
+}
 
 ssize_t res_counter_read(struct res_counter *counter, int member,
 		const char __user *buf, size_t nbytes, loff_t *pos,
Index: mmotm-0125/kernel/res_counter.c
===================================================================
--- mmotm-0125.orig/kernel/res_counter.c
+++ mmotm-0125/kernel/res_counter.c
@@ -126,7 +126,7 @@ ssize_t res_counter_read(struct res_coun
 			pos, buf, s - buf);
 }
 
-u64 res_counter_read_u64(struct res_counter *counter, int member)
+u64 res_counter_read_u64_locked(struct res_counter *counter, int member)
 {
 	return *res_counter_member(counter, member);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

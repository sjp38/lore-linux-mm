Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0FC6B025E
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 04:23:40 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id v14so57406434ykd.3
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 01:23:40 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id t82si47448157ywa.142.2015.12.30.01.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 01:23:39 -0800 (PST)
Received: by mail-yk0-x22c.google.com with SMTP id v14so57406192ykd.3
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 01:23:39 -0800 (PST)
Date: Wed, 30 Dec 2015 04:23:37 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v4.4-rc7] sched: isolate task_struct bitfields according to
 synchronization domains
Message-ID: <20151230092337.GD3873@htj.duckdns.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
 <20151211162554.GS30240@mtj.duckdns.org>
 <20151215192245.GK6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151215192245.GK6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mhocko@kernel.org, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, vdavydov@parallels.com, kernel-team@fb.com, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

task_struct has a cluster of unsigned bitfields.  Some are updated
under scheduler locks while others are updated only by the task
itself.  Currently, the two classes of bitfields aren't distinguished
and end up on the same word which can lead to clobbering when there
are simultaneous read-modify-write attempts.  While difficult to prove
definitely, it's likely that the resulting inconsistency led to low
frqeuency failures such as wrong memcg_may_oom state or loadavg
underflow due to clobbered sched_contributes_to_load.

Fix it by putting the two classes of the bitfields into separate
unsigned longs.

Original-patch-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Tejun Heo <tj@kernel.org>
Link: http://lkml.kernel.org/g/55FEC685.5010404@oracle.com
Cc: stable@vger.kernel.org
---
Hello,

Peter, I took the patch and changed the bitfields to ulong.

Thanks.

 include/linux/sched.h |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..e51464d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1455,22 +1455,25 @@ struct task_struct {
 	/* Used for emulating ABI behavior of previous Linux versions */
 	unsigned int personality;
 
-	unsigned in_execve:1;	/* Tell the LSMs that the process is doing an
-				 * execve */
-	unsigned in_iowait:1;
-
-	/* Revert to default priority/policy when forking */
-	unsigned sched_reset_on_fork:1;
-	unsigned sched_contributes_to_load:1;
-	unsigned sched_migrated:1;
+	/* scheduler bits, serialized by scheduler locks */
+	unsigned long sched_reset_on_fork:1;
+	unsigned long sched_contributes_to_load:1;
+	unsigned long sched_migrated:1;
+
+	/* force alignment to the next boundary */
+	unsigned long :0;
+
+	/* unserialized, strictly 'current' */
+	unsigned long in_execve:1; /* bit to tell LSMs we're in execve */
+	unsigned long in_iowait:1;
 #ifdef CONFIG_MEMCG
-	unsigned memcg_may_oom:1;
+	unsigned long memcg_may_oom:1;
 #endif
 #ifdef CONFIG_MEMCG_KMEM
-	unsigned memcg_kmem_skip_account:1;
+	unsigned long memcg_kmem_skip_account:1;
 #endif
 #ifdef CONFIG_COMPAT_BRK
-	unsigned brk_randomized:1;
+	unsigned long brk_randomized:1;
 #endif
 
 	unsigned long atomic_flags; /* Flags needing atomic access. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

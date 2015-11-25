Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A4A2B6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:02:23 -0500 (EST)
Received: by wmww144 with SMTP id w144so183680574wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:02:23 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id xa1si35261696wjc.7.2015.11.25.07.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 07:02:12 -0800 (PST)
Date: Wed, 25 Nov 2015 16:02:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20151125150207.GM11639@twins.programming.kicks-ass.net>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125144354.GB17308@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Wed, Nov 25, 2015 at 03:43:54PM +0100, Peter Zijlstra wrote:
> On Mon, Sep 21, 2015 at 04:01:41PM -0400, Tejun Heo wrote:
> > So, the only way the patch could have caused the above is if someone
> > who isn't the task itself is writing to the bitfields while the task
> > is running.  Looking through the fields, ->sched_reset_on_fork seems a
> > bit suspicious.  __sched_setscheduler() looks like it can modify the
> > bit while the target task is running.  Peter, am I misreading the
> > code?
> 
> Nope, that's quite possible. Looks like we need to break up those
> bitfields a bit. All the scheduler ones should be serialized by
> scheduler locks, but the others are fair game.

Maybe something like so; but my brain is a complete mess today.

---
 include/linux/sched.h | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index f425aac63317..b474e0f05327 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1455,14 +1455,15 @@ struct task_struct {
 	/* Used for emulating ABI behavior of previous Linux versions */
 	unsigned int personality;
 
-	unsigned in_execve:1;	/* Tell the LSMs that the process is doing an
-				 * execve */
-	unsigned in_iowait:1;
-
-	/* Revert to default priority/policy when forking */
+	/* scheduler bits, serialized by scheduler locks */
 	unsigned sched_reset_on_fork:1;
 	unsigned sched_contributes_to_load:1;
 	unsigned sched_migrated:1;
+	unsigned __padding_sched:29;
+
+	/* unserialized, strictly 'current' */
+	unsigned in_execve:1; /* bit to tell LSMs we're in execve */
+	unsigned in_iowait:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 09 Jun 2003 11:51:30 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.70-mm6
Message-ID: <51250000.1055184690@flay>
In-Reply-To: <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv>
References: <20030607151440.6982d8c6.akpm@digeo.com><Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv> <46580000.1055180345@flay> <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> If you don't nice the hell out of X, does it work OK?
> No.
> 
> The way I reproduce the sound skips:
> run xmms, run evolution, compose a mail with gpg.
> on mm6 the gpg part stops the sound for a few seconds. (with X -10 and 0)
> on mm5 xmms plays without stops. (with X -10)

Does this (from Ingo?) do anything useful to it?

diff -urpN -X /home/fletch/.diff.exclude 400-reiserfs_dio/kernel/sched.c 420-sched_interactive/kernel/sched.c
--- 400-reiserfs_dio/kernel/sched.c	Fri May 30 19:26:34 2003
+++ 420-sched_interactive/kernel/sched.c	Fri May 30 19:28:06 2003
@@ -89,6 +89,8 @@ int node_threshold = 125;
 #define STARVATION_LIMIT	(starvation_limit)
 #define NODE_THRESHOLD		(node_threshold)
 
+#define TIMESLICE_GRANULARITY (HZ/20 ?: 1)
+
 /*
  * If a task is 'interactive' then we reinsert it in the active
  * array after it has expired its current timeslice. (it will not
@@ -1365,6 +1367,27 @@ void scheduler_tick(int user_ticks, int 
 			enqueue_task(p, rq->expired);
 		} else
 			enqueue_task(p, rq->active);
+	} else {
+		/*
+		 * Prevent a too long timeslice allowing a task to monopolize
+		 * the CPU. We do this by splitting up the timeslice into
+		 * smaller pieces.
+		 *
+		 * Note: this does not mean the task's timeslices expire or
+		 * get lost in any way, they just might be preempted by
+		 * another task of equal priority. (one with higher
+		 * priority would have preempted this task already.) We
+		 * requeue this task to the end of the list on this priority
+		 * level, which is in essence a round-robin of tasks with
+		 * equal priority.
+		 */
+		if (!(p->time_slice % TIMESLICE_GRANULARITY) &&
+			       		(p->array == rq->active)) {
+			dequeue_task(p, rq->active);
+			set_tsk_need_resched(p);
+			p->prio = effective_prio(p);
+			enqueue_task(p, rq->active);
+		}
 	}
 out_unlock:
 	spin_unlock(&rq->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: by ug-out-1314.google.com with SMTP id u40so1433849ugc.29
        for <linux-mm@kvack.org>; Sun, 02 Mar 2008 15:15:07 -0800 (PST)
Date: Mon, 3 Mar 2008 00:09:18 +0100 (CET)
Subject: [PATCH] leak less memory in failure paths of
 alloc_rt_sched_group()
Message-ID: <alpine.LNX.1.00.0803030002520.4939@dragon.funnycrock.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
From: Jesper Juhl <jesper.juhl@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Jesper Juhl <jesper.juhl@gmail.com>
List-ID: <linux-mm.kvack.org>

In kernel/sched.c b/kernel/sched.c::alloc_rt_sched_group() we currently do 
some paired memory allocations, and if one fails we bail out without 
freeing the previous one.

If we fail inside the loop we should proably roll the whole thing back. 
This patch does not do that, it simply frees the first member of the 
paired alloc if the second fails. This is not perfect, but it's a simple 
change that will, at least, result in us leaking a little less than we 
currently do when an allocation fails.

So, not perfect, but better than what we currently have.
Please consider applying.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 sched.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index f06950c..360857f 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -7685,8 +7685,10 @@ static int alloc_rt_sched_group(struct task_group *tg)
 	if (!tg->rt_rq)
 		goto err;
 	tg->rt_se = kzalloc(sizeof(rt_se) * NR_CPUS, GFP_KERNEL);
-	if (!tg->rt_se)
+	if (!tg->rt_se) {
+		kfree(tg->rt_rq);
 		goto err;
+	}
 
 	tg->rt_runtime = 0;
 
@@ -7700,8 +7702,10 @@ static int alloc_rt_sched_group(struct task_group *tg)
 
 		rt_se = kmalloc_node(sizeof(struct sched_rt_entity),
 				GFP_KERNEL|__GFP_ZERO, cpu_to_node(i));
-		if (!rt_se)
+		if (!rt_se) {
+			kfree(rt_rq);
 			goto err;
+		}
 
 		init_tg_rt_entry(rq, tg, rt_rq, rt_se, i, 0);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

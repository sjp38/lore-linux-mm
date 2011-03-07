Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 182FF8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:37:01 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p27Kauil008807
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 12:36:56 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz17.hot.corp.google.com with ESMTP id p27KaeER013735
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 12:36:55 -0800
Received: by pwj4 with SMTP id 4so964164pwj.16
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 12:36:54 -0800 (PST)
Date: Mon, 7 Mar 2011 12:36:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <AANLkTi=d+eZxg_NgNWa7roo=1YQS06=EaWJzjseL_Hhs@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103071234480.10264@chino.kir.corp.google.com>
References: <1299286307-4386-1-git-send-email-avagin@openvz.org> <20110306193519.49DD.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com> <AANLkTi=d+eZxg_NgNWa7roo=1YQS06=EaWJzjseL_Hhs@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-1855919177-1299530211=:10264"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-1855919177-1299530211=:10264
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 7 Mar 2011, Andrew Vagin wrote:

> > Andrey is patching the case where an eligible TIF_MEMDIE process is found
> > but it has already detached its ->mm.  In combination with the patch
> > posted to linux-mm, oom: prevent unnecessary oom kills or kernel panics,
> > which makes select_bad_process() iterate over all threads, it is an
> > effective solution.
> 
> Probably you said about the first version of my patch.
> This version is incorrect because of
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=dd8e8f405ca386c7ce7cbb996ccd985d283b0e03
> 
> but my first patch is correct and it has a simple reproducer(I
> attached it). You can execute it and your kernel hangs up, because the
> parent doesn't wait children, but the one child (zombie) will have
> flag TIF_MEMDIE, oom_killer will kill nobody
> 

The second version of your patch works fine in combination with the 
pending "oom: prevent unnecessary oom kills or kernel panics" patch from 
linux-mm (included below).  Try your test case with both this patch and 
the second version of your patch.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -292,11 +292,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		unsigned long totalpages, struct mem_cgroup *mem,
 		const nodemask_t *nodemask)
 {
-	struct task_struct *p;
+	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	*ppoints = 0;
 
-	for_each_process(p) {
+	do_each_thread(g, p) {
 		unsigned int points;
 
 		if (oom_unkillable_task(p, mem, nodemask))
@@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
+		if ((p->flags & PF_EXITING) && p->mm) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
@@ -337,7 +337,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			chosen = p;
 			*ppoints = points;
 		}
-	}
+	} while_each_thread(g, p);
 
 	return chosen;
 }
--531368966-1855919177-1299530211=:10264--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

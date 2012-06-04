Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id CBE566B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 19:30:59 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8487915pbb.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 16:30:59 -0700 (PDT)
Date: Mon, 4 Jun 2012 16:30:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oomkillers gone wild.
In-Reply-To: <20120604152710.GA1710@redhat.com>
Message-ID: <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
References: <20120604152710.GA1710@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 4 Jun 2012, Dave Jones wrote:

> we picked this..
> 
> [21623.066911] [  588]     0   588    22206        1   2       0             0 dhclient
> 
> over say..
> 
> [21623.116597] [ 7092]  1000  7092  1051124    31660   3       0             0 trinity-child3
> 
> What went wrong here ?
> 
> And why does that score look so.. weird.
> 

It sounds like it's because pid 588 has uid=0 and the adjustment for root 
processes is causing an overflow.  I assume this fixes it?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -183,7 +183,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 			  const nodemask_t *nodemask, unsigned long totalpages)
 {
-	unsigned long points;
+	long points;
 
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
@@ -223,7 +223,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * Never return 0 for an eligible task regardless of the root bonus and
 	 * oom_score_adj (oom_score_adj can't be OOM_SCORE_ADJ_MIN here).
 	 */
-	return points ? points : 1;
+	return points > 0 ? points : 1;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

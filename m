Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2C08E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 21:42:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d1-v6so3484912qth.21
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 18:42:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m84-v6sor816835qke.63.2018.09.12.18.42.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 18:42:24 -0700 (PDT)
Date: Wed, 12 Sep 2018 21:42:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2018-09-12-16-40 uploaded (psi)
Message-ID: <20180913014222.GA2370@cmpxchg.org>
References: <20180912234039.Xa5RS%akpm@linux-foundation.org>
 <a9bef471-ac93-2983-618b-ffee65f01e0b@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9bef471-ac93-2983-618b-ffee65f01e0b@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

Hi Randy,

Thanks for the report.

On Wed, Sep 12, 2018 at 05:45:08PM -0700, Randy Dunlap wrote:
> Multiple build errors when CONFIG_SMP is not set: (this is on i386 fwiw)
> 
> in the psi (pressure) patches, I guess:
> 
> In file included from ../kernel/sched/sched.h:1367:0,
>                  from ../kernel/sched/core.c:8:
> ../kernel/sched/stats.h: In function 'psi_task_tick':
> ../kernel/sched/stats.h:135:33: error: 'struct rq' has no member named 'cpu'
>    psi_memstall_tick(rq->curr, rq->cpu);

This needs to use the SMP/UP config-aware accessor.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
index 2e07d8f59b3e..4904c4677000 100644
--- a/kernel/sched/stats.h
+++ b/kernel/sched/stats.h
@@ -132,7 +132,7 @@ static inline void psi_task_tick(struct rq *rq)
 		return;
 
 	if (unlikely(rq->curr->flags & PF_MEMSTALL))
-		psi_memstall_tick(rq->curr, rq->cpu);
+		psi_memstall_tick(rq->curr, cpu_of(rq));
 }
 #else /* CONFIG_PSI */
 static inline void psi_enqueue(struct task_struct *p, bool wakeup) {}

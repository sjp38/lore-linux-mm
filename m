Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B329F6B0011
	for <linux-mm@kvack.org>; Fri,  4 May 2018 06:45:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so13875591wrh.6
        for <linux-mm@kvack.org>; Fri, 04 May 2018 03:45:01 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g130-v6si1167550wme.55.2018.05.04.03.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 03:44:59 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
Date: Fri,  4 May 2018 12:44:51 +0200
Message-Id: <20180504104451.20278-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

This patch reverts commit c7f26ccfb2c3 ("mm/vmstat.c: fix
vmstat_update() preemption BUG").
Steven saw a "using smp_processor_id() in preemptible" message and
added a preempt_disable() section around it to keep it quiet. This is
not the right thing to do it does not fix the real problem.

vmstat_update() is invoked by a kworker on a specific CPU. This worker
it bound to this CPU. The name of the worker was "kworker/1:1" so it
should have been a worker which was bound to CPU1. A worker which can
run on any CPU would have a `u' before the first digit.

smp_processor_id() can be used in a preempt-enabled region as long as
the task is bound to a single CPU which is the case here. If it could
run on an arbitrary CPU then this is the problem we have an should seek
to resolve.
Not only this smp_processor_id() must not be migrated to another CPU but
also refresh_cpu_vm_stats() which might access wrong per-CPU variables.
Not to mention that other code relies on the fact that such a worker
runs on one specific CPU only.

Therefore I revert that commit and we should look instead what broke the
affinity mask of the kworker.

Cc: Steven J. Hill <steven.hill@cavium.com>
Cc: Tejun Heo <htejun@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/vmstat.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 33581be705f0..40b2db6db6b1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1839,11 +1839,9 @@ static void vmstat_update(struct work_struct *w)
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		preempt_disable();
 		queue_delayed_work_on(smp_processor_id(), mm_percpu_wq,
 				this_cpu_ptr(&vmstat_work),
 				round_jiffies_relative(sysctl_stat_interval));
-		preempt_enable();
 	}
 }
=20
--=20
2.17.0

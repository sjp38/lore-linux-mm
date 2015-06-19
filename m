Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D06956B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 13:36:16 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so95224063wgb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:36:16 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bt11si5830649wib.19.2015.06.19.10.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 10:36:15 -0700 (PDT)
Date: Fri, 19 Jun 2015 19:36:12 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH v2] mm: memcontrol: bring back the VM_BUG_ON() in
 mem_cgroup_swapout()
Message-ID: <20150619173612.GA7143@linutronix.de>
References: <20150619163418.GA21040@linutronix.de>
 <20150619171118.GA11423@cmpxchg.org>
 <55844EE7.7070508@linutronix.de>
 <20150619172802.GA11492@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20150619172802.GA11492@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, rostedt@goodmis.org, williams@redhat.com

Clark stumbled over a VM_BUG_ON() in -RT which was then was removed by
Johannes in commit f371763a79d ("mm: memcontrol: fix false-positive
VM_BUG_ON() on -rt"). The comment before that patch was a tiny bit
better than it is now. While the patch claimed to fix a false-postive on
-RT this was not the case. None of the -RT folks ACKed it and it was not a
false positive report. That was a *real* problem.

This patch updates the comment that is improper because it refers to
"disabled preemption" as a consequence of that lock being taken. A
spin_lock() disables preemption, true, but in this case the code relies on
the fact that the lock _also_ disables interrupts once it is acquired. And
this is the important detail (which was checked the VM_BUG_ON()) which needs
to be pointed out. This is the hint one needs while looking at the code. It
was explained by Johannes on the list that the per-CPU variables are protec=
ted
by local_irq_save(). The BUG_ON() was helpful. This code has been workaroun=
ded
in -RT in the meantime. I wouldn't mind running into more of those if the c=
ode
in question uses *special* kind of locking since now there is no
verification (in terms of lockdep or BUG_ON()) and therefore I bring the
VM_BUG_ON() check back in.

The two functions after the comment could also have a "local_irq_save()"
dance around them in order to serialize access to the per-CPU variables.
This has been avoided because the interrupts should be off.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: bring back VM_BUG_ON()

 mm/memcontrol.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a04225d372ba..fefbb37e5bad 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5835,7 +5835,13 @@ void mem_cgroup_swapout(struct page *page, swp_entry=
_t entry)
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
=20
-	/* Caller disabled preemption with mapping->tree_lock */
+	/*
+	 * Interrupts should be disabled here because the caller holds the
+	 * mapping->tree_lock lock which is taken with interrupts-off. It is
+	 * important here to have the interrupts disabled because it is the
+	 * only synchronisation we have for udpating the per-CPU variables.
+	 */
+	VM_BUG_ON(!irqs_disabled());
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
 }
--=20
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

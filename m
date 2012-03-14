Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C22966B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 02:52:18 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so2176675vcb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 23:52:17 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 14 Mar 2012 08:52:17 +0200
Message-ID: <CAOtvUMdVrjUHLx2jZ2xbpBoDBMCX8sdCASEkmXCtBrU-gQ3EhQ@mail.gmail.com>
Subject: [PATCH] mm: fix vmstat_update to keep scheduling itself on all cores
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>

We set up per-cpu work structures for vmstat and schedule them on
each cpu when they go online only to re-schedule them on the general
work queue when they first run.

This doesn't seem right - how do we ever=A0guarantee=A0that vmstat_update r=
uns
on all cpus? Either I've missed something or our vm stats are off and per-c=
pu
pages=A0are not drained as frequently as we think they are.

Fix it by re-scheduling the work item on the same cpu it first ran on.

Tested on x86 on 8 way SMP VM.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Christoph Lameter <cl@linux.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Andi Kleen <ak@linux.intel.com>
CC: linux-mm@kvack.org
---

diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..b396044 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1144,8 +1144,10 @@ int sysctl_stat_interval __read_mostly =3D HZ;

 static void vmstat_update(struct work_struct *w)
 {
-	refresh_cpu_vm_stats(smp_processor_id());
-	schedule_delayed_work(&__get_cpu_var(vmstat_work),
+	int cpu =3D smp_processor_id();
+
+	refresh_cpu_vm_stats(cpu);
+	schedule_delayed_work_on(cpu, &__get_cpu_var(vmstat_work),
 		round_jiffies_relative(sysctl_stat_interval));
 }



--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

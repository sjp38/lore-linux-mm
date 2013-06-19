Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 95C576B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 16:18:19 -0400 (EDT)
Date: Wed, 19 Jun 2013 20:18:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat kthreads
In-Reply-To: <20130619145906.GB5146@linux.vnet.ibm.com>
Message-ID: <0000013f5e167883-3b022396-6162-4079-b80d-789b797e5ecb-000000@email.amazonses.com>
References: <20130618152302.GA10702@linux.vnet.ibm.com> <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com> <20130618182616.GT5146@linux.vnet.ibm.com> <0000013f5cd1c54a-31d71292-c227-4f84-925d-75407a687824-000000@email.amazonses.com>
 <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com> <20130619145906.GB5146@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com, Frederic Weisbecker <fweisbec@gmail.com>

On Wed, 19 Jun 2013, Paul E. McKenney wrote:

> > I've just ported them over to 3.10 and they merge (with a small fix
> > due to deferred workqueue API changes) and build. I did not try to run
> > this version though.
> > I'll post them as replies to this message.
> >
> > I'd be happy to rescue them from the "TODO" pile... :-)
>
> Please!  ;-)

Well if we are going into vmstat mods then I'd also like to throw in this
old patch:

Subject: vmstat: Avoid interrupt disable in vm stats loop

There is no need to disable interrupts if we use xchg().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2013-05-20 15:19:28.000000000 -0500
+++ linux/mm/vmstat.c	2013-06-19 10:09:09.954024071 -0500
@@ -445,13 +445,8 @@ void refresh_cpu_vm_stats(int cpu)

 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
-				unsigned long flags;
-				int v;
+				int v = xchg(p->vm_stat_diff + i, 0);

-				local_irq_save(flags);
-				v = p->vm_stat_diff[i];
-				p->vm_stat_diff[i] = 0;
-				local_irq_restore(flags);
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_diff[i] += v;
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

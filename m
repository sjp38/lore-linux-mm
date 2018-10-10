Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 712076B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:02:48 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 135-v6so2881184yww.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:02:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8-v6sor1364858ywb.156.2018.10.10.07.02.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 07:02:42 -0700 (PDT)
Date: Wed, 10 Oct 2018 10:02:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-ID: <20181010140239.GA2527@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
 <20181009184732.762-4-hannes@cmpxchg.org>
 <20181009150401.c72cde05338c1ec80a4b8701@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009150401.c72cde05338c1ec80a4b8701@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 09, 2018 at 03:04:01PM -0700, Andrew Morton wrote:
> On Tue,  9 Oct 2018 14:47:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Make it easier to catch bugs in the shadow node shrinker by adding a
> > counter for the shadow nodes in circulation.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  include/linux/mmzone.h |  1 +
> >  mm/vmstat.c            |  1 +
> >  mm/workingset.c        | 12 ++++++++++--
> >  3 files changed, 12 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 4179e67add3d..d82e80d82aa6 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -161,6 +161,7 @@ enum node_stat_item {
> >  	NR_SLAB_UNRECLAIMABLE,
> >  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> >  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> > +	WORKINGSET_NODES,
> 
> Documentation/admin-guide/cgroup-v2.rst, please.  And please check for
> any other missing items while in there?

The new counter isn't being added to the per-cgroup memory.stat,
actually, it just shows in /proc/vmstat.

It seemed a bit too low-level for the cgroup interface, and the other
stats in there are in bytes, which isn't straight-forward to calculate
with sl*b packing.

Not that I'm against adding a cgroup breakdown in general, but the
global counter was enough to see if things were working right or not,
so I'd cross that bridge when somebody needs it per cgroup.

But I checked cgroup-v2.rst anyway: all the exported items are
documented. Only the reclaim vs. refault stats were in different
orders: the doc has the refault stats first, the interface leads with
the reclaim stats. The refault stats go better with the page fault
stats, and are probably of more interest (since they have higher
impact on performance) than the LRU shuffling, so maybe this?

---
Subject: [PATCH] mm: memcontrol: fix memory.stat item ordering

The refault stats go better with the page fault stats, and are of
higher interest than the stats on LRU operations. In fact they used to
be grouped together; when the LRU operation stats were added later on,
they were wedged in between.

Move them back together. Documentation/admin-guide/cgroup-v2.rst
already lists them in the right order.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 81b47d0b14d7..ed15f233d31d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5575,6 +5575,13 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "pgfault %lu\n", acc.events[PGFAULT]);
 	seq_printf(m, "pgmajfault %lu\n", acc.events[PGMAJFAULT]);
 
+	seq_printf(m, "workingset_refault %lu\n",
+		   acc.stat[WORKINGSET_REFAULT]);
+	seq_printf(m, "workingset_activate %lu\n",
+		   acc.stat[WORKINGSET_ACTIVATE]);
+	seq_printf(m, "workingset_nodereclaim %lu\n",
+		   acc.stat[WORKINGSET_NODERECLAIM]);
+
 	seq_printf(m, "pgrefill %lu\n", acc.events[PGREFILL]);
 	seq_printf(m, "pgscan %lu\n", acc.events[PGSCAN_KSWAPD] +
 		   acc.events[PGSCAN_DIRECT]);
@@ -5585,13 +5592,6 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "pglazyfree %lu\n", acc.events[PGLAZYFREE]);
 	seq_printf(m, "pglazyfreed %lu\n", acc.events[PGLAZYFREED]);
 
-	seq_printf(m, "workingset_refault %lu\n",
-		   acc.stat[WORKINGSET_REFAULT]);
-	seq_printf(m, "workingset_activate %lu\n",
-		   acc.stat[WORKINGSET_ACTIVATE]);
-	seq_printf(m, "workingset_nodereclaim %lu\n",
-		   acc.stat[WORKINGSET_NODERECLAIM]);
-
 	return 0;
 }
 

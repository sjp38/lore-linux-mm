Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0274F900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 21:20:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8AA013EE0BD
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 10:20:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7190245DEB2
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 10:20:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5591A45DE7E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 10:20:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 450EC1DB803B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 10:20:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 023981DB8037
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 10:20:29 +0900 (JST)
Date: Tue, 30 Aug 2011 10:12:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110829155113.GA21661@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 29 Aug 2011 17:51:13 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 8 Aug 2011 14:43:33 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > 
> > > On Fri, Jul 22, 2011 at 05:15:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > +When under_hierarchy is added in the tail, the number indicates the
> > > > +total memcg scan of its children and itself.
> > > 
> > > In your implementation, statistics are only accounted to the memcg
> > > triggering the limit and the respectively scanned memcgs.
> > > 
> > > Consider the following setup:
> > > 
> > >         A
> > >        / \
> > >       B   C
> > >      /
> > >     D
> > > 
> > > If D tries to charge but hits the limit of A, then B's hierarchy
> > > counters do not reflect the reclaim activity resulting in D.
> > > 
> > yes, as I expected.
> 
> Andrew,
> 
> with a flawed design, the author unwilling to fix it, and two NAKs,
> can we please revert this before the release?
> 

How about this ?
==
Now, vmscan_stat's hierarchy counter just counts scan data which
is caused by the owner of limits. Then, it's not 'hierarchical'
as other parts of memcg does.

For example, Assuming following hierarchy

	A
       /
      B
     /
    C

When B,C, is scanned because of A's limit, vmscan_stat's
hierarchy accounting does
   A's hierarchy scan = A'scan + B'scan + C'scan
   B's hierarchy scan = 0
   C's hierarchy scan = 0
This first design was because the author considered C's
scan is caused by A. But considering interface compatibility,
following is natural.

  A's hierarchy scan = A'scan + B'scan + C'scan
  B's hierarchy scan = B'scan + C'scan
  C's hierarchy scan = C'scan

This patch changes counting implementation.

Suggested-by: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

Index: mmotm-Aug29/mm/memcontrol.c
===================================================================
--- mmotm-Aug29.orig/mm/memcontrol.c
+++ mmotm-Aug29/mm/memcontrol.c
@@ -229,7 +229,7 @@ enum {
 struct scanstat {
 	spinlock_t	lock;
 	unsigned long	stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
-	unsigned long	rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
+	unsigned long	hierarchy_stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
 };
 
 const char *scanstat_string[NR_SCANSTATS] = {
@@ -1701,6 +1701,7 @@ static void __mem_cgroup_record_scanstat
 static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
 {
 	struct mem_cgroup *memcg;
+	struct cgroup *cgroup;
 	int context = rec->context;
 
 	if (context >= NR_SCAN_CONTEXT)
@@ -1710,11 +1711,18 @@ static void mem_cgroup_record_scanstat(s
 	spin_lock(&memcg->scanstat.lock);
 	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
 	spin_unlock(&memcg->scanstat.lock);
-
-	memcg = rec->root;
-	spin_lock(&memcg->scanstat.lock);
-	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
-	spin_unlock(&memcg->scanstat.lock);
+	cgroup = memcg->css.cgroup;
+	do {
+		spin_lock(&memcg->scanstat.lock);
+		__mem_cgroup_record_scanstat(
+			memcg->scanstat.hierarchy_stats[context], rec);
+		spin_unlock(&memcg->scanstat.lock);
+		if (!cgroup->parent)
+			break;
+		cgroup = cgroup->parent;
+		memcg = mem_cgroup_from_cont(cgroup);
+	} while (memcg->use_hierarchy && memcg != rec->root);
+	return;
 }
 
 /*
@@ -4733,14 +4741,14 @@ static int mem_cgroup_vmscan_stat_read(s
 		strcat(string, SCANSTAT_WORD_LIMIT);
 		strcat(string, SCANSTAT_WORD_HIERARCHY);
 		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_LIMIT][i]);
+		    string, memcg->scanstat.hierarchy_stats[SCAN_BY_LIMIT][i]);
 	}
 	for (i = 0; i < NR_SCANSTATS; i++) {
 		strcpy(string, scanstat_string[i]);
 		strcat(string, SCANSTAT_WORD_SYSTEM);
 		strcat(string, SCANSTAT_WORD_HIERARCHY);
 		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
+		    string, memcg->scanstat.hierarchy_stats[SCAN_BY_SYSTEM][i]);
 	}
 	return 0;
 }
@@ -4752,8 +4760,8 @@ static int mem_cgroup_reset_vmscan_stat(
 
 	spin_lock(&memcg->scanstat.lock);
 	memset(&memcg->scanstat.stats, 0, sizeof(memcg->scanstat.stats));
-	memset(&memcg->scanstat.rootstats,
-		0, sizeof(memcg->scanstat.rootstats));
+	memset(&memcg->scanstat.hierarchy_stats,
+		0, sizeof(memcg->scanstat.hierarchy_stats));
 	spin_unlock(&memcg->scanstat.lock);
 	return 0;
 }






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

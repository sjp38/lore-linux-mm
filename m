Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D97186B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 11:39:35 -0400 (EDT)
Date: Wed, 7 Apr 2010 16:39:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/14] Add /proc trigger for memory compaction
Message-ID: <20100407153910.GR17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-10-git-send-email-mel@csn.ul.ie> <20100406170555.1efe35b0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170555.1efe35b0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:55PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:43 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> > value is written to the file,
> 
> Might be better if "when the number 1 is written...".  That permits you
> to add 2, 3 and 4 later on.
> 

Ok.

> > all zones are compacted. The expected user
> > of such a trigger is a job scheduler that prepares the system before the
> > target application runs.
> > 
> 
> Ick.  The days of multi-user computers seems to have passed.
> 

Functionally, they shouldn't even need it. Direct compaction should work
just fine but it's the type of thing a job scheduler might want so it could
easily work out how many huge pages it potentially has in advance for example.
The same information could be figured out if your kpagemap-foo was strong
enough.

It would also be useful for debugging direct compaction in the same way
drop_caches can be useful. i.e. it's rarely the right thing to use but
it can be handy to illustrate a point. I didn't want to write that into
the docs though.

> > ...
> >
> > +/* Compact all zones within a node */
> > +static int compact_node(int nid)
> > +{
> > +	int zoneid;
> > +	pg_data_t *pgdat;
> > +	struct zone *zone;
> > +
> > +	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
> > +		return -EINVAL;
> > +	pgdat = NODE_DATA(nid);
> > +
> > +	/* Flush pending updates to the LRU lists */
> > +	lru_add_drain_all();
> > +
> > +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> > +		struct compact_control cc;
> > +
> > +		zone = &pgdat->node_zones[zoneid];
> > +		if (!populated_zone(zone))
> > +			continue;
> > +
> > +		cc.nr_freepages = 0;
> > +		cc.nr_migratepages = 0;
> > +		cc.zone = zone;
> 
> It would be better to do
> 
> 	struct compact_control cc = {
> 		.nr_freepages = 0,
> 		etc
> 
> because if you later add more fields to compact_control, everything
> else works by magick.  That's served us pretty well with
> writeback_control, scan_control, etc.
> 	

Done. This is done in the patch below. It'll then collide with a later
patch where order is introduced but it's a trivial fixup to move the
initialisation.

> > +		INIT_LIST_HEAD(&cc.freepages);
> > +		INIT_LIST_HEAD(&cc.migratepages);
> > +
> > +		compact_zone(zone, &cc);
> > +
> > +		VM_BUG_ON(!list_empty(&cc.freepages));
> > +		VM_BUG_ON(!list_empty(&cc.migratepages));
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +/* Compact all nodes in the system */
> > +static int compact_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for_each_online_node(nid)
> > +		compact_node(nid);
> 
> What if a node goes offline?
> 

Then it won't be in the online map?

> > +	return COMPACT_COMPLETE;
> > +}
> > +
> >

==== CUT HERE ====

mm,compaction: Tighten up the allowed values for compact_memory and initialisation

This patch updates the documentation on compact_memory to only define 1
as an allowed value in case it needs to be expanded later. It also
changes how a compact_control structure is initialised to avoid
potential trouble in the future.

This is a fix to the patch "Add /proc trigger for memory compaction".

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/sysctl/vm.txt |    9 ++++-----
 mm/compaction.c             |    9 +++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 803c018..3b3fa1b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -67,11 +67,10 @@ information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
 
 compact_memory
 
-Available only when CONFIG_COMPACTION is set. When an arbitrary value
-is written to the file, all zones are compacted such that free memory
-is available in contiguous blocks where possible. This can be important
-for example in the allocation of huge pages although processes will also
-directly compact memory as required.
+Available only when CONFIG_COMPACTION is set. When 1 is written to the file,
+all zones are compacted such that free memory is available in contiguous
+blocks where possible. This can be important for example in the allocation of
+huge pages although processes will also directly compact memory as required.
 
 ==============================================================
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 615b811..d9c5733 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -393,15 +393,16 @@ static int compact_node(int nid)
 	lru_add_drain_all();
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-		struct compact_control cc;
+		struct compact_control cc = {
+			.nr_freepages = 0,
+			.nr_migratepages = 0,
+			.zone = zone,
+		};
 
 		zone = &pgdat->node_zones[zoneid];
 		if (!populated_zone(zone))
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
-		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

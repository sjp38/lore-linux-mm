Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA056B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:07:45 -0500 (EST)
Received: by igl9 with SMTP id 9so98945854igl.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:07:45 -0800 (PST)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id b19si16535433igr.100.2015.12.01.15.07.44
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 15:07:44 -0800 (PST)
Date: Wed, 2 Dec 2015 08:07:42 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: [PATCH v2] mm: fix warning in comparing enumerator
Message-ID: <20151201230742.GA13514@www9186uo.sakura.ne.jp>
References: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1512011425230.19510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1512011425230.19510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 01, 2015 at 02:25:50PM -0800, David Rientjes wrote:
> On Tue, 1 Dec 2015, Naoya Horiguchi wrote:
> 
> > I saw the following warning when building mmotm-2015-11-25-17-08.
> > 
> > mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
> >   for (i = 0; i < MAX_ZONELISTS; i++) {
> >                 ^
> > 
> > enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
> > we are somehow doing incorrect comparison. Just fixes it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/page_alloc.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> > 
> > diff --git mmotm-2015-11-25-17-08/mm/page_alloc.c mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
> > index e267faa..b801e6f 100644
> > --- mmotm-2015-11-25-17-08/mm/page_alloc.c
> > +++ mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
> > @@ -4174,8 +4174,7 @@ static void set_zonelist_order(void)
> >  
> >  static void build_zonelists(pg_data_t *pgdat)
> >  {
> > -	int j, node, load;
> > -	enum zone_type i;
> > +	int i, j, node, load;
> >  	nodemask_t used_mask;
> >  	int local_node, prev_node;
> >  	struct zonelist *zonelist;
> 
> Obviously correct, but I would have thought we could just remove 'j' and 
> used 'i' as our iterator through the entire function.

You're right, thank you.

Here is v2.

---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] mm: fix warning in comparing enumerator

I saw the following warning when building mmotm-2015-11-25-17-08.

mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
  for (i = 0; i < MAX_ZONELISTS; i++) {
                ^

enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
we are somehow doing incorrect comparison. Just fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
v1 -> v2:
- remove 'j'
---
 mm/page_alloc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e267faad4649..54fcd0a60d5e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4174,8 +4174,7 @@ static void set_zonelist_order(void)
 
 static void build_zonelists(pg_data_t *pgdat)
 {
-	int j, node, load;
-	enum zone_type i;
+	int i, node, load;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
@@ -4195,7 +4194,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	j = 0;
+	i = 0;
 
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
 		/*
@@ -4212,12 +4211,12 @@ static void build_zonelists(pg_data_t *pgdat)
 		if (order == ZONELIST_ORDER_NODE)
 			build_zonelists_in_node_order(pgdat, node);
 		else
-			node_order[j++] = node;	/* remember order */
+			node_order[i++] = node;	/* remember order */
 	}
 
 	if (order == ZONELIST_ORDER_ZONE) {
 		/* calculate node order -- i.e., DMA last! */
-		build_zonelists_in_zone_order(pgdat, j);
+		build_zonelists_in_zone_order(pgdat, i);
 	}
 
 	build_thisnode_zonelists(pgdat);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

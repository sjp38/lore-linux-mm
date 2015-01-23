Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B64B66B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 12:37:12 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id b13so8715572wgh.9
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:37:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l5si3924366wiy.6.2015.01.23.09.37.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 09:37:11 -0800 (PST)
Date: Fri, 23 Jan 2015 12:36:59 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150123173659.GB12036@phnom.home.cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <alpine.DEB.2.11.1501230908560.15325@gentwo.org>
 <20150123160204.GA32592@phnom.home.cmpxchg.org>
 <54C27E07.6000908@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C27E07.6000908@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz

On Fri, Jan 23, 2015 at 08:59:51AM -0800, Guenter Roeck wrote:
> On 01/23/2015 08:02 AM, Johannes Weiner wrote:
> >On Fri, Jan 23, 2015 at 09:17:44AM -0600, Christoph Lameter wrote:
> >>On Fri, 23 Jan 2015, Johannes Weiner wrote:
> >>
> >>>Is the assumption of this patch wrong?  Does the specified node have
> >>>to be online for the fallback to work?
> >>
> >>Nodes that are offline have no control structures allocated and thus
> >>allocations will likely segfault when the address of the controls
> >>structure for the node is accessed.
> >>
> >>If we wanted to prevent that then every allocation would have to add a
> >>check to see if the nodes are online which would impact performance.
> >
> >Okay, that makes sense, thank you.
> >
> >Andrew, can you please drop this patch?
> >
> Problem is that there are three patches.
> 
> 2537ffb mm: memcontrol: consolidate swap controller code
> 2f9b346 mm: memcontrol: consolidate memory controller initialization
> a40d0d2 mm: memcontrol: remove unnecessary soft limit tree node test
> 
> Reverting (or dropping) a40d0d2 alone is not possible since it modifies
> mem_cgroup_soft_limit_tree_init which is removed by 2f9b346.

("mm: memcontrol: consolidate swap controller code") gave me no issues
when rebasing, but ("mm: memcontrol: consolidate memory controller
initialization") needs updating.

So how about this one to replace ("mm: memcontrol: remove unnecessary
soft limit tree node test"):

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: simplify soft limit tree init code

- No need to test the node for N_MEMORY.  node_online() is enough for
  node fallback to work in slab, use NUMA_NO_NODE for everything else.

- Remove the BUG_ON() for allocation failure.  A NULL pointer crash is
  just as descriptive, and the absent return value check is obvious.

- Move local variables to the inner-most blocks.

- Point to the tree structure after its initialized, not before, it's
  just more logical that way.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb9788af4a3e..88c67303d141 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4537,24 +4537,23 @@ EXPORT_SYMBOL(parent_mem_cgroup);
 
 static void __init mem_cgroup_soft_limit_tree_init(void)
 {
-	struct mem_cgroup_tree_per_node *rtpn;
-	struct mem_cgroup_tree_per_zone *rtpz;
-	int tmp, node, zone;
+	int node;
 
 	for_each_node(node) {
-		tmp = node;
-		if (!node_state(node, N_NORMAL_MEMORY))
-			tmp = -1;
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
-		BUG_ON(!rtpn);
+		struct mem_cgroup_tree_per_node *rtpn;
+		int zone;
 
-		soft_limit_tree.rb_tree_per_node[node] = rtpn;
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
+				    node_online(node) ? node : NUMA_NO_NODE);
 
 		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			struct mem_cgroup_tree_per_zone *rtpz;
+
 			rtpz = &rtpn->rb_tree_per_zone[zone];
 			rtpz->rb_root = RB_ROOT;
 			spin_lock_init(&rtpz->lock);
 		}
+		soft_limit_tree.rb_tree_per_node[node] = rtpn;
 	}
 }
 
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 29 Nov 2007 11:24:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
Message-Id: <20071129112406.c6820a5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071129103702.cbc5cf73.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
	<20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
	<1196284799.5318.34.camel@localhost>
	<20071129103702.cbc5cf73.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 10:37:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Maybe zonelists of NODE_DATA() is not initialized. you are right.
> I think N_HIGH_MEMORY will be suitable here...(I'll consider node-hotplug case later.)
> 
> Thank you for test!
> 
Could you try this ? 

Thanks,
-Kame
==

Don't call kmalloc() against possible but offline node.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

Index: test-2.6.24-rc3-mm1/mm/memcontrol.c
===================================================================
--- test-2.6.24-rc3-mm1.orig/mm/memcontrol.c
+++ test-2.6.24-rc3-mm1/mm/memcontrol.c
@@ -1117,8 +1117,14 @@ static int alloc_mem_cgroup_per_zone_inf
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
 	int zone;
-
-	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, node);
+	/*
+	 * This routine is called against possible nodes.
+	 * But it's BUG to call kmalloc() against offline node.
+	 */
+	if (node_state(N_ONLINE, node))
+		pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, node);
+	else
+		pn = kmalloc(sizeof(*pn), GFP_KERNEL);
 	if (!pn)
 		return 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

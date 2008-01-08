Date: Mon, 7 Jan 2008 21:38:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org>
 <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
 <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
 <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
 <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, KAMEZAWA Hiroyuki wrote:

> In usual alloc_pages() allocator, this is done by zonelist fallback.

Hmmm... __cache_alloc_node does:

    if (unlikely(!cachep->nodelists[nodeid])) {
                /* Node not bootstrapped yet */
                ptr = fallback_alloc(cachep, flags);
                goto out;
        }

So kmalloc_node does the correct fallback.

Kmalloc does not fall back but relies on numa_node_id() referring to a 
node that has ZONE_NORMAL memory. Sigh.

cache_alloc_refill:

        node = numa_node_id();

        check_irq_off();
        ac = cpu_cache_get(cachep);
retry:
        batchcount = ac->batchcount;
        if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
                /*
                 * If there was little recent activity on this cache, then
                 * perform only a partial refill.  Otherwise we could generate
                 * refill bouncing.
                 */
                batchcount = BATCHREFILL_LIMIT;
        }
        l3 = cachep->nodelists[node];

	BUG_ON(ac->avail > 0 || !l3);
	^^^^ triggers


> complicated ?

Hmm.. We could check for l3 == NULL and fail in that case? The 
___cache_alloc would fail and __do_cache_alloc would call 
___cache_alloc_node whicvh would provide the correct fallback.

Doesd this fix it?


---
 mm/slab.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-01-07 21:37:34.000000000 -0800
+++ linux-2.6/mm/slab.c	2008-01-07 21:38:09.000000000 -0800
@@ -2977,7 +2977,10 @@ retry:
 	}
 	l3 = cachep->nodelists[node];
 
-	BUG_ON(ac->avail > 0 || !l3);
+	if (!l3)
+		return NULL;
+
+	BUG_ON(ac->avail > 0);
 	spin_lock(&l3->list_lock);
 
 	/* See if we can refill from the shared array */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

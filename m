Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4E2C76B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 03:32:32 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1112020842280.10975@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 09 Dec 2011 16:30:02 +0800
Message-ID: <1323419402.16790.6105.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, 2011-12-02 at 22:43 +0800, Christoph Lameter wrote:
> On Fri, 2 Dec 2011, Alex Shi wrote:
> 
> > From: Alex Shi <alexs@intel.com>
> >
> > Times performance regression were due to slub add to node partial head
> > or tail. That inspired me to do tunning on the node partial adding, to
> > set a criteria for head or tail position selection when do partial
> > adding.
> > My experiment show, when used objects is less than 1/4 total objects
> > of slub performance will get about 1.5% improvement on netperf loopback
> > testing with 2048 clients, wherever on our 4 or 2 sockets platforms,
> > includes sandbridge or core2.
> 
> The number of free objects in a slab may have nothing to do with cache
> hotness of all objects in the slab. You can only be sure that one object
> (the one that was freed) is cache hot. Netperf may use them in sequence
> and therefore you are likely to get series of frees on the same slab
> page. How are other benchmarks affected by this change?


I did some experiments on add_partial judgment against rc4, like to put
the slub into node partial head or tail according to free objects, or
like Eric's suggest to combine the external parameter, like below: 

        n->nr_partial++;
-       if (tail == DEACTIVATE_TO_TAIL)
+       if (tail == DEACTIVATE_TO_TAIL || 
+               page->inuse > page->objects /2)
                list_add_tail(&page->lru, &n->partial);
        else
                list_add(&page->lru, &n->partial);

But the result is out of my expectation before. Now we set all of slub
into the tail of node partial, we get the best performance, even it is
just a slight improvement. 

{
        n->nr_partial++;
-       if (tail == DEACTIVATE_TO_TAIL)
-               list_add_tail(&page->lru, &n->partial);
-       else
-               list_add(&page->lru, &n->partial);
+       list_add_tail(&page->lru, &n->partial);
 }
 
This change can bring about 2% improvement on our WSM-ep machine, and 1%
improvement on our SNB-ep and NHM-ex machine. and no clear effect for
core2 machine. on hackbench process benchmark.

 	./hackbench 100 process 2000 
 
For multiple clients loopback netperf, only a suspicious 1% improvement
on our 2 sockets machine. and others have no clear effect. 

But, when I check the deactivate_to_head/to_tail statistics on original
code, the to_head is just hundreds or thousands times, while to_tail is
called about teens millions times. 

David, could you like to try above change? move all slub to partial
tail. 

add_partial statistics collection patch: 
---
commit 1ff731282acb521f3a7c2e3fb94d35ec4d0ff07e
Author: Alex Shi <alex.shi@intel.com>
Date:   Fri Dec 9 18:12:14 2011 +0800

    slub: statistics collection for add_partial

diff --git a/mm/slub.c b/mm/slub.c
index 5843846..a2b1143 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1904,10 +1904,11 @@ static void unfreeze_partials(struct kmem_cache *s)
 			if (l != m) {
 				if (l == M_PARTIAL)
 					remove_partial(n, page);
-				else
+				else {
 					add_partial(n, page,
 						DEACTIVATE_TO_TAIL);
-
+					stat(s, DEACTIVATE_TO_TAIL);
+				}
 				l = m;
 			}
 
@@ -2480,6 +2481,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 			remove_full(s, page);
 			add_partial(n, page, DEACTIVATE_TO_TAIL);
 			stat(s, FREE_ADD_PARTIAL);
+			stat(s, DEACTIVATE_TO_TAIL);
 		}
 	}
 	spin_unlock_irqrestore(&n->list_lock, flags);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

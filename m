Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D845D600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 04:11:17 -0500 (EST)
Date: Tue, 1 Dec 2009 10:11:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091201091111.GK30235@random.random>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241640590.25288@sister.anvils>
 <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
 <20091130120705.GD30235@random.random>
 <20091201093945.8c24687f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091201093945.8c24687f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 01, 2009 at 09:39:45AM +0900, KAMEZAWA Hiroyuki wrote:
> Maybe some modification to lru scanning is necessary independent from ksm.
> I think.

It looks independent from ksm yes. Larry case especially has cpus
hanging in fork, and for those cpus to make progress it'd be enough to
release the anon_vma lock for a little while. I think counting the
number of young bits we found might be enough to fix this (at least
for anon_vma were we can easily randomize the ptes we scan). Let's
just break the rmap loop of page_referenced() after we cleared N young
bits. If we found so many young bits it's pointless to continue. It
still looks preferable than doing nothing or a full scan depending on
a magic mapcount value. It's preferable because we'll do real work
incrementally and we give a chance to heavily mapped but totally
unused pages to go away in perfect lru order.

Sure we can still end up with a 10000 length of anon_vma chain (or
rmap_item chain, or prio_tree scan) with all N young bits set in the
very last N vmas we check. But statistically with so many mappings
such a scenario has a very low probability to materialize. It's not
very useful to be so aggressive on a page where the young bits are
refreshed quick all the time because of plenty of mappings and many of
them using the page. If we do this, we've also to rotate the anon_vma
list too to start from a new vma, which globally it means randomizing
it. For anon_vma (and conceptually for ksm rmap_item, not sure in
implementation terms) it's trivial to rotate to randomize the young
bit scan. For prio_tree (that includes tmpfs) it's much harder.

In addition to returning 1 every N young bit cleared, we should
ideally also have a spin_needbreak() for the rmap lock so things like
fork can continue against page_referenced one and try_to_unmap
too. Even for the prio_tree we could record the prio_tree position on
the stack and we can add a bit that signals when the prio_tree got
modified under us. But if the rmap structure modified from under us
we're in deep trouble: after that we have to either restart from
scratch (risking a livelock in page_referenced(), so not really
feasible) or alternatively to return 1 breaking the loop which would
make the VM less reliable (which means we would be increasing the
probability of a suprious OOM) . Somebody could just mmap the hugely
mapped file from another task in a loop, and prevent the
page_referenced_one and try_to_unmap to ever complete on all pages of
that file! So I don't really know how to implement the spin_needbreak
without making the VM exploitable. But I'm quite confident there is no
way the below can make the VM less reliable, and the spin_needbreak is
much less relevant for anon_vma than it is for prio_tree because it's
trivial to randomize the ptes we scan for young bit with
anon_vma. Maybe this also is enough to fix tmpfs.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -60,6 +60,8 @@
 
 #include "internal.h"
 
+#define MAX_YOUNG_BIT_CLEARED 64
+
 static struct kmem_cache *anon_vma_cachep;
 
 static inline struct anon_vma *anon_vma_alloc(void)
@@ -420,6 +422,24 @@ static int page_referenced_anon(struct p
 						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
+
+		/*
+		 * Break the loop early if we found many active
+		 * mappings and go deep into the long chain only if
+		 * this looks a fully unused page. Otherwise we only
+		 * waste this cpu and we hang other CPUs too that
+		 * might be waiting on our lock to be released.
+		 */
+		if (referenced >= MAX_YOUNG_BIT_CLEARED) {
+			/*
+			 * randomize the MAX_YOUNG_BIT_CLEARED ptes
+			 * that we scan at every page_referenced_one()
+			 * call on this page.
+			 */
+			list_del(&anon_vma->head);
+			list_add(&anon_vma->head, &vma->anon_vma_node);
+			break;
+		}
 	}
 
 	page_unlock_anon_vma(anon_vma);
@@ -485,6 +505,16 @@ static int page_referenced_file(struct p
 						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
+
+		/*
+		 * Break the loop early if we found many active
+		 * mappings and go deep into the long chain only if
+		 * this looks a fully unused page. Otherwise we only
+		 * waste this cpu and we hang other CPUs too that
+		 * might be waiting on our lock to be released.
+		 */
+		if (referenced >= MAX_YOUNG_BIT_CLEARED)
+			break;
 	}
 
 	spin_unlock(&mapping->i_mmap_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

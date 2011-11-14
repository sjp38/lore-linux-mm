Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E02676B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 00:24:42 -0500 (EST)
Subject: Re: INFO: possible recursive locking detected: get_partial_node()
 on 3.2-rc1
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1111110857330.3557@router.home>
References: <20111109090556.GA5949@zhy>
	 <201111102335.06046.kernelmail.jms@gmail.com>
	 <1320980671.22361.252.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111110857330.3557@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Nov 2011 13:34:13 +0800
Message-ID: <1321248853.22361.280.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Julie Sullivan <kernelmail.jms@gmail.com>, Yong Zhang <yong.zhang0@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-11-11 at 23:02 +0800, Christoph Lameter wrote:
> On Fri, 11 Nov 2011, Shaohua Li wrote:
> 
> > Looks this could be a real dead lock. we hold a lock to free a object,
> > but the free need allocate a new object. if the new object and the freed
> > object are from the same slab, there is a deadlock.
> 
> unfreeze partials is never called when going through get_partial_node()
> so there is no deadlock AFAICT.
the unfreeze_partial isn't called from get_partial_node(). I thought the
code path is something like this: kmem_cache_free()->put_cpu_partial()
(hold lock) ->unfreeze_partials() ->discard_slab ->debug_object_init()
->kmem_cache_alloc->get_partial_node()(hold lock). Not sure if this will
really happen, but looks like a deadlock.
But anyway, discard_slab() can be move out of unfreeze_partials()

> > discard_slab() doesn't need hold the lock if the slab is already removed
> > from partial list. how about below patch, only compile tested.
> 
> In general I think it is good to move the call to discard_slab() out from
> under the list_lock in unfreeze_partials(). Could you fold
> discard_page_list into unfreeze_partials()? __flush_cpu_slab still calls
> discard_page_list with disabled interrupts even after your patch.
I'm afraid there is alloc-in-atomic() error, but Yong & Julie's test
shows this is over thinking. Here is the updated patch. Yong & Julie, I
added your report/test by, because the new patch should be just like the
old one, but since I changed it a little bit, can you please have a
quick check? Thanks!



Subject: slub: move discard_slab out of node lock

Lockdep reports there is potential deadlock for slub node list_lock.
discard_slab() is called with the lock hold in unfreeze_partials(),
which could trigger a slab allocation, which could hold the lock again.

discard_slab() doesn't need hold the lock actually, if the slab is
already removed from partial list.

Reported-and-tested-by: Yong Zhang <yong.zhang0@gmail.com>
Reported-and-tested-by: Julie Sullivan <kernelmail.jms@gmail.com>
Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/slub.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-11-11 16:17:39.000000000 +0800
+++ linux/mm/slub.c	2011-11-14 13:11:11.000000000 +0800
@@ -1862,7 +1862,7 @@ static void unfreeze_partials(struct kme
 {
 	struct kmem_cache_node *n = NULL;
 	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
-	struct page *page;
+	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
 		enum slab_modes { M_PARTIAL, M_FREE };
@@ -1916,14 +1916,22 @@ static void unfreeze_partials(struct kme
 				"unfreezing slab"));
 
 		if (m == M_FREE) {
-			stat(s, DEACTIVATE_EMPTY);
-			discard_slab(s, page);
-			stat(s, FREE_SLAB);
+			page->next = discard_page;
+			discard_page = page;
 		}
 	}
 
 	if (n)
 		spin_unlock(&n->list_lock);
+
+	while (discard_page) {
+		page = discard_page;
+		discard_page = discard_page->next;
+
+		stat(s, DEACTIVATE_EMPTY);
+		discard_slab(s, page);
+		stat(s, FREE_SLAB);
+	}
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

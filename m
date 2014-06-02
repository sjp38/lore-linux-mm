Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C5E5D6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 05:31:41 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so4025022pbc.12
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 02:31:41 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id vx5si15348627pab.104.2014.06.02.02.31.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 02:31:40 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so3227631pdj.20
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 02:31:40 -0700 (PDT)
Date: Mon, 2 Jun 2014 02:30:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: sleeping function warning from __put_anon_vma
In-Reply-To: <20140601193240.GF16155@laptop.programming.kicks-ass.net>
Message-ID: <alpine.LSU.2.11.1406020216240.1177@eggly.anvils>
References: <20140530000944.GA29942@redhat.com> <alpine.LSU.2.11.1405311321340.10272@eggly.anvils> <20140601193240.GF16155@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 1 Jun 2014, Peter Zijlstra wrote:
> On Sat, May 31, 2014 at 01:33:13PM -0700, Hugh Dickins wrote:
> > [PATCH] mm: fix sleeping function warning from __put_anon_vma
> > 
> > Trinity reports BUG:
> > sleeping function called from invalid context at kernel/locking/rwsem.c:47
> > in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
> > __might_sleep < down_write < __put_anon_vma < page_get_anon_vma <
> > migrate_pages < compact_zone < compact_zone_order < try_to_compact_pages ..
> > 
> > Right, since conversion to mutex then rwsem, we should not put_anon_vma()
> > from inside an rcu_read_lock()ed section: fix the two places that did so.
> > 
> > Fixes: 88c22088bf23 ("mm: optimize page_lock_anon_vma() fast-path")
> > Reported-by: Dave Jones <davej@redhat.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Needs-Ack-from: Peter Zijlstra <peterz@infradead.org>
> > ---
> > 
> >  mm/rmap.c |    8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > --- 3.15-rc7/mm/rmap.c	2014-04-13 17:24:36.680507189 -0700
> > +++ linux/mm/rmap.c	2014-05-31 12:02:08.496088637 -0700
> > @@ -426,12 +426,14 @@ struct anon_vma *page_get_anon_vma(struc
> >  	 * above cannot corrupt).
> >  	 */
> >  	if (!page_mapped(page)) {
> > +		rcu_read_unlock();
> >  		put_anon_vma(anon_vma);
> >  		anon_vma = NULL;
> > +		goto outer;
> >  	}
> >  out:
> >  	rcu_read_unlock();
> > -
> > +outer:
> >  	return anon_vma;
> >  }
> 
> I think we can do that without the goto if we write something like:
> 
> 	if (!page_mapped(page)) {
> 		rcu_read_unlock();
> 		put_anon_vma(anon_vma);
> 		return NULL;
> 	}

Yes, that was my preference too.  Then I thought we'd be accused of
mixing early returns and gotos, so did it the goto way.  Since we
both prefer the early return, I'll put it back to that.

> 
> > @@ -477,9 +479,10 @@ struct anon_vma *page_lock_anon_vma_read
> >  	}
> >  
> >  	if (!page_mapped(page)) {
> > +		rcu_read_unlock();
> >  		put_anon_vma(anon_vma);
> >  		anon_vma = NULL;
> > -		goto out;
> > +		goto outer;
> >  	}
> >  
> >  	/* we pinned the anon_vma, its safe to sleep */
> > @@ -501,6 +504,7 @@ struct anon_vma *page_lock_anon_vma_read
> >  
> >  out:
> >  	rcu_read_unlock();
> > +outer:
> >  	return anon_vma;
> >  }
> 
> Same here too, I suppose.
> 
> Interesting that we never managed to hit this one; it might also make
> sense to put a might_sleep() in anon_vma_free().

Yes, good idea, that's an excellent place for a might_sleep(): done.

Though it does change the patch from a "push this out immediately" to a
"let's wait a little to check we don't now see lots of new warnings".

But that's okay, we've survived three years without it; and I saw no
no warnings myself from the new patch, when running under load plus
lots of page migration.

> 
> Other than that, I don't see anything really odd, then again, its sunday
> evening and my thinking cap isn't exactly on proper.

Thank you - shout if any worries arise once the cap is back on.
I think it's fine, I just felt more comfortable bringing you in.

[PATCH v2] mm: fix sleeping function warning from __put_anon_vma

Trinity reports BUG:
sleeping function called from invalid context at kernel/locking/rwsem.c:47
in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
__might_sleep < down_write < __put_anon_vma < page_get_anon_vma <
migrate_pages < compact_zone < compact_zone_order < try_to_compact_pages ..

Right, since conversion to mutex then rwsem, we should not put_anon_vma()
from inside an rcu_read_lock()ed section: fix the two places that did so.
And add might_sleep() to anon_vma_free(), as suggested by Peter Zijlstra.

Fixes: 88c22088bf23 ("mm: optimize page_lock_anon_vma() fast-path")
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
v2: use early return instead of goto
    add might_sleep in anon_vma_free

 mm/rmap.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- 3.15-rc8/mm/rmap.c	2014-04-13 17:24:36.680507189 -0700
+++ linux/mm/rmap.c	2014-06-01 13:08:24.432176737 -0700
@@ -103,6 +103,7 @@ static inline void anon_vma_free(struct
 	 * LOCK should suffice since the actual taking of the lock must
 	 * happen _before_ what follows.
 	 */
+	might_sleep();
 	if (rwsem_is_locked(&anon_vma->root->rwsem)) {
 		anon_vma_lock_write(anon_vma);
 		anon_vma_unlock_write(anon_vma);
@@ -426,8 +427,9 @@ struct anon_vma *page_get_anon_vma(struc
 	 * above cannot corrupt).
 	 */
 	if (!page_mapped(page)) {
+		rcu_read_unlock();
 		put_anon_vma(anon_vma);
-		anon_vma = NULL;
+		return NULL;
 	}
 out:
 	rcu_read_unlock();
@@ -477,9 +479,9 @@ struct anon_vma *page_lock_anon_vma_read
 	}
 
 	if (!page_mapped(page)) {
+		rcu_read_unlock();
 		put_anon_vma(anon_vma);
-		anon_vma = NULL;
-		goto out;
+		return NULL;
 	}
 
 	/* we pinned the anon_vma, its safe to sleep */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

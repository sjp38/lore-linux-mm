Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3DE6B6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 11:23:01 -0500 (EST)
Date: Thu, 25 Nov 2010 17:21:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05 of 66] compound_lock
Message-ID: <20101125162158.GO6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <fc2579c9bddbfcf78d72.1288798060@v2.random>
 <20101118114902.GJ8135@csn.ul.ie>
 <AANLkTik9U_r7tqdDYw24xwTgvp5c740Z9eMQeh8y4Hpi@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTik9U_r7tqdDYw24xwTgvp5c740Z9eMQeh8y4Hpi@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 09:28:27AM -0800, Linus Torvalds wrote:
> On Thu, Nov 18, 2010 at 3:49 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >> +
> >> +static inline void compound_lock_irqsave(struct page *page,
> >> +                                      unsigned long *flagsp)
> >> +{
> >> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >> +     unsigned long flags;
> >> +     local_irq_save(flags);
> >> +     compound_lock(page);
> >> +     *flagsp = flags;
> >> +#endif
> >> +}
> >> +
> >
> > The pattern for spinlock irqsave passes in unsigned long, not unsigned
> > long *. It'd be nice if they matched.
> 
> Indeed. Just make the thing return the flags the way the normal
> spin_lock_irqsave() function does.

Done.

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -320,15 +320,14 @@ static inline void compound_unlock(struc
 #endif
 }
 
-static inline void compound_lock_irqsave(struct page *page,
-					 unsigned long *flagsp)
+static inline unsigned long compound_lock_irqsave(struct page *page)
 {
+	unsigned long uninitialized_var(flags);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	unsigned long flags;
 	local_irq_save(flags);
 	compound_lock(page);
-	*flagsp = flags;
 #endif
+	return flags;
 }
 
 static inline void compound_unlock_irqrestore(struct page *page,


diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -94,7 +94,7 @@ static void put_compound_page(struct pag
 			 */
 			smp_mb();
 			/* page_head wasn't a dangling pointer */
-			compound_lock_irqsave(page_head, &flags);
+			flags = compound_lock_irqsave(page_head);
 			if (unlikely(!PageTail(page))) {
 				/* __split_huge_page_refcount run before us */
 				compound_unlock_irqrestore(page_head, flags);


Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

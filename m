Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 492B76B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 22:52:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1K3qLo8007759
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 20 Feb 2010 12:52:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EE4045DE5D
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 12:52:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6858045DE4E
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 12:52:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49196E78001
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 12:52:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E66761DB803A
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 12:52:20 +0900 (JST)
Date: Sat, 20 Feb 2010 12:48:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM and
 page migration
Message-Id: <20100220124847.0b441e76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100219140500.GG30258@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	<1266516162-14154-4-git-send-email-mel@csn.ul.ie>
	<20100219091859.195d922c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100219140500.GG30258@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010 14:05:00 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Fri, Feb 19, 2010 at 09:18:59AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 18 Feb 2010 18:02:33 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > For clarity of review, KSM and page migration have separate refcounts on
> > > the anon_vma. While clear, this is a waste of memory. This patch gets
> > > KSM and page migration to share their toys in a spirit of harmony.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Nitpick:
> > I think this refcnt has something different characteristics than other
> > usual refcnts. Even when refcnt goes down to 0, anon_vma will not be freed.
> > So, I think some kind of name as temporal_reference_count is better than
> > simple "refcnt". Then, it will be clearer what this refcnt is for.
> > 
> 
> When I read this in a few years, I'll have no idea what "temporal" is
> referring to. The holder of this account is by a process that does not
> necessarily own the page or its mappings but "remote" has special
> meaning as well. "external_count" ?
> 
"external" seems good. My selection of word is tend to be bad ;)

Off topic:
But as Christoph says, make this as real reference counter as
"if coutner goes down to 0, it's freed." may be good.
I'm not fully aware of how anon_vma is copiled after Rik's anon_vma split(?)
work. So, it may be complicated than I'm thinking.

Thanks,
-Kame


> > 
> > > ---
> > >  include/linux/rmap.h |   50 ++++++++++++++++++--------------------------------
> > >  mm/ksm.c             |    4 ++--
> > >  mm/migrate.c         |    4 ++--
> > >  mm/rmap.c            |    6 ++----
> > >  4 files changed, 24 insertions(+), 40 deletions(-)
> > > 
> > > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > > index 6b5a1a9..55c0e9e 100644
> > > --- a/include/linux/rmap.h
> > > +++ b/include/linux/rmap.h
> > > @@ -26,11 +26,17 @@
> > >   */
> > >  struct anon_vma {
> > >  	spinlock_t lock;	/* Serialize access to vma list */
> > > -#ifdef CONFIG_KSM
> > > -	atomic_t ksm_refcount;
> > > -#endif
> > > -#ifdef CONFIG_MIGRATION
> > > -	atomic_t migrate_refcount;
> > > +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
> > > +
> > > +	/*
> > > +	 * The refcount is taken by either KSM or page migration
> > > +	 * to take a reference to an anon_vma when there is no
> > > +	 * guarantee that the vma of page tables will exist for
> > > +	 * the duration of the operation. A caller that takes
> > > +	 * the reference is responsible for clearing up the
> > > +	 * anon_vma if they are the last user on release
> > > +	 */
> > > +	atomic_t refcount;
> > >  #endif
> > >  	/*
> > >  	 * NOTE: the LSB of the head.next is set by
> > > @@ -44,46 +50,26 @@ struct anon_vma {
> > >  };
> > >  
> > >  #ifdef CONFIG_MMU
> > > -#ifdef CONFIG_KSM
> > > -static inline void ksm_refcount_init(struct anon_vma *anon_vma)
> > > +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
> > > +static inline void anonvma_refcount_init(struct anon_vma *anon_vma)
> > >  {
> > > -	atomic_set(&anon_vma->ksm_refcount, 0);
> > > +	atomic_set(&anon_vma->refcount, 0);
> > >  }
> > >  
> > > -static inline int ksm_refcount(struct anon_vma *anon_vma)
> > > +static inline int anonvma_refcount(struct anon_vma *anon_vma)
> > >  {
> > > -	return atomic_read(&anon_vma->ksm_refcount);
> > > +	return atomic_read(&anon_vma->refcount);
> > >  }
> > >  #else
> > > -static inline void ksm_refcount_init(struct anon_vma *anon_vma)
> > > +static inline void anonvma_refcount_init(struct anon_vma *anon_vma)
> > >  {
> > >  }
> > >  
> > > -static inline int ksm_refcount(struct anon_vma *anon_vma)
> > > +static inline int anonvma_refcount(struct anon_vma *anon_vma)
> > >  {
> > >  	return 0;
> > >  }
> > >  #endif /* CONFIG_KSM */
> > > -#ifdef CONFIG_MIGRATION
> > > -static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> > > -{
> > > -	atomic_set(&anon_vma->migrate_refcount, 0);
> > > -}
> > > -
> > > -static inline int migrate_refcount(struct anon_vma *anon_vma)
> > > -{
> > > -	return atomic_read(&anon_vma->migrate_refcount);
> > > -}
> > > -#else
> > > -static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> > > -{
> > > -}
> > > -
> > > -static inline int migrate_refcount(struct anon_vma *anon_vma)
> > > -{
> > > -	return 0;
> > > -}
> > > -#endif /* CONFIG_MIGRATE */
> > >  
> > >  static inline struct anon_vma *page_anon_vma(struct page *page)
> > >  {
> > > diff --git a/mm/ksm.c b/mm/ksm.c
> > > index 56a0da1..7decf73 100644
> > > --- a/mm/ksm.c
> > > +++ b/mm/ksm.c
> > > @@ -318,14 +318,14 @@ static void hold_anon_vma(struct rmap_item *rmap_item,
> > >  			  struct anon_vma *anon_vma)
> > >  {
> > >  	rmap_item->anon_vma = anon_vma;
> > > -	atomic_inc(&anon_vma->ksm_refcount);
> > > +	atomic_inc(&anon_vma->refcount);
> > >  }
> > >  
> > >  static void drop_anon_vma(struct rmap_item *rmap_item)
> > >  {
> > >  	struct anon_vma *anon_vma = rmap_item->anon_vma;
> > >  
> > > -	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
> > > +	if (atomic_dec_and_lock(&anon_vma->refcount, &anon_vma->lock)) {
> > >  		int empty = list_empty(&anon_vma->head);
> > >  		spin_unlock(&anon_vma->lock);
> > >  		if (empty)
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index 1ce6a2f..00777b0 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -619,7 +619,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> > >  		rcu_read_lock();
> > >  		rcu_locked = 1;
> > >  		anon_vma = page_anon_vma(page);
> > > -		atomic_inc(&anon_vma->migrate_refcount);
> > > +		atomic_inc(&anon_vma->refcount);
> > >  	}
> > >  
> > >  	/*
> > > @@ -661,7 +661,7 @@ skip_unmap:
> > >  rcu_unlock:
> > >  
> > >  	/* Drop an anon_vma reference if we took one */
> > > -	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> > > +	if (anon_vma && atomic_dec_and_lock(&anon_vma->refcount, &anon_vma->lock)) {
> > >  		int empty = list_empty(&anon_vma->head);
> > >  		spin_unlock(&anon_vma->lock);
> > >  		if (empty)
> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > index 11ba74a..96b5905 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -172,8 +172,7 @@ void anon_vma_unlink(struct vm_area_struct *vma)
> > >  	list_del(&vma->anon_vma_node);
> > >  
> > >  	/* We must garbage collect the anon_vma if it's empty */
> > > -	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
> > > -					!migrate_refcount(anon_vma);
> > > +	empty = list_empty(&anon_vma->head) && !anonvma_refcount(anon_vma);
> > >  	spin_unlock(&anon_vma->lock);
> > >  
> > >  	if (empty)
> > > @@ -185,8 +184,7 @@ static void anon_vma_ctor(void *data)
> > >  	struct anon_vma *anon_vma = data;
> > >  
> > >  	spin_lock_init(&anon_vma->lock);
> > > -	ksm_refcount_init(anon_vma);
> > > -	migrate_refcount_init(anon_vma);
> > > +	anonvma_refcount_init(anon_vma);
> > >  	INIT_LIST_HEAD(&anon_vma->head);
> > >  }
> > >  
> > > -- 
> > > 1.6.5
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
> > > 
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6DF6B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 06:01:46 -0400 (EDT)
Date: Wed, 7 Apr 2010 11:01:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/14] mm: Share the anon_vma ref counts between KSM
	and page migration
Message-ID: <20100407100124.GM17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-4-git-send-email-mel@csn.ul.ie> <20100406170528.ecb30941.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170528.ecb30941.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:28PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:37 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > For clarity of review, KSM and page migration have separate refcounts on
> > the anon_vma. While clear, this is a waste of memory. This patch gets
> > KSM and page migration to share their toys in a spirit of harmony.
> > 
> > ...
> >
> > @@ -26,11 +26,17 @@
> >   */
> >  struct anon_vma {
> >  	spinlock_t lock;	/* Serialize access to vma list */
> > -#ifdef CONFIG_KSM
> > -	atomic_t ksm_refcount;
> > -#endif
> > -#ifdef CONFIG_MIGRATION
> > -	atomic_t migrate_refcount;
> > +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
> > +
> > +	/*
> > +	 * The external_refcount is taken by either KSM or page migration
> > +	 * to take a reference to an anon_vma when there is no
> > +	 * guarantee that the vma of page tables will exist for
> > +	 * the duration of the operation. A caller that takes
> > +	 * the reference is responsible for clearing up the
> > +	 * anon_vma if they are the last user on release
> > +	 */
> > +	atomic_t external_refcount;
> >  #endif
> 
> hah.
> 

hah indeed. There is a very strong case for merging patch 1 and 3 into
the same patch. They were kept separate because the combined patch was
going to be tricky to review. The expansion of the comment in patch 3
was to avoid a full explanation that was then editted in a later patch.

> > @@ -653,7 +653,7 @@ skip_unmap:
> >  rcu_unlock:
> >  
> >  	/* Drop an anon_vma reference if we took one */
> > -	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> > +	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
> >  		int empty = list_empty(&anon_vma->head);
> >  		spin_unlock(&anon_vma->lock);
> >  		if (empty)
> 
> So we now _do_ test ksm_refcount.  Perhaps that fixed a bug added in [1/14]
> 

Would you like to make patch 3 patch 2 instead and then merge them when
going upstream?

As it is you are right in that there could be a bug if just 1 was merged
but not 3 because both refcounts are not taken. I could fix up patch 1
but a merge would make a lot more sense.

> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 578d0fe..af35b75 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -248,8 +248,7 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
> >  	list_del(&anon_vma_chain->same_anon_vma);
> >  
> >  	/* We must garbage collect the anon_vma if it's empty */
> > -	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
> > -					!migrate_refcount(anon_vma);
> > +	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
> >  	spin_unlock(&anon_vma->lock);
> >  
> >  	if (empty)
> > @@ -273,8 +272,7 @@ static void anon_vma_ctor(void *data)
> >  	struct anon_vma *anon_vma = data;
> >  
> >  	spin_lock_init(&anon_vma->lock);
> > -	ksm_refcount_init(anon_vma);
> > -	migrate_refcount_init(anon_vma);
> > +	anonvma_external_refcount_init(anon_vma);
> 
> What a mouthful.  Can we do s/external_//g?
> 

We could, but it would be misleading.

anon_vma has an explicit and implicit refcount. The implicit reference
is a VMA being on the anon_vma list. The explicit count is
external_refcount. Just "refcount" implies that it is properly reference
counted which is not the case. Someone looking at memory.c might
conclude that there is a refcounting bug because just the list is
checked.

Now, the right thing to do here is to get rid of implicit reference
counting. Peter Ziljstra has posted an RFC patch series on mm preempt
and the first two patches of that cover using proper reference counting.
When/if that gets merged, a rename from external_refcount to refcount
would be appropriate.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

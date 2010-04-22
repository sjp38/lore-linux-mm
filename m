Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 715AC6B01FA
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:40:21 -0400 (EDT)
Received: by wwe15 with SMTP id 15so107112wwe.14
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 07:40:19 -0700 (PDT)
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache  pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1271946226.2100.211.camel@barrios-desktop>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.2.00.1004210927550.4959@router.home>
	 <20100421150037.GJ30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211004360.4959@router.home>
	 <20100421151417.GK30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211027120.4959@router.home>
	 <20100421153421.GM30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211038020.4959@router.home>
	 <20100422092819.GR30306@csn.ul.ie>
	 <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
	 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
	 <1271946226.2100.211.camel@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Apr 2010 23:40:06 +0900
Message-ID: <1271947206.2100.216.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-04-22 at 23:23 +0900, Minchan Kim wrote:
> On Thu, 2010-04-22 at 19:51 +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 22 Apr 2010 19:31:06 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Thu, 22 Apr 2010 19:13:12 +0900
> > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > > 
> > > > On Thu, Apr 22, 2010 at 6:46 PM, KAMEZAWA Hiroyuki
> > > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > > Hmm..in my test, the case was.
> > > > >
> > > > > Before try_to_unmap:
> > > > >        mapcount=1, SwapCache, remap_swapcache=1
> > > > > After remap
> > > > >        mapcount=0, SwapCache, rc=0.
> > > > >
> > > > > So, I think there may be some race in rmap_walk() and vma handling or
> > > > > anon_vma handling. migration_entry isn't found by rmap_walk.
> > > > >
> > > > > Hmm..it seems this kind patch will be required for debug.
> > > > 
> > 
> > Ok, here is my patch for _fix_. But still testing...
> > Running well at least for 30 minutes, where I can see bug in 10minutes.
> > But this patch is too naive. please think about something better fix.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > At adjust_vma(), vma's start address and pgoff is updated under
> > write lock of mmap_sem. This means the vma's rmap information
> > update is atoimic only under read lock of mmap_sem.
> > 
> > 
> > Even if it's not atomic, in usual case, try_to_ummap() etc...
> > just fails to decrease mapcount to be 0. no problem.
> > 
> > But at page migration's rmap_walk(), it requires to know all
> > migration_entry in page tables and recover mapcount.
> > 
> > So, this race in vma's address is critical. When rmap_walk meet
> > the race, rmap_walk will mistakenly get -EFAULT and don't call
> > rmap_one(). This patch adds a lock for vma's rmap information. 
> > But, this is _very slow_.
> > We need something sophisitcated, light-weight update for this..
> > 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/mm_types.h |    1 +
> >  kernel/fork.c            |    1 +
> >  mm/mmap.c                |   11 ++++++++++-
> >  mm/rmap.c                |    3 +++
> >  4 files changed, 15 insertions(+), 1 deletion(-)
> > 
> > Index: linux-2.6.34-rc4-mm1/include/linux/mm_types.h
> > ===================================================================
> > --- linux-2.6.34-rc4-mm1.orig/include/linux/mm_types.h
> > +++ linux-2.6.34-rc4-mm1/include/linux/mm_types.h
> > @@ -183,6 +183,7 @@ struct vm_area_struct {
> >  #ifdef CONFIG_NUMA
> >  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
> >  #endif
> > +	spinlock_t adjust_lock;
> >  };
> >  
> >  struct core_thread {
> > Index: linux-2.6.34-rc4-mm1/mm/mmap.c
> > ===================================================================
> > --- linux-2.6.34-rc4-mm1.orig/mm/mmap.c
> > +++ linux-2.6.34-rc4-mm1/mm/mmap.c
> > @@ -584,13 +584,20 @@ again:			remove_next = 1 + (end > next->
> >  		if (adjust_next)
> >  			vma_prio_tree_remove(next, root);
> >  	}
> > -
> > +	/*
> > +	 * changing all params in atomic. If not, vma_address in rmap.c
> > + 	 * can see wrong result.
> > + 	 */
> > +	spin_lock(&vma->adjust_lock);
> >  	vma->vm_start = start;
> >  	vma->vm_end = end;
> >  	vma->vm_pgoff = pgoff;
> > +	spin_unlock(&vma->adjust_lock);
> >  	if (adjust_next) {
> > +		spin_lock(&next->adjust_lock);
> >  		next->vm_start += adjust_next << PAGE_SHIFT;
> >  		next->vm_pgoff += adjust_next;
> > +		spin_unlock(&next->adjust_lock);
> >  	}
> >  
> >  	if (root) {
> > @@ -1939,6 +1946,7 @@ static int __split_vma(struct mm_struct 
> >  	*new = *vma;
> >  
> >  	INIT_LIST_HEAD(&new->anon_vma_chain);
> > +	spin_lock_init(&new->adjust_lock);
> >  
> >  	if (new_below)
> >  		new->vm_end = addr;
> > @@ -2338,6 +2346,7 @@ struct vm_area_struct *copy_vma(struct v
> >  			if (IS_ERR(pol))
> >  				goto out_free_vma;
> >  			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
> > +			spin_lock_init(&new_vma->adjust_lock);
> >  			if (anon_vma_clone(new_vma, vma))
> >  				goto out_free_mempol;
> >  			vma_set_policy(new_vma, pol);
> > Index: linux-2.6.34-rc4-mm1/kernel/fork.c
> > ===================================================================
> > --- linux-2.6.34-rc4-mm1.orig/kernel/fork.c
> > +++ linux-2.6.34-rc4-mm1/kernel/fork.c
> > @@ -350,6 +350,7 @@ static int dup_mmap(struct mm_struct *mm
> >  			goto fail_nomem;
> >  		*tmp = *mpnt;
> >  		INIT_LIST_HEAD(&tmp->anon_vma_chain);
> > +		spin_lock_init(&tmp->adjust_lock);
> >  		pol = mpol_dup(vma_policy(mpnt));
> >  		retval = PTR_ERR(pol);
> >  		if (IS_ERR(pol))
> > Index: linux-2.6.34-rc4-mm1/mm/rmap.c
> > ===================================================================
> > --- linux-2.6.34-rc4-mm1.orig/mm/rmap.c
> > +++ linux-2.6.34-rc4-mm1/mm/rmap.c
> > @@ -332,11 +332,14 @@ vma_address(struct page *page, struct vm
> >  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> >  	unsigned long address;
> >  
> > +	spin_lock(&vma->adjust_lock);
> >  	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> >  	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
> > +		spin_unlock(&vma->adjust_lock);
> >  		/* page should be within @vma mapping range */
> >  		return -EFAULT;
> >  	}
> > +	spin_unlock(&vma->adjust_lock);
> >  	return address;
> >  }
> >  
> 
> Nice Catch, Kame. :)
> 
> For further optimization, we can hold vma->adjust_lock if vma_address
> returns -EFAULT. But I hope we redesigns it without new locking. 
> But I don't have good idea, now. :(

How about this?
I just merged ideas of Mel and Kame.:)

It just shows the concept, not formal patch. 


diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..61ea742 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -578,6 +578,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	if (vma->anon_vma)
+		spin_lock(&vma->anon_vma->lock);
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -619,7 +621,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
-
+	if (vma->anon_vma) 
+		spin_unlock(&vma->anon_vma->lock);
 	if (remove_next) {
 		if (file) {
 			fput(file);
diff --git a/mm/rmap.c b/mm/rmap.c
index 3a53d9f..8075057 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1359,9 +1359,22 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
+		struct anon_vma *tmp_anon_vma = vma->anon_vma;
+		unsigned long address;
+		int tmp_vma_lock = 0;
+		
+		if (tmp_anon_vma != anon_vma) {
+			spin_lock(&tmp_anon_vma->lock);	
+			tmp_vma_lock = 1;
+		}
+		address = vma_address(page, vma);
+		if (address == -EFAULT) {
+			if (tmp_vma_lock)
+				spin_unlock(&tmp_anon_vma->lock);
 			continue;
+		}
+		if (tmp_vma_lock)
+			spin_unlock(&tmp_anon_vma->lock);
 		ret = rmap_one(page, vma, address, arg);
 		if (ret != SWAP_AGAIN)
 			break;
-- 
1.7.0.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

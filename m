Date: Fri, 8 Jun 2007 14:54:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
Message-Id: <20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 22:47:08 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> >  static inline void anon_vma_lock(struct vm_area_struct *vma)
> >  {
> >  	struct anon_vma *anon_vma = vma->anon_vma;
> 
> Could you fold as much as possible into mm/migrate.c?
> 
Ah, maybe ok. But scattering codes around rmap in several files is ok ?


> > +void anon_vma_release(struct anon_vma *anon_vma, struct vm_area_struct *holder)
> > +{
> > +	if (!anon_vma)
> > +		return;
> > +	BUG_ON(anon_vma != holder->anon_vma);
> > +	anon_vma_unlink(holder);
> > +}
> > +#endif
> 
> This is mostly also specific to page migration?
> 
yes. 

> > @@ -333,6 +362,8 @@ static int page_referenced_anon(struct p
> >  
> >  	mapcount = page_mapcount(page);
> >  	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> > +		if (is_dummy_vma(vma))
> > +			continue;
> >  		referenced += page_referenced_one(page, vma, &mapcount);
> >  		if (!mapcount)
> >  			break;
> > @@ -864,6 +895,8 @@ static int try_to_unmap_anon(struct page
> >  		return ret;
> >  
> >  	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> > +		if (is_dummy_vma(vma))
> > +			continue;
> >  		ret = try_to_unmap_one(page, vma, migration);
> >  		if (ret == SWAP_FAIL || !page_mapped(page))
> >  			break;
> 
> Could you avoid these checks by having page_referend_one fail
> appropriately on the dummy vma?
> 
Hmm, Is this better ?
==
static int page_referenced_one(struct page *page,
        struct vm_area_struct *vma, unsigned int *mapcount)
{
        struct mm_struct *mm = vma->vm_mm;
        unsigned long address;
        pte_t *pte;
        spinlock_t *ptl;
        int referenced = 0;

+	if(is_dummy_vma(vma))
+		return 0;
==

-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

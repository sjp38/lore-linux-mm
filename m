Date: Fri, 8 Jun 2007 15:06:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
Message-Id: <20070608150602.78f07b34.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
	<20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
	<20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 22:57:19 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > Ah, maybe ok. But scattering codes around rmap in several files is ok ?
> 
> No. Lets try to keep the changes to rmap minimal.
> 
Okay, will do my best.

> > > Could you avoid these checks by having page_referend_one fail
> > > appropriately on the dummy vma?
> > > 
> > Hmm, Is this better ?
> > ==
> > static int page_referenced_one(struct page *page,
> >         struct vm_area_struct *vma, unsigned int *mapcount)
> > {
> >         struct mm_struct *mm = vma->vm_mm;
> >         unsigned long address;
> >         pte_t *pte;
> >         spinlock_t *ptl;
> >         int referenced = 0;
> > 
> > +	if(is_dummy_vma(vma))
> > +		return 0;
> 
> The best solution would be if you could fill the dummy vma with such 
> values that will give you the intended result without having to modify 
> page_referenced_one. If you can make vma_address() fail then you have 
> what you want. F.e. setting vma->vm_end to zero should do it. (is it not 
> already zero?)
> 
> 
Hmm, maybe your option will work. I'll try it in the next set.
My concern is that almost all people will never imagine anon_vma can includes
dummy_vma in some special case..

-Kame


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

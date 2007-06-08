Date: Thu, 7 Jun 2007 22:57:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
In-Reply-To: <20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
 <20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:

> On Thu, 7 Jun 2007 22:47:08 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > >  static inline void anon_vma_lock(struct vm_area_struct *vma)
> > >  {
> > >  	struct anon_vma *anon_vma = vma->anon_vma;
> > 
> > Could you fold as much as possible into mm/migrate.c?
> > 
> Ah, maybe ok. But scattering codes around rmap in several files is ok ?

No. Lets try to keep the changes to rmap minimal.

> > Could you avoid these checks by having page_referend_one fail
> > appropriately on the dummy vma?
> > 
> Hmm, Is this better ?
> ==
> static int page_referenced_one(struct page *page,
>         struct vm_area_struct *vma, unsigned int *mapcount)
> {
>         struct mm_struct *mm = vma->vm_mm;
>         unsigned long address;
>         pte_t *pte;
>         spinlock_t *ptl;
>         int referenced = 0;
> 
> +	if(is_dummy_vma(vma))
> +		return 0;

The best solution would be if you could fill the dummy vma with such 
values that will give you the intended result without having to modify 
page_referenced_one. If you can make vma_address() fail then you have 
what you want. F.e. setting vma->vm_end to zero should do it. (is it not 
already zero?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

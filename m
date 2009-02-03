Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA1C5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:47:59 -0500 (EST)
Subject: Re: [PATCH] fix mlocked page counter mismatch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090202232719.GC13532@barrios-desktop>
References: <20090202061622.GA13286@barrios-desktop>
	 <1233594995.17895.144.camel@lts-notebook>
	 <20090202232719.GC13532@barrios-desktop>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 20:48:06 -0500
Message-Id: <1233625686.17895.219.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-03 at 08:27 +0900, MinChan Kim wrote:
> On Mon, Feb 02, 2009 at 12:16:35PM -0500, Lee Schermerhorn wrote:
> > On Mon, 2009-02-02 at 15:16 +0900, MinChan Kim wrote:
> > > When I tested following program, I found that mlocked counter 
> > > is strange. 
> > > It couldn't free some mlocked pages of test program.
> > > 
> > > It is caused that try_to_unmap_file don't check real 
> > > page mapping in vmas. 
> > > That's because goal of address_space for file is to find all processes 
> > > into which the file's specific interval is mapped. 
> > > What I mean is that it's not related page but file's interval.
> > > 
> > > Even if the page isn't really mapping at the vma, it returns 
> > > SWAP_MLOCK since the vma have VM_LOCKED, then calls 
> > > try_to_mlock_page. After all, mlocked counter is increased again. 
> > > 
> > > This patch is based on 2.6.28-rc2-mm1.
> > > 
> > > -- my test program --
> > > 
> > > #include <stdio.h>
> > > #include <sys/mman.h>
> > > int main()
> > > {
> > >         mlockall(MCL_CURRENT);
> > >         return 0;
> > > }
> > > 
> > > -- before --
> > > 
> > > root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> > > Unevictable:           0 kB
> > > Mlocked:               0 kB
> > > 
> > > -- after --
> > > 
> > > root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> > > Unevictable:           8 kB
> > > Mlocked:               8 kB
> > > 
> > > 
> > > --
> > > 
> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > index 1099394..9ba1fdf 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -1073,6 +1073,9 @@ static int try_to_unmap_file(struct page *page, int unlock, int migration)
> > >  	unsigned long max_nl_size = 0;
> > >  	unsigned int mapcount;
> > >  	unsigned int mlocked = 0;
> > > +	unsigned long address;
> > > +	pte_t *pte;
> > > +	spinlock_t *ptl;
> > >  
> > >  	if (MLOCK_PAGES && unlikely(unlock))
> > >  		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
> > > @@ -1089,6 +1092,13 @@ static int try_to_unmap_file(struct page *page, int unlock, int migration)
> > >  				goto out;
> > >  		}
> > >  		if (ret == SWAP_MLOCK) {
> > > +     address = vma_address(page, vma);
> > > +     if (address != -EFAULT) {
> > > +       pte = page_check_address(page, vma->vm_mm, address, &ptl, 0);
> > > +       if (!pte)
> > > +            continue; 
> > > +       pte_unmap_unlock(pte, ptl);
> > > +     } 
> > >  			mlocked = try_to_mlock_page(page, vma);
> > >  			if (mlocked)
> > >  				break;  /* stop if actually mlocked page */
> > 
> > Hi, MinChan:
> > 
> >    Interestingly, Rik had addressed this [simpler patch below] way back
> > when he added the page_mapped_in_vma() function.  I asked him whether
> 
> 
> > the rb tree shouldn't have filtered any vmas that didn't have the page
> > mapped.  He agreed and removed the check from try_to_unmap_file().
> > Guess I can be very convincing, even when I'm wrong [happening a lot
> > lately].  Of course, in this instance, the rb-tree filtering only works
> > for shared, page-cache pages.  The problem uncovered by your test case
> 
> It's not rb-tree but priority tree. ;-)

Yeah, that one :).

> 
> > is with a COWed anon page in a file-backed vma.  Yes, the vma 'maps' the
> > virtual address range containing the page in question, but since it's a
> > private COWed anon page, it isn't necessarily "mapped" in the VM_LOCKED
> > vma's mm's page table.  We need the check...
> 
> Indeed!
> 
> > 
> > I've added the variant below [CURRENTLY UNTESTED] to my test tree.
> > 
> > Lee
> > 
> > [intentionally omitted sign off, until tested.]
> 
> I shouldn't forgot page_mapped_in_vma.
> However, It looks good to me. 
> Thank you for testing. 

I did test this on 29-rc3 on a 4 socket x dual core x86_64 platform and
it seems to resolve the statistics miscount.  How do you want to
proceed.  Do you want to repost with this version of patch?  Or shall I?

Regards,
Lee

> > 
> > 
> > Index: linux-2.6.29-rc3/mm/rmap.c
> > ===================================================================
> > --- linux-2.6.29-rc3.orig/mm/rmap.c	2009-01-30 14:13:56.000000000 -0500
> > +++ linux-2.6.29-rc3/mm/rmap.c	2009-02-02 11:27:11.000000000 -0500
> > @@ -1072,7 +1072,8 @@ static int try_to_unmap_file(struct page
> >  	spin_lock(&mapping->i_mmap_lock);
> >  	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> >  		if (MLOCK_PAGES && unlikely(unlock)) {
> > -			if (!(vma->vm_flags & VM_LOCKED))
> > +			if (!((vma->vm_flags & VM_LOCKED) &&
> > +			      page_mapped_in_vma(page, vma)))
> >  				continue;	/* must visit all vmas */
> >  			ret = SWAP_MLOCK;
> >  		} else {
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

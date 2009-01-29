Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8026B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 20:49:01 -0500 (EST)
Subject: Re: [BUG] mlocked page counter mismatch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090128235514.GB24924@barrios-desktop>
References: <20090128102841.GA24924@barrios-desktop>
	 <1233156832.8760.85.camel@lts-notebook>
	 <20090128235514.GB24924@barrios-desktop>
Content-Type: text/plain
Date: Wed, 28 Jan 2009 20:48:56 -0500
Message-Id: <1233193736.8760.199.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-01-29 at 08:55 +0900, MinChan Kim wrote:
> On Wed, Jan 28, 2009 at 10:33:52AM -0500, Lee Schermerhorn wrote:
> > On Wed, 2009-01-28 at 19:28 +0900, MinChan Kim wrote:
> > > After executing following program, 'cat /proc/meminfo' shows
> > > following result. 
> > > 
> > > --
> > > # cat /proc/meminfo 
> > > ..
> > > Unevictable:           8 kB
> > > Mlocked:               8 kB
> > > ..
> > 
> > Sorry, from your description, I can't understand what the problem is.
> > Are you saying that 8kB [2 pages] remains locked after you run your
> > test?
> 
> Yes. 
> Sorry. My explanation was not enought. 
> 
> > 
> > What did meminfo show before running the test program?  And what kernel
> > version?
> 
> The meminfo showed mlocked, unevictable pages was zero. 
> My kernel version is 2.6.29-rc2. 

OK, thanks.
> 
> > 
> > > 
> > > -- test program --
> > > 
> > > #include <stdio.h>
> > > #include <sys/mman.h>
> > > int main()
> > > {
> > >         char buf[64] = {0,};
> > >         char *ptr;
> > >         int k;
> > >         int i,j;
> > >         int x,y;
> > >         mlockall(MCL_CURRENT);
> > >         sprintf(buf, "cat /proc/%d/maps", getpid());
> > >         system(buf);
> > >         return 0;
> > > }
> > > 
> > > --
> > > 
> > > It seems mlocked page counter have a problem.
> > > After I diged in source, I found that try_to_unmap_file called 
> > > try_to_mlock_page about shared mapping pages 
> > > since other vma had VM_LOCKED flag.
> > > After all, try_to_mlock_page called mlock_vma_page. 
> > > so, mlocked counter increased
> > 
> > This path of try_to_unmap_file() -> try_to_mlock_page() should only be
> > invoked during reclaim--from shrink_page_list().  [try_to_unmap() is
> > also called from page migration, but in this case, try_to_unmap_one()
> > won't return SWAP_MLOCK so we don't call try_to_mlock_page().]  Unless
> > your system is in continuous reclaim, I don't think you'd hit this
> > during your test program.
> 
> My system was not reclaim mode. It could be called following path. 
> exit_mmap -> munlock_vma_pages_all->munlock_vma_page->try_to_munlock->
> try_to_unmap_file->try_to_mlock_page

Ah.  Yes.  Well, try_to_mlock_page() should only call mlock_vma_page()
if some other vma that maps the pages is VM_LOCKED.  The vma in the task
calling try_to_munlock() should have already cleared VM_LOCKED for the
vma.  However, we need to ensure that the page is actually mapped in the
address range of any VM_LOCKED vma.  I recall that Rik discovered this
back during testing and fixed it, but perhaps it was another path.  

Looks at code again....

I think I see it.  In try_to_unmap_anon(), called from try_to_munlock(),
we have:

         list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
                if (MLOCK_PAGES && unlikely(unlock)) {
                        if (!((vma->vm_flags & VM_LOCKED) &&
!!! should be '||' ?                                      ^^
                              page_mapped_in_vma(page, vma)))
                                continue;  /* must visit all unlocked vmas */
                        ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
                } else {
                        ret = try_to_unmap_one(page, vma, migration);
                        if (ret == SWAP_FAIL || !page_mapped(page))
                                break;
                }
                if (ret == SWAP_MLOCK) {
                        mlocked = try_to_mlock_page(page, vma);
                        if (mlocked)
                                break;  /* stop if actually mlocked page */
                }
        }

or that clause [under if (MLOCK_PAGES && unlikely(unlock))]
might be clearer as:

               if ((vma->vm_flags & VM_LOCKED) && page_mapped_in_vma(page, vma))
                      ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
               else
                      continue;  /* must visit all unlocked vmas */


Do you agree?

And, I wonder if we need a similar check for 
page_mapped_in_vma(page, vma) up in try_to_unmap_one()?

> 
> > 
> > > 
> > > But, After I called munlockall intentionally, the counter work well. 
> > > In case of munlockall, we already had a mmap_sem about write. 
> > > Such a case, try_to_mlock_page can't call mlock_vma_page.
> > > so, mlocked counter didn't increased. 
> > > As a result, the counter seems to be work well but I think 
> > > it also have a problem.
> > 
> > I THINK this is a artifact of the way stats are accumulated in per cpu
> > differential counters and pushed to the zone state accumulators when a
> > threshold is reached.  I've seen this condition before, but it
> > eventually clears itself as the stats get pushed to the zone state.
> > Still, it bears more investigation, as it's been a while since I worked
> > on this and some subsequent fixes could have broken it:
> 
> Hmm... My test result is as follow. 
> 
> 1) without munlockall
> before:
> 
> root@barrios-target-linux:~# tail -8 /proc/vmstat 
> unevictable_pgs_culled 0
> unevictable_pgs_scanned 0
> unevictable_pgs_rescued 0
> unevictable_pgs_mlocked 0
> unevictable_pgs_munlocked 0
> unevictable_pgs_cleared 0
> unevictable_pgs_stranded 0
> unevictable_pgs_mlockfreed 0
> 
> root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> Unevictable:           0 kB
> Mlocked:               0 kB
> 
> after:
> root@barrios-target-linux:~# tail -8 /proc/vmstat 
> unevictable_pgs_culled 369
> unevictable_pgs_scanned 0
> unevictable_pgs_rescued 388
> unevictable_pgs_mlocked 392
> unevictable_pgs_munlocked 387
> unevictable_pgs_cleared 1

this looks like either some task forked and COWed an anon page--perhaps
a stack page--or truncated a mlocked, mmaped file.  

> unevictable_pgs_stranded 0
> unevictable_pgs_mlockfreed 0
> 
> root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> Unevictable:           8 kB
> Mlocked:               8 kB
> 
> after dropping cache
> 
> root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> Unevictable:           4 kB
> Mlocked:               4 kB

Same effect I was seeing.  Two extra mlock counts until we drop cache.
Then only 1.  Interesting.

> 
> 
> 2) with munlockall 
> 
> barrios-target@barrios-target-linux:~$ tail -8 /proc/vmstat
> unevictable_pgs_culled 0
> unevictable_pgs_scanned 0
> unevictable_pgs_rescued 0
> unevictable_pgs_mlocked 0
> unevictable_pgs_munlocked 0
> unevictable_pgs_cleared 0
> unevictable_pgs_stranded 0
> unevictable_pgs_mlockfreed 0
> 
> barrios-target@barrios-target-linux:~$ cat /proc/meminfo | egrep 'Mlo|Unev'
> Unevictable:           0 kB
> Mlocked:               0 kB
> 
> after
> 
> 
> root@barrios-target-linux:~# tail -8 /proc/vmstat
> unevictable_pgs_culled 369
> unevictable_pgs_scanned 0
> unevictable_pgs_rescued 389
> unevictable_pgs_mlocked 389
> unevictable_pgs_munlocked 389
> unevictable_pgs_cleared 0
> unevictable_pgs_stranded 0
> unevictable_pgs_mlockfreed 0
> 
> root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
> Unevictable:           0 kB
> Mlocked:               0 kB
> 
> Both tests have to show same result. 
> But is didn't. 
> 
> I think it's not per-cpu problem. 
> 
> When I digged in the source, I found that. 
> In case of test without munlockall, try_to_unmap_file calls try_to_mlock_page 

This I don't understand.  exit_mmap() calls munlock_vma_pages_all() for
all VM_LOCKED vmas.  This should have the same effect as calling
mlock_fixup() without VM_LOCKED flags, which munlockall() does.


> since some pages are mapped several vmas(I don't know why that pages is shared 
> other vma in same process. 

Isn't necessarily in the same task.  We're traversing the list of vma's
associated with a single anon_vma.  This includes all ancestors and
descendants that haven't exec'd.  Of course, I don't see a fork() in
either of your test programs, so I don't know what's happening.

> One of page which i have seen is test program's 
> first code page[page->index : 0 vma->vm_pgoff : 0]. It was mapped by data vma, too). 
> Other vma have VM_LOCKED.
> So try_to_unmap_file calls try_to_mlock_page. Then, After calling 
> successful down_read_try_lock call, mlock_vma_page increased mlocked
> counter again. 
> 
> In case of test with munlockall, try_to_mlock_page's down_read_trylock 
> couldn't be sucessful. That's because munlockall called down_write.
> At result, try_to_mlock_page cannot call try_to_mlock_page. so, mlocked counter 
> don't increased. I think it's not right. 
> But fortunately Mlocked number is right. :(


I'll try with your 2nd test program [sent via separate mail] and try the
fix above.  I also want to understand the difference between exit_mmap()
for a task that called mlockall() and the munlockall() case.

Regards,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

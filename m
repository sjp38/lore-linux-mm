Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 731146B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 18:55:43 -0500 (EST)
Received: by ewy9 with SMTP id 9so345980ewy.14
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 15:55:41 -0800 (PST)
Date: Thu, 29 Jan 2009 08:55:14 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [BUG] mlocked page counter mismatch
Message-ID: <20090128235514.GB24924@barrios-desktop>
References: <20090128102841.GA24924@barrios-desktop> <1233156832.8760.85.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1233156832.8760.85.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 28, 2009 at 10:33:52AM -0500, Lee Schermerhorn wrote:
> On Wed, 2009-01-28 at 19:28 +0900, MinChan Kim wrote:
> > After executing following program, 'cat /proc/meminfo' shows
> > following result. 
> > 
> > --
> > # cat /proc/meminfo 
> > ..
> > Unevictable:           8 kB
> > Mlocked:               8 kB
> > ..
> 
> Sorry, from your description, I can't understand what the problem is.
> Are you saying that 8kB [2 pages] remains locked after you run your
> test?

Yes. 
Sorry. My explanation was not enought. 

> 
> What did meminfo show before running the test program?  And what kernel
> version?

The meminfo showed mlocked, unevictable pages was zero. 
My kernel version is 2.6.29-rc2. 

> 
> > 
> > -- test program --
> > 
> > #include <stdio.h>
> > #include <sys/mman.h>
> > int main()
> > {
> >         char buf[64] = {0,};
> >         char *ptr;
> >         int k;
> >         int i,j;
> >         int x,y;
> >         mlockall(MCL_CURRENT);
> >         sprintf(buf, "cat /proc/%d/maps", getpid());
> >         system(buf);
> >         return 0;
> > }
> > 
> > --
> > 
> > It seems mlocked page counter have a problem.
> > After I diged in source, I found that try_to_unmap_file called 
> > try_to_mlock_page about shared mapping pages 
> > since other vma had VM_LOCKED flag.
> > After all, try_to_mlock_page called mlock_vma_page. 
> > so, mlocked counter increased
> 
> This path of try_to_unmap_file() -> try_to_mlock_page() should only be
> invoked during reclaim--from shrink_page_list().  [try_to_unmap() is
> also called from page migration, but in this case, try_to_unmap_one()
> won't return SWAP_MLOCK so we don't call try_to_mlock_page().]  Unless
> your system is in continuous reclaim, I don't think you'd hit this
> during your test program.

My system was not reclaim mode. It could be called following path. 
exit_mmap -> munlock_vma_pages_all->munlock_vma_page->try_to_munlock->
try_to_unmap_file->try_to_mlock_page

> 
> > 
> > But, After I called munlockall intentionally, the counter work well. 
> > In case of munlockall, we already had a mmap_sem about write. 
> > Such a case, try_to_mlock_page can't call mlock_vma_page.
> > so, mlocked counter didn't increased. 
> > As a result, the counter seems to be work well but I think 
> > it also have a problem.
> 
> I THINK this is a artifact of the way stats are accumulated in per cpu
> differential counters and pushed to the zone state accumulators when a
> threshold is reached.  I've seen this condition before, but it
> eventually clears itself as the stats get pushed to the zone state.
> Still, it bears more investigation, as it's been a while since I worked
> on this and some subsequent fixes could have broken it:

Hmm... My test result is as follow. 

1) without munlockall
before:

root@barrios-target-linux:~# tail -8 /proc/vmstat 
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           0 kB
Mlocked:               0 kB

after:
root@barrios-target-linux:~# tail -8 /proc/vmstat 
unevictable_pgs_culled 369
unevictable_pgs_scanned 0
unevictable_pgs_rescued 388
unevictable_pgs_mlocked 392
unevictable_pgs_munlocked 387
unevictable_pgs_cleared 1
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           8 kB
Mlocked:               8 kB

after dropping cache

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           4 kB
Mlocked:               4 kB


2) with munlockall 

barrios-target@barrios-target-linux:~$ tail -8 /proc/vmstat
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

barrios-target@barrios-target-linux:~$ cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           0 kB
Mlocked:               0 kB

after


root@barrios-target-linux:~# tail -8 /proc/vmstat
unevictable_pgs_culled 369
unevictable_pgs_scanned 0
unevictable_pgs_rescued 389
unevictable_pgs_mlocked 389
unevictable_pgs_munlocked 389
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           0 kB
Mlocked:               0 kB

Both tests have to show same result. 
But is didn't. 

I think it's not per-cpu problem. 

When I digged in the source, I found that. 
In case of test without munlockall, try_to_unmap_file calls try_to_mlock_page 
since some pages are mapped several vmas(I don't know why that pages is shared 
other vma in same process. One of page which i have seen is test program's 
first code page[page->index : 0 vma->vm_pgoff : 0]. It was mapped by data vma, too). 
Other vma have VM_LOCKED.
So try_to_unmap_file calls try_to_mlock_page. Then, After calling 
successful down_read_try_lock call, mlock_vma_page increased mlocked
counter again. 

In case of test with munlockall, try_to_mlock_page's down_read_trylock 
couldn't be sucessful. That's because munlockall called down_write.
At result, try_to_mlock_page cannot call try_to_mlock_page. so, mlocked counter 
don't increased. I think it's not right. 
But fortunately Mlocked number is right. :(

--
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

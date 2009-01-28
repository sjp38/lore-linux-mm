Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B49C36B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 10:34:17 -0500 (EST)
Subject: Re: [BUG] mlocked page counter mismatch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090128102841.GA24924@barrios-desktop>
References: <20090128102841.GA24924@barrios-desktop>
Content-Type: text/plain
Date: Wed, 28 Jan 2009 10:33:52 -0500
Message-Id: <1233156832.8760.85.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-01-28 at 19:28 +0900, MinChan Kim wrote:
> After executing following program, 'cat /proc/meminfo' shows
> following result. 
> 
> --
> # cat /proc/meminfo 
> ..
> Unevictable:           8 kB
> Mlocked:               8 kB
> ..

Sorry, from your description, I can't understand what the problem is.
Are you saying that 8kB [2 pages] remains locked after you run your
test?

What did meminfo show before running the test program?  And what kernel
version?

> 
> -- test program --
> 
> #include <stdio.h>
> #include <sys/mman.h>
> int main()
> {
>         char buf[64] = {0,};
>         char *ptr;
>         int k;
>         int i,j;
>         int x,y;
>         mlockall(MCL_CURRENT);
>         sprintf(buf, "cat /proc/%d/maps", getpid());
>         system(buf);
>         return 0;
> }
> 
> --
> 
> It seems mlocked page counter have a problem.
> After I diged in source, I found that try_to_unmap_file called 
> try_to_mlock_page about shared mapping pages 
> since other vma had VM_LOCKED flag.
> After all, try_to_mlock_page called mlock_vma_page. 
> so, mlocked counter increased

This path of try_to_unmap_file() -> try_to_mlock_page() should only be
invoked during reclaim--from shrink_page_list().  [try_to_unmap() is
also called from page migration, but in this case, try_to_unmap_one()
won't return SWAP_MLOCK so we don't call try_to_mlock_page().]  Unless
your system is in continuous reclaim, I don't think you'd hit this
during your test program.

> 
> But, After I called munlockall intentionally, the counter work well. 
> In case of munlockall, we already had a mmap_sem about write. 
> Such a case, try_to_mlock_page can't call mlock_vma_page.
> so, mlocked counter didn't increased. 
> As a result, the counter seems to be work well but I think 
> it also have a problem.

I THINK this is a artifact of the way stats are accumulated in per cpu
differential counters and pushed to the zone state accumulators when a
threshold is reached.  I've seen this condition before, but it
eventually clears itself as the stats get pushed to the zone state.
Still, it bears more investigation, as it's been a while since I worked
on this and some subsequent fixes could have broken it:

I ran your test program on one of our x86_64 test systems running
2.6.29-rc2-mmotm-090116-1618, immediately after boot.  Here's what I
saw:

## before:
#cat /proc/meminfo | egrep 'Unev|Mlo'
Unevictable:        3448 kB
Mlocked:            3448 kB	# = 862 4k pages

This is the usual case on this platform. I'm using a RHEL5 distro
installation and one of the system daemons mlocks itself.  I forget
which.  I'll need to investigate further.  Also, it's possible that this
value itself is lower than the actual number of mlocked pages because
some of the counts may still be in the per cpu differential counters.

#tail -8 /proc/vmstat
unevictable_pgs_culled 738
unevictable_pgs_scanned 0
unevictable_pgs_rescued 117  # = 89 + 28 - OK
unevictable_pgs_mlocked 979  # 979 - 117 = 862 remaining locked
unevictable_pgs_munlocked 89
unevictable_pgs_cleared 28
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

So far, so good.  Now, run your test:

#./mck-mlock-test
<snip the map output>
#cat /proc/meminfo | egrep 'Unev|Mlo'
Unevictable:        3460 kB
Mlocked:            3460 kB	# = 865 pages;  3 more than above

# tail -8 /proc/vmstat
unevictable_pgs_culled 757
unevictable_pgs_scanned 0
unevictable_pgs_rescued 154	# = 125 + 29 - OK
unevictable_pgs_mlocked 1374	# 1374 - 154 = 1220 ???? 
unevictable_pgs_munlocked 125
unevictable_pgs_cleared 29
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

So, we have 3 additional pages shown as unevictable; and our stats don't
add up.  We see way more pages mlocked than munlocked/cleared.  [Aside:
clear happens on file truncation and COW of mlocked pages.]  I wonder if
this is the result of removing some of the lru_add_drain_all() calls
that we used to have in the mlock code to improve the statistics.  We
don't seem to have stranded any pages--that is, left them unevictable
because we couldn't isolate them from the lru for munlock.

If I drop caches, or run a moderately heavy mlock test--both of which
generate quite a bit of zone and vmstat activity--the meminfo values
become:

Unevictable:        3456 kB
Mlocked:            3456 kB

Which is two more mlocked pages than we saw right after boot.  If I
rerun your test repeatedly, the values always show as 3460kB.  Dropping
caches always restores it to 3456kB.  This may be the correct value with
the per cpu differential values pushed.  You could try dropping the page
cache and see what the values are on your system.  You could also add
the following line to your test program before the call to mlockall()
and after the existing call to system():

	system("cat /proc/meminfo | egrep 'Unev|Mlo'");

I will add this to my list of things to be investigated, but I won't get
to it for a while.  If I see more evidence that the counters are,
indeed, broken, I'll try to bump the priority.

Thanks,
Lee





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 26C176B0098
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:26:55 -0400 (EDT)
Date: Tue, 13 Oct 2009 10:26:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: oomkiller over-ambitious after "vmscan: make mapped executable
	pages the first class citizen" (bisected)
Message-ID: <20091013022650.GB7345@localhost>
References: <200910122244.19666.borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200910122244.19666.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Thanks for the report!

On Tue, Oct 13, 2009 at 04:44:19AM +0800, Christian Borntraeger wrote:
> I have seen some OOM-killer action on my s390x system when using large amounts 
> of anonymous memory:
> 
> [cborntra@t63lp34 ~]$ cat memeat.c
> #include <sys/mman.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <stdlib.h>
> 
> int main()
> {
>         char *start;
>         char *a;
>         start = mmap(NULL, 4300000000UL,
>                     PROT_READ | PROT_WRITE,
>                     MAP_SHARED | MAP_ANONYMOUS, -1 , 0);
>
>         if (start == MAP_FAILED) {
>                 printf("cannot map guest memory\n");
>                 exit (1);
>         }
>         for (a = start; a < start + 4300000000UL; a += 4096)
>             *a='a';
>         exit(0);
> }
> [cborntra@t63lp34 ~]$ ./memeat
> Connection to t63lp34 closed.
> 
> 
> I attached the dmesg with the oom messages.
> 
> As you can see we are failing several order 0 allocations with gfpmask=0x201da. 
> 
> The application uses slightly more memory than is available. The thing is, that 
> there is plenty of swap space to fullfill the (non-atomic) request:
> 
> [cborntra@t63lp34 ~]$ free
>              total       used       free     shared    buffers     cached
> Mem:       4166560     127148    4039412          0       2256      19752
> -/+ buffers/cache:     105140    4061420
> Swap:      9615904       8328    9607576
> 
> Since old kernels never showed OOM, I was able to bisect the first kernel that 
> shows this behaviour:
> commit 8cab4754d24a0f2e05920170c845bd84472814c6                                                                                                                             
> Author: Wu Fengguang <fengguang.wu@intel.com>                                                                                                                               
>     vmscan: make mapped executable pages the first class citizen
> 
> In fact, applying this patch makes the problem go away:
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -1345,22 +1345,8 @@ static void shrink_active_list(unsigned 
>  
>  		/* page_referenced clears PageReferenced */
>  		if (page_mapping_inuse(page) &&
> -		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> +		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
>  			nr_rotated++;
> -			/*
> -			 * Identify referenced, file-backed active pages and
> -			 * give them one more trip around the active list. So
> -			 * that executable code get better chances to stay in
> -			 * memory under moderate memory pressure.  Anon pages
> -			 * are not likely to be evicted by use-once streaming
> -			 * IO, plus JVM can create lots of anon VM_EXEC pages,
> -			 * so we ignore them here.
> -			 */
> -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> -				list_add(&page->lru, &l_active);
> -				continue;
> -			}
> -		}
>  
>  		ClearPageActive(page);	/* we are de-activating */
>  		list_add(&page->lru, &l_inactive);
> 
> 
> 
> the interesting part is, that s390x in the default configuration has no no-
> execute feature, resulting in the following map 
> c0000000-1c04cd000 rwxs 00000000 00:04 18517        /dev/zero (deleted)
>
> As you can see, this area looks file mapped (/dev/zero) and executable. On the 
> other hand, the !PageAnon clause should cover this case. I am lost.

Yes, I can see this map in my desktop:

        $ cat /proc/5016/smaps #smaps for Xorg

        417fe000-41800000 rwxp 00000000 00:11 1370                               /dev/zero
        Size:                  8 kB
        Rss:                   8 kB
        Pss:                   8 kB
        Shared_Clean:          0 kB
        Shared_Dirty:          0 kB
        Private_Clean:         0 kB
        Private_Dirty:         8 kB
        Referenced:            8 kB
        Swap:                  0 kB
        KernelPageSize:        4 kB
        MMUPageSize:           4 kB

        # page-types -p 5016 -a 0x417fe,0x41800 -r
                     flags      page-count       MB  symbolic-flags                     long-symbolic-flags
        0x0000000000005868               2        0  ___U_lA____Ma_b_________________   uptodate,lru,active,mmap,anonymous,swapbacked
                     total               2        0

You can see page-types reports the expected "anonymous,swapbacked".

However, for your program (modified to reduce the page number and add
sleep), I see:

        root /home/wfg# cat /proc/`pidof memeat`/smaps

        7fa012722000-7fa012b3c000 rw-s 00000000 00:08 321900                     /dev/zero (deleted)
        Size:               4200 kB
        Rss:                4200 kB
        Pss:                4200 kB
        Shared_Clean:          0 kB
        Shared_Dirty:          0 kB
        Private_Clean:         0 kB
        Private_Dirty:      4200 kB
        Referenced:         4200 kB
        Swap:                  0 kB
        KernelPageSize:        4 kB
        MMUPageSize:           4 kB

        # page-types -p `pidof memeat` -a 0x7fa012722,0x7fa012b3c
                     flags      page-count       MB  symbolic-flags                     long-symbolic-flags
        0x0000000000004878            1050        4  ___UDlA____M__b_________________   uptodate,dirty,lru,active,mmap,swapbacked
                     total            1050        4

So the "(deleted)" /dev/zero has only "swapbacked" set.

In particular, the page belongs to the file initialized by shmem_zero_setup()
and populated by shmem_fault() => shmem_getpage().

> Does anybody on the CC (taken from the original patch) has an idea what the 
> problem is and how to fix this properly?

Can you try this patch? Thanks!

---
vmscan: limit VM_EXEC protection to file pages

It is possible to have !Anon but SwapBacked pages, and some apps could
create huge number of such pages with MAP_SHARED|MAP_ANONYMOUS. These
pages go into the ANON lru list, and hence shall not be protected: we
only care mapped executable files. Failing to do so may trigger OOM.

Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/mm/vmscan.c	2009-10-13 09:49:05.000000000 +0800
+++ linux/mm/vmscan.c	2009-10-13 09:49:37.000000000 +0800
@@ -1356,7 +1356,7 @@ static void shrink_active_list(unsigned 
 			 * IO, plus JVM can create lots of anon VM_EXEC pages,
 			 * so we ignore them here.
 			 */
-			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
+			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

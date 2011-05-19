Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 48CC96B0027
	for <linux-mm@kvack.org>; Thu, 19 May 2011 00:56:35 -0400 (EDT)
Date: Wed, 18 May 2011 23:56:31 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
Message-ID: <20110519045630.GA22533@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20110518153445.GA18127@sgi.com> <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, rja@americas.sgi.com

On Wed, May 18, 2011 at 09:51:03PM -0300, Rafael Aquini wrote:
> Howdy,
> 
> On Wed, May 18, 2011 at 12:34 PM, Russ Anderson <rja@sgi.com> wrote:
> 
> > If the total size of hugepages allocated on a system is
> > over half of the total memory size, commitlimit becomes
> > a negative number.
> >
> > What happens in fs/proc/meminfo.c is this calculation:
> >
> >        allowed = ((totalram_pages - hugetlb_total_pages())
> >                * sysctl_overcommit_ratio / 100) + total_swap_pages;
> >
> > The problem is that hugetlb_total_pages() is larger than
> > totalram_pages resulting in a negative number.  Since
> > allowed is an unsigned long the negative shows up as a
> > big number.
> >
> > A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.
> >
> > A symptom of this problem is that /proc/meminfo prints a
> > very large CommitLimit number.
> >
> > CommitLimit:    737869762947802600 kB
> >
> > To reproduce the problem reserve over half of memory as hugepages.
> > For example "default_hugepagesz=1G hugepagesz=1G hugepages=64
> > Then look at /proc/meminfo "CommitLimit:" to see if it is too big.
> >
> > The fix is to not subtract hugetlb_total_pages().  When hugepages
> > are allocated totalram_pages is decremented so there is no need to
> > subtract out hugetlb_total_pages() a second time.
> >
> > Reported-by: Russ Anderson <rja@sgi.com>
> > Signed-off-by: Russ Anderson <rja@sgi.com>
> >
> > ---
> >
> > Example of "CommitLimit:" being too big.
> >
> > uv1-sys:~ # cat /proc/meminfo
> > MemTotal:       32395508 kB
> > MemFree:        32029276 kB
> > Buffers:            8656 kB
> > Cached:            89548 kB
> > SwapCached:            0 kB
> > Active:            55336 kB
> > Inactive:          73916 kB
> > Active(anon):      31220 kB
> > Inactive(anon):       36 kB
> > Active(file):      24116 kB
> > Inactive(file):    73880 kB
> > Unevictable:           0 kB
> > Mlocked:               0 kB
> > SwapTotal:             0 kB
> > SwapFree:              0 kB
> > Dirty:              1692 kB
> > Writeback:             0 kB
> > AnonPages:         31132 kB
> > Mapped:            15668 kB
> > Shmem:               152 kB
> > Slab:              70256 kB
> > SReclaimable:      17148 kB
> > SUnreclaim:        53108 kB
> > KernelStack:        6536 kB
> > PageTables:         3704 kB
> > NFS_Unstable:          0 kB
> > Bounce:                0 kB
> > WritebackTmp:          0 kB
> > CommitLimit:    737869762947802600 kB
> > Committed_AS:     394044 kB
> > VmallocTotal:   34359738367 kB
> > VmallocUsed:      713960 kB
> > VmallocChunk:   34325764204 kB
> > HardwareCorrupted:     0 kB
> > HugePages_Total:      32
> > HugePages_Free:       32
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > Hugepagesize:    1048576 kB
> > DirectMap4k:       16384 kB
> > DirectMap2M:     2064384 kB
> > DirectMap1G:    65011712 kB
> >
> >  fs/proc/meminfo.c |    2 +-
> >  mm/mmap.c         |    3 +--
> >  2 files changed, 2 insertions(+), 3 deletions(-)
> >
> > Index: linux/fs/proc/meminfo.c
> > ===================================================================
> > --- linux.orig/fs/proc/meminfo.c        2011-05-17 16:03:50.935658801 -0500
> > +++ linux/fs/proc/meminfo.c     2011-05-18 08:53:00.568784147 -0500
> > @@ -36,7 +36,7 @@ static int meminfo_proc_show(struct seq_
> >        si_meminfo(&i);
> >        si_swapinfo(&i);
> >        committed = percpu_counter_read_positive(&vm_committed_as);
> > -       allowed = ((totalram_pages - hugetlb_total_pages())
> > +       allowed = (totalram_pages
> >                * sysctl_overcommit_ratio / 100) + total_swap_pages;
> >
> >        cached = global_page_state(NR_FILE_PAGES) -
> > Index: linux/mm/mmap.c
> > ===================================================================
> > --- linux.orig/mm/mmap.c        2011-05-17 16:03:51.727658828 -0500
> > +++ linux/mm/mmap.c     2011-05-18 08:54:34.912222405 -0500
> > @@ -167,8 +167,7 @@ int __vm_enough_memory(struct mm_struct
> >                goto error;
> >        }
> >
> > -       allowed = (totalram_pages - hugetlb_total_pages())
> > -               * sysctl_overcommit_ratio / 100;
> > +       allowed = totalram_pages * sysctl_overcommit_ratio / 100;
> >        /*
> >         * Leave the last 3% for root
> >         */
> > --
> > Russ Anderson, OS RAS/Partitioning Project Lead
> > SGI - Silicon Graphics Inc          rja@sgi.com
> 
> 
> I'm afraid this will introduce a bug on how accurate kernel will account
> memory for overcommitment limits.
> 
> totalram_pages is not decremented as hugepages are allocated. Since

Are you running on x86?  It decrements totalram_pages on a x86_64 
test system.  Perhaps different architectures allocate hugepages
differently.

The way it was verified was putting a printk in to print totalram_pages
and hugetlb_total_pages.  First the system was booted without any huge
pages.  The next boot one huge page was allocated.  The next boot more
hugepages allocated.  Each time totalram_pages was reduced by the nuber
of huge pages allocated, with totalram_pages + hugetlb_total_pages
equaling the original number of pages. 

That behavior is also consistent with allocating over half of memory
resulting in CommitLimit going negative (as is shown in the above
output).  

Here is some data.  Each represents a boot using 1G hugepages.
   0 hugepages : totalram_pages 16519867 hugetlb_total_pages       0
   1 hugepages : totalram_pages 16257723 hugetlb_total_pages  262144
   2 hugepages : totalram_pages 15995578 hugetlb_total_pages  524288
  31 hugepages : totalram_pages  8393403 hugetlb_total_pages 8126464
  32 hugepages : totalram_pages  8131258 hugetlb_total_pages 8388608


> hugepages are reserved, hugetlb_total_pages() has to be accounted and
> subtracted from totalram_pages in order to render an accurate number of
> remaining pages available to the general memory workload commitment.
> 
> I've tried to reproduce your findings on my boxes,  without
> success, unfortunately.

Put a printk in meminfo_proc_show() to print totalram_pages and
hugetlb_total_pages().  Add "default_hugepagesz=1G hugepagesz=1G hugepages=64"
to the boot line (varying the number of hugepages).

> I'll keep chasing to hit this behaviour, though.
> 
> Cheers!
> --aquini

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

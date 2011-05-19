Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 038DE6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:37:17 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3557069bwz.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 06:37:13 -0700 (PDT)
MIME-Version: 1.0
Reply-To: aquini@linux.com
In-Reply-To: <20110519045630.GA22533@sgi.com>
References: <20110518153445.GA18127@sgi.com>
	<BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
	<20110519045630.GA22533@sgi.com>
Date: Thu, 19 May 2011 10:37:13 -0300
Message-ID: <BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
From: Rafael Aquini <aquini@linux.com>
Content-Type: multipart/alternative; boundary=00032555645e4ee04804a3a11a74
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, rja@americas.sgi.com

--00032555645e4ee04804a3a11a74
Content-Type: text/plain; charset=ISO-8859-1

Howdy Russ,

On Thu, May 19, 2011 at 1:56 AM, Russ Anderson <rja@sgi.com> wrote:

> On Wed, May 18, 2011 at 09:51:03PM -0300, Rafael Aquini wrote:
> > Howdy,
> >
> > On Wed, May 18, 2011 at 12:34 PM, Russ Anderson <rja@sgi.com> wrote:
> >
> > > If the total size of hugepages allocated on a system is
> > > over half of the total memory size, commitlimit becomes
> > > a negative number.
> > >
> > > What happens in fs/proc/meminfo.c is this calculation:
> > >
> > >        allowed = ((totalram_pages - hugetlb_total_pages())
> > >                * sysctl_overcommit_ratio / 100) + total_swap_pages;
> > >
> > > The problem is that hugetlb_total_pages() is larger than
> > > totalram_pages resulting in a negative number.  Since
> > > allowed is an unsigned long the negative shows up as a
> > > big number.
> > >
> > > A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.
> > >
> > > A symptom of this problem is that /proc/meminfo prints a
> > > very large CommitLimit number.
> > >
> > > CommitLimit:    737869762947802600 kB
> > >
> > > To reproduce the problem reserve over half of memory as hugepages.
> > > For example "default_hugepagesz=1G hugepagesz=1G hugepages=64
> > > Then look at /proc/meminfo "CommitLimit:" to see if it is too big.
> > >
> > > The fix is to not subtract hugetlb_total_pages().  When hugepages
> > > are allocated totalram_pages is decremented so there is no need to
> > > subtract out hugetlb_total_pages() a second time.
> > >
> > > Reported-by: Russ Anderson <rja@sgi.com>
> > > Signed-off-by: Russ Anderson <rja@sgi.com>
> > >
> > > ---
> > >
> > > Example of "CommitLimit:" being too big.
> > >
> > > uv1-sys:~ # cat /proc/meminfo
> > > MemTotal:       32395508 kB
> > > MemFree:        32029276 kB
> > > Buffers:            8656 kB
> > > Cached:            89548 kB
> > > SwapCached:            0 kB
> > > Active:            55336 kB
> > > Inactive:          73916 kB
> > > Active(anon):      31220 kB
> > > Inactive(anon):       36 kB
> > > Active(file):      24116 kB
> > > Inactive(file):    73880 kB
> > > Unevictable:           0 kB
> > > Mlocked:               0 kB
> > > SwapTotal:             0 kB
> > > SwapFree:              0 kB
> > > Dirty:              1692 kB
> > > Writeback:             0 kB
> > > AnonPages:         31132 kB
> > > Mapped:            15668 kB
> > > Shmem:               152 kB
> > > Slab:              70256 kB
> > > SReclaimable:      17148 kB
> > > SUnreclaim:        53108 kB
> > > KernelStack:        6536 kB
> > > PageTables:         3704 kB
> > > NFS_Unstable:          0 kB
> > > Bounce:                0 kB
> > > WritebackTmp:          0 kB
> > > CommitLimit:    737869762947802600 kB
> > > Committed_AS:     394044 kB
> > > VmallocTotal:   34359738367 kB
> > > VmallocUsed:      713960 kB
> > > VmallocChunk:   34325764204 kB
> > > HardwareCorrupted:     0 kB
> > > HugePages_Total:      32
> > > HugePages_Free:       32
> > > HugePages_Rsvd:        0
> > > HugePages_Surp:        0
> > > Hugepagesize:    1048576 kB
> > > DirectMap4k:       16384 kB
> > > DirectMap2M:     2064384 kB
> > > DirectMap1G:    65011712 kB
> > >
> > >  fs/proc/meminfo.c |    2 +-
> > >  mm/mmap.c         |    3 +--
> > >  2 files changed, 2 insertions(+), 3 deletions(-)
> > >
> > > Index: linux/fs/proc/meminfo.c
> > > ===================================================================
> > > --- linux.orig/fs/proc/meminfo.c        2011-05-17 16:03:50.935658801
> -0500
> > > +++ linux/fs/proc/meminfo.c     2011-05-18 08:53:00.568784147 -0500
> > > @@ -36,7 +36,7 @@ static int meminfo_proc_show(struct seq_
> > >        si_meminfo(&i);
> > >        si_swapinfo(&i);
> > >        committed = percpu_counter_read_positive(&vm_committed_as);
> > > -       allowed = ((totalram_pages - hugetlb_total_pages())
> > > +       allowed = (totalram_pages
> > >                * sysctl_overcommit_ratio / 100) + total_swap_pages;
> > >
> > >        cached = global_page_state(NR_FILE_PAGES) -
> > > Index: linux/mm/mmap.c
> > > ===================================================================
> > > --- linux.orig/mm/mmap.c        2011-05-17 16:03:51.727658828 -0500
> > > +++ linux/mm/mmap.c     2011-05-18 08:54:34.912222405 -0500
> > > @@ -167,8 +167,7 @@ int __vm_enough_memory(struct mm_struct
> > >                goto error;
> > >        }
> > >
> > > -       allowed = (totalram_pages - hugetlb_total_pages())
> > > -               * sysctl_overcommit_ratio / 100;
> > > +       allowed = totalram_pages * sysctl_overcommit_ratio / 100;
> > >        /*
> > >         * Leave the last 3% for root
> > >         */
> > > --
> > > Russ Anderson, OS RAS/Partitioning Project Lead
> > > SGI - Silicon Graphics Inc          rja@sgi.com
> >
> >
> > I'm afraid this will introduce a bug on how accurate kernel will account
> > memory for overcommitment limits.
> >
> > totalram_pages is not decremented as hugepages are allocated. Since
>
> Are you running on x86?  It decrements totalram_pages on a x86_64
> test system.  Perhaps different architectures allocate hugepages
> differently.
>
> The way it was verified was putting a printk in to print totalram_pages
> and hugetlb_total_pages.  First the system was booted without any huge
> pages.  The next boot one huge page was allocated.  The next boot more
> hugepages allocated.  Each time totalram_pages was reduced by the nuber
> of huge pages allocated, with totalram_pages + hugetlb_total_pages
> equaling the original number of pages.
>
> That behavior is also consistent with allocating over half of memory
> resulting in CommitLimit going negative (as is shown in the above
> output).
>
> Here is some data.  Each represents a boot using 1G hugepages.
>   0 hugepages : totalram_pages 16519867 hugetlb_total_pages       0
>   1 hugepages : totalram_pages 16257723 hugetlb_total_pages  262144
>   2 hugepages : totalram_pages 15995578 hugetlb_total_pages  524288
>  31 hugepages : totalram_pages  8393403 hugetlb_total_pages 8126464
>  32 hugepages : totalram_pages  8131258 hugetlb_total_pages 8388608
>
>
> > hugepages are reserved, hugetlb_total_pages() has to be accounted and
> > subtracted from totalram_pages in order to render an accurate number of
> > remaining pages available to the general memory workload commitment.
> >
> > I've tried to reproduce your findings on my boxes,  without
> > success, unfortunately.
>
> Put a printk in meminfo_proc_show() to print totalram_pages and
> hugetlb_total_pages().  Add "default_hugepagesz=1G hugepagesz=1G
> hugepages=64"
> to the boot line (varying the number of hugepages).
>
> > I'll keep chasing to hit this behaviour, though.
> >
> > Cheers!
> > --aquini
>
> --
> Russ Anderson, OS RAS/Partitioning Project Lead
> SGI - Silicon Graphics Inc          rja@sgi.com
>


I got what I was doing different, and you are partially right.
Checking mm/hugetlb.c:
1811 static int __init hugetlb_nrpages_setup(char *s)
1812 {
....
1834         /*
1835          * Global state is always initialized later in hugetlb_init.
1836          * But we need to allocate >= MAX_ORDER hstates here early to
still
1837          * use the bootmem allocator.
1838          */
1839         if (max_hstate && parsed_hstate->order >= MAX_ORDER)
1840                 hugetlb_hstate_alloc_pages(parsed_hstate);
1841
1842         last_mhp = mhp;
1843
1844         return 1;
1845 }
1846 __setup("hugepages=", hugetlb_nrpages_setup);

I realize this issue you've reported only happens when you're using
oversized hugepages. As their order are always >= MAX_ORDER, they got pages
early allocated from bootmem allocator. So, these pages are not accounted
for totalram_pages.

Although your patch covers a fix for the proposed case, it only works for
scenarios where oversized hugepages are allocated on boot. I think it will,
unfortunately, cause a bug for the remaining scenarios.

Cheers!
--aquini

--00032555645e4ee04804a3a11a74
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Howdy Russ,<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 1:56 =
AM, Russ Anderson <span dir=3D"ltr">&lt;<a href=3D"mailto:rja@sgi.com">rja@=
sgi.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, May 18, 2011 at 09:51:03PM -0300,=
 Rafael Aquini wrote:<br>
&gt; Howdy,<br>
&gt;<br>
&gt; On Wed, May 18, 2011 at 12:34 PM, Russ Anderson &lt;<a href=3D"mailto:=
rja@sgi.com">rja@sgi.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; If the total size of hugepages allocated on a system is<br>
&gt; &gt; over half of the total memory size, commitlimit becomes<br>
&gt; &gt; a negative number.<br>
&gt; &gt;<br>
&gt; &gt; What happens in fs/proc/meminfo.c is this calculation:<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0allowed =3D ((totalram_pages - hugetlb_total_pages=
())<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sysctl_overcommit_ratio / 100) +=
 total_swap_pages;<br>
&gt; &gt;<br>
&gt; &gt; The problem is that hugetlb_total_pages() is larger than<br>
&gt; &gt; totalram_pages resulting in a negative number. =A0Since<br>
&gt; &gt; allowed is an unsigned long the negative shows up as a<br>
&gt; &gt; big number.<br>
&gt; &gt;<br>
&gt; &gt; A similar calculation occurs in __vm_enough_memory() in mm/mmap.c=
.<br>
&gt; &gt;<br>
&gt; &gt; A symptom of this problem is that /proc/meminfo prints a<br>
&gt; &gt; very large CommitLimit number.<br>
&gt; &gt;<br>
&gt; &gt; CommitLimit: =A0 =A0737869762947802600 kB<br>
&gt; &gt;<br>
&gt; &gt; To reproduce the problem reserve over half of memory as hugepages=
.<br>
&gt; &gt; For example &quot;default_hugepagesz=3D1G hugepagesz=3D1G hugepag=
es=3D64<br>
&gt; &gt; Then look at /proc/meminfo &quot;CommitLimit:&quot; to see if it =
is too big.<br>
&gt; &gt;<br>
&gt; &gt; The fix is to not subtract hugetlb_total_pages(). =A0When hugepag=
es<br>
&gt; &gt; are allocated totalram_pages is decremented so there is no need t=
o<br>
&gt; &gt; subtract out hugetlb_total_pages() a second time.<br>
&gt; &gt;<br>
&gt; &gt; Reported-by: Russ Anderson &lt;<a href=3D"mailto:rja@sgi.com">rja=
@sgi.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Russ Anderson &lt;<a href=3D"mailto:rja@sgi.com">r=
ja@sgi.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; ---<br>
&gt; &gt;<br>
&gt; &gt; Example of &quot;CommitLimit:&quot; being too big.<br>
&gt; &gt;<br>
&gt; &gt; uv1-sys:~ # cat /proc/meminfo<br>
&gt; &gt; MemTotal: =A0 =A0 =A0 32395508 kB<br>
&gt; &gt; MemFree: =A0 =A0 =A0 =A032029276 kB<br>
&gt; &gt; Buffers: =A0 =A0 =A0 =A0 =A0 =A08656 kB<br>
&gt; &gt; Cached: =A0 =A0 =A0 =A0 =A0 =A089548 kB<br>
&gt; &gt; SwapCached: =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
&gt; &gt; Active: =A0 =A0 =A0 =A0 =A0 =A055336 kB<br>
&gt; &gt; Inactive: =A0 =A0 =A0 =A0 =A073916 kB<br>
&gt; &gt; Active(anon): =A0 =A0 =A031220 kB<br>
&gt; &gt; Inactive(anon): =A0 =A0 =A0 36 kB<br>
&gt; &gt; Active(file): =A0 =A0 =A024116 kB<br>
&gt; &gt; Inactive(file): =A0 =A073880 kB<br>
&gt; &gt; Unevictable: =A0 =A0 =A0 =A0 =A0 0 kB<br>
&gt; &gt; Mlocked: =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
&gt; &gt; SwapTotal: =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
&gt; &gt; SwapFree: =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
&gt; &gt; Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A01692 kB<br>
&gt; &gt; Writeback: =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
&gt; &gt; AnonPages: =A0 =A0 =A0 =A0 31132 kB<br>
&gt; &gt; Mapped: =A0 =A0 =A0 =A0 =A0 =A015668 kB<br>
&gt; &gt; Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A0 152 kB<br>
&gt; &gt; Slab: =A0 =A0 =A0 =A0 =A0 =A0 =A070256 kB<br>
&gt; &gt; SReclaimable: =A0 =A0 =A017148 kB<br>
&gt; &gt; SUnreclaim: =A0 =A0 =A0 =A053108 kB<br>
&gt; &gt; KernelStack: =A0 =A0 =A0 =A06536 kB<br>
&gt; &gt; PageTables: =A0 =A0 =A0 =A0 3704 kB<br>
&gt; &gt; NFS_Unstable: =A0 =A0 =A0 =A0 =A00 kB<br>
&gt; &gt; Bounce: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
&gt; &gt; WritebackTmp: =A0 =A0 =A0 =A0 =A00 kB<br>
&gt; &gt; CommitLimit: =A0 =A0737869762947802600 kB<br>
&gt; &gt; Committed_AS: =A0 =A0 394044 kB<br>
&gt; &gt; VmallocTotal: =A0 34359738367 kB<br>
&gt; &gt; VmallocUsed: =A0 =A0 =A0713960 kB<br>
&gt; &gt; VmallocChunk: =A0 34325764204 kB<br>
&gt; &gt; HardwareCorrupted: =A0 =A0 0 kB<br>
&gt; &gt; HugePages_Total: =A0 =A0 =A032<br>
&gt; &gt; HugePages_Free: =A0 =A0 =A0 32<br>
&gt; &gt; HugePages_Rsvd: =A0 =A0 =A0 =A00<br>
&gt; &gt; HugePages_Surp: =A0 =A0 =A0 =A00<br>
&gt; &gt; Hugepagesize: =A0 =A01048576 kB<br>
&gt; &gt; DirectMap4k: =A0 =A0 =A0 16384 kB<br>
&gt; &gt; DirectMap2M: =A0 =A0 2064384 kB<br>
&gt; &gt; DirectMap1G: =A0 =A065011712 kB<br>
&gt; &gt;<br>
&gt; &gt; =A0fs/proc/meminfo.c | =A0 =A02 +-<br>
&gt; &gt; =A0mm/mmap.c =A0 =A0 =A0 =A0 | =A0 =A03 +--<br>
&gt; &gt; =A02 files changed, 2 insertions(+), 3 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; Index: linux/fs/proc/meminfo.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- linux.orig/fs/proc/meminfo.c =A0 =A0 =A0 =A02011-05-17 16:03:=
50.935658801 -0500<br>
&gt; &gt; +++ linux/fs/proc/meminfo.c =A0 =A0 2011-05-18 08:53:00.568784147=
 -0500<br>
&gt; &gt; @@ -36,7 +36,7 @@ static int meminfo_proc_show(struct seq_<br>
&gt; &gt; =A0 =A0 =A0 =A0si_meminfo(&amp;i);<br>
&gt; &gt; =A0 =A0 =A0 =A0si_swapinfo(&amp;i);<br>
&gt; &gt; =A0 =A0 =A0 =A0committed =3D percpu_counter_read_positive(&amp;vm=
_committed_as);<br>
&gt; &gt; - =A0 =A0 =A0 allowed =3D ((totalram_pages - hugetlb_total_pages(=
))<br>
&gt; &gt; + =A0 =A0 =A0 allowed =3D (totalram_pages<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sysctl_overcommit_ratio / 100) +=
 total_swap_pages;<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0cached =3D global_page_state(NR_FILE_PAGES) -<br>
&gt; &gt; Index: linux/mm/mmap.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- linux.orig/mm/mmap.c =A0 =A0 =A0 =A02011-05-17 16:03:51.72765=
8828 -0500<br>
&gt; &gt; +++ linux/mm/mmap.c =A0 =A0 2011-05-18 08:54:34.912222405 -0500<b=
r>
&gt; &gt; @@ -167,8 +167,7 @@ int __vm_enough_memory(struct mm_struct<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;<br>
&gt; &gt; =A0 =A0 =A0 =A0}<br>
&gt; &gt;<br>
&gt; &gt; - =A0 =A0 =A0 allowed =3D (totalram_pages - hugetlb_total_pages()=
)<br>
&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 * sysctl_overcommit_ratio / 100;<br=
>
&gt; &gt; + =A0 =A0 =A0 allowed =3D totalram_pages * sysctl_overcommit_rati=
o / 100;<br>
&gt; &gt; =A0 =A0 =A0 =A0/*<br>
&gt; &gt; =A0 =A0 =A0 =A0 * Leave the last 3% for root<br>
&gt; &gt; =A0 =A0 =A0 =A0 */<br>
&gt; &gt; --<br>
&gt; &gt; Russ Anderson, OS RAS/Partitioning Project Lead<br>
&gt; &gt; SGI - Silicon Graphics Inc =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:r=
ja@sgi.com">rja@sgi.com</a><br>
&gt;<br>
&gt;<br>
&gt; I&#39;m afraid this will introduce a bug on how accurate kernel will a=
ccount<br>
&gt; memory for overcommitment limits.<br>
&gt;<br>
&gt; totalram_pages is not decremented as hugepages are allocated. Since<br=
>
<br>
</div></div>Are you running on x86? =A0It decrements totalram_pages on a x8=
6_64<br>
test system. =A0Perhaps different architectures allocate hugepages<br>
differently.<br>
<br>
The way it was verified was putting a printk in to print totalram_pages<br>
and hugetlb_total_pages. =A0First the system was booted without any huge<br=
>
pages. =A0The next boot one huge page was allocated. =A0The next boot more<=
br>
hugepages allocated. =A0Each time totalram_pages was reduced by the nuber<b=
r>
of huge pages allocated, with totalram_pages + hugetlb_total_pages<br>
equaling the original number of pages.<br>
<br>
That behavior is also consistent with allocating over half of memory<br>
resulting in CommitLimit going negative (as is shown in the above<br>
output).<br>
<br>
Here is some data. =A0Each represents a boot using 1G hugepages.<br>
 =A0 0 hugepages : totalram_pages 16519867 hugetlb_total_pages =A0 =A0 =A0 =
0<br>
 =A0 1 hugepages : totalram_pages 16257723 hugetlb_total_pages =A0262144<br=
>
 =A0 2 hugepages : totalram_pages 15995578 hugetlb_total_pages =A0524288<br=
>
 =A031 hugepages : totalram_pages =A08393403 hugetlb_total_pages 8126464<br=
>
 =A032 hugepages : totalram_pages =A08131258 hugetlb_total_pages 8388608<br=
>
<div class=3D"im"><br>
<br>
&gt; hugepages are reserved, hugetlb_total_pages() has to be accounted and<=
br>
&gt; subtracted from totalram_pages in order to render an accurate number o=
f<br>
&gt; remaining pages available to the general memory workload commitment.<b=
r>
&gt;<br>
&gt; I&#39;ve tried to reproduce your findings on my boxes, =A0without<br>
&gt; success, unfortunately.<br>
<br>
</div>Put a printk in meminfo_proc_show() to print totalram_pages and<br>
hugetlb_total_pages(). =A0Add &quot;default_hugepagesz=3D1G hugepagesz=3D1G=
 hugepages=3D64&quot;<br>
to the boot line (varying the number of hugepages).<br>
<div class=3D"im"><br>
&gt; I&#39;ll keep chasing to hit this behaviour, though.<br>
&gt;<br>
&gt; Cheers!<br>
&gt; --aquini<br>
<br>
</div>--<br>
<div><div></div><div class=3D"h5">Russ Anderson, OS RAS/Partitioning Projec=
t Lead<br>
SGI - Silicon Graphics Inc =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:rja@sgi.com=
">rja@sgi.com</a><br>
</div></div></blockquote></div><br><div><br></div><div>I got what I was doi=
ng different, and you are partially right.=A0</div><div>Checking=A0mm/huget=
lb.c:</div><div>1811 static int __init hugetlb_nrpages_setup(char *s)</div>
<div>1812 {</div><div>....</div><div>1834 =A0 =A0 =A0 =A0 /*</div><div>1835=
 =A0 =A0 =A0 =A0 =A0* Global state is always initialized later in hugetlb_i=
nit.</div><div>1836 =A0 =A0 =A0 =A0 =A0* But we need to allocate &gt;=3D MA=
X_ORDER hstates here early to still</div>
<div>1837 =A0 =A0 =A0 =A0 =A0* use the bootmem allocator.</div><div>1838 =
=A0 =A0 =A0 =A0 =A0*/</div><div>1839 =A0 =A0 =A0 =A0 if (max_hstate &amp;&a=
mp; parsed_hstate-&gt;order &gt;=3D MAX_ORDER)</div><div>1840 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 hugetlb_hstate_alloc_pages(parsed_hstate);</div>
<div>1841=A0</div><div>1842 =A0 =A0 =A0 =A0 last_mhp =3D mhp;</div><div>184=
3=A0</div><div>1844 =A0 =A0 =A0 =A0 return 1;</div><div>1845 }</div><div>18=
46 __setup(&quot;hugepages=3D&quot;, hugetlb_nrpages_setup);</div><div><br>=
</div><div>I realize this issue you&#39;ve reported only happens when you&#=
39;re using oversized hugepages. As their order are always &gt;=3D MAX_ORDE=
R, they got pages early allocated from bootmem allocator. So, these pages a=
re not accounted for totalram_pages.</div>
<div><br></div><div>Although your patch covers a fix for the proposed case,=
 it only works for scenarios where oversized hugepages are allocated on boo=
t. I think it will, unfortunately, cause a bug for the remaining scenarios.=
</div>
<div><br></div><div>Cheers!</div><div>--aquini</div>

--00032555645e4ee04804a3a11a74--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

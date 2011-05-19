Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 84E546B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:51:07 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2894292bwz.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 17:51:03 -0700 (PDT)
MIME-Version: 1.0
Reply-To: aquini@linux.com
In-Reply-To: <20110518153445.GA18127@sgi.com>
References: <20110518153445.GA18127@sgi.com>
Date: Wed, 18 May 2011 21:51:03 -0300
Message-ID: <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
From: Rafael Aquini <aquini@linux.com>
Content-Type: multipart/alternative; boundary=00032555aefe4da90e04a39666ee
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>

--00032555aefe4da90e04a39666ee
Content-Type: text/plain; charset=ISO-8859-1

Howdy,

On Wed, May 18, 2011 at 12:34 PM, Russ Anderson <rja@sgi.com> wrote:

> If the total size of hugepages allocated on a system is
> over half of the total memory size, commitlimit becomes
> a negative number.
>
> What happens in fs/proc/meminfo.c is this calculation:
>
>        allowed = ((totalram_pages - hugetlb_total_pages())
>                * sysctl_overcommit_ratio / 100) + total_swap_pages;
>
> The problem is that hugetlb_total_pages() is larger than
> totalram_pages resulting in a negative number.  Since
> allowed is an unsigned long the negative shows up as a
> big number.
>
> A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.
>
> A symptom of this problem is that /proc/meminfo prints a
> very large CommitLimit number.
>
> CommitLimit:    737869762947802600 kB
>
> To reproduce the problem reserve over half of memory as hugepages.
> For example "default_hugepagesz=1G hugepagesz=1G hugepages=64
> Then look at /proc/meminfo "CommitLimit:" to see if it is too big.
>
> The fix is to not subtract hugetlb_total_pages().  When hugepages
> are allocated totalram_pages is decremented so there is no need to
> subtract out hugetlb_total_pages() a second time.
>
> Reported-by: Russ Anderson <rja@sgi.com>
> Signed-off-by: Russ Anderson <rja@sgi.com>
>
> ---
>
> Example of "CommitLimit:" being too big.
>
> uv1-sys:~ # cat /proc/meminfo
> MemTotal:       32395508 kB
> MemFree:        32029276 kB
> Buffers:            8656 kB
> Cached:            89548 kB
> SwapCached:            0 kB
> Active:            55336 kB
> Inactive:          73916 kB
> Active(anon):      31220 kB
> Inactive(anon):       36 kB
> Active(file):      24116 kB
> Inactive(file):    73880 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:             0 kB
> SwapFree:              0 kB
> Dirty:              1692 kB
> Writeback:             0 kB
> AnonPages:         31132 kB
> Mapped:            15668 kB
> Shmem:               152 kB
> Slab:              70256 kB
> SReclaimable:      17148 kB
> SUnreclaim:        53108 kB
> KernelStack:        6536 kB
> PageTables:         3704 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    737869762947802600 kB
> Committed_AS:     394044 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      713960 kB
> VmallocChunk:   34325764204 kB
> HardwareCorrupted:     0 kB
> HugePages_Total:      32
> HugePages_Free:       32
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:    1048576 kB
> DirectMap4k:       16384 kB
> DirectMap2M:     2064384 kB
> DirectMap1G:    65011712 kB
>
>  fs/proc/meminfo.c |    2 +-
>  mm/mmap.c         |    3 +--
>  2 files changed, 2 insertions(+), 3 deletions(-)
>
> Index: linux/fs/proc/meminfo.c
> ===================================================================
> --- linux.orig/fs/proc/meminfo.c        2011-05-17 16:03:50.935658801 -0500
> +++ linux/fs/proc/meminfo.c     2011-05-18 08:53:00.568784147 -0500
> @@ -36,7 +36,7 @@ static int meminfo_proc_show(struct seq_
>        si_meminfo(&i);
>        si_swapinfo(&i);
>        committed = percpu_counter_read_positive(&vm_committed_as);
> -       allowed = ((totalram_pages - hugetlb_total_pages())
> +       allowed = (totalram_pages
>                * sysctl_overcommit_ratio / 100) + total_swap_pages;
>
>        cached = global_page_state(NR_FILE_PAGES) -
> Index: linux/mm/mmap.c
> ===================================================================
> --- linux.orig/mm/mmap.c        2011-05-17 16:03:51.727658828 -0500
> +++ linux/mm/mmap.c     2011-05-18 08:54:34.912222405 -0500
> @@ -167,8 +167,7 @@ int __vm_enough_memory(struct mm_struct
>                goto error;
>        }
>
> -       allowed = (totalram_pages - hugetlb_total_pages())
> -               * sysctl_overcommit_ratio / 100;
> +       allowed = totalram_pages * sysctl_overcommit_ratio / 100;
>        /*
>         * Leave the last 3% for root
>         */
> --
> Russ Anderson, OS RAS/Partitioning Project Lead
> SGI - Silicon Graphics Inc          rja@sgi.com


I'm afraid this will introduce a bug on how accurate kernel will account
memory for overcommitment limits.

totalram_pages is not decremented as hugepages are allocated. Since
hugepages are reserved, hugetlb_total_pages() has to be accounted and
subtracted from totalram_pages in order to render an accurate number of
remaining pages available to the general memory workload commitment.

I've tried to reproduce your findings on my boxes,  without
success, unfortunately.

I'll keep chasing to hit this behaviour, though.

Cheers!
--aquini

--00032555aefe4da90e04a39666ee
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Howdy,<br><br><div class=3D"gmail_quote">On Wed, May 18, 2011 at 12:34 PM, =
Russ Anderson <span dir=3D"ltr">&lt;<a href=3D"mailto:rja@sgi.com">rja@sgi.=
com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
If the total size of hugepages allocated on a system is<br>
over half of the total memory size, commitlimit becomes<br>
a negative number.<br>
<br>
What happens in fs/proc/meminfo.c is this calculation:<br>
<br>
 =A0 =A0 =A0 =A0allowed =3D ((totalram_pages - hugetlb_total_pages())<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sysctl_overcommit_ratio / 100) + total_sw=
ap_pages;<br>
<br>
The problem is that hugetlb_total_pages() is larger than<br>
totalram_pages resulting in a negative number. =A0Since<br>
allowed is an unsigned long the negative shows up as a<br>
big number.<br>
<br>
A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.<br>
<br>
A symptom of this problem is that /proc/meminfo prints a<br>
very large CommitLimit number.<br>
<br>
CommitLimit: =A0 =A0737869762947802600 kB<br>
<br>
To reproduce the problem reserve over half of memory as hugepages.<br>
For example &quot;default_hugepagesz=3D1G hugepagesz=3D1G hugepages=3D64<br=
>
Then look at /proc/meminfo &quot;CommitLimit:&quot; to see if it is too big=
.<br>
<br>
The fix is to not subtract hugetlb_total_pages(). =A0When hugepages<br>
are allocated totalram_pages is decremented so there is no need to<br>
subtract out hugetlb_total_pages() a second time.<br>
<br>
Reported-by: Russ Anderson &lt;<a href=3D"mailto:rja@sgi.com">rja@sgi.com</=
a>&gt;<br>
Signed-off-by: Russ Anderson &lt;<a href=3D"mailto:rja@sgi.com">rja@sgi.com=
</a>&gt;<br>
<br>
---<br>
<br>
Example of &quot;CommitLimit:&quot; being too big.<br>
<br>
uv1-sys:~ # cat /proc/meminfo<br>
MemTotal: =A0 =A0 =A0 32395508 kB<br>
MemFree: =A0 =A0 =A0 =A032029276 kB<br>
Buffers: =A0 =A0 =A0 =A0 =A0 =A08656 kB<br>
Cached: =A0 =A0 =A0 =A0 =A0 =A089548 kB<br>
SwapCached: =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
Active: =A0 =A0 =A0 =A0 =A0 =A055336 kB<br>
Inactive: =A0 =A0 =A0 =A0 =A073916 kB<br>
Active(anon): =A0 =A0 =A031220 kB<br>
Inactive(anon): =A0 =A0 =A0 36 kB<br>
Active(file): =A0 =A0 =A024116 kB<br>
Inactive(file): =A0 =A073880 kB<br>
Unevictable: =A0 =A0 =A0 =A0 =A0 0 kB<br>
Mlocked: =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
SwapTotal: =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
SwapFree: =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A01692 kB<br>
Writeback: =A0 =A0 =A0 =A0 =A0 =A0 0 kB<br>
AnonPages: =A0 =A0 =A0 =A0 31132 kB<br>
Mapped: =A0 =A0 =A0 =A0 =A0 =A015668 kB<br>
Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A0 152 kB<br>
Slab: =A0 =A0 =A0 =A0 =A0 =A0 =A070256 kB<br>
SReclaimable: =A0 =A0 =A017148 kB<br>
SUnreclaim: =A0 =A0 =A0 =A053108 kB<br>
KernelStack: =A0 =A0 =A0 =A06536 kB<br>
PageTables: =A0 =A0 =A0 =A0 3704 kB<br>
NFS_Unstable: =A0 =A0 =A0 =A0 =A00 kB<br>
Bounce: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB<br>
WritebackTmp: =A0 =A0 =A0 =A0 =A00 kB<br>
CommitLimit: =A0 =A0737869762947802600 kB<br>
Committed_AS: =A0 =A0 394044 kB<br>
VmallocTotal: =A0 34359738367 kB<br>
VmallocUsed: =A0 =A0 =A0713960 kB<br>
VmallocChunk: =A0 34325764204 kB<br>
HardwareCorrupted: =A0 =A0 0 kB<br>
HugePages_Total: =A0 =A0 =A032<br>
HugePages_Free: =A0 =A0 =A0 32<br>
HugePages_Rsvd: =A0 =A0 =A0 =A00<br>
HugePages_Surp: =A0 =A0 =A0 =A00<br>
Hugepagesize: =A0 =A01048576 kB<br>
DirectMap4k: =A0 =A0 =A0 16384 kB<br>
DirectMap2M: =A0 =A0 2064384 kB<br>
DirectMap1G: =A0 =A065011712 kB<br>
<br>
=A0fs/proc/meminfo.c | =A0 =A02 +-<br>
=A0mm/mmap.c =A0 =A0 =A0 =A0 | =A0 =A03 +--<br>
=A02 files changed, 2 insertions(+), 3 deletions(-)<br>
<br>
Index: linux/fs/proc/meminfo.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- linux.orig/fs/proc/meminfo.c =A0 =A0 =A0 =A02011-05-17 16:03:50.9356588=
01 -0500<br>
+++ linux/fs/proc/meminfo.c =A0 =A0 2011-05-18 08:53:00.568784147 -0500<br>
@@ -36,7 +36,7 @@ static int meminfo_proc_show(struct seq_<br>
 =A0 =A0 =A0 =A0si_meminfo(&amp;i);<br>
 =A0 =A0 =A0 =A0si_swapinfo(&amp;i);<br>
 =A0 =A0 =A0 =A0committed =3D percpu_counter_read_positive(&amp;vm_committe=
d_as);<br>
- =A0 =A0 =A0 allowed =3D ((totalram_pages - hugetlb_total_pages())<br>
+ =A0 =A0 =A0 allowed =3D (totalram_pages<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sysctl_overcommit_ratio / 100) + total_sw=
ap_pages;<br>
<br>
 =A0 =A0 =A0 =A0cached =3D global_page_state(NR_FILE_PAGES) -<br>
Index: linux/mm/mmap.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- linux.orig/mm/mmap.c =A0 =A0 =A0 =A02011-05-17 16:03:51.727658828 -0500=
<br>
+++ linux/mm/mmap.c =A0 =A0 2011-05-18 08:54:34.912222405 -0500<br>
@@ -167,8 +167,7 @@ int __vm_enough_memory(struct mm_struct<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;<br>
 =A0 =A0 =A0 =A0}<br>
<br>
- =A0 =A0 =A0 allowed =3D (totalram_pages - hugetlb_total_pages())<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 * sysctl_overcommit_ratio / 100;<br>
+ =A0 =A0 =A0 allowed =3D totalram_pages * sysctl_overcommit_ratio / 100;<b=
r>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * Leave the last 3% for root<br>
 =A0 =A0 =A0 =A0 */<br>
--<br>
Russ Anderson, OS RAS/Partitioning Project Lead<br>
SGI - Silicon Graphics Inc =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:rja@sgi.com=
">rja@sgi.com</a></blockquote><div><br></div><div>I&#39;m afraid this will =
introduce a bug on how accurate kernel will account memory for overcommitme=
nt limits.</div>
<div><br></div><div>totalram_pages is not decremented as hugepages are allo=
cated. Since hugepages are reserved,=A0hugetlb_total_pages() has to be acco=
unted and subtracted from totalram_pages in order to render an accurate num=
ber of remaining pages available to the general memory workload commitment.=
</div>
<div><br></div><div>I&#39;ve tried to reproduce your findings on my boxes,=
=A0=A0without success,=A0unfortunately.</div><meta http-equiv=3D"content-ty=
pe" content=3D"text/html; charset=3Dutf-8"><meta http-equiv=3D"content-type=
" content=3D"text/html; charset=3Dutf-8"><meta http-equiv=3D"content-type" =
content=3D"text/html; charset=3Dutf-8"><div>
<br></div><div>I&#39;ll keep chasing to hit this behaviour, though.</div><d=
iv><br></div><div>Cheers!</div><div>--aquini</div></div>

--00032555aefe4da90e04a39666ee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

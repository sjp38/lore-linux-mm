Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 943988D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:17:24 -0400 (EDT)
Received: by iwg8 with SMTP id 8so5046315iwg.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:17:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1301282760-30730-1-git-send-email-yinghan@google.com>
References: <1301282760-30730-1-git-send-email-yinghan@google.com>
Date: Tue, 29 Mar 2011 08:17:20 +0900
Message-ID: <BANLkTinh+X24CWq1F4S=cjOM5vJ1D_w7mQ@mail.gmail.com>
Subject: Re: [PATCH V2] Add the pagefault count into memcg stats
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 12:26 PM, Ying Han <yinghan@google.com> wrote:
> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
>
> "pgfault"
> "pgmajfault"
>
> They are different from "pgpgin"/"pgpgout" stat which count number of
> pages charged/discharged to the cgroup and have no meaning of reading/
> writing page to disk.
>
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> Counting pagefaults per process is useful, but we also need the aggregate=
d
> value since processes are monitored and controlled in cgroup basis in mem=
cg.
>
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
>
> $ cat /proc/vmstat | grep fault
> pgfault 1070751
> pgmajfault 553
>
> $ cat /dev/cgroup/memory.stat | grep fault
> pgfault 1071138
> pgmajfault 553
> total_pgfault 1071142
> total_pgmajfault 553
>
> $ cat /dev/cgroup/A/memory.stat | grep fault
> pgfault 199
> pgmajfault 0
> total_pgfault 199
> total_pgmajfault 0
>
> Performance test: run page fault test(pft) wit 16 thread on faulting in 1=
5G
> anon pages in 16G container. There is no regression noticed on the "flt/c=
pu/s"
>
> Sample output from pft:
> TAG pft:anon-sys-default:
> =C2=A0Gb =C2=A0Thr CLine =C2=A0 User =C2=A0 =C2=A0 System =C2=A0 =C2=A0 W=
all =C2=A0 =C2=A0flt/cpu/s fault/wsec
> =C2=A015 =C2=A0 16 =C2=A0 1 =C2=A0 =C2=A0 0.69s =C2=A0 230.99s =C2=A0 =C2=
=A014.62s =C2=A0 16972.539 268876.196
>
> +------------------------------------------------------------------------=
-+
> =C2=A0 =C2=A0N =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Min =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 Max =C2=A0 =C2=A0 =C2=A0 =C2=A0Median =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 Avg =C2=A0 =C2=A0 =C2=A0 =C2=A0Stddev
> x =C2=A010 =C2=A0 =C2=A0 16682.962 =C2=A0 =C2=A0 17344.027 =C2=A0 =C2=A0 =
16913.524 =C2=A0 =C2=A0 16928.812 =C2=A0 =C2=A0 =C2=A0166.5362
> + =C2=A010 =C2=A0 =C2=A0 =C2=A016718.92 =C2=A0 =C2=A0 17023.453 =C2=A0 =
=C2=A0 16907.164 =C2=A0 =C2=A0 16902.399 =C2=A0 =C2=A0 88.468851
> No difference proven at 95.0% confidence
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0Documentation/cgroups/memory.txt | =C2=A0 =C2=A04 +++
> =C2=A0fs/ncpfs/mmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 =C2=A02 +
> =C2=A0include/linux/memcontrol.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 18 +++++++=
+++++++
> =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 47 ++++++++++++++++++++++++++++++++++++++
> =C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +
> =C2=A0mm/shmem.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +
> =C2=A07 files changed, 76 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index b6ed61c..2db6103 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,8 @@ mapped_file - # of bytes of mapped file (includes tmp=
fs/shmem)
> =C2=A0pgpgin =C2=A0 =C2=A0 =C2=A0 =C2=A0 - # of pages paged in (equivalen=
t to # of charging events).
> =C2=A0pgpgout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- # =
of pages paged out (equivalent to # of uncharging events).
> =C2=A0swap =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 - # of bytes of swap usage
> +pgfault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- # of pa=
ge faults.
> +pgmajfault =C2=A0 =C2=A0 - # of major page faults.
> =C2=A0inactive_anon =C2=A0- # of bytes of anonymous memory and swap cache=
 memory on
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0LRU list.
> =C2=A0active_anon =C2=A0 =C2=A0- # of bytes of anonymous and swap cache m=
emory on active
> @@ -406,6 +408,8 @@ total_mapped_file =C2=A0 - sum of all children's "cac=
he"
> =C2=A0total_pgpgin =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 - sum of all childr=
en's "pgpgin"
> =C2=A0total_pgpgout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- sum of all childr=
en's "pgpgout"
> =C2=A0total_swap =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 - sum of all c=
hildren's "swap"
> +total_pgfault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- sum of all children's =
"pgfault"
> +total_pgmajfault =C2=A0 =C2=A0 =C2=A0 - sum of all children's "pgmajfaul=
t"
> =C2=A0total_inactive_anon =C2=A0 =C2=A0- sum of all children's "inactive_=
anon"
> =C2=A0total_active_anon =C2=A0 =C2=A0 =C2=A0- sum of all children's "acti=
ve_anon"
> =C2=A0total_inactive_file =C2=A0 =C2=A0- sum of all children's "inactive_=
file"
> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
> index a7c07b4..e5d71b2 100644
> --- a/fs/ncpfs/mmap.c
> +++ b/fs/ncpfs/mmap.c
> @@ -16,6 +16,7 @@
> =C2=A0#include <linux/mman.h>
> =C2=A0#include <linux/string.h>
> =C2=A0#include <linux/fcntl.h>
> +#include <linux/memcontrol.h>
>
> =C2=A0#include <asm/uaccess.h>
> =C2=A0#include <asm/system.h>
> @@ -92,6 +93,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *a=
rea,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * -- wli
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0count_vm_event(PGMAJFAULT);
> + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_count_vm_event(area->vm_mm, PGMAJFAULT)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return VM_FAULT_MAJOR;
> =C2=A0}
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5a5ce70..45e5268 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -24,6 +24,7 @@ struct mem_cgroup;
> =C2=A0struct page_cgroup;
> =C2=A0struct page;
> =C2=A0struct mm_struct;
> +enum vm_event_item;
>
> =C2=A0/* Stats that can be updated by kernel. */
> =C2=A0enum mem_cgroup_page_stat_item {
> @@ -147,6 +148,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zo=
ne *zone, int order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0gfp_t gfp_mask);
> =C2=A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>
> +void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val);
> +void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val);

Do we have to expose above two functions?
Isn't it enough to only mem_cgroup_count_vm_event?

> +void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item =
idx);


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

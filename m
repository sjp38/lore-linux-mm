Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 42C2C8D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 20:14:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9EE9E3EE0C1
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:14:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7709845DE51
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:14:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E0F245DE4F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:14:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3787B1DB8041
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:14:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ED53D1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:14:40 +0900 (JST)
Date: Mon, 28 Mar 2011 09:07:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add the pagefault count into memcg stats.
Message-Id: <20110328090752.9dd5d968.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301184884-17155-1-git-send-email-yinghan@google.com>
References: <1301184884-17155-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Sat, 26 Mar 2011 17:14:44 -0700
Ying Han <yinghan@google.com> wrote:

> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
> 
> "pgfault"
> "pgmajfault"
> 
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> 
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
> 
> $ cat /proc/vmstat | grep fault
> pgfault 1070751
> pgmajfault 553
> 
> $ cat /dev/cgroup/memory.stat | grep fault
> pgfault 1069962
> pgmajfault 553
> total_pgfault 1069966
> total_pgmajfault 553
> 
> $ cat /dev/cgroup/A/memory.stat | grep fault
> pgfault 199
> pgmajfault 0
> total_pgfault 199
> total_pgmajfault 0
> 
> Performance test: run page fault test(pft) wit 16 thread on faulting in 15G
> anon pages in 16G container. There is no regression noticed on the "flt/cpu/s"
> 
> Sample output from pft:
> TAG pft:anon-sys-default:
>   Gb  Thr CLine   User     System     Wall    flt/cpu/s fault/wsec
>   15   16   1     0.67s   232.11s    14.68s   16892.130 267796.518
> 
> $ ./ministat mmotm.txt mmotm_fault.txt
> x mmotm.txt (w/o patch)
> + mmotm_fault.txt (w/ patch)
> +-------------------------------------------------------------------------+
>     N           Min           Max        Median           Avg        Stddev
> x  10     16682.962     17344.027     16913.524     16928.812      166.5362
> +  10      16696.49      17480.09     16949.143     16951.448     223.56288
> No difference proven at 95.0% confidence
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Hmm, maybe useful ? (It's good to describe what is difference with PGPGIN)
Especially, you should show why this is useful than per process pgfault count.
What I thought of this, I thought that I need per-process information, finally...
and didn't add this.

Anyway, I have a request for the style of the function. (see below)


> ---
>  Documentation/cgroups/memory.txt |    4 +++
>  fs/ncpfs/mmap.c                  |    2 +
>  include/linux/memcontrol.h       |   22 +++++++++++++++
>  mm/filemap.c                     |    1 +
>  mm/memcontrol.c                  |   54 ++++++++++++++++++++++++++++++++++++++
>  mm/memory.c                      |    2 +
>  mm/shmem.c                       |    1 +
>  7 files changed, 86 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b6ed61c..2db6103 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,8 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>  swap		- # of bytes of swap usage
> +pgfault		- # of page faults.
> +pgmajfault	- # of major page faults.
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active
> @@ -406,6 +408,8 @@ total_mapped_file	- sum of all children's "cache"
>  total_pgpgin		- sum of all children's "pgpgin"
>  total_pgpgout		- sum of all children's "pgpgout"
>  total_swap		- sum of all children's "swap"
> +total_pgfault		- sum of all children's "pgfault"
> +total_pgmajfault	- sum of all children's "pgmajfault"
>  total_inactive_anon	- sum of all children's "inactive_anon"
>  total_active_anon	- sum of all children's "active_anon"
>  total_inactive_file	- sum of all children's "inactive_file"
> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
> index a7c07b4..adb3f45 100644
> --- a/fs/ncpfs/mmap.c
> +++ b/fs/ncpfs/mmap.c
> @@ -16,6 +16,7 @@
>  #include <linux/mman.h>
>  #include <linux/string.h>
>  #include <linux/fcntl.h>
> +#include <linux/memcontrol.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -92,6 +93,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *area,
>  	 * -- wli
>  	 */
>  	count_vm_event(PGMAJFAULT);
> +	mem_cgroup_pgmajfault_from_mm(area->vm_mm);

Could you do this as  mem_cgroup_count_vm_event(area->vm_mm, PGMAJFAULT) ?

<snip>

> +void mem_cgroup_pgfault_from_mm(struct mm_struct *mm)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (!mm)
> +		return;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!mem))
> +		goto out;
> +	mem_cgroup_pgfault(mem, 1);
> +
> +out:
> +	rcu_read_unlock();
> +}
> +
> +void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (!mm)
> +		return;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!mem))
> +		goto out;
> +	mem_cgroup_pgmajfault(mem, 1);
> +out:
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(mem_cgroup_pgmajfault_from_mm);
> +

Then, you can do above 2 in a function.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

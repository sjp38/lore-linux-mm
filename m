Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE228D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:30:43 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p2THUdFp027430
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:30:39 -0700
Received: from yxp4 (yxp4.prod.google.com [10.190.4.196])
	by hpaq3.eem.corp.google.com with ESMTP id p2THTdCv000478
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:30:38 -0700
Received: by yxp4 with SMTP id 4so209212yxp.24
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:30:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329153023.GC2879@balbir.in.ibm.com>
References: <1301184884-17155-1-git-send-email-yinghan@google.com>
	<20110329153023.GC2879@balbir.in.ibm.com>
Date: Tue, 29 Mar 2011 10:30:37 -0700
Message-ID: <BANLkTimboXMj_MC3F0yU7paWi5r29BH0Zg@mail.gmail.com>
Subject: Re: [PATCH] Add the pagefault count into memcg stats.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 8:30 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Ying Han <yinghan@google.com> [2011-03-26 17:14:44]:
>
>> Two new stats in per-memcg memory.stat which tracks the number of
>> page faults and number of major page faults.
>>
>> "pgfault"
>> "pgmajfault"
>>
>> It is valuable to track the two stats for both measuring application's
>> performance as well as the efficiency of the kernel page reclaim path.
>>
>> Functional test: check the total number of pgfault/pgmajfault of all
>> memcgs and compare with global vmstat value:
>>
>> $ cat /proc/vmstat | grep fault
>> pgfault 1070751
>> pgmajfault 553
>>
>> $ cat /dev/cgroup/memory.stat | grep fault
>> pgfault 1069962
>> pgmajfault 553
>> total_pgfault 1069966
>> total_pgmajfault 553
>>
>> $ cat /dev/cgroup/A/memory.stat | grep fault
>> pgfault 199
>> pgmajfault 0
>> total_pgfault 199
>> total_pgmajfault 0
>>
>> Performance test: run page fault test(pft) wit 16 thread on faulting in =
15G
>> anon pages in 16G container. There is no regression noticed on the "flt/=
cpu/s"
>>
>> Sample output from pft:
>> TAG pft:anon-sys-default:
>> =A0 Gb =A0Thr CLine =A0 User =A0 =A0 System =A0 =A0 Wall =A0 =A0flt/cpu/=
s fault/wsec
>> =A0 15 =A0 16 =A0 1 =A0 =A0 0.67s =A0 232.11s =A0 =A014.68s =A0 16892.13=
0 267796.518
>>
>> $ ./ministat mmotm.txt mmotm_fault.txt
>> x mmotm.txt (w/o patch)
>> + mmotm_fault.txt (w/ patch)
>> +-----------------------------------------------------------------------=
--+
>> =A0 =A0 N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =
=A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev
>> x =A010 =A0 =A0 16682.962 =A0 =A0 17344.027 =A0 =A0 16913.524 =A0 =A0 16=
928.812 =A0 =A0 =A0166.5362
>> + =A010 =A0 =A0 =A016696.49 =A0 =A0 =A017480.09 =A0 =A0 16949.143 =A0 =
=A0 16951.448 =A0 =A0 223.56288
>> No difference proven at 95.0% confidence
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 =A04 +++
>> =A0fs/ncpfs/mmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 22 +++++++++++++++
>> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 54 +++++++++=
+++++++++++++++++++++++++++++
>> =A0mm/memory.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0mm/shmem.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
>> =A07 files changed, 86 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index b6ed61c..2db6103 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -385,6 +385,8 @@ mapped_file =A0 =A0 =A0 - # of bytes of mapped file =
(includes tmpfs/shmem)
>> =A0pgpgin =A0 =A0 =A0 =A0 =A0 =A0 =A0 - # of pages paged in (equivalent =
to # of charging events).
>> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equivalent=
 to # of uncharging events).
>> =A0swap =A0 =A0 =A0 =A0 - # of bytes of swap usage
>> +pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
>> +pgmajfault =A0 - # of major page faults.
>> =A0inactive_anon =A0 =A0 =A0 =A0- # of bytes of anonymous memory and swa=
p cache memory on
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 LRU list.
>> =A0active_anon =A0- # of bytes of anonymous and swap cache memory on act=
ive
>> @@ -406,6 +408,8 @@ total_mapped_file - sum of all children's "cache"
>> =A0total_pgpgin =A0 =A0 =A0 =A0 - sum of all children's "pgpgin"
>> =A0total_pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's =
"pgpgout"
>> =A0total_swap =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
>> +total_pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's "p=
gfault"
>> +total_pgmajfault =A0 =A0 - sum of all children's "pgmajfault"
>> =A0total_inactive_anon =A0- sum of all children's "inactive_anon"
>> =A0total_active_anon =A0 =A0- sum of all children's "active_anon"
>> =A0total_inactive_file =A0- sum of all children's "inactive_file"
>> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
>> index a7c07b4..adb3f45 100644
>> --- a/fs/ncpfs/mmap.c
>> +++ b/fs/ncpfs/mmap.c
>> @@ -16,6 +16,7 @@
>> =A0#include <linux/mman.h>
>> =A0#include <linux/string.h>
>> =A0#include <linux/fcntl.h>
>> +#include <linux/memcontrol.h>
>>
>> =A0#include <asm/uaccess.h>
>> =A0#include <asm/system.h>
>> @@ -92,6 +93,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *=
area,
>> =A0 =A0 =A0 =A0* -- wli
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 count_vm_event(PGMAJFAULT);
>> + =A0 =A0 mem_cgroup_pgmajfault_from_mm(area->vm_mm);
>> =A0 =A0 =A0 return VM_FAULT_MAJOR;
>> =A0}
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 5a5ce70..f771fc1 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -147,6 +147,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct =
zone *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pgfault_from_mm(struct mm_struct *mm);
>> +void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm);
>> +
>> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> =A0void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail=
);
>> =A0#endif
>> @@ -354,6 +359,23 @@ static inline void mem_cgroup_split_huge_fixup(stru=
ct page *head,
>> =A0{
>> =A0}
>>
>> +static inline void mem_cgroup_pgfault(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 in=
t val)
>> +{
>> +}
>> +
>> +static inline void mem_cgroup_pgmajfault(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0int val)
>> +{
>> +}
>> +
>> +static inline void mem_cgroup_pgfault_from_mm(struct mm_struct *mm)
>> +{
>> +}
>> +
>> +static inline void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm)
>> +{
>> +}
>> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>>
>> =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index a6cfecf..5dc5401 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -1683,6 +1683,7 @@ int filemap_fault(struct vm_area_struct *vma, stru=
ct vm_fault *vmf)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* No page in the page cache at all */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_sync_mmap_readahead(vma, ra, file, offset=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(PGMAJFAULT);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pgmajfault_from_mm(vma->vm_mm);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D VM_FAULT_MAJOR;
>> =A0retry_find:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D find_get_page(mapping, offset);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 4407dd0..63d66f1 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -94,6 +94,8 @@ enum mem_cgroup_events_index {
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGIN, =A0 =A0 =A0 /* # of pages paged in=
 */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGOUT, =A0 =A0 =A0/* # of pages paged ou=
t */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_COUNT, =A0 =A0 =A0 =A0/* # of pages paged =
in/out */
>> + =A0 =A0 MEM_CGROUP_EVENTS_PGFAULT, =A0 =A0 =A0/* # of page-faults */
>> + =A0 =A0 MEM_CGROUP_EVENTS_PGMAJFAULT, =A0 /* # of major page-faults */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_NSTATS,
>> =A0};
>> =A0/*
>> @@ -585,6 +587,16 @@ static void mem_cgroup_swap_statistics(struct mem_c=
group *mem,
>> =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val)=
;
>> =A0}
>>
>> +void mem_cgroup_pgfault(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val=
);
>> +}
>> +
>> +void mem_cgroup_pgmajfault(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], =
val);
>> +}
>> +
>> =A0static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 enum mem_cgroup_events_index idx)
>> =A0{
>> @@ -813,6 +825,40 @@ static inline bool mem_cgroup_is_root(struct mem_cg=
roup *mem)
>> =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
>> =A0}
>>
>> +void mem_cgroup_pgfault_from_mm(struct mm_struct *mm)
>> +{
>> + =A0 =A0 struct mem_cgroup *mem;
>> +
>> + =A0 =A0 if (!mm)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 mem =3D mem_cgroup_from_task(rcu_dereference(mm->owner));
>> + =A0 =A0 if (unlikely(!mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> A lot of this can be reused, just a minor nitpick. May be you can
> combine this function and the one below

This has been fixed in V3 :)

--Ying
>
>> + =A0 =A0 mem_cgroup_pgfault(mem, 1);
>> +
>> +out:
>> + =A0 =A0 rcu_read_unlock();
>> +}
>> +
>> +void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm)
>> +{
>> + =A0 =A0 struct mem_cgroup *mem;
>> +
>> + =A0 =A0 if (!mm)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 mem =3D mem_cgroup_from_task(rcu_dereference(mm->owner));
>> + =A0 =A0 if (unlikely(!mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 mem_cgroup_pgmajfault(mem, 1);
>> +out:
>> + =A0 =A0 rcu_read_unlock();
>> +}
>> +EXPORT_SYMBOL(mem_cgroup_pgmajfault_from_mm);
>> +
>> =A0/*
>> =A0 * Following LRU functions are allowed to be used without PCG_LOCK.
>> =A0 * Operations are called by routine of global LRU independently from =
memcg.
>> @@ -3772,6 +3818,8 @@ enum {
>> =A0 =A0 =A0 MCS_PGPGIN,
>> =A0 =A0 =A0 MCS_PGPGOUT,
>> =A0 =A0 =A0 MCS_SWAP,
>> + =A0 =A0 MCS_PGFAULT,
>> + =A0 =A0 MCS_PGMAJFAULT,
>> =A0 =A0 =A0 MCS_INACTIVE_ANON,
>> =A0 =A0 =A0 MCS_ACTIVE_ANON,
>> =A0 =A0 =A0 MCS_INACTIVE_FILE,
>> @@ -3794,6 +3842,8 @@ struct {
>> =A0 =A0 =A0 {"pgpgin", "total_pgpgin"},
>> =A0 =A0 =A0 {"pgpgout", "total_pgpgout"},
>> =A0 =A0 =A0 {"swap", "total_swap"},
>> + =A0 =A0 {"pgfault", "total_pgfault"},
>> + =A0 =A0 {"pgmajfault", "total_pgmajfault"},
>> =A0 =A0 =A0 {"inactive_anon", "total_inactive_anon"},
>> =A0 =A0 =A0 {"active_anon", "total_active_anon"},
>> =A0 =A0 =A0 {"inactive_file", "total_inactive_file"},
>> @@ -3822,6 +3872,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem,=
 struct mcs_total_stat *s)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP=
_STAT_SWAPOUT);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->stat[MCS_SWAP] +=3D val * PAGE_SIZE;
>> =A0 =A0 =A0 }
>> + =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT)=
;
>> + =A0 =A0 s->stat[MCS_PGFAULT] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAU=
LT);
>> + =A0 =A0 s->stat[MCS_PGMAJFAULT] +=3D val;
>>
>> =A0 =A0 =A0 /* per zone stat */
>> =A0 =A0 =A0 val =3D mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON=
);
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 8617d39..0f7ebc9 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2836,6 +2836,7 @@ static int do_swap_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Had to read the page from swap area: Majo=
r fault */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D VM_FAULT_MAJOR;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(PGMAJFAULT);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pgmajfault_from_mm(mm);
>> =A0 =A0 =A0 } else if (PageHWPoison(page)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* hwpoisoned dirty swapcache pages are ke=
pt for killing
>> @@ -3375,6 +3376,7 @@ int handle_mm_fault(struct mm_struct *mm, struct v=
m_area_struct *vma,
>> =A0 =A0 =A0 __set_current_state(TASK_RUNNING);
>>
>> =A0 =A0 =A0 count_vm_event(PGFAULT);
>> + =A0 =A0 mem_cgroup_pgfault_from_mm(mm);
>>
>> =A0 =A0 =A0 /* do counter updates before entering really critical sectio=
n. */
>> =A0 =A0 =A0 check_sync_rss_stat(current);
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index ad8346b..5a82674 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -1289,6 +1289,7 @@ repeat:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* here we actually do the i=
o */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (type && !(*type & VM_FAU=
LT_MAJOR)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_e=
vent(PGMAJFAULT);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pgm=
ajfault_from_mm(current->mm);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *type |=3D V=
M_FAULT_MAJOR;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&info->lock);
>> --
>> 1.7.3.1
>>
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

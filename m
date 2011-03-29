Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B00438D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 01:10:53 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p2T5AplM016368
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:10:51 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by hpaq7.eem.corp.google.com with ESMTP id p2T59biu026972
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:10:49 -0700
Received: by qyk35 with SMTP id 35so1814931qyk.13
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:10:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinh+X24CWq1F4S=cjOM5vJ1D_w7mQ@mail.gmail.com>
References: <1301282760-30730-1-git-send-email-yinghan@google.com>
	<BANLkTinh+X24CWq1F4S=cjOM5vJ1D_w7mQ@mail.gmail.com>
Date: Mon, 28 Mar 2011 22:10:44 -0700
Message-ID: <BANLkTi=DSVBRBQ=R3tbOt=8gMwpuCL02-w@mail.gmail.com>
Subject: Re: [PATCH V2] Add the pagefault count into memcg stats
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 4:17 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Mon, Mar 28, 2011 at 12:26 PM, Ying Han <yinghan@google.com> wrote:
>> Two new stats in per-memcg memory.stat which tracks the number of
>> page faults and number of major page faults.
>>
>> "pgfault"
>> "pgmajfault"
>>
>> They are different from "pgpgin"/"pgpgout" stat which count number of
>> pages charged/discharged to the cgroup and have no meaning of reading/
>> writing page to disk.
>>
>> It is valuable to track the two stats for both measuring application's
>> performance as well as the efficiency of the kernel page reclaim path.
>> Counting pagefaults per process is useful, but we also need the aggregat=
ed
>> value since processes are monitored and controlled in cgroup basis in me=
mcg.
>>
>> Functional test: check the total number of pgfault/pgmajfault of all
>> memcgs and compare with global vmstat value:
>>
>> $ cat /proc/vmstat | grep fault
>> pgfault 1070751
>> pgmajfault 553
>>
>> $ cat /dev/cgroup/memory.stat | grep fault
>> pgfault 1071138
>> pgmajfault 553
>> total_pgfault 1071142
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
>> =A0Gb =A0Thr CLine =A0 User =A0 =A0 System =A0 =A0 Wall =A0 =A0flt/cpu/s=
 fault/wsec
>> =A015 =A0 16 =A0 1 =A0 =A0 0.69s =A0 230.99s =A0 =A014.62s =A0 16972.539=
 268876.196
>>
>> +-----------------------------------------------------------------------=
--+
>> =A0 =A0N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =A0=
Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev
>> x =A010 =A0 =A0 16682.962 =A0 =A0 17344.027 =A0 =A0 16913.524 =A0 =A0 16=
928.812 =A0 =A0 =A0166.5362
>> + =A010 =A0 =A0 =A016718.92 =A0 =A0 17023.453 =A0 =A0 16907.164 =A0 =A0 =
16902.399 =A0 =A0 88.468851
>> No difference proven at 95.0% confidence
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 =A04 +++
>> =A0fs/ncpfs/mmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 18 ++++++++++++++
>> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 47 +++++++++=
+++++++++++++++++++++++++++++
>> =A0mm/memory.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0mm/shmem.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +
>> =A07 files changed, 76 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index b6ed61c..2db6103 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -385,6 +385,8 @@ mapped_file - # of bytes of mapped file (includes tm=
pfs/shmem)
>> =A0pgpgin =A0 =A0 =A0 =A0 - # of pages paged in (equivalent to # of char=
ging events).
>> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equiva=
lent to # of uncharging events).
>> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
>> +pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
>> +pgmajfault =A0 =A0 - # of major page faults.
>> =A0inactive_anon =A0- # of bytes of anonymous memory and swap cache memo=
ry on
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU list.
>> =A0active_anon =A0 =A0- # of bytes of anonymous and swap cache memory on=
 active
>> @@ -406,6 +408,8 @@ total_mapped_file =A0 - sum of all children's "cache=
"
>> =A0total_pgpgin =A0 =A0 =A0 =A0 =A0 - sum of all children's "pgpgin"
>> =A0total_pgpgout =A0 =A0 =A0 =A0 =A0- sum of all children's "pgpgout"
>> =A0total_swap =A0 =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
>> +total_pgfault =A0 =A0 =A0 =A0 =A0- sum of all children's "pgfault"
>> +total_pgmajfault =A0 =A0 =A0 - sum of all children's "pgmajfault"
>> =A0total_inactive_anon =A0 =A0- sum of all children's "inactive_anon"
>> =A0total_active_anon =A0 =A0 =A0- sum of all children's "active_anon"
>> =A0total_inactive_file =A0 =A0- sum of all children's "inactive_file"
>> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
>> index a7c07b4..e5d71b2 100644
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
>> =A0 =A0 =A0 =A0 * -- wli
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0count_vm_event(PGMAJFAULT);
>> + =A0 =A0 =A0 mem_cgroup_count_vm_event(area->vm_mm, PGMAJFAULT);
>> =A0 =A0 =A0 =A0return VM_FAULT_MAJOR;
>> =A0}
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 5a5ce70..45e5268 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -24,6 +24,7 @@ struct mem_cgroup;
>> =A0struct page_cgroup;
>> =A0struct page;
>> =A0struct mm_struct;
>> +enum vm_event_item;
>>
>> =A0/* Stats that can be updated by kernel. */
>> =A0enum mem_cgroup_page_stat_item {
>> @@ -147,6 +148,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct z=
one *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val);
>
> Do we have to expose above two functions?
> Isn't it enough to only mem_cgroup_count_vm_event?

probably not. will send another patch.

thanks
--Ying
>
>> +void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item=
 idx);
>
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

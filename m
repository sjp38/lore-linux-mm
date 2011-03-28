Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2868C8D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 23:16:34 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p2S3GUHp014999
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 20:16:30 -0700
Received: from ywg4 (ywg4.prod.google.com [10.192.7.4])
	by hpaq1.eem.corp.google.com with ESMTP id p2S3GRBK018553
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 20:16:29 -0700
Received: by ywg4 with SMTP id 4so1266344ywg.24
        for <linux-mm@kvack.org>; Sun, 27 Mar 2011 20:16:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328090752.9dd5d968.kamezawa.hiroyu@jp.fujitsu.com>
References: <1301184884-17155-1-git-send-email-yinghan@google.com>
	<20110328090752.9dd5d968.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 27 Mar 2011 20:16:27 -0700
Message-ID: <AANLkTimBMEOTCKZGzzbKGmrt156XsnK0cBrugBqe0EZJ@mail.gmail.com>
Subject: Re: [PATCH] Add the pagefault count into memcg stats.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Sun, Mar 27, 2011 at 5:07 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sat, 26 Mar 2011 17:14:44 -0700
> Ying Han <yinghan@google.com> wrote:
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
>
> Hmm, maybe useful ? (It's good to describe what is difference with PGPGIN=
)
> Especially, you should show why this is useful than per process pgfault c=
ount.
> What I thought of this, I thought that I need per-process information, fi=
nally...
> and didn't add this.
>
> Anyway, I have a request for the style of the function. (see below)

Thanks for your comment, and I will post V2 shortly.

>
>
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
>
> Could you do this as =A0mem_cgroup_count_vm_event(area->vm_mm, PGMAJFAULT=
) ?

will be included in V2.


>
> <snip>
>
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
>
> Then, you can do above 2 in a function.

--Ying
>
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

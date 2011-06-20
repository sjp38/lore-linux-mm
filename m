Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFF7A6B007E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 02:09:07 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p5K68sZB014654
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:08:55 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by wpaz24.hot.corp.google.com with ESMTP id p5K68nLP009881
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:08:53 -0700
Received: by qyl38 with SMTP id 38so1304648qyl.9
        for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:08:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110620084537.24b28e53.kamezawa.hiroyu@jp.fujitsu.com>
References: <1308354828-30670-1-git-send-email-yinghan@google.com>
	<20110620084537.24b28e53.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 19 Jun 2011 23:08:52 -0700
Message-ID: <BANLkTi=fj8xaThqSVFtzX1WGuzykkqSwpQ@mail.gmail.com>
Subject: Re: [PATCH V3] memcg: add reclaim pgfault latency histograms
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sunday, June 19, 2011, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 17 Jun 2011 16:53:48 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> This adds histogram to capture pagefault latencies on per-memcg basis. I=
 used
>> this patch on the memcg background reclaim test, and figured there could=
 be more
>> usecases to monitor/debug application performance.
>>
>> The histogram is composed 8 bucket in us unit. The last one is "rest" wh=
ich is
>> everything beyond the last one. To be more flexible, the buckets can be =
reset
>> and also each bucket is configurable at runtime.
>>
>> memory.pgfault_histogram: exports the histogram on per-memcg basis and a=
lso can
>> be reset by echoing "-1". Meantime, all the buckets are writable by echo=
ing
>> the range into the API. see the example below.
>>
>> change v3..v2:
>> no change except rebasing the patch to 3.0-rc3 and retested.
>>
>> change v2..v1:
>> 1. record the page fault involving reclaim only and changing the unit to=
 us.
>> 2. rename the "inf" to "rest".
>> 3. removed the global tunable to turn on/off the recording. this is ok s=
ince
>> there is no overhead measured by collecting the data.
>> 4. changed reseting the history by echoing "-1".
>>
>> Functional Test:
>> $ cat /dev/cgroup/memory/D/memory.pgfault_histogram
>> page reclaim latency histogram (us):
>> < 150 =A0 =A0 =A0 =A0 =A0 =A022
>> < 200 =A0 =A0 =A0 =A0 =A0 =A017434
>> < 250 =A0 =A0 =A0 =A0 =A0 =A069135
>> < 300 =A0 =A0 =A0 =A0 =A0 =A017182
>> < 350 =A0 =A0 =A0 =A0 =A0 =A04180
>> < 400 =A0 =A0 =A0 =A0 =A0 =A03179
>> < 450 =A0 =A0 =A0 =A0 =A0 =A02644
>> < rest =A0 =A0 =A0 =A0 =A0 29840
>>
>> $ echo -1 >/dev/cgroup/memory/D/memory.pgfault_histogram
>> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> page reclaim latency histogram (us):
>> < 150 =A0 =A0 =A0 =A0 =A0 =A00
>> < 200 =A0 =A0 =A0 =A0 =A0 =A00
>> < 250 =A0 =A0 =A0 =A0 =A0 =A00
>> < 300 =A0 =A0 =A0 =A0 =A0 =A00
>> < 350 =A0 =A0 =A0 =A0 =A0 =A00
>> < 400 =A0 =A0 =A0 =A0 =A0 =A00
>> < 450 =A0 =A0 =A0 =A0 =A0 =A00
>> < rest =A0 =A0 =A0 =A0 =A0 0
>>
>> $ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/D/memory.pgfaul=
t_histogram
>> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
>> page reclaim latency histogram (us):
>> < 500 =A0 =A0 =A0 =A0 =A0 =A00
>> < 520 =A0 =A0 =A0 =A0 =A0 =A00
>> < 540 =A0 =A0 =A0 =A0 =A0 =A00
>> < 580 =A0 =A0 =A0 =A0 =A0 =A00
>> < 600 =A0 =A0 =A0 =A0 =A0 =A00
>> < 1000 =A0 =A0 =A0 =A0 =A0 0
>> < 5000 =A0 =A0 =A0 =A0 =A0 0
>> < rest =A0 =A0 =A0 =A0 =A0 0
>>
>> Performance Test:
>> I ran through the PageFaultTest (pft) benchmark to measure the overhead =
of
>> recording the histogram. There is no overhead observed on both "flt/cpu/=
s"
>> and "fault/wsec".
>>
>> $ mkdir /dev/cgroup/memory/A
>> $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
>> $ echo $$ >/dev/cgroup/memory/A/tasks
>> $ ./pft -m 15g -t 8 -T a
>>
>> Result:
>> $ ./ministat no_histogram histogram
>>
>> "fault/wsec"
>> x fault_wsec/no_histogram
>> + fault_wsec/histogram
>> +-----------------------------------------------------------------------=
--+
>> =A0 =A0 N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =
=A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev
>> x =A0 5 =A0 =A0 864432.44 =A0 =A0 880840.81 =A0 =A0 879707.95 =A0 =A0 87=
4606.51 =A0 =A0 7687.9841
>> + =A0 5 =A0 =A0 861986.57 =A0 =A0 877867.25 =A0 =A0 =A0870823.9 =A0 =A0 =
870901.38 =A0 =A0 6413.8821
>> No difference proven at 95.0% confidence
>>
>> "flt/cpu/s"
>> x flt_cpu_s/no_histogram
>> + flt_cpu_s/histogram
>> +-----------------------------------------------------------------------=
--+
>> =A0 =A0 I'll never ack this.

The patch is created as part of effort testing per-memcg bg reclaim
patch. I don't have strong opinion that we indeed need to merge it,
but found it is a useful testing and monitoring tool.

Meantime, can you help to clarify your concern? In case I missed
something here.

Thanks

--ying
>
> Thanks,
> -Kame
>
>> ---
>> =A0include/linux/memcontrol.h | =A0 =A03 +
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0130 +++++++++++++++++++++=
+++++++++++++++++++++++
>> =A02 files changed, 133 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 9724a38..96f93e0 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -85,6 +85,8 @@ int task_in_mem_cgroup(struct task_struct *task, const=
 struct mem_cgroup *mem);
>> =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *p=
age);
>> =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)=
;
>>
>> +extern void memcg_histogram_record(struct task_struct *tsk, u64 delta);
>> +
>> =A0static inline
>> =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgro=
up *cgroup)
>> =A0{
>> @@ -362,6 +364,7 @@ static inline void mem_cgroup_split_huge_fixup(struc=
t page *head,
>>
>> =A0static inline
>> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_it=
em idx)
>> +void memcg_histogram_record(struct task_struct *tsk, u64 delta)
>> =A0{
>> =A0}
>> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index bd9052a..7735ca1 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -48,6 +48,7 @@
>> =A0#include <linux/page_cgroup.h>
>> =A0#include <linux/cpu.h>
>> =A0#include <linux/oom.h>
>> +#include <linux/ctype.h>
>> =A0#include "internal.h"
>>
>> =A0#include <asm/uaccess.h>
>> @@ -202,6 +203,12 @@ struct mem_cgroup_eventfd_list {
>> =A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
>> =A0static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>>
>> +#define MEMCG_NUM_HISTO_BUCKETS =A0 =A0 =A0 =A0 =A0 =A0 =A08
>> +
>> +struct memcg_histo {
>> + =A0 =A0 u64 count[MEMCG_NUM_HISTO_BUCKETS];
>> +};
>> +
>> =A0/*
>> =A0 * The memory controller data structure. The memory controller contro=
ls both
>> =A0 * page cache and RSS per cgroup. We would eventually like to provide
>> @@ -279,6 +286,9 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 struct mem_cgroup_stat_cpu nocpu_base;
>> =A0 =A0 =A0 spinlock_t pcp_counter_lock;
>> +
>> + =A0 =A0 struct memcg_histo *memcg_histo;
>> + =A0 =A0 u64 memcg_histo_range[MEMCG_NUM_HISTO_BUCKETS];
>> =A0};
>>
>> =A0/* Stuffs for move charges at task migration. */
>> @@ -2117,6 +2127,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup =
*mem, gfp_t gfp_mask,
>> =A0 =A0 =A0 struct mem_cgroup *mem_over_limit;
>> =A0 =A0 =A0 struct res_counter *fail_res;
>> =A0 =A0 =A0 unsigned long flags =3D 0;
>> + =A0 =A0 unsigned long long start, delta;
>> =A0 =A0 =A0 int ret;
>>
>> =A0 =A0 =A0 ret =3D res_counter_charge(&mem->res, csize, &fail_res);
>> @@ -2146,8 +2157,14 @@ static int mem_cgroup_do_charge(struct mem_cgroup=
 *mem, gfp_t gfp_mask,
>> =A0 =A0 =A0 if (!(gfp_mask & __GFP_WAIT))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return CHARGE_WOULDBLOCK;
>>
>> + =A0 =A0 start =3D sched_clock();
>> =A0 =A0 =A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL=
,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 gfp_mask, flags, NULL);
>> + =A0 =A0 delta =3D sched_clock() - start;
>> + =A0 =A0 if (unlikely(delta < 0))
>> + =A0 =A0 =A0 =A0 =A0 =A0 delta =3D 0;
>> + =A0 =A0 memcg_histogram_record(current, delta);
>> +
>> =A0 =A0 =A0 if (mem_cgroup_margin(mem_over_limit) >=3D nr_pages)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return CHARGE_RETRY;
>> =A0 =A0 =A0 /*
>> @@ -4573,6 +4590,102 @@ static int mem_control_numa_stat_open(struct ino=
de *unused, struct file *file)
>> =A0}
>> =A0#endif /* CONFIG_NUMA */
>>
>> +static int mem_cgroup_histogram_seq_read(struct cgroup *cgrp,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct cftype *cft, > --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

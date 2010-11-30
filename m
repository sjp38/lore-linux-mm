Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D0EB96B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:44:19 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oAUKiGFc004426
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:44:16 -0800
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by hpaq2.eem.corp.google.com with ESMTP id oAUKiE9T014059
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:44:14 -0800
Received: by qwk3 with SMTP id 3so656919qwk.16
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:44:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130162133.970dc0cd.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-3-git-send-email-yinghan@google.com>
	<20101130162133.970dc0cd.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 12:44:13 -0800
Message-ID: <AANLkTik2Sy0MzGAsZyDHsoZYKUpdJ7kS7nFM1QX_ioZR@mail.gmail.com>
Subject: Re: [PATCH 2/4] Add per cgroup reclaim watermarks.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 11:21 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Nov 2010 22:49:43 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> The per cgroup kswapd is invoked at mem_cgroup_charge when the cgroup's =
memory
>> usage above a threshold--low_wmark. Then the kswapd thread starts to rec=
laim
>> pages in a priority loop similar to global algorithm. The kswapd is done=
 if the
>> memory usage below a threshold--high_wmark.
>>
>> The per cgroup background reclaim is based on the per cgroup LRU and als=
o adds
>> per cgroup watermarks. There are two watermarks including "low_wmark" an=
d
>> "high_wmark", and they are calculated based on the limit_in_bytes(hard_l=
imit)
>> for each cgroup. Each time the hard_limit is change, the corresponding w=
marks
>> are re-calculated. Since memory controller charges only user pages, ther=
e is
>> no need for a "min_wmark". The current calculation of wmarks is a functi=
on of
>> "memory.min_free_kbytes" which could be adjusted by writing different va=
lues
>> into the new api. This is added mainly for debugging purpose.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> A few points.
>
> 1. I can understand the motivation for including low/high watermark to
> =A0 res_coutner. But, sadly, compareing all charge will make the counter =
slow.
> =A0 IMHO, as memory controller threshold-check or soft limit, checking us=
age
> =A0 periodically based on event counter is enough. It will be low cost.

If we have other limits using the event counter, this sounds a
feasible try for the
wmarks. I can look into that.

>
> 2. min_free_kbytes must be automatically calculated.
> =A0 For example, max(3% of limit, 20MB) or some.

Now the wmark is automatically calculated based on the limit. Adding
the min_free_kbytes gives
us more flexibility to adjust the portion of the threshold. This could
just be a performance tuning
parameter later. I need it now at least at the beginning before
figuring out a reasonable calculation
formula.

>
> 3. When you allow min_free_kbytes to be set by users, please compare
> =A0 it with the limit.
> =A0 I think min_free_kbyte interface itself should be in another patch...
> =A0 interface code tends to make patch bigger.

Sounds feasible.

--Ying
>
>
>> ---
>> =A0include/linux/memcontrol.h =A0| =A0 =A01 +
>> =A0include/linux/res_counter.h | =A0 88 ++++++++++++++++++++++++++++++-
>> =A0kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 26 ++++++++--
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0123 ++++++++++++++++++++=
+++++++++++++++++++++--
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 ++++
>> =A05 files changed, 238 insertions(+), 10 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 159a076..90fe7fe 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -76,6 +76,7 @@ int task_in_mem_cgroup(struct task_struct *task, const=
 struct mem_cgroup *mem);
>>
>> =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *p=
age);
>> =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)=
;
>> +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_f=
lags);
>>
>> =A0static inline
>> =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgro=
up *cgroup)
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index fcb9884..eed12c5 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -39,6 +39,16 @@ struct res_counter {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 unsigned long long soft_limit;
>> =A0 =A0 =A0 /*
>> + =A0 =A0 =A0* the limit that reclaim triggers. TODO: res_counter in mem
>> + =A0 =A0 =A0* or wmark_limit.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long long low_wmark_limit;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* the limit that reclaim stops. TODO: res_counter in mem or
>> + =A0 =A0 =A0* wmark_limit.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long long high_wmark_limit;
>> + =A0 =A0 /*
>> =A0 =A0 =A0 =A0* the number of unsuccessful attempts to consume the reso=
urce
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 unsigned long long failcnt;
>> @@ -55,6 +65,10 @@ struct res_counter {
>>
>> =A0#define RESOURCE_MAX (unsigned long long)LLONG_MAX
>>
>> +#define CHARGE_WMARK_MIN =A0 =A0 0x01
>> +#define CHARGE_WMARK_LOW =A0 =A0 0x02
>> +#define CHARGE_WMARK_HIGH =A0 =A00x04
>> +
>> =A0/**
>> =A0 * Helpers to interact with userspace
>> =A0 * res_counter_read_u64() - returns the value of the specified member=

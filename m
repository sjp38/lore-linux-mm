Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D5BAE6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:03:26 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p0IK2uT8007470
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:02:56 -0800
Received: from qyk8 (qyk8.prod.google.com [10.241.83.136])
	by kpbe19.cbf.corp.google.com with ESMTP id p0IK2q1M016544
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:02:54 -0800
Received: by qyk8 with SMTP id 8so3308876qyk.20
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:02:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-3-git-send-email-yinghan@google.com>
	<20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 18 Jan 2011 12:02:51 -0800
Message-ID: <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 4:11 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 13 Jan 2011 14:00:32 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> The per cgroup kswapd is invoked when the cgroup's free memory (limit - =
usage)
>> is less than a threshold--low_wmark. Then the kswapd thread starts to re=
claim
>> pages in a priority loop similar to global algorithm. The kswapd is done=
 if the
>> free memory is above a threshold--high_wmark.
>>
>> The per cgroup background reclaim is based on the per cgroup LRU and als=
o adds
>> per cgroup watermarks. There are two watermarks including "low_wmark" an=
d
>> "high_wmark", and they are calculated based on the limit_in_bytes(hard_l=
imit)
>> for each cgroup. Each time the hard_limit is changed, the corresponding =
wmarks
>> are re-calculated. Since memory controller charges only user pages, ther=
e is
>> no need for a "min_wmark". The current calculation of wmarks is a functi=
on of
>> "memory.min_free_kbytes" which could be adjusted by writing different va=
lues
>> into the new api. This is added mainly for debugging purpose.
>>
>> Change log v2...v1:
>> 1. Remove the res_counter_charge on wmark due to performance concern.
>> 2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate commi=
t.
>> 3. Calculate the min_free_kbytes automatically based on the limit_in_byt=
es.
>> 4. make the wmark to be consistant with core VM which checks the free pa=
ges
>> instead of usage.
>> 5. changed wmark to be boolean
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>

Thank you  KAMEZAWA for your comments.

> Hmm, I don't think using the same algorithm as min_free_kbytes is good.
>
> Why it's bad to have 2 interfaces as low_wmark and high_wmark ?


>
> And in this patch, min_free_kbytes can be [256...65536]...I think this
> '256' is not good because it should be able to be set to '0'.
>
> IIUC, in enterprise systems, there are users who want to keep a fixed amo=
unt
> of free memory always. This interface will not allow such use case.

>
> I think we should have 2 interfaces as low_wmark and high_wmark. But as d=
efault
> value, the same value as to the alogorithm with min_free_kbytes will make=
 sense.

I agree that "min_free_kbytes" concept doesn't apply well since there
is no notion of "reserved pool" in memcg. I borrowed it at the
beginning is to add a tunable to the per-memcg watermarks besides the
hard_limit. I read the
patch posted from Satoru Moriya "Tunable watermarks", and introducing
the per-memcg-per-watermark tunable
sounds good to me. Might consider adding it to the next post.

>
> BTW, please divide res_counter part and memcg part in the next post.

Will do.

>
> Please explain your handling of 'hierarchy' in description.
I haven't thought through the 'hierarchy' handling in this patchset
which I will probably put more thoughts in the following
posts. Do you have recommendations on handing the 'hierarchy' ?

--Ying

>
> Thanks,
> -Kame
>
>
>> ---
>> =A0include/linux/memcontrol.h =A0| =A0 =A01 +
>> =A0include/linux/res_counter.h | =A0 83 ++++++++++++++++++++++++++++++++=
+++++++++++
>> =A0kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 =A06 +++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 73 ++++++++++++++++++++=
+++++++++++++++++
>> =A04 files changed, 163 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 3433784..80a605f 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -93,6 +93,7 @@ int task_in_mem_cgroup(struct task_struct *task, const=
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
>> index fcb9884..10b7e59 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -39,6 +39,15 @@ struct res_counter {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 unsigned long long soft_limit;
>> =A0 =A0 =A0 /*
>> + =A0 =A0 =A0* the limit that reclaim triggers. it is the free count
>> + =A0 =A0 =A0* (limit - usage)
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long long low_wmark_limit;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* the limit that reclaim stops. it is the free count
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long long high_wmark_limit;
>> + =A0 =A0 /*
>> =A0 =A0 =A0 =A0* the number of unsuccessful attempts to consume the reso=
urce
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 unsigned long long failcnt;
>> @@ -55,6 +64,9 @@ struct res_counter {
>>
>> =A0#define RESOURCE_MAX (unsigned long long)LLONG_MAX
>>
>> +#define CHARGE_WMARK_LOW =A0 =A0 0x02
>> +#define CHARGE_WMARK_HIGH =A0 =A00x04
>> +
>> =A0/**
>> =A0 * Helpers to interact with userspace
>> =A0 * res_counter_read_u64() - returns the value of the specified member=

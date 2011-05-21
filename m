Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 38E32900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 20:41:54 -0400 (EDT)
Received: by bwz17 with SMTP id 17so5117826bwz.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 17:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520145115.d52f3693.akpm@linux-foundation.org>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520145115.d52f3693.akpm@linux-foundation.org>
Date: Sat, 21 May 2011 09:41:50 +0900
Message-ID: <BANLkTinwmtgh+p=aeZux3NuC2ftbR5OMgQ@mail.gmail.com>
Subject: Re: [PATCH 8/8] memcg asyncrhouns reclaim workqueue
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 20 May 2011 12:48:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> workqueue for memory cgroup asynchronous memory shrinker.
>>
>> This patch implements the workqueue of async shrinker routine. each
>> memcg has a work and only one work can be scheduled at the same time.
>>
>> If shrinking memory doesn't goes well, delay will be added to the work.
>>
>
> When this code explodes (as it surely will), users will see large
> amounts of CPU consumption in the work queue thread. =A0We want to make
> this as easy to debug as possible, so we should try to make the
> workqueue's names mappable back onto their memcg's. =A0And anything else
> we can think of to help?
>

I had a patch for showing per-memcg reclaim latency stats. It will be help.
I'll add it again to this set. I just dropped it because there are many pat=
ches
onto memory.stat in flight..


>>
>> ...
>>
>> +static void mem_cgroup_async_shrink(struct work_struct *work)
>> +{
>> + =A0 =A0 struct delayed_work *dw =3D to_delayed_work(work);
>> + =A0 =A0 struct mem_cgroup *mem =3D container_of(dw,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup, async_work)=
;
>> + =A0 =A0 bool congested =3D false;
>> + =A0 =A0 int delay =3D 0;
>> + =A0 =A0 unsigned long long required, usage, limit, shrink_to;
>
> There's a convention which is favored by some (and ignored by the
> clueless ;)) which says "one definition per line".
>
> The reason I like one-definition-per-line is that it leaves a little
> room on the right where the programmer can explain the role of the
> local.
>
> Another advantage is that one can initialise it. =A0eg:
>
> =A0 =A0 =A0 =A0unsigned long limit =3D res_counter_read_u64(&mem->res, RE=
S_LIMIT);
>
> That conveys useful information: the reader can see what it's
> initialised with and can infer its use.
>
> A third advantage is that it can now be made const, which conveys very
> useful informtation and can prevent bugs.
>
> A fourth advantage is that it makes later patches to this function more
> readable and easier to apply when there are conflicts.
>
ok, I will fix.

>
>> + =A0 =A0 limit =3D res_counter_read_u64(&mem->res, RES_LIMIT);
>> + =A0 =A0 shrink_to =3D limit - MEMCG_ASYNC_MARGIN - PAGE_SIZE;
>> + =A0 =A0 usage =3D res_counter_read_u64(&mem->res, RES_USAGE);
>> + =A0 =A0 if (shrink_to <=3D usage) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 required =3D usage - shrink_to;
>> + =A0 =A0 =A0 =A0 =A0 =A0 required =3D (required >> PAGE_SHIFT) + 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* This scans some number of pages and retur=
ns that memory
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaim was slow or now. If slow, we add =
a delay as
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* congestion_wait() in vmscan.c
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 congested =3D mem_cgroup_shrink_static_scan(me=
m, (long)required);
>> + =A0 =A0 }
>> + =A0 =A0 if (test_bit(ASYNC_NORESCHED, &mem->async_flags)
>> + =A0 =A0 =A0 =A0 || mem_cgroup_async_should_stop(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto finish_scan;
>> + =A0 =A0 /* If memory reclaim couldn't go well, add delay */
>> + =A0 =A0 if (congested)
>> + =A0 =A0 =A0 =A0 =A0 =A0 delay =3D HZ/10;
>
> Another magic number.
>
> If Moore's law holds, we need to reduce this number by 1.4 each year.
> Is this good?
>

not good.  I just used the same magic number now used with wait_iff_congest=
ed.
Other than timer, I can use pagein/pageout event counter. If we have
dirty_ratio,
I may able to link this to dirty_ratio and wait until dirty_ratio is enough=
 low.
Or, wake up again hit limit.

Do you have suggestion ?



>> + =A0 =A0 queue_delayed_work(memcg_async_shrinker, &mem->async_work, del=
ay);
>> + =A0 =A0 return;
>> +finish_scan:
>> + =A0 =A0 cgroup_release_and_wakeup_rmdir(&mem->css);
>> + =A0 =A0 clear_bit(ASYNC_RUNNING, &mem->async_flags);
>> + =A0 =A0 return;
>> +}
>> +
>> +static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (test_bit(ASYNC_NORESCHED, &mem->async_flags))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>
> I can't work out what ASYNC_NORESCHED does. =A0Is its name well-chosen?
>
how about BLOCK/STOP_ASYNC_RECLAIM ?

>> + =A0 =A0 if (test_and_set_bit(ASYNC_RUNNING, &mem->async_flags))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 cgroup_exclude_rmdir(&mem->css);
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* start reclaim with small delay. This delay will allow us =
to do job
>> + =A0 =A0 =A0* in batch.
>
> Explain more?
>
yes, or I'll change this logic. I wanted to do low/high watermark
without "low" watermark...

>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (!queue_delayed_work(memcg_async_shrinker, &mem->async_work=
, 1)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&mem->css);
>> + =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(ASYNC_RUNNING, &mem->async_flags);
>> + =A0 =A0 }
>> + =A0 =A0 return;
>> +}
>> +
>>
>> ...
>>
>

Thank you for review. I realized I need some amount of works. I'll add text=
s to
explain behavior and make codes simpler.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9582D9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 23:40:34 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3R3eR6s032679
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:40:27 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe20.cbf.corp.google.com with ESMTP id p3R3eP4F014694
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:40:26 -0700
Received: by qyk7 with SMTP id 7so1554483qyk.19
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:40:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427093116.3e9b43d3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425184219.285c2396.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikB_4DXw2hPkBW4DDB1ZnXAJuSLKQ@mail.gmail.com>
	<20110427093116.3e9b43d3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 20:40:25 -0700
Message-ID: <BANLkTim21OMo5K5YKe0494zrUEUoJW5Ekw@mail.gmail.com>
Subject: Re: [PATCH 7/7] memcg watermark reclaim workqueue.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Tue, Apr 26, 2011 at 5:31 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 Apr 2011 16:19:41 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Mon, Apr 25, 2011 at 2:42 AM, KAMEZAWA Hiroyuki <
>> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> > @@ -3661,6 +3683,67 @@ unsigned long mem_cgroup_soft_limit_recl
>> > =A0 =A0 =A0 =A0return nr_reclaimed;
>> > =A0}
>> >
>> > +struct workqueue_struct *memcg_bgreclaimq;
>> > +
>> > +static int memcg_bgreclaim_init(void)
>> > +{
>> > + =A0 =A0 =A0 /*
>> > + =A0 =A0 =A0 =A0* use UNBOUND workqueue because we traverse nodes (no=
 locality)
>> > and
>> > + =A0 =A0 =A0 =A0* the work is cpu-intensive.
>> > + =A0 =A0 =A0 =A0*/
>> > + =A0 =A0 =A0 memcg_bgreclaimq =3D alloc_workqueue("memcg",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WQ_MEM_RECLAIM | WQ_UNBO=
UND | WQ_FREEZABLE, 0);
>> > + =A0 =A0 =A0 return 0;
>> > +}
>> >
>>
>> I read about the documentation of workqueue. So the WQ_UNBOUND support t=
he
>> max 512 execution contexts per CPU. Does the execution context means thr=
ead?
>>
>> I think I understand the motivation of that flag, so we can have more
>> concurrency of bg reclaim workitems. But one question is on the workqueu=
e
>> scheduling mechanism. If we can queue the item anywhere as long as they =
are
>> inserted in the queue, do we have mechanism to support the load balancin=
g
>> like the system scheduler? The scenario I am thinking is that one CPU ha=
s
>> 512 work items and the other one has 1.
>>
> IIUC, UNBOUND workqueue doesn't have cpumask and it can be scheduled anyw=
here.
> So, scheduler's load balancing works well.
>
> Because unbound_gcwq_nr_running =3D=3D 0 always (If I believe comment on =
source),
> =A0__need_more_worker() always returns true and
> need_to_create_worker() returns true if no idle thread.
>
> Then, I think new kthread is created always if there is a work.

Ah, ok. Then this works better than I thought, so we can use the
scheduler to put threads onto the
CPUs.

>
> I wonder I shoud use WQ_CPU_INTENSIVE and spread jobs to each cpu per mem=
cg. But
> I don't see problem with UNBOUND wq, yet.

I think the UNBOUND is good to start with.

>
>
>> I don't think this is directly related issue for this patch, and I just =
hope
>> the workqueue mechanism already support something like that for load
>> balancing.
>>
> If not, we can add it.

So, you might already answered my question. The load balancing is done
by the system
scheduler since we fork new thread for the queued items.

--Ying
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 21CE86B004D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:50:42 -0500 (EST)
Received: by qcsg1 with SMTP id g1so1664853qcs.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 15:50:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBAuDABE7u1wyc+45ZGoVos5PnxMe6P=ET-CHf-LChTpgw@mail.gmail.com>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
	<20120123130221.GA15113@tiehlicka.suse.cz>
	<CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
	<CAJd=RBAuDABE7u1wyc+45ZGoVos5PnxMe6P=ET-CHf-LChTpgw@mail.gmail.com>
Date: Tue, 24 Jan 2012 15:50:40 -0800
Message-ID: <CALWz4iwa=d_CDgUmsWB=xaS-7-X+r+2riD7HM3yxHWRTyResOg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 23, 2012 at 7:26 PM, Hillf Danton <dhillf@gmail.com> wrote:
> Hi all
>
> On Tue, Jan 24, 2012 at 3:14 AM, Ying Han <yinghan@google.com> wrote:
>> On Mon, Jan 23, 2012 at 5:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>> On Sat 21-01-12 22:49:23, Hillf Danton wrote:
>>>> In soft limit reclaim, overreclaim occurs when pages are reclaimed from mem
>>>> group that is under its soft limit, or when more pages are reclaimd than the
>>>> exceeding amount, then performance of reclaimee goes down accordingly.
>>>
>>> First of all soft reclaim is more a help for the global memory pressure
>>> balancing rather than any guarantee about how much we reclaim for the
>>> group.
>>> We need to do more changes in order to make it a guarantee.
>>> For example you implementation will cause severe problems when all
>>> cgroups are soft unlimited (default conf.) or when nobody is above the
>>> limit but the total consumption triggers the global reclaim. Therefore
>>> nobody is in excess and you would skip all groups and only bang on the
>>> root memcg.
>
> If soft limits are set to be limited and there are no excessors,
> who are consuming physical pages? The consumers maybe those with soft
> unlimited. If so, they should be punished first, based on the assumption that
> the unlimited is treated with no guarantee. Then soft limit guarantee could
> be assured without changes in the current default setting of soft limit, no?

The current code set the softlimit default to be RESOURCE_MAX, but we
do have plan to change it to 0. Then every cgroup will be eligible for
soft limit reclaim unless we set it otherwise. Not sure if that will
answer some of the questions?

>
> With soft limit available, victims are only selected from excessors, I think.
>
>>>
>>> Ying Han has a patch which basically skips all cgroups which are under
>>> its limit until we reach a certain reclaim priority but even for this we
>>> need some additional changes - e.g. reverse the current default setting
>>> of the soft limit.
>>>
>>> Anyway, I like the nr_to_reclaim reduction idea because we have to do
>>> this in some way because the global reclaim starts with ULONG
>>> nr_to_scan.
>>
>> Agree with Michal where there are quite a lot changes we need to get
>> in for soft limit before any further optimization.
>>
>> Hillf, please refer to the patch from Johannes
>> https://lkml.org/lkml/2012/1/13/99 which got quite a lot recent
>> discussions. I am expecting to get that in before further soft limit
>> changes.
>>
>
> Johannes did great cleanup, why barriered?

Not sure about the barriered here. As far as I can tell, some changes
we are talking about here would be easier to be applied after that
cleanup.

--Ying
>
> Thanks
> Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C92A26B004F
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 22:48:22 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so3035166vcb.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 19:48:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
	<20120123130221.GA15113@tiehlicka.suse.cz>
	<CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
Date: Tue, 24 Jan 2012 09:18:21 +0530
Message-ID: <CAKTCnzk1srmgyDzmSDzMsnbjmmt1ke91=kr0C4bECyxb1J6Rog@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jan 24, 2012 at 12:44 AM, Ying Han <yinghan@google.com> wrote:
> On Mon, Jan 23, 2012 at 5:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> On Sat 21-01-12 22:49:23, Hillf Danton wrote:
>>> In soft limit reclaim, overreclaim occurs when pages are reclaimed from mem
>>> group that is under its soft limit, or when more pages are reclaimd than the
>>> exceeding amount, then performance of reclaimee goes down accordingly.
>>
>> First of all soft reclaim is more a help for the global memory pressure
>> balancing rather than any guarantee about how much we reclaim for the
>> group.
>> We need to do more changes in order to make it a guarantee.
>> For example you implementation will cause severe problems when all
>> cgroups are soft unlimited (default conf.) or when nobody is above the
>> limit but the total consumption triggers the global reclaim. Therefore
>> nobody is in excess and you would skip all groups and only bang on the
>> root memcg.
>>

True, ideally soft reclaim should not turn on and allow global reclaim
to occur in the scenario mentioned.

>> Ying Han has a patch which basically skips all cgroups which are under
>> its limit until we reach a certain reclaim priority but even for this we
>> need some additional changes - e.g. reverse the current default setting
>> of the soft limit.
>>

I'd be wary of that approach, because it might be harder to explain
the working of soft limits,I'll look at the discussion thread
mentioned earlier for the benefits of that approach.

>> Anyway, I like the nr_to_reclaim reduction idea because we have to do
>> this in some way because the global reclaim starts with ULONG
>> nr_to_scan.
>
> Agree with Michal where there are quite a lot changes we need to get
> in for soft limit before any further optimization.
>
> Hillf, please refer to the patch from Johannes
> https://lkml.org/lkml/2012/1/13/99 which got quite a lot recent
> discussions. I am expecting to get that in before further soft limit
> changes.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

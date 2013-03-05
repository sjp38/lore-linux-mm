Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D5D8D6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 02:17:32 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id jm19so24296bkc.30
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 23:17:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <51344C57.7030807@parallels.com>
References: <512F0E76.2020707@parallels.com>
	<CAFj3OHXJckvDPWSnq9R8nZ00Sb0Juxq9oCrGCBeO0UZmgH6OzQ@mail.gmail.com>
	<51344C57.7030807@parallels.com>
Date: Tue, 5 Mar 2013 15:17:30 +0800
Message-ID: <CAFj3OHWJzfJ2_0f59n13fP0fiq5xuLs+DGVSGwzKBbVe_=C5fw@mail.gmail.com>
Subject: Re: per-cpu statistics
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Mon, Mar 4, 2013 at 3:25 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 03/01/2013 05:48 PM, Sha Zhengju wrote:
>> Hi Glauber,
>>
>> Forgive me, I'm replying not because I know the reason of current
>> per-cpu implementation but that I notice you're mentioning something
>> I'm also interested in. Below is the detail.
>>
>>
>> I'm not sure I fully understand your points, root memcg now don't
>> charge page already and only do some page stat
>> accounting(CACHE/RSS/SWAP).
>
> Can you point me to the final commits of this in the tree? I am using
> the latest git mm from mhocko and it is not entirely clear for me what
> are you talking about.

Sorry, maybe my "root memcg charge" is confusing. What I mean is that
root memcg don't do resource counter charge ( mem_cgroup_is_root()
checking in __mem_cgroup_try_charge()) but still need to do other
works(in __mem_cgroup_commit_charge): set pc->mem_cgroup,
SetPageCgroupUsed, and account memcg page statistics such as
CACHE/RSS.

Btw. the original commit is  0c3e73e84f(memcg: improve resource
counter scalability), but it has been drastically modified now. : )

>
>>  Now I'm also trying to do some
>> optimization specific to the overhead of root memcg stat accounting,
>> and the first attempt is posted here:
>> https://lkml.org/lkml/2013/1/2/71 . But it only covered
>> FILE_MAPPED/DIRTY/WRITEBACK(I've add the last two accounting in that
>> patchset) and Michal Hock accepted the approach (so did Kame) and
>> suggested I should handle all the stats in the same way including
>> CACHE/RSS. But I do not handle things related to memcg LRU where I
>> notice you have done some work.
>>
> Yes, LRU is a bit tricky and it is what is keeping me from posting the
> patchset I have. I haven't fully done it, but I am on my way.
>
>
>> It's possible that we may take different ways to bypass root memcg
>> stat accounting. The next round of the part will be sent out in
>> following few days(doing some tests now), and for myself any comments
>> and collaboration are welcome. (Glad to cc to you of course if you're
>> also interest in it. :) )
>>
>
> I am interested, of course. As you know, I started to work on this a
> while ago and had to interrupt it for a while. I resumed it last week,
> but if you managed to merge something already, I'd happy to rebase.
>

I do appreciate your support! Thanks!


Regards,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 281256B0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 17:36:11 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so3140015pbc.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 14:36:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121211155432.GC1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
	<1353955671-14385-4-git-send-email-mhocko@suse.cz>
	<CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
	<20121211155432.GC1612@dhcp22.suse.cz>
Date: Tue, 11 Dec 2012 14:36:10 -0800
Message-ID: <CALWz4izL7fEuQhEvKa7mUqi0sa25mcFP-xnTnL3vU3Z17k7VHg@mail.gmail.com>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup iterators
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue, Dec 11, 2012 at 7:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sun 09-12-12 11:39:50, Ying Han wrote:
>> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
> [...]
>> >                 if (reclaim) {
>> > -                       iter->position = id;
>> > +                       struct mem_cgroup *curr = memcg;
>> > +
>> > +                       if (last_visited)
>> > +                               css_put(&last_visited->css);
>                             ^^^^^^^^^^^
>                             here
>> > +
>> > +                       if (css && !memcg)
>> > +                               curr = mem_cgroup_from_css(css);
>> > +
>> > +                       /* make sure that the cached memcg is not removed */
>> > +                       if (curr)
>> > +                               css_get(&curr->css);
>> > +                       iter->last_visited = curr;
>>
>> Here we take extra refcnt for last_visited, and assume it is under
>> target reclaim which then calls mem_cgroup_iter_break() and we leaked
>> a refcnt of the target memcg css.
>
> I think you are not right here. The extra reference is kept for
> iter->last_visited and it will be dropped the next time somebody sees
> the same zone-priority iter. See above.
>
> Or have I missed your question?

Hmm, question remains.

My understanding of the mem_cgroup_iter() is that each call path
should close the loop itself, in the sense that no *leaked* css refcnt
after that loop finished. It is the case for all the caller today
where the loop terminates at memcg == NULL, where all the refcnt have
been dropped by then.

One exception is mem_cgroup_iter_break(), where the loop terminates
with *leaked* refcnt and that is what the iter_break() needs to clean
up. We can not rely on the next caller of the loop since it might
never happen.

It makes sense to drop the refcnt of last_visited, the same reason as
drop refcnt of prev. I don't see why it makes different.

--Ying


>
> [...]
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

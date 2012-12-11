Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id AE5CE6B0093
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 17:31:50 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1939729dak.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 14:31:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121211155025.GB1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
	<1353955671-14385-4-git-send-email-mhocko@suse.cz>
	<CALWz4iwNvRd7AgEiSzd7Gr-7P5oh0uESS5A7rLZ7dZWeTjOzpQ@mail.gmail.com>
	<20121211155025.GB1612@dhcp22.suse.cz>
Date: Tue, 11 Dec 2012 14:31:49 -0800
Message-ID: <CALWz4izk-A-DPCEnCsVMvzjtgL2W2ydcRM1vyKcLhjWtUzTpkg@mail.gmail.com>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup iterators
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue, Dec 11, 2012 at 7:50 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sun 09-12-12 08:59:54, Ying Han wrote:
>> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
> [...]
>> > +               /*
>> > +                * Even if we found a group we have to make sure it is alive.
>> > +                * css && !memcg means that the groups should be skipped and
>> > +                * we should continue the tree walk.
>> > +                * last_visited css is safe to use because it is protected by
>> > +                * css_get and the tree walk is rcu safe.
>> > +                */
>> > +               if (css == &root->css || (css && css_tryget(css)))
>> > +                       memcg = mem_cgroup_from_css(css);
>> >
>> >                 if (reclaim) {
>> > -                       iter->position = id;
>> > +                       struct mem_cgroup *curr = memcg;
>> > +
>> > +                       if (last_visited)
>> > +                               css_put(&last_visited->css);
>> > +
>> > +                       if (css && !memcg)
>> > +                               curr = mem_cgroup_from_css(css);
>>
>> In this case, the css_tryget() failed which implies the css is on the
>> way to be removed. (refcnt ==0) If so, why it is safe to call
>> css_get() directly on it below? It seems not preventing the css to be
>> removed by doing so.
>
> Well, I do not remember exactly but I guess the code is meant to say
> that we need to store a half-dead memcg because the loop has to be
> retried. As we are under RCU hood it is just half dead.
> Now that you brought this up I think this is not safe as well because
> another thread could have seen the cached value while we tried to retry
> and his RCU is not protecting the group anymore. The follow up patch
> fixes this by retrying within the loop. I will bring that part into
> this patch already and then leave only css clean up in the other patch.
>
> Thanks for spotting this Ying!

I understand the intention here where we want to move on to the next
css if the css_tryget() failed. But css_get() won't hold on it in that
case.

I fixed that on my local branch which do the retry after css_tryget()
failed, just like what you talked about. And I will wait for you fix
on that.

--Ying

>
>>
>> > +                       /* make sure that the cached memcg is not removed */
>> > +                       if (curr)
>> > +                               css_get(&curr->css);
>>
>> --Ying
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

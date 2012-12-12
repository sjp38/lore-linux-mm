Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E031E6B0062
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:09:44 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so776555pbc.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 10:09:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121212090652.GB32081@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
	<1353955671-14385-4-git-send-email-mhocko@suse.cz>
	<CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
	<20121211155432.GC1612@dhcp22.suse.cz>
	<CALWz4izL7fEuQhEvKa7mUqi0sa25mcFP-xnTnL3vU3Z17k7VHg@mail.gmail.com>
	<20121212090652.GB32081@dhcp22.suse.cz>
Date: Wed, 12 Dec 2012 10:09:43 -0800
Message-ID: <CALWz4iwq+vRN+rreOk7Jg4rHWWBSmNwBW8Kko45E-D8Vi66eQA@mail.gmail.com>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup iterators
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Wed, Dec 12, 2012 at 1:06 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 11-12-12 14:36:10, Ying Han wrote:
>> On Tue, Dec 11, 2012 at 7:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Sun 09-12-12 11:39:50, Ying Han wrote:
>> >> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > [...]
>> >> >                 if (reclaim) {
>> >> > -                       iter->position = id;
>> >> > +                       struct mem_cgroup *curr = memcg;
>> >> > +
>> >> > +                       if (last_visited)
>> >> > +                               css_put(&last_visited->css);
>> >                             ^^^^^^^^^^^
>> >                             here
>> >> > +
>> >> > +                       if (css && !memcg)
>> >> > +                               curr = mem_cgroup_from_css(css);
>> >> > +
>> >> > +                       /* make sure that the cached memcg is not removed */
>> >> > +                       if (curr)
>> >> > +                               css_get(&curr->css);
>> >> > +                       iter->last_visited = curr;
>> >>
>> >> Here we take extra refcnt for last_visited, and assume it is under
>> >> target reclaim which then calls mem_cgroup_iter_break() and we leaked
>> >> a refcnt of the target memcg css.
>> >
>> > I think you are not right here. The extra reference is kept for
>> > iter->last_visited and it will be dropped the next time somebody sees
>> > the same zone-priority iter. See above.
>> >
>> > Or have I missed your question?
>>
>> Hmm, question remains.
>>
>> My understanding of the mem_cgroup_iter() is that each call path
>> should close the loop itself, in the sense that no *leaked* css refcnt
>> after that loop finished. It is the case for all the caller today
>> where the loop terminates at memcg == NULL, where all the refcnt have
>> been dropped by then.
>
> Now I am not sure I understand you. mem_cgroup_iter_break will always
> drop the reference of the last returned memcg. So far so good.

Yes, and the patch doesn't change that.

But if
> the last memcg got cached in per-zone-priority last_visited then we
> _have_ to keep a reference to it regardless we broke out of the loop.
> The last_visited thingy is shared between all parallel reclaimers so we
> cannot just drop a reference to it.

Agree that the last_visited is shared between all the memcgs accessing
the per-zone-per-iterator.

Also agree that we don't want to drop reference of it if last_visited
is cached after the loop.

But If i look at the callers of mem_cgroup_iter(), they all look like
the following:

memcg = mem_cgroup_iter(root, NULL, &reclaim);
do {

    // do something

    memcg = mem_cgroup_iter(root, memcg, &reclaim);
} while (memcg);

So we get out of the loop when memcg returns as NULL, where the
last_visited is cached as NULL as well thus no css_get(). That is what
I meant by "each reclaim thread closes the loop". If that is true, the
current implementation of mem_cgroup_iter_break() changes that.


>
>> One exception is mem_cgroup_iter_break(), where the loop terminates
>> with *leaked* refcnt and that is what the iter_break() needs to clean
>> up. We can not rely on the next caller of the loop since it might
>> never happen.
>
> Yes, this is true and I already have a half baked patch for that. I
> haven't posted it yet but it basically checks all node-zone-prio
> last_visited and removes itself from them on the way out in pre_destroy
> callback (I just need to cleanup "find a new last_visited" part and will
> post it).

Not sure whether that or just change the mem_cgroup_iter_break() by
dropping the refcnt of last_visited.

--Ying
>
>> It makes sense to drop the refcnt of last_visited, the same reason as
>> drop refcnt of prev. I don't see why it makes different.
>
> Because then it might vanish when somebody else wants to access it. If
> we just did mem_cgroup_get which would be enough to keep only memcg part
> in memory then what can we do at the time we visit it? css_tryget would
> tell us "no your buddy is gone", you do not have any links to the tree
> so you would need to start from the beginning. That is what I have
> implemented in the first version. Then I've realized that this could
> make a bigger pressure on the groups created earlier which doesn't seem
> to be right. With css pinning we are sure that there is a link to a next
> node in the tree.
>
> Thanks!
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 4C8566B006E
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 22:43:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so151915pad.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 19:43:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
	<1353955671-14385-4-git-send-email-mhocko@suse.cz>
	<CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
Date: Thu, 6 Dec 2012 19:43:52 -0800
Message-ID: <CALWz4iwrJtG-YUkA8ZpQC=JDMs3_ZRqwjrg+OEEO+_HA_KM9UA@mail.gmail.com>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup iterators
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Thu, Dec 6, 2012 at 7:39 PM, Ying Han <yinghan@google.com> wrote:
> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> mem_cgroup_iter curently relies on css->id when walking down a group
>> hierarchy tree. This is really awkward because the tree walk depends on
>> the groups creation ordering. The only guarantee is that a parent node
>> is visited before its children.
>> Example
>>  1) mkdir -p a a/d a/b/c
>>  2) mkdir -a a/b/c a/d
>> Will create the same trees but the tree walks will be different:
>>  1) a, d, b, c
>>  2) a, b, c, d
>>
>> 574bd9f7 (cgroup: implement generic child / descendant walk macros) has
>> introduced generic cgroup tree walkers which provide either pre-order
>> or post-order tree walk. This patch converts css->id based iteration
>> to pre-order tree walk to keep the semantic with the original iterator
>> where parent is always visited before its subtree.
>>
>> cgroup_for_each_descendant_pre suggests using post_create and
>> pre_destroy for proper synchronization with groups addidition resp.
>> removal. This implementation doesn't use those because a new memory
>> cgroup is fully initialized in mem_cgroup_create and css reference
>> counting enforces that the group is alive for both the last seen cgroup
>> and the found one resp. it signals that the group is dead and it should
>> be skipped.
>>
>> If the reclaim cookie is used we need to store the last visited group
>> into the iterator so we have to be careful that it doesn't disappear in
>> the mean time. Elevated reference count on the css keeps it alive even
>> though the group have been removed (parked waiting for the last dput so
>> that it can be freed).
>>
>> V2
>> - use css_{get,put} for iter->last_visited rather than
>>   mem_cgroup_{get,put} because it is stronger wrt. cgroup life cycle
>> - cgroup_next_descendant_pre expects NULL pos for the first iterartion
>>   otherwise it might loop endlessly for intermediate node without any
>>   children.
>>
>> Signed-off-by: Michal Hocko <mhocko@suse.cz>
>> ---
>>  mm/memcontrol.c |   74 ++++++++++++++++++++++++++++++++++++++++++-------------
>>  1 file changed, 57 insertions(+), 17 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 1f5528d..6bcc97b 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -144,8 +144,8 @@ struct mem_cgroup_stat_cpu {
>>  };
>>
>>  struct mem_cgroup_reclaim_iter {
>> -       /* css_id of the last scanned hierarchy member */
>> -       int position;
>> +       /* last scanned hierarchy member with elevated css ref count */
>> +       struct mem_cgroup *last_visited;
>>         /* scan generation, increased every round-trip */
>>         unsigned int generation;
>>         /* lock to protect the position and generation */
>> @@ -1066,7 +1066,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>>                                    struct mem_cgroup_reclaim_cookie *reclaim)
>>  {
>>         struct mem_cgroup *memcg = NULL;
>> -       int id = 0;
>> +       struct mem_cgroup *last_visited = NULL;
>>
>>         if (mem_cgroup_disabled())
>>                 return NULL;
>> @@ -1075,7 +1075,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>>                 root = root_mem_cgroup;
>>
>>         if (prev && !reclaim)
>> -               id = css_id(&prev->css);
>> +               last_visited = prev;
>>
>>         if (!root->use_hierarchy && root != root_mem_cgroup) {
>>                 if (prev)
>> @@ -1083,9 +1083,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>>                 return root;
>>         }
>>
>> +       rcu_read_lock();
>>         while (!memcg) {
>>                 struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
>> -               struct cgroup_subsys_state *css;
>> +               struct cgroup_subsys_state *css = NULL;
>>
>>                 if (reclaim) {
>>                         int nid = zone_to_nid(reclaim->zone);
>> @@ -1095,34 +1096,73 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>>                         mz = mem_cgroup_zoneinfo(root, nid, zid);
>>                         iter = &mz->reclaim_iter[reclaim->priority];
>>                         spin_lock(&iter->iter_lock);
>> +                       last_visited = iter->last_visited;
>>                         if (prev && reclaim->generation != iter->generation) {
>> +                               if (last_visited) {
>> +                                       css_put(&last_visited->css);
>> +                                       iter->last_visited = NULL;
>> +                               }
>>                                 spin_unlock(&iter->iter_lock);
>> -                               goto out_css_put;
>> +                               goto out_unlock;
>>                         }
>> -                       id = iter->position;
>>                 }
>>
>> -               rcu_read_lock();
>> -               css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
>> -               if (css) {
>> -                       if (css == &root->css || css_tryget(css))
>> -                               memcg = mem_cgroup_from_css(css);
>> -               } else
>> -                       id = 0;
>> -               rcu_read_unlock();
>> +               /*
>> +                * Root is not visited by cgroup iterators so it needs an
>> +                * explicit visit.
>> +                */
>> +               if (!last_visited) {
>> +                       css = &root->css;
>> +               } else {
>> +                       struct cgroup *prev_cgroup, *next_cgroup;
>> +
>> +                       prev_cgroup = (last_visited == root) ? NULL
>> +                               : last_visited->css.cgroup;
>> +                       next_cgroup = cgroup_next_descendant_pre(prev_cgroup,
>> +                                       root->css.cgroup);
>> +                       if (next_cgroup)
>> +                               css = cgroup_subsys_state(next_cgroup,
>> +                                               mem_cgroup_subsys_id);
>> +               }
>> +
>> +               /*
>> +                * Even if we found a group we have to make sure it is alive.
>> +                * css && !memcg means that the groups should be skipped and
>> +                * we should continue the tree walk.
>> +                * last_visited css is safe to use because it is protected by
>> +                * css_get and the tree walk is rcu safe.
>> +                */
>> +               if (css == &root->css || (css && css_tryget(css)))
>> +                       memcg = mem_cgroup_from_css(css);
>>
>>                 if (reclaim) {
>> -                       iter->position = id;
>> +                       struct mem_cgroup *curr = memcg;
>> +
>> +                       if (last_visited)
>> +                               css_put(&last_visited->css);
>> +
>> +                       if (css && !memcg)
>> +                               curr = mem_cgroup_from_css(css);
>> +
>> +                       /* make sure that the cached memcg is not removed */
>> +                       if (curr)
>> +                               css_get(&curr->css);
>> +                       iter->last_visited = curr;
>> +
>>                         if (!css)
>>                                 iter->generation++;
>>                         else if (!prev && memcg)
>>                                 reclaim->generation = iter->generation;
>>                         spin_unlock(&iter->iter_lock);
>> +               } else if (css && !memcg) {
>> +                       last_visited = mem_cgroup_from_css(css);
>>                 }
>>
>>                 if (prev && !css)
>> -                       goto out_css_put;
>> +                       goto out_unlock;
>>         }
>> +out_unlock:
>> +       rcu_read_unlock();
>>  out_css_put:
>>         if (prev && prev != root)
>>                 css_put(&prev->css);
>> --
>> 1.7.10.4
>>
>
> Michal,
>
> I got some trouble while running this patch with my test. The test
> creates hundreds of memcgs which each runs some workload to generate
> global pressure. At the last, it removes all the memcgs by rmdir. Then
> the cmd "ls /dev/cgroup/memory/" hangs afterwards.
>
> I studied a bit of the patch, but not spending too much time on it
> yet. Looks like that the v2 has something different from your last
> post, where you replaces the mem_cgroup_get() with css_get() on the
> iter->last_visited. Didn't follow why we made that change, but after
> restoring the behavior a bit seems passed my test. Here is the patch I
> applied on top of this one:
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f2eeee6..4aadb9f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1003,12 +1003,16 @@ struct mem_cgroup *mem_cgroup_iter(struct
> mem_cgroup *root,
>                         last_visited = iter->last_visited;
>                         if (prev && reclaim->generation != iter->generation) {
>                                 if (last_visited) {
> -                                       css_put(&last_visited->css);
> +                                       mem_cgroup_put(last_visited);
>                                         iter->last_visited = NULL;
>                                 }
>                                 spin_unlock(&iter->iter_lock);
>                                 goto out_unlock;
>                         }
> +                       if (last_visited && !css_tryget(&last_visited->css)) {
> +                               mem_cgroup_put(last_visited);
> +                               last_visited = NULL;
> +                       }
>                 }
>
>                 /*
> @@ -1041,15 +1045,17 @@ struct mem_cgroup *mem_cgroup_iter(struct
> mem_cgroup *root,
>                 if (reclaim) {
>                         struct mem_cgroup *curr = memcg;
>
> -                       if (last_visited)
> +                       if (last_visited) {
>                                 css_put(&last_visited->css);
> +                               mem_cgroup_put(last_visited);
> +                       }
>
>                         if (css && !memcg)
>                                 curr = container_of(css, struct
> mem_cgroup, css);
>
>                         /* make sure that the cached memcg is not removed */
>                         if (curr)
> -                               css_get(&curr->css);
> +                               mem_cgroup_get(curr);
>                         iter->last_visited = curr;
>
>                         if (!css)
>
>
> I will probably look into why next, but like to bring it up in case it
> rings the bell on your side :)


Forgot to mention, I was testing 3.7-rc6 with the two cgroup changes :

cgroup: Use rculist ops for cgroup->children
cgroup: implement generic child / descendant walk macros

> --Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

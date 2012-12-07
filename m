Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 3330B6B0071
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 12:27:39 -0500 (EST)
Date: Fri, 7 Dec 2012 18:27:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121207172734.GG31938@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
 <CALWz4iwrJtG-YUkA8ZpQC=JDMs3_ZRqwjrg+OEEO+_HA_KM9UA@mail.gmail.com>
 <20121207085839.GB31938@dhcp22.suse.cz>
 <CALWz4iwP5vzqE8O0uyCuBnOwbJX_07CB=CsGpP3yzrtQDkr2Qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwP5vzqE8O0uyCuBnOwbJX_07CB=CsGpP3yzrtQDkr2Qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Fri 07-12-12 09:12:25, Ying Han wrote:
> On Fri, Dec 7, 2012 at 12:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 06-12-12 19:43:52, Ying Han wrote:
> > [...]
> >> Forgot to mention, I was testing 3.7-rc6 with the two cgroup changes :
> >
> > Could you give a try to -mm tree as well. There are some changes for
> > memcgs removal in that tree which are not in Linus's tree.
> 
> I will give a try, which patchset you have in mind so i can double check?

Have a look at ba5e0e6be1c76fd37508b2825372b28a90a5b729 in my tree.
 
> I didn't find the place where the css pins the memcg, which either
> something i missed or not in place in my tree.

Yeah, it is carefully hidden ;).
css pins cgroup (last css_put will call dput on the cgroup dentry - via
css_dput_fn) and the last reference to memcg is dropped from ->destroy
callback (mem_cgroup_destroy) called from cgroup_diput.

> I twisted the patch a bit to make it closer to your v2 version,
> but instead keep the mem_cgroup_put() as well as using
> css_tryget(). Again, my test is happy with it:

This is really strange, there must be something weird with ref counting
going on.
Anyway, thanks for your testing! I will try to enahance my testing some
more next week.

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f2eeee6..acec05a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1004,6 +1004,7 @@ struct mem_cgroup *mem_cgroup_iter(struct
> mem_cgroup *root,
>                         if (prev && reclaim->generation != iter->generation) {
>                                 if (last_visited) {
>                                         css_put(&last_visited->css);
> +                                       mem_cgroup_put(last_visited);
>                                         iter->last_visited = NULL;
>                                 }
>                                 spin_unlock(&iter->iter_lock);
> @@ -1041,15 +1042,22 @@ struct mem_cgroup *mem_cgroup_iter(struct
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
> -                       if (curr)
> -                               css_get(&curr->css);
> +                       if (curr) {
> +                               mem_cgroup_get(curr);
> +                               if (!css_tryget(&curr->css)) {
> +                                       mem_cgroup_put(curr);
> +                                       curr = NULL;
> +                               }
> +                       }
>                         iter->last_visited = curr;
> 
>                         if (!css)
> 
> 
> --Ying
> 
> > --
> > Michal Hocko
> > SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

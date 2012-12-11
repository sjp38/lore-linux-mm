Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2FF3B6B005D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 10:54:39 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so4815748oag.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 07:54:38 -0800 (PST)
Date: Tue, 11 Dec 2012 16:54:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121211155432.GC1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Sun 09-12-12 11:39:50, Ying Han wrote:
> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
[...]
> >                 if (reclaim) {
> > -                       iter->position = id;
> > +                       struct mem_cgroup *curr = memcg;
> > +
> > +                       if (last_visited)
> > +                               css_put(&last_visited->css);
			    ^^^^^^^^^^^
			    here
> > +
> > +                       if (css && !memcg)
> > +                               curr = mem_cgroup_from_css(css);
> > +
> > +                       /* make sure that the cached memcg is not removed */
> > +                       if (curr)
> > +                               css_get(&curr->css);
> > +                       iter->last_visited = curr;
> 
> Here we take extra refcnt for last_visited, and assume it is under
> target reclaim which then calls mem_cgroup_iter_break() and we leaked
> a refcnt of the target memcg css.

I think you are not right here. The extra reference is kept for
iter->last_visited and it will be dropped the next time somebody sees
the same zone-priority iter. See above.

Or have I missed your question?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

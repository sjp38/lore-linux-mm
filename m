Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 83E0E6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:25:47 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so1549724ied.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 12:25:46 -0700 (PDT)
Date: Wed, 24 Oct 2012 12:25:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121024192535.GG12182@atj.dyndns.org>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
 <20121019133244.GE799@dhcp22.suse.cz>
 <20121019202405.GR13370@google.com>
 <20121022103021.GA6367@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121022103021.GA6367@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

Hello, Michal.

On Mon, Oct 22, 2012 at 12:30:21PM +0200, Michal Hocko wrote:
> > > We can still fail inn #3 without this patch becasuse there are is no
> > > guarantee that a new task is attached to the group. And I wanted to keep
> > > memcg and generic cgroup parts separated.
> > 
> > Yes, but all other controllers are broken that way too
> 
> It's just hugetlb and memcg that have pre_destroy.
> 
> > and the worst thing which will hapen is triggering WARN_ON_ONCE().
> 
> The patch does BUG_ON(ss->pre_destroy(cgrp)). I am not sure WARN_ON_ONCE is
> appropriate here because we would like to have it at least per
> controller warning. I do not see any reason why to make this more
> complicated but I am open to suggestions.

Once it's dropped from memcg, the next patch can update cgroup core
accordingly and the bug will exist for a single commit and the failure
mode would be triggering of WARN_ON_ONCE().  Seems pretty simple to
me.

> > Let's note the failure in the commit and remove
> > DEPREDATED_clear_css_refs in the previous patch.  Then, I can pull
> > from you, clean up pre_destroy mess and then you can pull back for
> > further cleanups.
> 
> Well this will get complicated as there are dependencies between memcg
> parts (based on Andrew's tree) and your tree. My tree is not pullable as
> all the patches go via Andrew. I am not sure how to get out of this.
> There is only one cgroup patch so what about pushing all of this via
> Andrew and do the follow up cleanups once they get merged? We are not in
> hurry, are we?

Let's create a cgroup branch and build things there.  I don't think
cgroup changes are gonna be a single patch and expect to see at least
some bug fixes afterwards and don't wanna keep them floating separate
from other cgroup changes.  mm being based on top of -next, that
should work, right?

> Anyway does it really make sense to drop DEPREDATED_clear_css_refs
> already in the previous patch when it is _not_ guaranteed that
> pre_destroy succeeds?

It makes things simpler here by decoupling memcg change with core
cgroup changes and the introduced bug isn't too easy to trigger and
even when triggered the failure mode isn't critical.  It's not gonna
break normal common operations or bisection.  As long as the issue is
clearly documented, I think it should be fine.  Just note that this
opens up a race window from deficient cgroup API and the following
commits will address it.

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

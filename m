Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 925A66B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 10:38:27 -0400 (EDT)
Date: Thu, 25 Oct 2012 16:37:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121025143756.GI11105@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
 <20121019133244.GE799@dhcp22.suse.cz>
 <20121019202405.GR13370@google.com>
 <20121022103021.GA6367@dhcp22.suse.cz>
 <20121024192535.GG12182@atj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121024192535.GG12182@atj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Wed 24-10-12 12:25:35, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Oct 22, 2012 at 12:30:21PM +0200, Michal Hocko wrote:
> > > > We can still fail inn #3 without this patch becasuse there are is no
> > > > guarantee that a new task is attached to the group. And I wanted to keep
> > > > memcg and generic cgroup parts separated.
> > > 
> > > Yes, but all other controllers are broken that way too
> > 
> > It's just hugetlb and memcg that have pre_destroy.
> > 
> > > and the worst thing which will hapen is triggering WARN_ON_ONCE().
> > 
> > The patch does BUG_ON(ss->pre_destroy(cgrp)). I am not sure WARN_ON_ONCE is
> > appropriate here because we would like to have it at least per
> > controller warning. I do not see any reason why to make this more
> > complicated but I am open to suggestions.
> 
> Once it's dropped from memcg, the next patch can update cgroup core
> accordingly and the bug will exist for a single commit and the failure
> mode would be triggering of WARN_ON_ONCE().  Seems pretty simple to
> me.

I am not sure I understand you here. So are you suggesting
s/BUG_ON/WARN_ON_ONCE/ in this patch?
It is true that this will not break bisectability but it is still not
correct (strictly speaking because any load that can race group removal
with new tasks addition would hit BUG/WARN and we will remove a group
with a task inside).
The patchset as posted makes sure that none of the stages adds a
regression and I would like to stick with that as much as possible if it
doesn't cause too much of a hassle.

> > > Let's note the failure in the commit and remove
> > > DEPREDATED_clear_css_refs in the previous patch.  Then, I can pull
> > > from you, clean up pre_destroy mess and then you can pull back for
> > > further cleanups.
> > 
> > Well this will get complicated as there are dependencies between memcg
> > parts (based on Andrew's tree) and your tree. My tree is not pullable as
> > all the patches go via Andrew. I am not sure how to get out of this.
> > There is only one cgroup patch so what about pushing all of this via
> > Andrew and do the follow up cleanups once they get merged? We are not in
> > hurry, are we?
> 
> Let's create a cgroup branch and build things there.  I don't think
> cgroup changes are gonna be a single patch and expect to see at least
> some bug fixes afterwards and don't wanna keep them floating separate
> from other cgroup changes.  

> mm being based on top of -next, that should work, right?

Well, a tree based on -next is, ehm, impractical. I can create a bug on
top of my -mm git branch (where I merge your cgroup common changes) for
development and then when we are ready we can send it as a series and
push it via Andrew. Would that work for you?
Or we can push the core part via Andrew, wait for the merge and work on
the follow up cleanups later?
It is not like the follow up part is really urgent, isn't it? I would
just like the memcg part settled first because this can potentially
conflict with other memcg work.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

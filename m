Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 99A956B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:32:47 -0400 (EDT)
Date: Fri, 19 Oct 2012 15:32:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121019133244.GE799@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121018224148.GR13370@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 18-10-12 15:41:48, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Oct 17, 2012 at 03:30:46PM +0200, Michal Hocko wrote:
> > Now that mem_cgroup_pre_destroy callback doesn't fail finally we can
> > safely move on and forbit all the callbacks to fail. The last missing
> > piece is moving cgroup_call_pre_destroy after cgroup_clear_css_refs so
> > that css_tryget fails so no new charges for the memcg can happen.
> > The callbacks are also called from within cgroup_lock to guarantee that
> > no new tasks show up. We could theoretically call them outside of the
> > lock but then we have to move after CGRP_REMOVED flag is set.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> So, the plan is to do something like the following once memcg is
> ready.
> 
>   http://thread.gmane.org/gmane.linux.kernel.containers/22559/focus=75251
> 
> Note that the patch is broken in a couple places but it does show the
> general direction.  I'd prefer if patch #3 simply makes pre_destroy()
> return 0 and drop __DEPRECATED_clear_css_refs from mem_cgroup_subsys.

We can still fail inn #3 without this patch becasuse there are is no
guarantee that a new task is attached to the group. And I wanted to keep
memcg and generic cgroup parts separated.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

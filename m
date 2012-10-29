Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 99AA56B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 10:17:57 -0400 (EDT)
Date: Mon, 29 Oct 2012 15:17:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121029141755.GC20757@dhcp22.suse.cz>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
 <1351251453-6140-5-git-send-email-mhocko@suse.cz>
 <508E8CDE.1090702@parallels.com>
 <508E8D6A.5040602@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508E8D6A.5040602@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Mon 29-10-12 18:06:34, Glauber Costa wrote:
> On 10/29/2012 06:04 PM, Glauber Costa wrote:
> > On 10/26/2012 03:37 PM, Michal Hocko wrote:
> >> Now that mem_cgroup_pre_destroy callback doesn't fail (other than a race
> >> with a task attach resp. child group appears) finally we can safely move
> >> on and forbit all the callbacks to fail.
> >> The last missing piece is moving cgroup_call_pre_destroy after
> >> cgroup_clear_css_refs so that css_tryget fails so no new charges for the
> >> memcg can happen.
> >> We cannot, however, move cgroup_call_pre_destroy right after because we
> >> cannot call mem_cgroup_pre_destroy with the cgroup_lock held (see
> >> 3fa59dfb cgroup: fix potential deadlock in pre_destroy) so we have to
> >> move it after the lock is released.
> >>
> > 
> > If we don't have the cgroup lock held, how safe is the following
> > statement in mem_cgroup_reparent_charges():
> > 
> > if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
> > 	return -EBUSY;
> > 
> > ?
> > 
> > IIUC, although this is not generally safe, but it would be safe here
> > because at this point we are expected to had already set the removed bit
> > in the css. If this is the case, however, this condition is impossible
> > and becomes useless - in which case you may want to remove it from Patch1.
> > 
> Which I just saw you doing in patch5... =)

Yes, I just wanted to keep this one cgroup core only to enable further
cgroup clean ups easier. Dropping the earlier in the series could
introduce regressions which I tried to avoid as much as possible.

Thanks

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

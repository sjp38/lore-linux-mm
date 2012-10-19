Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 637F46B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 07:09:53 -0400 (EDT)
Date: Fri, 19 Oct 2012 13:09:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121019110949.GC799@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <50811E5E.1090205@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50811E5E.1090205@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Fri 19-10-12 17:33:18, Li Zefan wrote:
> On 2012/10/17 21:30, Michal Hocko wrote:
> > Now that mem_cgroup_pre_destroy callback doesn't fail finally we can
> > safely move on and forbit all the callbacks to fail. The last missing
> > piece is moving cgroup_call_pre_destroy after cgroup_clear_css_refs so
> > that css_tryget fails so no new charges for the memcg can happen.
> 
> > The callbacks are also called from within cgroup_lock to guarantee that
> > no new tasks show up. 
> 
> I'm afraid this won't work. See commit 3fa59dfbc3b223f02c26593be69ce6fc9a940405
> ("cgroup: fix potential deadlock in pre_destroy")

Very good point. Thanks for poiting this out. So we should call
pre_destroy at the very end? What about the following?
Or should be rather drop the lock after check_for_release(parent) or
sooner but after CGRP_REMOVED is set?
---

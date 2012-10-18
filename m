Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B1F886B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 20:30:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D74E73EE0BD
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:30:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE39645DEB5
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:30:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CE2845DEBA
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:30:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9114F1DB803E
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:30:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47BB61DB803B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:30:39 +0900 (JST)
Message-ID: <507F4D86.106@jp.fujitsu.com>
Date: Thu, 18 Oct 2012 09:29:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memcg/cgroup: do not fail fail on pre_destroy callbacks
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>

(2012/10/17 22:30), Michal Hocko wrote:
> Hi,
> memcg is the only controller which might fail in its pre_destroy
> callback which makes the cgroup core more complicated for no good
> reason. This is an attempt to change this unfortunate state.
> 
> I am sending this a RFC because I would like to hear back whether the
> approach is correct. I thought that the changes would be more invasive
> but it seems that the current code was mostly prepared for this and it
> needs just some small tweaks (so I might be missing something important
> here).
> 
> The first two patches are just clean ups. They could be merged even
> without the rest.
> 
> The real change, although the code is not changed that much, is the 3rd
> patch. It changes the way how we handle mem_cgroup_move_parent failures.
> We have to realize that all those failures are *temporal*. Because we
> are either racing with the page removal or the page is temporarily off
> the LRU because of migration resp. global reclaim. As a result we do
> not fail mem_cgroup_force_empty_list if the page cannot be moved to the
> parent and rather retry until the LRU is empty.
> 
> The 4th patch is for cgroup core. I have moved cgroup_call_pre_destroy
> inside the cgroup_lock which is not very nice because the callbacks
> can take some time. Maybe we can move this call at the very end of the
> function?
> All I need for memcg is that cgroup_call_pre_destroy has been called and
> that no new cgroups can be attached to the group. The cgroup_lock is
> necessary for the later condition but if we move after CGRP_REMOVED flag
> is set then we are safe as well.
> 
> The last two patches are trivial follow ups for the cgroups core change
> because now we know that nobody will interfere with us so we can drop
> those empty && no child condition.
> 
> Comments, thoughts?
> 
> Michal Hocko (6):
>        memcg: split mem_cgroup_force_empty into reclaiming and reparenting parts
>        memcg: root_cgroup cannot reach mem_cgroup_move_parent
>        memcg: Simplify mem_cgroup_force_empty_list error handling
>        cgroups: forbid pre_destroy callback to fail
>        memcg: make mem_cgroup_reparent_charges non failing
>        hugetlb: do not fail in hugetlb_cgroup_pre_destroy
> 
> Cumulative diffstat:
>   kernel/cgroup.c     |   30 ++++---------
>   mm/hugetlb_cgroup.c |   11 ++---
>   mm/memcontrol.c     |  124 +++++++++++++++++++++++++++------------------------
>   3 files changed, 78 insertions(+), 87 deletions(-)

Thank you very much ! The whole patch seems good to me and I like this approach.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id DB4236B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:26:55 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id q58so16010334wes.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:26:55 -0800 (PST)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id w4si4022281wju.37.2015.01.15.09.26.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 09:26:55 -0800 (PST)
Received: by mail-wg0-f49.google.com with SMTP id n12so16259495wgh.8
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:26:55 -0800 (PST)
Date: Thu, 15 Jan 2015 18:26:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150115172652.GF7008@dhcp22.suse.cz>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <20150110214316.GF25319@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150110214316.GF25319@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Sat 10-01-15 16:43:16, Tejun Heo wrote:
> Currently, if a hierarchy doesn't have any live children when it's
> unmounted, the hierarchy starts dying by killing its refcnt.  The
> expectation is that even if there are lingering dead children which
> are lingering due to remaining references, they'll be put in a finite
> amount of time.  When the children are finally released, the hierarchy
> is destroyed and all controllers bound to it also are released.
> 
> However, for memcg, the premise that the lingering refs will be put in
> a finite amount time is not true.  In the absense of memory pressure,
> dead memcg's may hang around indefinitely pinned by its pages.  This
> unfortunately may lead to indefinite hang on the next mount attempt
> involving memcg as the mount logic waits for it to get released.
> 
> While we can change hierarchy destruction logic such that a hierarchy
> is only destroyed when it's not mounted anywhere and all its children,
> live or dead, are gone, this makes whether the hierarchy gets
> destroyed or not to be determined by factors opaque to userland.
> Userland may or may not get a new hierarchy on the next mount attempt.
> Worse, if it explicitly wants to create a new hierarchy with different
> options or controller compositions involving memcg, it will fail in an
> essentially arbitrary manner.
> 
> We want to guarantee that a hierarchy is destroyed once the
> conditions, unmounted and no visible children, are met.  To aid it,
> this patch introduces a new callback cgroup_subsys->unbind() which is
> invoked right before the hierarchy a subsystem is bound to starts
> dying.  memcg can implement this callback and initiate draining of
> remaining refs so that the hierarchy can eventually be released in a
> finite amount of time.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vladimir Davydov <vdavydov@parallels.com>

Ohh, I have missed this one as I wasn't on the CC list.

FWIW this approach makes sense to me. I just think that we should have a
way to fail. E.g. kmem pages are impossible to reclaim because there
might be some objects lingering somewhere not bound to a task context
and reparenting is hard as Vladimir has pointed out several times
already.
Normal LRU pages should be reclaimable or reparented to the root easily.

I cannot judge the implementation but I agree with the fact that memcg
controller should be the one to take an action.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

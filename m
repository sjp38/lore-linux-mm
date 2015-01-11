Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7B86B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 15:55:58 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so16021002wes.13
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 12:55:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hs6si31871436wjb.68.2015.01.11.12.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Jan 2015 12:55:57 -0800 (PST)
Date: Sun, 11 Jan 2015 15:55:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150111205543.GA5480@phnom.home.cmpxchg.org>
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
Cc: Vladimir Davydov <vdavydov@parallels.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Sat, Jan 10, 2015 at 04:43:16PM -0500, Tejun Heo wrote:
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
> ---
> Hello,
> 
> > May be, we should kill the ref counter to the memory controller root in
> > cgroup_kill_sb only if there is no children at all, neither online nor
> > offline.
> 
> Ah, thanks for the analysis, but I really wanna avoid making hierarchy
> destruction conditions opaque to userland.  This is userland visible
> behavior.  It shouldn't be determined by kernel internals invisible
> outside.  This patch adds ss->unbind() which memcg can hook into to
> kick off draining of residual refs.  If this would work, I'll add this
> patch to cgroup/for-3.19-fixes, possibly with stable cc'd.

How about this ->unbind() for memcg?

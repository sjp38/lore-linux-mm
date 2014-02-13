Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id B4E236B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 19:28:57 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so14922183qaq.25
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:28:57 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id o46si13216qgo.158.2014.02.12.16.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 16:28:57 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id k4so15242868qaq.15
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:28:56 -0800 (PST)
Date: Wed, 12 Feb 2014 19:28:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] cgroup: bring back kill_cnt to order css destruction
Message-ID: <20140213002853.GC2916@htj.dyndns.org>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207164321.GE6963@cmpxchg.org>
 <alpine.LSU.2.11.1402121417230.5029@eggly.anvils>
 <alpine.LSU.2.11.1402121504150.5029@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402121504150.5029@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Hugh.

On Wed, Feb 12, 2014 at 03:06:26PM -0800, Hugh Dickins wrote:
> Sometimes the cleanup after memcg hierarchy testing gets stuck in
> mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> 
> There may turn out to be several causes, but a major cause is this: the
> workitem to offline parent can get run before workitem to offline child;
> parent's mem_cgroup_reparent_charges() circles around waiting for the
> child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> which prevents the child from reaching its mem_cgroup_reparent_charges().
> 
> Further testing showed that an ordered workqueue for cgroup_destroy_wq
> is not always good enough: percpu_ref_kill_and_confirm's call_rcu_sched
> stage on the way can mess up the order before reaching the workqueue.
> 
> Instead bring back v3.11's css kill_cnt, repurposing it to make sure
> that offline_css() is not called for parent before it has been called
> for all children.
> 
> Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: Filipe Brandenburger <filbranden@google.com>
> Cc: stable@vger.kernel.org # v3.10+ (but will need extra care)
> ---
> This is an alternative to Filipe's 1/2: there's no need for both,
> but each has its merits.  I prefer Filipe's, which is much easier to
> understand: this one made more sense in v3.11, when it was just a matter
> of extending the use of css_kill_cnt; but might be preferred if offlining
> children before parent is thought to be a good idea generally.

Not that your implementation is bad or anything but the patch itself
somehow makes me cringe a bit.  It's probably just because it has to
add to the already overly complicated offline path.  Guaranteeing
strict offline ordering might be a good idea but at least for the
immediate bug fix, I agree that the memcg specific fix seems better
suited.  Let's apply that one and reconsider this one if it turns out
we do need strict offline reordering.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B34026B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:20:27 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md12so366776pbc.30
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 01:20:26 -0700 (PDT)
Date: Wed, 5 Jun 2013 01:20:23 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605082023.GG7303@mtj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605073023.GB15997@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello, Michal.

On Wed, Jun 05, 2013 at 09:30:23AM +0200, Michal Hocko wrote:
> > I don't really get that.  As long as the amount is bound and the
> > overhead negligible / acceptable, why does it matter how long the
> > pinning persists? 
> 
> Because the amount is not bound either. Just create a hierarchy and
> trigger the hard limit and if you are careful enough you can always keep
> some of the children in the cached pointer (with css reference, if you
> will) and then release the hierarchy. You can do that repeatedly and
> leak considerable amount of memory.

It's still bound, no?  Each live memcg can only keep limited number of
cgroups cached, right?

> > We aren't talking about something gigantic or can
> 
> mem_cgroup is 888B now (depending on configuration). So I wouldn't call
> it negligible.

Do you think that the number can actually grow harmful?  Would you be
kind enough to share some calculations with me?

> > In the off chance that this is a real problem, which I strongly doubt,
> > as I wrote to Johannes, we can implement extremely dumb cleanup
> > routine rather than this weak reference beast.
> 
> That was my first version (https://lkml.org/lkml/2013/1/3/298) and
> Johannes didn't like. To be honest I do not care _much_ which way we go
> but we definitely cannot pin those objects for ever.

I'll get to the barrier thread but really complex barrier dancing like
that is only justifiable in extremely hot paths a lot of people pay
attention to.  It doesn't belong inside memcg proper.  If the cached
amount is an actual concern, let's please implement a simple clean up
thing.  All we need is a single delayed_work which scans the tree
periodically.

Johannes, what do you think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

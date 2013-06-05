Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 72BED6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:45:00 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w16so1500578pde.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 01:44:59 -0700 (PDT)
Date: Wed, 5 Jun 2013 01:44:56 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605084456.GA7990@mtj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605083628.GE15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605083628.GE15997@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hey,

On Wed, Jun 05, 2013 at 10:36:28AM +0200, Michal Hocko wrote:
> > It's still bound, no?  Each live memcg can only keep limited number of
> > cgroups cached, right?
> 
> Assuming that they are cleaned up when the memcg is offlined then yes.

Oh yeah, that's just me being forgetful.  We definitely need to clean
it up on offlining.

> > Do you think that the number can actually grow harmful?  Would you be
> > kind enough to share some calculations with me?
> 
> Well, each intermediate node might pin up-to NR_NODES * NR_ZONES *
> NR_PRIORITY groups. You would need a big hierarchy to have chance to
> cache different groups so that it starts matter.

Yeah, NR_NODES can be pretty big.  I'm still not sure whether this
would be a problem in practice but yeah it can grow pretty big.

> And do what? css_try_get to find out whether the cached memcg is still

Hmmm? It can just look at the timestamp and if too old do

	cached = xchg(&iter->hint, NULL);
	if (cached)
		css_put(cached);

> alive. Sorry, I do not like it at all. I find it much better to clean up
> when the group is removed. Because doing things asynchronously just
> makes it more obscure. There is no reason to do such a thing on the
> background when we know _when_ to do the cleanup and that is definitely
> _not a hot path_.

Yeah, that's true.  I just wanna avoid the barrier dancing.  Only one
of the ancestors can cache a memcg, right?  Walking up the tree
scanning for cached ones and putting them should work?  Is that what
you were suggesting?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

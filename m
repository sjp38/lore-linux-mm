Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3CF296B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:36:31 -0400 (EDT)
Date: Wed, 5 Jun 2013 10:36:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605083628.GE15997@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605082023.GG7303@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed 05-06-13 01:20:23, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Jun 05, 2013 at 09:30:23AM +0200, Michal Hocko wrote:
> > > I don't really get that.  As long as the amount is bound and the
> > > overhead negligible / acceptable, why does it matter how long the
> > > pinning persists? 
> > 
> > Because the amount is not bound either. Just create a hierarchy and
> > trigger the hard limit and if you are careful enough you can always keep
> > some of the children in the cached pointer (with css reference, if you
> > will) and then release the hierarchy. You can do that repeatedly and
> > leak considerable amount of memory.
> 
> It's still bound, no?  Each live memcg can only keep limited number of
> cgroups cached, right?

Assuming that they are cleaned up when the memcg is offlined then yes.

> > > We aren't talking about something gigantic or can
> > 
> > mem_cgroup is 888B now (depending on configuration). So I wouldn't call
> > it negligible.
> 
> Do you think that the number can actually grow harmful?  Would you be
> kind enough to share some calculations with me?

Well, each intermediate node might pin up-to NR_NODES * NR_ZONES *
NR_PRIORITY groups. You would need a big hierarchy to have chance to
cache different groups so that it starts matter.

The problem is the clean up though. It might be a simple object at the
time when it never gets freed. So there _must_ be something that would
release the css reference to free the associated resources. As I said
this can be done either during css_offline or in a lazy fashion that we
have currently. I really do not care much which way it is done.

> > > In the off chance that this is a real problem, which I strongly doubt,
> > > as I wrote to Johannes, we can implement extremely dumb cleanup
> > > routine rather than this weak reference beast.
> > 
> > That was my first version (https://lkml.org/lkml/2013/1/3/298) and
> > Johannes didn't like. To be honest I do not care _much_ which way we go
> > but we definitely cannot pin those objects for ever.
> 
> I'll get to the barrier thread but really complex barrier dancing like
> that is only justifiable in extremely hot paths a lot of people pay
> attention to.  It doesn't belong inside memcg proper.  If the cached
> amount is an actual concern, let's please implement a simple clean up
> thing.  All we need is a single delayed_work which scans the tree
> periodically.

And do what? css_try_get to find out whether the cached memcg is still
alive. Sorry, I do not like it at all. I find it much better to clean up
when the group is removed. Because doing things asynchronously just
makes it more obscure. There is no reason to do such a thing on the
background when we know _when_ to do the cleanup and that is definitely
_not a hot path_.

> Johannes, what do you think?
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

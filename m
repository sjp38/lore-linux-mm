Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B5F476B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 03:30:26 -0400 (EDT)
Date: Wed, 5 Jun 2013 09:30:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605073023.GB15997@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604215535.GM14916@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Tue 04-06-13 14:55:35, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Jun 04, 2013 at 11:28:08PM +0200, Michal Hocko wrote:
> > Well, I do not mind pinning when I know that somebody releases the
> > reference in a predictable future (ideally almost immediately). But the
> > cached iter represents time unbounded pinning because nobody can
> > guarantee that priority 3 at zone Normal at node 3 will be ever scanned
> > again and the pointer in the last_visited node will be stuck there for
> 
> I don't really get that.  As long as the amount is bound and the
> overhead negligible / acceptable, why does it matter how long the
> pinning persists? 

Because the amount is not bound either. Just create a hierarchy and
trigger the hard limit and if you are careful enough you can always keep
some of the children in the cached pointer (with css reference, if you
will) and then release the hierarchy. You can do that repeatedly and
leak considerable amount of memory.

> We aren't talking about something gigantic or can

mem_cgroup is 888B now (depending on configuration). So I wouldn't call
it negligible.

> leak continuously.  It will only matter iff cgroups are continuously
> created and destroyed and each live memcg will be able to pin one
> memcg (BTW, I think I forgot to unpin on memcg destruction).
> 
> > eternity. Can we free memcg with only css elevated and safely check that
> > the cached pointer can be used without similar dances we have now?
> > I am open to any suggestions.
> 
> I really think this is worrying too much about something which doesn't
> really matter and then coming up with an over-engineered solution for
> the imagined problem.  This isn't a real problem.  No solution is
> necessary.
> 
> In the off chance that this is a real problem, which I strongly doubt,
> as I wrote to Johannes, we can implement extremely dumb cleanup
> routine rather than this weak reference beast.

That was my first version (https://lkml.org/lkml/2013/1/3/298) and
Johannes didn't like. To be honest I do not care _much_ which way we go
but we definitely cannot pin those objects for ever.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

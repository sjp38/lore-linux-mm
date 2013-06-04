Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 87D206B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 17:41:07 -0400 (EDT)
Date: Tue, 4 Jun 2013 17:40:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130604214050.GP15576@cmpxchg.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604205025.GG14916@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Tue, Jun 04, 2013 at 01:50:25PM -0700, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Jun 04, 2013 at 03:18:43PM +0200, Michal Hocko wrote:
> > > +	if (memcg)
> > > +		css_get(&memcg->css);
> > 
> > This is all good and nice but it re-introduces the same problem which
> > has been fixed by (5f578161: memcg: relax memcg iter caching). You are
> > pinning memcg in memory for unbounded amount of time because css
> > reference will not let object to leave and rest.
> 
> I don't get why that is a problem.  Can you please elaborate?  css's
> now explicitly allow holding onto them.  We now have clear separation
> of "destruction" and "release" and blkcg also depends on it.  If memcg
> still doesn't distinguish the two properly, that's where the problem
> should be fixed.
> 
> > I understand your frustration about the complexity of the current
> > synchronization but we didn't come up with anything easier.
> > Originally I though that your tree walk updates which allow dropping rcu
> > would help here but then I realized that not really because the iterator
> > (resp. pos) has to be a valid pointer and there is only one possibility
> > to do that AFAICS here and that is css pinning. And is no-go.
> 
> I find the above really weird.  If css can't be pinned for position
> caching, isn't it natural to ask why it can't be and then fix it?
> Because that's what the whole refcnt thing is about and a usage which
> cgroup explicitly allows (e.g. blkcg also does it).  Why do you go
> from there to "this batshit crazy barrier dancing is the only
> solution"?
> 
> Can you please explain why memcg css's can't be pinned?

We might pin them indefinitely.  In a hierarchy with hundreds of
groups that is short by 10M of memory, we only reclaim from a couple
of groups before we stop and leave the iterator pointing somewhere in
the hierarchy.  Until the next reclaimer comes along, which might be a
split second later or three days later.

There is a reclaim iterator for every memcg (since every memcg
represents a hierarchy), so we could pin a lot of csss for an
indefinite amount of time.

If you say that the delta between destruction and release is small
enough, I'd be happy to get rid of the weak referencing.

We had weak referencing with css_id before and didn't want to lose
predictability and efficiency of our resource usage when switching
away from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

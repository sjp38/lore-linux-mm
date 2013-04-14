Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C9B386B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 10:56:24 -0400 (EDT)
Date: Sun, 14 Apr 2013 10:55:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130414145532.GB5701@cmpxchg.org>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
 <20130414004252.GA1330@suse.de>
 <20130414143420.GA6478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130414143420.GA6478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>

On Sun, Apr 14, 2013 at 07:34:20AM -0700, Michal Hocko wrote:
> On Sun 14-04-13 01:42:52, Mel Gorman wrote:
> > On Tue, Apr 09, 2013 at 02:13:13PM +0200, Michal Hocko wrote:
> > > @@ -1961,6 +1973,13 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > >  		do {
> > >  			struct lruvec *lruvec;
> > >  
> > > +			if (soft_reclaim &&
> > > +					!mem_cgroup_soft_reclaim_eligible(memcg)) {
> > > +				memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > > +				continue;
> > > +			}
> > > +
> > 
> > Calling mem_cgroup_soft_reclaim_eligible means we do multiple searches
> > of the hierarchy while ascending the hierarchy. It's a stretch but it
> > may be a problem for very deep hierarchies.
> 
> I think it shouldn't be a problem for hundreds of memcgs and I am quite
> sceptical about such configurations for other reasons (e.g. charging
> overhead). And we are in the reclaim path so this is hardly a hot path
> (unlike the chargin). So while this might turn out to be a real problem
> we would need to fix other parts as well with higher priority.
> 
> > Would it be worth having mem_cgroup_soft_reclaim_eligible return what
> > the highest parent over its soft limit was and stop the iterator when
> > the highest parent is reached?  I think this would avoid calling
> > mem_cgroup_soft_reclaim_eligible multiple times.
> 
> This is basically what the original implementation did and I think it is
> not the right way to go. First why should we care who is the most
> exceeding group. We should treat them equally if the there is no special
> reason to not do so. And I do not see such a special reason. Besides
> that keeping a exceed sorted data structure of memcgs turned out quite a
> lot of code. Note that the later patch integrate soft reclaim into
> targeted reclaim which would mean that we would have to keep such a
> list/tree per memcg.

I think what Mel suggests is not to return the highest excessor, but
return the highest parent in the hierarchy that is in excess.  Once
you have this parent, you know that all children are in excess,
without looking them up individually.

However, that parent is not necessarily the root of the hierarchy that
is being reclaimed and you might have multiple of such sub-hierarchies
in excess.  To handle all the corner cases, I'd expect the
relationship checking to get really complicated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

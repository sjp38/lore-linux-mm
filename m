Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id ACD4C9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 09:07:00 -0400 (EDT)
Date: Mon, 19 Sep 2011 15:06:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/11] mm: memcg: consolidate hierarchy iteration
 primitives
Message-ID: <20110919130656.GD21847@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-2-git-send-email-jweiner@redhat.com>
 <20110912223746.GA20765@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110912223746.GA20765@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 13-09-11 01:37:46, Kirill A. Shutemov wrote:
> On Mon, Sep 12, 2011 at 12:57:18PM +0200, Johannes Weiner wrote:
[...]
> >  	while (1) {
> > -		victim = mem_cgroup_select_victim(root_memcg);
> > -		if (victim == root_memcg) {
> > +		victim = mem_cgroup_iter(root_memcg, victim, true);
> > +		if (!victim) {
> >  			loop++;
> >  			/*
> >  			 * We are not draining per cpu cached charges during
> > @@ -1689,10 +1644,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
> >  				 * anything, it might because there are
> >  				 * no reclaimable pages under this hierarchy
> >  				 */
> > -				if (!check_soft || !total) {
> > -					css_put(&victim->css);
> > +				if (!check_soft || !total)
> >  					break;
> > -				}
> >  				/*
> >  				 * We want to do more targeted reclaim.
> >  				 * excess >> 2 is not to excessive so as to
> > @@ -1700,15 +1653,13 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
> >  				 * coming back to reclaim from this cgroup
> >  				 */
> >  				if (total >= (excess >> 2) ||
> > -					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
> > -					css_put(&victim->css);
> > +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> >  					break;
> > -				}
> >  			}
> > +			continue;
> 
> Souldn't we do
> 
> victim = root_memcg;
> 
> instead?

You want to save mem_cgroup_iter call?
Yes it will work... I am not sure it is really an improvement. If we
just continue we can rely on mem_cgroup_iter doing the right thing.
Assignment might be not that obvious. But I dunno. 
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

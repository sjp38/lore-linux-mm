Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF57E9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:57:45 -0400 (EDT)
Date: Wed, 21 Sep 2011 15:57:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 08/11] mm: vmscan: convert global reclaim to per-memcg
 LRU lists
Message-ID: <20110921135741.GF8501@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-9-git-send-email-jweiner@redhat.com>
 <20110921131045.GD8501@tiehlicka.suse.cz>
 <20110921135142.GE22516@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110921135142.GE22516@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-09-11 15:51:43, Johannes Weiner wrote:
> On Wed, Sep 21, 2011 at 03:10:45PM +0200, Michal Hocko wrote:
> > On Mon 12-09-11 12:57:25, Johannes Weiner wrote:
[...]
> > > @@ -2451,13 +2445,24 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> > >  static void age_active_anon(struct zone *zone, struct scan_control *sc,
> > >  			    int priority)
> > >  {
> > > -	struct mem_cgroup_zone mz = {
> > > -		.mem_cgroup = NULL,
> > > -		.zone = zone,
> > > -	};
> > > +	struct mem_cgroup *mem;
> > > +
> > > +	if (!total_swap_pages)
> > > +		return;
> > > +
> > > +	mem = mem_cgroup_iter(NULL, NULL, NULL);
> > 
> > Wouldn't be for_each_mem_cgroup more appropriate? Macro is not exported
> > but probably worth exporting? The same applies for
> > scan_zone_unevictable_pages from the previous patch.
> 
> Unfortunately, in generic code, these loops need to be layed out like
> this for !CONFIG_MEMCG to do the right thing.  mem_cgroup_iter() will
> return NULL and the loop has to execute exactly once.

Ahh, right you are. I have missed that.

> 
> This is something that will go away once we implement Christoph's
> suggestion of always having a (skeleton) root_mem_cgroup around, even
> for !CONFIG_MEMCG.

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

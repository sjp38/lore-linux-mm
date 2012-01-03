Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5317F6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 06:05:20 -0500 (EST)
Date: Tue, 3 Jan 2012 12:05:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
Message-ID: <20120103110516.GK7910@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
 <alpine.LSU.2.00.1112312329240.18500@eggly.anvils>
 <20120102125913.GG7910@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1201021104160.1854@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1201021104160.1854@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Mon 02-01-12 11:43:27, Hugh Dickins wrote:
> On Mon, 2 Jan 2012, Michal Hocko wrote:
> > On Sat 31-12-11 23:30:38, Hugh Dickins wrote:
> > > I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
> > > to obscure the LRU counts.  For easier searching?  So call it
> > > lru_size rather than bare count (lru_length sounds better, but
> > > would be wrong, since each huge page raises lru_size hugely).
> > 
> > lru_size is unique at the global scope at the moment but this might
> > change in the future. MEM_CGROUP_ZSTAT should be unique and so easier
> > to grep or cscope. 
> > On the other hand lru_size sounds like a better name so I am all for
> > renaming but we should make sure that we somehow get memcg into it
> > (either to macro MEM_CGROUP_LRU_SIZE or get rid of macro and have
> > memcg_lru_size field name - which is ugly long).
> 
> I do disagree.  You're asking to introduce artificial differences,
> whereas generally we're trying to minimize the differences between
> global and memcg.

I am not asking to _introduce_ a new artificial difference I just wanted
to make memcg lru accounting obvious. 
Currently, if I want to check that we account correctly I cscope/grep
__mod_zone_page_state on the global level and we have MEM_CGROUP_ZSTAT
for the memcg. If you remove the macro then it would be little bit
harder (it won't actually because lru_size is unique at the moment it is
just not that obvious).

> I'm happy with the way mem_cgroup_zone_lruvec(), for example, returns
> a pointer to the relevant structure, whether it's global or per-memcg,
> and we then work with the contents of that structure, whichever it is:
> lruvec in each case, not global_lruvec in one case and memcg_lruvec
> in the other.

Yes, I like it as well but we do not account the same way for memcg and
global.

Anyway, I do not have any strong opinion about the macro. Nevertheless,
I definitely like the count->lru_size renaming.

Thanks
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

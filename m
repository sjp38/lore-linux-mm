Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 252FF6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 02:21:13 -0400 (EDT)
Date: Tue, 10 Jul 2012 08:21:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 08/11] mm: memcg: remove needless !mm fixup to init_mm
 when charging
Message-ID: <20120710062104.GA19223@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-9-git-send-email-hannes@cmpxchg.org>
 <20120709152058.GK4627@tiehlicka.suse.cz>
 <20120710061021.GA6096@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120710061021.GA6096@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 10-07-12 14:10:21, Wanpeng Li wrote:
> On Mon, Jul 09, 2012 at 05:20:58PM +0200, Michal Hocko wrote:
> >On Thu 05-07-12 02:45:00, Johannes Weiner wrote:
> >> It does not matter to __mem_cgroup_try_charge() if the passed mm is
> >> NULL or init_mm, it will charge the root memcg in either case.
> 
> You can also change the comment in __mem_cgroup_try_charge :
> 
> "if so charge the init_mm" => "if so charge the root memcg"

This is already in place:
"
If mm is NULL and the caller doesn't pass a valid memcg pointer, that is
treated as a charge to root_mem_cgroup.
"
> 
> >> 
> >> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >
> >Acked-by: Michal Hocko <mhocko@suse.cz>
> >
> >> ---
> >>  mm/memcontrol.c |    5 -----
> >>  1 files changed, 0 insertions(+), 5 deletions(-)
> >> 
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 418b47d..6fe4101 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -2766,8 +2766,6 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> >>  		ret = 0;
> >>  	return ret;
> >>  charge_cur_mm:
> >> -	if (unlikely(!mm))
> >> -		mm = &init_mm;
> >>  	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
> >>  	if (ret == -EINTR)
> >>  		ret = 0;
> >> @@ -2832,9 +2830,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >>  	if (PageCompound(page))
> >>  		return 0;
> >>  
> >> -	if (unlikely(!mm))
> >> -		mm = &init_mm;
> >> -
> >>  	if (!PageSwapCache(page))
> >>  		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> >>  	else { /* page is swapcache/shmem */
> >> -- 
> >> 1.7.7.6
> >> 
> >
> >-- 
> >Michal Hocko
> >SUSE Labs
> >SUSE LINUX s.r.o.
> >Lihovarska 1060/12
> >190 00 Praha 9    
> >Czech Republic
> >--
> >To unsubscribe from this list: send the line "unsubscribe cgroups" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

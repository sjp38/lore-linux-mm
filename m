Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 488976B02C1
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 05:47:02 -0500 (EST)
Date: Wed, 14 Dec 2011 11:46:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
Message-ID: <20111214104658.GB11786@tiehlicka.suse.cz>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
 <20111213162126.GE30440@tiehlicka.suse.cz>
 <CALWz4iwHVMK_k5bxP_m1E8Ugq_FE5XTzHDNi7A8CRhkWHG_Z9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwHVMK_k5bxP_m1E8Ugq_FE5XTzHDNi7A8CRhkWHG_Z9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Tue 13-12-11 10:43:16, Ying Han wrote:
> On Tue, Dec 13, 2011 at 8:21 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 12-12-11 18:16:27, Ying Han wrote:
> >> In __mem_cgroup_try_charge() function, the parameter "oom" is passed from the
> >> caller indicating whether or not the charge should enter memcg oom kill. In
> >> fact, we should be able to eliminate that by using the existing gfp_mask and
> >> __GFP_NORETRY flag.
> >>
> >> This patch removed the "oom" parameter, and add the __GFP_NORETRY flag into
> >> gfp_mask for those doesn't want to enter memcg oom. There is no functional
> >> change for those setting false to "oom" like mem_cgroup_move_parent(), but
> >> __GFP_NORETRY now is checked for those even setting true to "oom".
> >>
> >> The __GFP_NORETRY is used in page allocator to bypass retry and oom kill. I
> >> believe there is a reason for callers to use that flag, and in memcg charge
> >> we need to respect it as well.
> >
> > What is the reason for this change?
> > To be honest it makes the oom condition more obscure. __GFP_NORETRY
> > documentation doesn't say anything about OOM and one would have to know
> > details about allocator internals to follow this.
> > So I am not saying the patch is bad but I would need some strong reason
> > to like it ;)
> 
> Thank you for looking into this :)
> 
> This patch was made as part of the effort solving the livelock issue.
> Then it becomes a separate question by itself.
> 
> I don't quite understand the mismatch on gfp_mask = __GFP_NORETRY &&
> oom_check == true. 

__GFP_NORETRY is a global thingy (because page allocator is global)
while oom_check is internal memcg and it says that we do not want to go
into oom because we cannot charge, consider THP for example. We do not
want to OOM because we would go over hard limit and we rather want to
fallback into a single page allocation.

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

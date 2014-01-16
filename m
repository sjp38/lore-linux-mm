Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id CD9466B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:23:01 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so1210505eak.39
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:23:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si15227097eeo.242.2014.01.16.07.23.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 07:23:00 -0800 (PST)
Date: Thu, 16 Jan 2014 16:22:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140116152259.GG28157@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
 <20140114132727.GB32227@dhcp22.suse.cz>
 <20140114142610.GF32227@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz>
 <20140115121728.GJ8782@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401151241280.9004@eggly.anvils>
 <20140116081738.GA28157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140116081738.GA28157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-01-14 09:17:38, Michal Hocko wrote:
> On Wed 15-01-14 13:24:34, Hugh Dickins wrote:
> > On Wed, 15 Jan 2014, Michal Hocko wrote:
[...]
> > > From 560924e86059947ab9418732cb329ad149dd8f6a Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Wed, 15 Jan 2014 11:52:09 +0100
> > > Subject: [PATCH] memcg: fix css reference leak from mem_cgroup_iter
> > > 
> > > 19f39402864e (memcg: simplify mem_cgroup_iter) has introduced a css
> > > refrence leak (thus memory leak) because mem_cgroup_iter makes sure it
> > > doesn't put a css reference on the root of the tree walk. The mentioned
> > > commit however dropped the root check when the css reference is taken
> > > while it keept the css_put optimization fora the root in place.
> > > 
> > > This means that css_put is not called and so css along with mem_cgroup
> > > and other cgroup internal object tied by css lifetime are never freed.
> > > 
> > > Fix the issue by reintroducing root check in __mem_cgroup_iter_next.
> > > 
> > > This patch also fixes issue reported by Hugh Dickins when
> > > mem_cgroup_iter might end up in an endless loop because a group which is
> > > under hard limit reclaim is removed in parallel with iteration.
> > > __mem_cgroup_iter_next would always return NULL because css_tryget on
> > > the root (reclaimed memcg) would fail and there are no other memcg in
> > > the hierarchy. prev == NULL in mem_cgroup_iter would prevent break out
> > > from the root and so the while (!memcg) loop would never terminate.
> > > as css_tryget is no longer called for the root of the tree walk this
> > > doesn't happen anymore.
> > > 
> > > Cc: stable@vger.kernel.org # 3.10+
> > > Reported-and-debugged-by: Hugh Dickins <hughd@google.com>
> > 
> > Definitely not debugged by me!  Debugged and understood by you.
> 
> You still have debugged the second part of the problem (endless loop).
> But I will go with whatever tag you like.
> 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > ---
> > >  mm/memcontrol.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index f016d26adfd3..dd3974c9f08d 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1078,7 +1078,8 @@ skip_node:
> > >  	 * protected by css_get and the tree walk is rcu safe.
> > >  	 */
> > >  	if (next_css) {
> > > -		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
> > > +		if ((next_css->flags & CSS_ONLINE) &&
> > > +				(next_css == root || css_tryget(next_css)))
> > 
> > Not quite: next_css points to one thing and root to another.
> 
> Dohh, right you are next_css == root->css. I was wondering how I was
> able to see the leak being fixed and then realized that root->css has
> the same address as root...
> Anyway very well spotted.
> 
> > >  			return mem_cgroup_from_css(next_css);
> > >  		else {
> > >  			prev_css = next_css;
> > > -- 
> > 
> > This is how I've re-written that block, and started testing on it;
> > the unnecessary "else {" part was looking increasingly ugly to me
> > (though let loose on it, I might change it all around more...)
> > 
> > 	if (next_css) {
> > 		if ((next_css->flags & CSS_ONLINE) &&
> > 		    (next_css == &root->css || css_tryget(next_css)))
> > 			return mem_cgroup_from_css(next_css);
> > 		prev_css = next_css;
> > 		goto skip_node;
> > 	}
> 
> Yes, that looks better. Maybe put a blank line before prev_css = next_css?
> 
> > Sorry for being so slow to respond, by the way: for a couple of hours
> > I couldn't test at all, and thought I was going mad - one day I send
> > you that "cg" script, the next day it starts to break, it couldn't
> > "mkdir -p /cg/cg", claiming it already existed, wha???  Turns out the
> > fix for that has gone into yesterday's mmotm (though I've not had time
> > to move on to that yet): uninitialized ret in memcg_propagate_kmem().
> 
> Thanks a lot!

What about this? I have incorporated your root->css fix and else removal
+ added a comment to clarify importance of root css refcount exclusion.
I still prefer this going to the stable separately from CSS_ONLINE fix.
---

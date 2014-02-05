Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1B74C6B0031
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 08:49:59 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x55so314667wes.33
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 05:49:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp10si15119967wjb.12.2014.02.05.05.49.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 05:49:57 -0800 (PST)
Date: Wed, 5 Feb 2014 14:49:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 1/6] memcg: do not replicate
 try_get_mem_cgroup_from_mm in __mem_cgroup_try_charge
Message-ID: <20140205134956.GC2425@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-2-git-send-email-mhocko@suse.cz>
 <20140204155508.GM6963@cmpxchg.org>
 <20140204160521.GM4890@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140204160521.GM4890@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 04-02-14 17:05:21, Michal Hocko wrote:
> On Tue 04-02-14 10:55:08, Johannes Weiner wrote:
> > On Tue, Feb 04, 2014 at 02:28:55PM +0100, Michal Hocko wrote:
> > > Johannes Weiner has pointed out that __mem_cgroup_try_charge duplicates
> > > try_get_mem_cgroup_from_mm for charges which came without a memcg. The
> > > only reason seems to be a tiny optimization when css_tryget is not
> > > called if the charge can be consumed from the stock. Nevertheless
> > > css_tryget is very cheap since it has been reworked to use per-cpu
> > > counting so this optimization doesn't give us anything these days.
> > > 
> > > So let's drop the code duplication so that the code is more readable.
> > > While we are at it also remove a very confusing comment in
> > > try_get_mem_cgroup_from_mm.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > ---
> > >  mm/memcontrol.c | 49 ++++++++-----------------------------------------
> > >  1 file changed, 8 insertions(+), 41 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 53385cd4e6f0..042e4ff36c05 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1081,11 +1081,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> > >  
> > >  	if (!mm)
> > >  		return NULL;
> > 
> > While you're at it, this check also seems unnecessary.
> 
> Yes, it will be removed in a later patch. I wanted to have it in a
> separate patch for a better bisectability just in case I have really
> missed mm-might-by-NULL case.

Ohh, I have mixed that with the other mm check. You are right we can
remove this one as well. Thanks and sorry for confusion!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

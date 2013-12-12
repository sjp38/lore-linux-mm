Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 46B866B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 03:44:24 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so51160eak.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 00:44:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si22665581eeo.247.2013.12.12.00.44.23
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 00:44:23 -0800 (PST)
Date: Thu, 12 Dec 2013 09:44:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg, oom: lock mem_cgroup_print_oom_info
Message-ID: <20131212084420.GA2630@dhcp22.suse.cz>
References: <1386776545-24916-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.02.1312111421320.7354@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312111421320.7354@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 11-12-13 14:23:18, David Rientjes wrote:
> On Wed, 11 Dec 2013, Michal Hocko wrote:
> 
> > mem_cgroup_print_oom_info uses a static buffer (memcg_name) to store the
> > name of the cgroup. This is not safe as pointed out by David Rientjes
> > because memcg oom is locked only for its hierarchy and nothing prevents
> > another parallel hierarchy to trigger oom as well and overwrite the
> > already in-use buffer.
> > 
> > This patch introduces oom_info_lock hidden inside mem_cgroup_print_oom_info
> > which is held throughout the function. It make access to memcg_name safe
> > and as a bonus it also prevents parallel memcg ooms to interleave their
> > statistics which would make the printed data hard to analyze otherwise.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks

> 
> > ---
> >  mm/memcontrol.c | 12 +++++++-----
> >  1 file changed, 7 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 28c9221b74ea..c72b03bf9679 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1647,13 +1647,13 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
> >   */
> >  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  {
> > -	struct cgroup *task_cgrp;
> > -	struct cgroup *mem_cgrp;
> >  	/*
> > -	 * Need a buffer in BSS, can't rely on allocations. The code relies
> > -	 * on the assumption that OOM is serialized for memory controller.
> > -	 * If this assumption is broken, revisit this code.
> > +	 * protects memcg_name and makes sure that parallel ooms do not
> > +	 * interleave
> 
> Parallel memcg oom kills can happen in disjoint memcg hierarchies, this 
> just prevents the printing of the statistics from interleaving.  I'm not 
> sure if that's clear from this comment.

What about this instead:
	* Protects memcg_name and makes sure that ooms from parallel
	* hierarchies do not interleave.
?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

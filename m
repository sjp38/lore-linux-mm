Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCCD6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 18:31:55 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so962122yha.40
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 15:31:55 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id f29si28530yhd.70.2013.12.12.15.31.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 15:31:54 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so950201yhz.22
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 15:31:54 -0800 (PST)
Date: Thu, 12 Dec 2013 15:31:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, oom: lock mem_cgroup_print_oom_info
In-Reply-To: <20131212084420.GA2630@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312121528400.17641@chino.kir.corp.google.com>
References: <1386776545-24916-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.02.1312111421320.7354@chino.kir.corp.google.com> <20131212084420.GA2630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 12 Dec 2013, Michal Hocko wrote:

> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 28c9221b74ea..c72b03bf9679 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1647,13 +1647,13 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
> > >   */
> > >  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> > >  {
> > > -	struct cgroup *task_cgrp;
> > > -	struct cgroup *mem_cgrp;
> > >  	/*
> > > -	 * Need a buffer in BSS, can't rely on allocations. The code relies
> > > -	 * on the assumption that OOM is serialized for memory controller.
> > > -	 * If this assumption is broken, revisit this code.
> > > +	 * protects memcg_name and makes sure that parallel ooms do not
> > > +	 * interleave
> > 
> > Parallel memcg oom kills can happen in disjoint memcg hierarchies, this 
> > just prevents the printing of the statistics from interleaving.  I'm not 
> > sure if that's clear from this comment.
> 
> What about this instead:
> 	* Protects memcg_name and makes sure that ooms from parallel
> 	* hierarchies do not interleave.
> ?

I think it would be better to explicitly say that you're referring only to 
the printing here and that we're ensuring it does not interleave in the 
kernel log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

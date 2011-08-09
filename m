Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 135346B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 11:37:38 -0400 (EDT)
Date: Tue, 9 Aug 2011 17:37:32 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110809153732.GC13411@redhat.com>
References: <cover.1310732789.git.mhocko@suse.cz>
 <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
 <20110809140312.GA2265@redhat.com>
 <20110809152218.GK7463@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809152218.GK7463@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Aug 09, 2011 at 05:22:18PM +0200, Michal Hocko wrote:
> On Tue 09-08-11 16:03:12, Johannes Weiner wrote:
> >  	struct mem_cgroup *iter, *failed = NULL;
> >  	bool cond = true;
> >  
> >  	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > -		bool locked = iter->oom_lock;
> > -
> > -		iter->oom_lock = true;
> > -		if (lock_count == -1)
> > -			lock_count = iter->oom_lock;
> > -		else if (lock_count != locked) {
> > +		if (iter->oom_lock) {
> >  			/*
> >  			 * this subtree of our hierarchy is already locked
> >  			 * so we cannot give a lock.
> >  			 */
> > -			lock_count = 0;
> >  			failed = iter;
> >  			cond = false;
> > -		}
> > +		} else
> > +			iter->oom_lock = true;
> >  	}
> >  
> >  	if (!failed)
> 
> We can return here and get rid of done label.

Ah, right you are.  Here is an update.

---

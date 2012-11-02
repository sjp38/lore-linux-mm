Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9AD066B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:19:34 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2548297eek.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 13:19:33 -0700 (PDT)
Date: Fri, 2 Nov 2012 21:19:31 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 23/29] memcg: destroy memcg caches
Message-ID: <20121102201931.GB8899@dhcp22.suse.cz>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
 <1351771665-11076-24-git-send-email-glommer@parallels.com>
 <20121101170548.86e0c7e5.akpm@linux-foundation.org>
 <50937A62.1060105@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50937A62.1060105@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri 02-11-12 11:46:42, Glauber Costa wrote:
> On 11/02/2012 04:05 AM, Andrew Morton wrote:
> > On Thu,  1 Nov 2012 16:07:39 +0400
> > Glauber Costa <glommer@parallels.com> wrote:
> > 
> >> This patch implements destruction of memcg caches. Right now,
> >> only caches where our reference counter is the last remaining are
> >> deleted. If there are any other reference counters around, we just
> >> leave the caches lying around until they go away.
> >>
> >> When that happen, a destruction function is called from the cache
> >> code. Caches are only destroyed in process context, so we queue them
> >> up for later processing in the general case.
> >>
> >>
> >> ...
> >>
> >> @@ -5950,6 +6012,7 @@ static int mem_cgroup_pre_destroy(struct cgroup *cont)
> >>  {
> >>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> >>  
> >> +	mem_cgroup_destroy_all_caches(memcg);
> >>  	return mem_cgroup_force_empty(memcg, false);
> >>  }
> >>  
> > 
> > Conflicts with linux-next cgroup changes.  Looks pretty simple:
> > 
> > 
> > static int mem_cgroup_pre_destroy(struct cgroup *cont)
> > {
> > 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > 	int ret;
> > 
> > 	css_get(&memcg->css);
> > 	ret = mem_cgroup_reparent_charges(memcg);
> > 	mem_cgroup_destroy_all_caches(memcg);
> > 	css_put(&memcg->css);
> > 
> > 	return ret;
> > }
> > 
> 
> There is one significant difference between the code I had and the code
> after your fix up.
> 
> In my patch, caches were destroyed before the call to
> mem_cgroup_force_empty. In the final, version, they are destroyed after it.
> 
> I am here thinking, but I am not sure if this have any significant
> impact... If we run mem_cgroup_destroy_all_caches() before reparenting,
> we'll have shrunk a lot of the pending caches, and we will have less
> pages to reparent. But we only reparent pages in the lru anyway, and
> then expect kmem and remaining umem to match. So *in theory* it should
> be fine.
> 
> Where can I grab your final tree so I can test it and make sure it is
> all good ?

Everything is in the -mm git tree (I tend to take mmots trees if they
compile).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

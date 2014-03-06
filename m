Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B8DA06B0037
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 21:53:27 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id up15so1948889pbc.6
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 18:53:27 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id xn1si3898115pbc.158.2014.03.05.18.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 18:53:26 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id y13so1889819pdi.19
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 18:53:26 -0800 (PST)
Date: Wed, 5 Mar 2014 18:53:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 04/11] mm, memcg: add tunable for oom reserves
In-Reply-To: <20140305131757.ad538637c096266664c45f04@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1403051853010.30075@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <alpine.DEB.2.02.1403041955050.8067@chino.kir.corp.google.com> <20140305131757.ad538637c096266664c45f04@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Wed, 5 Mar 2014, Andrew Morton wrote:

> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -315,6 +315,9 @@ struct mem_cgroup {
> >  	/* OOM-Killer disable */
> >  	int		oom_kill_disable;
> >  
> > +	/* reserves for handling oom conditions, protected by res.lock */
> > +	unsigned long long	oom_reserve;
> 
> Units?  bytes, I assume.
> 

Yes, fixed.

> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> >  
> > @@ -5936,6 +5939,51 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
> >  	return 0;
> >  }
> >  
> > +static int mem_cgroup_resize_oom_reserve(struct mem_cgroup *memcg,
> > +					 unsigned long long new_limit)
> > +{
> > +	struct res_counter *res = &memcg->res;
> > +	u64 limit, usage;
> > +	int ret = 0;
> 
> The code mixes u64's and unsigned long longs in inexplicable ways. 
> Suggest using u64 throughout.
> 

Ok!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4B6326B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 08:08:10 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:08:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120927120806.GA29104@dhcp22.suse.cz>
References: <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
 <50634105.8060302@parallels.com>
 <20120926180124.GA12544@google.com>
 <50634FC9.4090609@parallels.com>
 <20120926193417.GJ12544@google.com>
 <50635B9D.8020205@parallels.com>
 <20120926195648.GA20342@google.com>
 <50635F46.7000700@parallels.com>
 <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50637298.2090904@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 27-09-12 01:24:40, Glauber Costa wrote:
[...]
> About use cases, I've already responded: my containers use case is kmem
> limited. There are people like Michal that specifically asked for
> user-only semantics to be preserved. 

Yes, because we have many users (basically almost all) who care only
about the user memory because that's what occupies the vast majority of
the memory. They usually want to isolate workload which would disrupt
the global memory otherwise (e.g. backup process vs. database). You
really do not want to pay an additional overhead for kmem accounting
here.

> So your question for global vs local switch (that again, doesn't
> exist; only a local *limit* exists) should really be posed in the
> following way:  "Can two different use cases with different needs be
> hosted in the same box?"

I think this is a good and a relevant question. I think this boils down
to whether you want to have trusted and untrusted workloads at the same
machine.
Trusted loads usually only need user memory accounting because kmem
consumption should be really negligible (unless kernel is doing
something really stupid and no kmem limit will help here). 
On the other hand, untrusted workloads can do nasty things that
administrator has hard time to mitigate and setting a kmem limit can
help significantly.

IMHO such a different loads exist on a single machine quite often (Web
server and a back up process as the most simplistic one). The per
hierarchy accounting, therefore, sounds like a good idea without too
much added complexity (actually the only added complexity is in the
proper kmem.limit_in_bytes handling which is a single place).

So I would rather go with per-hierarchy thing.

> > Michal, Johannes, Kamezawa, what are your thoughts?
> >
> waiting! =)

Well, you guys generated a lot of discussion that one has to read
through, didn't you :P

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

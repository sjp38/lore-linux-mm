Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F2A166B005D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:32:37 -0500 (EST)
Date: Fri, 16 Dec 2011 13:32:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v9 1/9] Basic kernel memory functionality for the Memory
 Controller
Message-ID: <20111216123233.GF3122@tiehlicka.suse.cz>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
 <1323676029-5890-2-git-send-email-glommer@parallels.com>
 <20111214170447.GB4856@tiehlicka.suse.cz>
 <4EE9E81E.2090700@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EE9E81E.2090700@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, Johannes Weiner <jweiner@redhat.com>

On Thu 15-12-11 16:29:18, Glauber Costa wrote:
> On 12/14/2011 09:04 PM, Michal Hocko wrote:
> >[Now with the current patch version, I hope]
> >On Mon 12-12-11 11:47:01, Glauber Costa wrote:
[...]
> >>@@ -3848,10 +3862,17 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> >>  	u64 val;
> >>
> >>  	if (!mem_cgroup_is_root(memcg)) {
> >>+		val = 0;
> >>+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> >>+		if (!memcg->kmem_independent_accounting)
> >>+			val = res_counter_read_u64(&memcg->kmem, RES_USAGE);
> >>+#endif
> >>  		if (!swap)
> >>-			return res_counter_read_u64(&memcg->res, RES_USAGE);
> >>+			val += res_counter_read_u64(&memcg->res, RES_USAGE);
> >>  		else
> >>-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
> >>+			val += res_counter_read_u64(&memcg->memsw, RES_USAGE);
> >>+
> >>+		return val;
> >>  	}
> >
> >So you report kmem+user but we do not consider kmem during charge so one
> >can easily end up with usage_in_bytes over limit but no reclaim is going
> >on. Not good, I would say.

I find this a problem and one of the reason I do not like !independent
accounting.

> >
> >OK, so to sum it up. The biggest problem I see is the (non)independent
> >accounting. We simply cannot mix user+kernel limits otherwise we would
> >see issues (like kernel resource hog would force memcg-oom and innocent
> >members would die because their rss is much bigger).
> >It is also not clear to me what should happen when we hit the kmem
> >limit. I guess it will be kmem cache dependent.
> 
> So right now, tcp is completely independent, since it is not
> accounted to kmem. 

So why do we need kmem accounting when tcp (the only user at the moment)
doesn't use it? 

> In summary, we still never do non-independent accounting. When we
> start doing it for the other caches, We will have to add a test at
> charge time as well.

So we shouldn't do it as a part of this patchset because the further
usage is not clear and I think there will be some real issues with
user+kmem accounting (e.g. a proper memcg-oom implementation).
Can you just drop this patch?

> We still need to keep it separate though, in case the independent
> flag is turned on/off

I don't mind to have kmem.tcp.* knobs.

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

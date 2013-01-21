Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8B47A6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 04:15:10 -0500 (EST)
Date: Mon, 21 Jan 2013 10:15:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
Message-ID: <20130121091507.GC7798@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-5-git-send-email-glommer@parallels.com>
 <20130118160610.GI10701@dhcp22.suse.cz>
 <50FCF539.6070000@parallels.com>
 <20130121083418.GA7798@dhcp22.suse.cz>
 <50FCFF34.9070308@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FCFF34.9070308@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon 21-01-13 12:41:24, Glauber Costa wrote:
> On 01/21/2013 12:34 PM, Michal Hocko wrote:
[...]
> > If you really insist on not using
> > children directly then do something like:
> > 	struct cgroup *pos;
> > 
> > 	if (!memcg->use_hierarchy)
> > 		cgroup_for_each_child(pos, memcg->css.cgroup)
> > 			return true;
> > 
> > 	return false;
> > 
> I don't oppose that.

OK, I guess I could live with that ;)

> > This still has an issue that a change (e.g. vm_swappiness) that requires
> > this check will fail even though the child creation fails after it is
> > made visible (e.g. during css_online).
> > 
> Is it a problem ?

I thought you were considering this a problem. Quoting from patch 3/7
"
> This calls for troubles and I do not think the win you get is really
> worth it. All it gives you is basically that you can change an
> inheritable attribute while your child is between css_alloc and
> css_online and so your attribute change doesn't fail if the child
> creation fails between those two. Is this the case you want to
> handle? Does it really even matter?

I think it matters a lot. Aside from the before vs after discussion to
which I've already conceded, without this protection we can't guarantee
that we won't end up with an inconsistent value of the tunables between
parent and child.
"

Just to make it clear. I do not see this failure as a big problem. We
can fix it by adding an Online check later if somebody complains.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

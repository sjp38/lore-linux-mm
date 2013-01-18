Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 70DB86B0007
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:56:24 -0500 (EST)
Date: Fri, 18 Jan 2013 16:56:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/7] memcg: provide online test for memcg
Message-ID: <20130118155621.GH10701@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-4-git-send-email-glommer@parallels.com>
 <20130118153715.GG10701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130118153715.GG10701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri 18-01-13 16:37:15, Michal Hocko wrote:
> On Fri 11-01-13 13:45:23, Glauber Costa wrote:
> > Since we are now splitting the memcg creation in two parts, following
> > the cgroup standard, it would be helpful to be able to determine if a
> > created memcg is already online.
> > 
> > We can do this by initially forcing the refcnt to 0, and waiting until
> > the last minute to flip it to 1.
> 
> Is this useful, though? What does it tell you? mem_cgroup_online can say
> false even though half of the attributes have been already copied for
> example. I think it should be vice versa. It should mark the point when
> we _start_ copying values. mem_cgroup_online is not the best name then
> of course. It depends what it is going to be used for...

And the later patch in the series shows that it is really not helpful on
its own. You need to rely on other lock to be helpful. This calls for
troubles and I do not think the win you get is really worth it. All it
gives you is basically that you can change an inheritable attribute
while your child is between css_alloc and css_online and so your
attribute change doesn't fail if the child creation fails between those
two. Is this the case you want to handle? Does it really even matter?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

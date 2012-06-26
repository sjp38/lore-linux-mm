Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DC8206B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 13:54:31 -0400 (EDT)
Date: Tue, 26 Jun 2012 19:54:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626175427.GA17619@tiehlicka.suse.cz>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626161501.GI9566@tiehlicka.suse.cz>
 <4FE9E53C.2050700@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9E53C.2050700@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Tue 26-06-12 20:37:16, Glauber Costa wrote:
> On 06/26/2012 08:15 PM, Michal Hocko wrote:
> >On Tue 26-06-12 19:47:14, Glauber Costa wrote:
> >>Okay, so after recent discussions, I am proposing the following
> >>patch. It won't remove hierarchy, or anything like that. Just default
> >>to true in the root cgroup, and print a warning once if you try
> >>to set it back to 0.
> >>
> >>I am not adding it to feature-removal-schedule.txt because I don't
> >>view it as a consensus. Rather, changing the default would allow us
> >>to give it a time around in the open, and see if people complain
> >>and what we can learn about that.
> >>
> >>Signed-off-by: Glauber Costa <glommer@parallels.com>
> >>Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> >>CC: Michal Hocko <mhocko@suse.cz>
> >>CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>CC: Tejun Heo <tj@kernel.org>
> >>---
> >>  mm/memcontrol.c |    5 +++++
> >>  1 file changed, 5 insertions(+)
> >>
> >>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>index 85f7790..c37e4c1 100644
> >>--- a/mm/memcontrol.c
> >>+++ b/mm/memcontrol.c
> >>@@ -3993,6 +3993,10 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
> >>  	if (memcg->use_hierarchy == val)
> >>  		goto out;
> >>
> >>+	WARN_ONCE(!parent_memcg && memcg->use_hierarchy,
> >
> >Do you have to test anything here at all? The test above will get you
> >out without doing anything if you are not trying to change anything.
> >The default is true so you have to be trying to disable it.
> >
> >If you omit !parent_memcg test as well you will get a bonus of the early
> >warning even if somebody has cgconfig.conf like this:
> >
> >	group a/b/c {
> >		memory {
> >			memory.use_hierarchy = 0;
> >			[...]
> >		}
> >	}
> >
> >which worked previously...
> >True there is a risk of a "false warning" when somebody just tries to
> >set disable hierarchy when it is (and never was) allowed but I do not
> >think this is that bad.
> 
> 
> Well, a false warning is not that bad.
> It is better to be vocal.
> 
> I will wait for Kame to put his comments, and I can resend with that change.

OK, you can resend with
Acked-by: Michal Hocko <mhocko@suse.cz>

And thanks!
I will try to push this into OpenSUSE kernels to have a wider audience
for testing. I think that the approach is safe because there is a safe
fallback I mentioned earlier (maybe you can put it into the changelog)
and if there really exists a setting which cannot be converted to
non-hierarchical layout then we should better know as soon as possible.
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

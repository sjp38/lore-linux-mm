Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3B6F76B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:10:46 -0400 (EDT)
Date: Wed, 15 Aug 2012 16:10:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
Message-ID: <20120815141041.GK23985@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-5-git-send-email-glommer@parallels.com>
 <20120814162144.GC6905@dhcp22.suse.cz>
 <502B6D03.1080804@parallels.com>
 <20120815123931.GF23985@dhcp22.suse.cz>
 <502B9BD4.4070003@parallels.com>
 <20120815130228.GH23985@dhcp22.suse.cz>
 <502B9E5F.2080907@parallels.com>
 <20120815132621.GJ23985@dhcp22.suse.cz>
 <502BA4AC.9040000@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502BA4AC.9040000@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On Wed 15-08-12 17:31:24, Glauber Costa wrote:
> On 08/15/2012 05:26 PM, Michal Hocko wrote:
> > On Wed 15-08-12 17:04:31, Glauber Costa wrote:
> >> On 08/15/2012 05:02 PM, Michal Hocko wrote:
> >>> On Wed 15-08-12 16:53:40, Glauber Costa wrote:
> >>> [...]
> >>>>>>> This doesn't check for the hierachy so kmem_accounted might not be in 
> >>>>>>> sync with it's parents. mem_cgroup_create (below) needs to copy
> >>>>>>> kmem_accounted down from the parent and the above needs to check if this
> >>>>>>> is a similar dance like mem_cgroup_oom_control_write.
> >>>>>>>
> >>>>>>
> >>>>>> I don't see why we have to.
> >>>>>>
> >>>>>> I believe in a A/B/C hierarchy, C should be perfectly able to set a
> >>>>>> different limit than its parents. Note that this is not a boolean.
> >>>>>
> >>>>> Ohh, I wasn't clear enough. I am not against setting the _limit_ I just
> >>>>> meant that the kmem_accounted should be consistent within the hierarchy.
> >>>>>
> >>>>
> >>>> If a parent of yours is accounted, you get accounted as well. This is
> >>>> not the state in this patch, but gets added later. Isn't this enough ?
> >>>
> >>> But if the parent is not accounted, you can set the children to be
> >>> accounted, right? Or maybe this is changed later in the series? I didn't
> >>> get to the end yet.
> >>>
> >>
> >> Yes, you can. Do you see any problem with that?
> > 
> > Well, if a child contributes with the kmem charges upwards the hierachy
> > then a parent can have kmem.usage > 0 with disabled accounting.
> > I am not saying this is a no-go but it definitely is confusing and I do
> > not see any good reason for it. I've considered it as an overlook rather
> > than a deliberate design decision.
> > 
> 
> No, it is not an overlook.
> It is theoretically possible to skip accounting on non-limited parents,
> but how expensive is that? This is, indeed, confusing.
> 
> Of course I can be biased, but the way I see it, once you have
> hierarchy, you account everything your child accounts.
>
> I really don't see what is the concern here.

OK, I missed an important point that kmem_accounted is not exported to
the userspace (I thought it would be done later in the series) which
is not the case so actually nobody get's confused by the inconsistency
because it is about RESOURCE_MAX which they see in both cases.
Sorry about the confusion!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

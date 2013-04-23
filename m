Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 217B16B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:29:02 -0400 (EDT)
Date: Tue, 23 Apr 2013 15:28:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130423132858.GI8001@dhcp22.suse.cz>
References: <20130422042445.GA25089@mtj.dyndns.org>
 <20130422153730.GG18286@dhcp22.suse.cz>
 <20130422154620.GB12543@htj.dyndns.org>
 <20130422155454.GH18286@dhcp22.suse.cz>
 <CANN689Hz5A+iMM3T76-8RCh8YDnoGrYBvtjL_+cXaYRR0OkGRQ@mail.gmail.com>
 <51765FB2.3070506@parallels.com>
 <20130423114020.GC8001@dhcp22.suse.cz>
 <CANN689FaGBi+LmdoSGBf3D9HmLD8Emma1_M3T1dARSD6=75B0w@mail.gmail.com>
 <20130423130627.GG8001@dhcp22.suse.cz>
 <517688F0.7010407@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517688F0.7010407@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>

On Tue 23-04-13 17:13:20, Glauber Costa wrote:
> On 04/23/2013 05:06 PM, Michal Hocko wrote:
> > On Tue 23-04-13 05:51:36, Michel Lespinasse wrote:
> > [...]
> >> The issue I see is that even when people configure soft limits B+C <
> >> A, your current proposal still doesn't "leave the other alone" as
> >> Glauber and I think we should.
> > 
> > If B+C < A then B resp. C get reclaimed only if A is over the limit
> > which means that it couldn't reclaimed enough to get bellow the limit
> > when we bang on it before B and C. We can update the implementation
> > later to be more clever in situations like this but this is not that
> > easy because once we get away from the round robin over the tree then we
> > might end up having other issues - like unfairness etc... That's why I
> > wanted to have this as simple as possible.
> > 
> Nobody is opposing this, Michal.
> 
> What people are opposing is you saying that the children should be
> reclaimed *regardless* of their softlimit when the parent is over their
> soft limit. Someone, specially you, saying this, highly threatens
> further development in this direction.

OK, I am feeling like repeating myself. Anyway once more. I am _all_ for
protecting children that are under their limit if that is _possible_[1].
We are not yet there though for generic configuration. That's why I was
so careful about the wording and careful configuration at this stage.
Is this sufficient for your concerns?

I do not see any giant obstacles in the current implementation to allow
this behavior. 

> It doesn't really matter if your current set is doing this, simply
> everybody already agreed that you are moving in a good direction.
> 
> If you believe that it is desired to protect the children from reclaim
> in situation in which the offender is only one of the children and that
> can be easily identified, please state that clearly.

Clearly yes.

---
[1] and to be even more clear there are cases where this will never be
possible. For an example:
	A (soft:0)
	|
	B (soft:MAX)

where B smart ass thinks that his group never gets reclaim although he
is the only source of the pressure. This is what I call untrusted
environment.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

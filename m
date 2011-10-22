Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BED7C6B002F
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 05:47:31 -0400 (EDT)
Date: Sat, 22 Oct 2011 11:47:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFD] Isolated memory cgroups again
Message-ID: <20111022094723.GD5497@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
 <CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
 <4EA12FBA.7090700@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EA12FBA.7090700@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Fri 21-10-11 12:39:22, Glauber Costa wrote:
> On 10/21/2011 03:41 AM, Ying Han wrote:
> >On Wed, Oct 19, 2011 at 6:33 PM, Michal Hocko<mhocko@suse.cz>  wrote:
[...]
> >>TODO
[...]
> >>- is bool sufficient. Don't we rather want something like priority
> >>  instead?
[...]
> >Hi Michal:
> >
> >I didn't read through the patch itself but only the description. If we
> >wanna protect a memcg being reclaimed from under global memory
> >pressure, I think we can approach it by making change on soft_limit
> >reclaim.
> >
> >I have a soft_limit change built on top of Johannes's patchset, which
> >does basically soft_limit aware reclaim under global memory pressure.
> >The implementation is simple, and I am looking forward to discuss more
> >with you guys in the conference.
> >
> >--Ying
> I don't think soft limits will help his case, if I know understand
> it correctly. Global reclaim can be triggered regardless of any soft
> limits we may set.
> 
> Now, there are two things I still don't like about it:
> * The definition of a "main workload", "main cgroup", or anything
> like that.

This was just because I wanted to point out the particular case that I
am interested in. You can of course setup more cgroups to be isolated
and balance them by the soft limit.

> I'd prefer to rank them according to some parameter,
> something akin to swapiness. This would allow for other people to
> use it in a different way, while still making you capable of
> reaching your goals through parameter settings (i.e. one cgroup has
> a high value of reclaim, all others, a much lower one)

Yes, this has been mentioned in the patch TODO section (above). I wanted
the first post to be as easy as possible for the discussion starter. I
guess that we really need something like priority in fact.

> 
> * The fact that you seem to want to *skip* reclaim altogether for a
> cgroup. That's a dangerous condition, IMHO. What I think we should
> try to achieve, is "skip it for practical purposes on sane
> workloads". 

Yes the feature might be dangerous (we provide many ways to shoot self
toes already ;)) but that is what you get if you want to guarantee
something.
But I agree, I guess we can be more clever and if it is priority based
we can map isolation priorities to the reclaim priorities somehow.

> Again, a parameter that when set to a very high mark, has the effect
> of disallowing reclaim for a cgroup under most sane circumstances.
> 
> What do you think of the above, Michal ?

Yes I guess that priority based isolation is the way to go. We should,
however, start with a consensus in this regard (should we do something
like that at all?).

Thanks
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

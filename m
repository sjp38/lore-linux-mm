Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97B976B002E
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 08:16:55 -0400 (EDT)
Date: Fri, 21 Oct 2011 08:16:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFD] Isolated memory cgroups again
Message-ID: <20111021114430.GA1317@cmpxchg.org>
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
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Fri, Oct 21, 2011 at 12:39:22PM +0400, Glauber Costa wrote:
> On 10/21/2011 03:41 AM, Ying Han wrote:
> >On Wed, Oct 19, 2011 at 6:33 PM, Michal Hocko<mhocko@suse.cz>  wrote:
> >>Hi all,
> >>this is a request for discussion (I hope we can touch this during memcg
> >>meeting during the upcoming KS). I have brought this up earlier this
> >>year before LSF (http://thread.gmane.org/gmane.linux.kernel.mm/60464).
> >>The patch got much smaller since then due to excellent Johannes' memcg
> >>naturalization work (http://thread.gmane.org/gmane.linux.kernel.mm/68724)
> >>which this is based on.
> >>I realize that this will be controversial but I would like to hear
> >>whether this is strictly no-go or whether we can go that direction (the
> >>implementation might differ of course).
> >>
> >>The patch is still half baked but I guess it should be sufficient to
> >>show what I am trying to achieve.
> >>The basic idea is that memcgs would get a new attribute (isolated) which
> >>would control whether that group should be considered during global
> >>reclaim.
> >>This means that we could achieve a certain memory isolation for
> >>processes in the group from the rest of the system activity which has
> >>been traditionally done by mlocking the important parts of memory.
> >>This approach, however, has some advantages. First of all, it is a kind
> >>of all or nothing type of approach. Either the memory is important and
> >>mlocked or you have no guarantee that it keeps resident.
> >>Secondly it is much more prone to OOM situation.
> >>Let's consider a case where a memory is evictable in theory but you
> >>would pay quite much if you have to get it back resident (pre calculated
> >>data from database - e.g. reports). The memory wouldn't be used very
> >>often so it would be a number one candidate to evict after some time.
> >>We would want to have something like a clever mlock in such a case which
> >>would evict that memory only if the cgroup itself gets under memory
> >>pressure (e.g. peak workload). This is not hard to do if we are not
> >>over committing the memory but things get tricky otherwise.
> >>With the isolated memcgs we get exactly such a guarantee because we would
> >>reclaim such a memory only from the hard limit reclaim paths or if the
> >>soft limit reclaim if it is set up.
> >>
> >>Any thoughts comments?
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
> 
> I don't think soft limits will help his case, if I know understand
> it correctly. Global reclaim can be triggered regardless of any soft
> limits we may set.
> 
> Now, there are two things I still don't like about it:
> * The definition of a "main workload", "main cgroup", or anything
> like that. I'd prefer to rank them according to some parameter,
> something akin to swapiness. This would allow for other people to
> use it in a different way, while still making you capable of
> reaching your goals through parameter settings (i.e. one cgroup has
> a high value of reclaim, all others, a much lower one)

This is essentially what I wanted to convert soft limit reclaim to: if
a cgroup is considered for reclaim and its exceeding its soft limit,
the amount of scanning force applied to it is doubled compared to its
buddies that are scanned in the same cycle.

> * The fact that you seem to want to *skip* reclaim altogether for a
> cgroup. That's a dangerous condition, IMHO. What I think we should
> try to achieve, is "skip it for practical purposes on sane
> workloads". Again, a parameter that when set to a very high mark,
> has the effect of disallowing reclaim for a cgroup under most sane
> circumstances.

Yes.  I think it would be better to have a minimum guarantee setting
rather than a wholesale cgroup isolation.  If the cgroup's memory
usage is below that guarantee, reclaim skips it.  If you insist, you
can still set this to ULONG_MAX.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

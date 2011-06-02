Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7F586B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 11:51:51 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p52FpfAu012816
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 08:51:42 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by kpbe17.cbf.corp.google.com with ESMTP id p52FpdXq010113
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 08:51:40 -0700
Received: by qwb8 with SMTP id 8so483815qwb.25
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 08:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602075028.GB20630@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
	<20110602075028.GB20630@cmpxchg.org>
Date: Thu, 2 Jun 2011 08:51:39 -0700
Message-ID: <BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 2, 2011 at 12:50 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Jun 01, 2011 at 09:05:18PM -0700, Ying Han wrote:
>> On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa
>> <kamezawa.hiroyuki@gmail.com> wrote:
>> > 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> >> Hi,
>> >>
>> >> this is the second version of the memcg naturalization series. =A0The
>> >> notable changes since the first submission are:
>> >>
>> >> =A0 =A0o the hierarchy walk is now intermittent and will abort and
>> >> =A0 =A0 =A0remember the last scanned child after sc->nr_to_reclaim pa=
ges
>> >> =A0 =A0 =A0have been reclaimed during the walk in one zone (Rik)
>> >>
>> >> =A0 =A0o the global lru lists are never scanned when memcg is enabled
>> >> =A0 =A0 =A0after #2 'memcg-aware global reclaim', which makes this pa=
tch
>> >> =A0 =A0 =A0self-sufficient and complete without requiring the per-mem=
cg lru
>> >> =A0 =A0 =A0lists to be exclusive (Michal)
>> >>
>> >> =A0 =A0o renamed sc->memcg and sc->current_memcg to sc->target_mem_cg=
roup
>> >> =A0 =A0 =A0and sc->mem_cgroup and fixed their documentation, I hope t=
his is
>> >> =A0 =A0 =A0better understandable now (Rik)
>> >>
>> >> =A0 =A0o the reclaim statistic counters have been renamed. =A0there i=
s no
>> >> =A0 =A0 =A0more distinction between 'pgfree' and 'pgsteal', it is now
>> >> =A0 =A0 =A0'pgreclaim' in both cases; 'kswapd' has been replaced by
>> >> =A0 =A0 =A0'background'
>> >>
>> >> =A0 =A0o fixed a nasty crash in the hierarchical soft limit check tha=
t
>> >> =A0 =A0 =A0happened during global reclaim in memcgs that are hierarch=
ical
>> >> =A0 =A0 =A0but have no hierarchical parents themselves
>> >>
>> >> =A0 =A0o properly implemented the memcg-aware unevictable page rescue
>> >> =A0 =A0 =A0scanner, there were several blatant bugs in there
>> >>
>> >> =A0 =A0o documentation on new public interfaces
>> >>
>> >> Thanks for your input on the first version.
>> >>
>> >> I ran microbenchmarks (sparse file catting, essentially) to stress
>> >> reclaim and LRU operations. =A0There is no measurable overhead for
>> >> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
>> >> configured groups, and hard limit reclaim.
>> >>
>> >> I also ran single-threaded kernbenchs in four unlimited memcgs in
>> >> parallel, contained in a hard-limited hierarchical parent that put
>> >> constant pressure on the workload. =A0There is no measurable differen=
ce
>> >> in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
>> >> this test compared to an unpatched kernel. =A0Needs more evaluation,
>> >> especially with a higher number of memcgs.
>> >>
>> >> The soft limit changes are also proven to work in so far that it is
>> >> possible to prioritize between children in a hierarchy under pressure
>> >> and that runtime differences corresponded directly to the soft limit
>> >> settings in the previously described kernbench setup with staggered
>> >> soft limits on the groups, but this needs quantification.
>> >>
>> >> Based on v2.6.39.
>> >>
>> >
>> > Hmm, I welcome and will review this patches but.....some points I want=
 to say.
>> >
>> > 1. No more conflict with Ying's work ?
>> > =A0 =A0Could you explain what she has and what you don't in this v2 ?
>> > =A0 =A0If Ying's one has something good to be merged to your set, plea=
se
>> > include it.
>>
>> My patch I sent out last time was doing rework of soft_limit reclaim.
>> It convert the RB-tree based to
>> a linked list round-robin fashion of all memcgs across their soft
>> limit per-zone.
>>
>> I will apply this patch and try to test it. After that i will get
>> better idea whether or not it is being covered here.
>
> Thanks!!
>
>> > 4. This work can be splitted into some small works.
>> > =A0 =A0 a) fix for current code and clean ups
>>
>> > =A0 =A0 a') statistics
>>
>> > =A0 =A0 b) soft limit rework
>>
>> > =A0 =A0 c) change global reclaim
>>
>> My last patchset starts with a patch reverting the RB-tree
>> implementation of the soft_limit
>> reclaim, and then the new round-robin implementation comes on the
>> following patches.
>>
>> I like the ordering here, and that is consistent w/ the plan we
>> discussed earlier in LSF. Changing
>> the global reclaim would be the last step when the changes before that
>> have been well understood
>> and tested.
>>
>> Sorry If that is how it is done here. I will read through the patchset.
>
> It's not. =A0The way I implemented soft limits depends on global reclaim
> performing hierarchical reclaim. =A0I don't see how I can reverse the
> order with this dependency.

That is something I don't quite get yet, and maybe need a closer look
into the patchset. The current design of
soft_limit doesn't do reclaim hierarchically but instead links the
memcgs together on per-zone basis.

However on this patchset, we changed that design and doing
hierarchy_walk of the memcg tree. Can we clarify more on why we made
the design change? I can see the current design provides a efficient
way to pick the one memcg over-their-soft-limit under shrink_zone().

--Ying

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

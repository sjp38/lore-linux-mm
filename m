Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2D08E6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 04:28:04 -0400 (EDT)
Date: Thu, 1 Sep 2011 10:27:55 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110901082755.GD22561@redhat.com>
References: <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <CALWz4iyXbrgcrZEOsgvvW9mu6fr7Qwbn2d1FR_BVw6R_pMZPsQ@mail.gmail.com>
 <20110901064034.GC22561@redhat.com>
 <CALWz4iyKXx+q5uKVOFqDs3Xx7ZGOertJ-ZWkwO=Z0Ynr4qsm2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iyKXx+q5uKVOFqDs3Xx7ZGOertJ-ZWkwO=Z0Ynr4qsm2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 01, 2011 at 12:04:24AM -0700, Ying Han wrote:
> On Wed, Aug 31, 2011 at 11:40 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> > On Wed, Aug 31, 2011 at 11:05:51PM -0700, Ying Han wrote:
> >> On Tue, Aug 30, 2011 at 1:42 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> >> > You want to look at A and see whether its limit was responsible for
> >> > reclaim scans in any children.  IMO, that is asking the question
> >> > backwards.  Instead, there is a cgroup under reclaim and one wants to
> >> > find out the cause for that.  Not the other way round.
> >> >
> >> > In my original proposal I suggested differentiating reclaim caused by
> >> > internal pressure (due to own limit) and reclaim caused by
> >> > external/hierarchical pressure (due to limits from parents).
> >> >
> >> > If you want to find out why C is under reclaim, look at its reclaim
> >> > statistics.  If the _limit numbers are high, C's limit is the problem.
> >> > If the _hierarchical numbers are high, the problem is B, A, or
> >> > physical memory, so you check B for _limit and _hierarchical as well,
> >> > then move on to A.
> >> >
> >> > Implementing this would be as easy as passing not only the memcg to
> >> > scan (victim) to the reclaim code, but also the memcg /causing/ the
> >> > reclaim (root_mem):
> >> >
> >> >        root_mem == victim -> account to victim as _limit
> >> >        root_mem != victim -> account to victim as _hierarchical
> >> >
> >> > This would make things much simpler and more natural, both the code
> >> > and the way of tracking down a problem, IMO.
> >>
> >> This is pretty much the stats I am currently using for debugging the
> >> reclaim patches. For example:
> >>
> >> scanned_pages_by_system 0
> >> scanned_pages_by_system_under_hierarchy 50989
> >>
> >> scanned_pages_by_limit 0
> >> scanned_pages_by_limit_under_hierarchy 0
> >>
> >> "_system" is count under global reclaim, and "_limit" is count under
> >> per-memcg reclaim.
> >> "_under_hiearchy" is set if memcg is not the one triggering pressure.
> >
> > I don't get this distinction between _system and _limit.  How is it
> > orthogonal to _limit vs. _hierarchy, i.e. internal vs. external?
> 
> Something like :
> 
> +enum mem_cgroup_scan_context {
> +       SCAN_BY_SYSTEM,
> +       SCAN_BY_SYSTEM_UNDER_HIERARCHY,
> +       SCAN_BY_LIMIT,
> +       SCAN_BY_LIMIT_UNDER_HIERARCHY,
> +       NR_SCAN_CONTEXT,
> +};
> 
> if (global_reclaim(sc))
>    context = scan_by_system
> else
>    context = scan_by_limit
> 
> if (target != mem)
>    context++;

I understand what you count, just not why.  If we just had

	SCAN_LIMIT
	SCAN_HIERARCHY

wouldn't it be able to convey all that is necessary?  Global pressure
is just hierarchical pressure, it comes from the outermost 'container'
that is the machine itself.

If you have one just memcg, SCAN_LIMIT shows reclaim pressure because
of the limit and SCAN_HIERARCHY shows global pressure.

With a hierarchical setup, you can find pressure either in SCAN_LIMIT
or by looking at SCAN_HIERARCHY and recursively check the parent.

        root_mem_cgroup
       /
      A
     /
    B

Where is the difference for B whether outside pressure is coming from
physical memory limitations or the limit in A?  The problem is not in
B, you have to check the parents anyway.

Or put differently:

                root_mem_cgroup
               /
              A
             /
            B
           /
          C

In C, you would account global pressure separately but would not make
a distinction between pressure from A's limit and pressure from B's
limit.

What makes the physical memory limit special that requires the
resulting reclaims to be designated over reclaims due to other
hierarchical limits?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

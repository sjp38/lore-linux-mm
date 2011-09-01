Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 949516B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 02:40:43 -0400 (EDT)
Date: Thu, 1 Sep 2011 08:40:34 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110901064034.GC22561@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
 <20110829155113.GA21661@redhat.com>
 <20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <CALWz4iyXbrgcrZEOsgvvW9mu6fr7Qwbn2d1FR_BVw6R_pMZPsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iyXbrgcrZEOsgvvW9mu6fr7Qwbn2d1FR_BVw6R_pMZPsQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2011 at 11:05:51PM -0700, Ying Han wrote:
> On Tue, Aug 30, 2011 at 1:42 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> > You want to look at A and see whether its limit was responsible for
> > reclaim scans in any children.  IMO, that is asking the question
> > backwards.  Instead, there is a cgroup under reclaim and one wants to
> > find out the cause for that.  Not the other way round.
> >
> > In my original proposal I suggested differentiating reclaim caused by
> > internal pressure (due to own limit) and reclaim caused by
> > external/hierarchical pressure (due to limits from parents).
> >
> > If you want to find out why C is under reclaim, look at its reclaim
> > statistics.  If the _limit numbers are high, C's limit is the problem.
> > If the _hierarchical numbers are high, the problem is B, A, or
> > physical memory, so you check B for _limit and _hierarchical as well,
> > then move on to A.
> >
> > Implementing this would be as easy as passing not only the memcg to
> > scan (victim) to the reclaim code, but also the memcg /causing/ the
> > reclaim (root_mem):
> >
> >        root_mem == victim -> account to victim as _limit
> >        root_mem != victim -> account to victim as _hierarchical
> >
> > This would make things much simpler and more natural, both the code
> > and the way of tracking down a problem, IMO.
> 
> This is pretty much the stats I am currently using for debugging the
> reclaim patches. For example:
> 
> scanned_pages_by_system 0
> scanned_pages_by_system_under_hierarchy 50989
> 
> scanned_pages_by_limit 0
> scanned_pages_by_limit_under_hierarchy 0
> 
> "_system" is count under global reclaim, and "_limit" is count under
> per-memcg reclaim.
> "_under_hiearchy" is set if memcg is not the one triggering pressure.

I don't get this distinction between _system and _limit.  How is it
orthogonal to _limit vs. _hierarchy, i.e. internal vs. external?

If the system scans memcgs then no limit is at fault.  It's just
external pressure.

For example, what is the distinction between scanned_pages_by_system
and scanned_pages_by_system_under_hierarchy?  The reason for
scanned_pages_by_system would be, per your definition, neither due to
the limit (_by_system -> global reclaim) nor not due to the limit
(!_under_hierarchy -> memcg is the one triggering pressure)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B19CA6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 07:40:22 -0400 (EDT)
Date: Tue, 23 Apr 2013 13:40:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130423114020.GC8001@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
 <20130422042445.GA25089@mtj.dyndns.org>
 <20130422153730.GG18286@dhcp22.suse.cz>
 <20130422154620.GB12543@htj.dyndns.org>
 <20130422155454.GH18286@dhcp22.suse.cz>
 <CANN689Hz5A+iMM3T76-8RCh8YDnoGrYBvtjL_+cXaYRR0OkGRQ@mail.gmail.com>
 <51765FB2.3070506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51765FB2.3070506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>

On Tue 23-04-13 14:17:22, Glauber Costa wrote:
> On 04/23/2013 01:58 PM, Michel Lespinasse wrote:
> > On Mon, Apr 22, 2013 at 8:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> On Mon 22-04-13 08:46:20, Tejun Heo wrote:
> >>> Oh, if so, I'm happy.  Sorry about being brash on the thread; however,
> >>> please talk with google memcg people.  They have very different
> >>> interpretation of what "softlimit" is and are using it according to
> >>> that interpretation.  If it *is* an actual soft limit, there is no
> >>> inherent isolation coming from it and that should be clear to
> >>> everyone.
> >>
> >> We have discussed that for a long time. I will not speak for Greg & Ying
> >> but from my POV we have agreed that the current implementation will work
> >> for them with some (minor) changes in their layout.
> >> As I have said already with a careful configuration (e.i. setting the
> >> soft limit only where it matters - where it protects an important
> >> memory which is usually in the leaf nodes)
> > 
> > I don't like your argument that soft limits work if you only set them
> > on leaves. To me this is just a fancy way of saying that hierarchical
> > soft limits don't work.
> > 
> > Also it is somewhat problematic to assume that important memory can
> > easily be placed in leaves. This is difficult to ensure when
> > subcontainer destruction, for example, moves the memory back into the
> > parent.
> > 
> 
> Michal,
> 
> For the most part, I am siding with you in this discussion.
> But with this only-in-leaves thing, I am forced to flip (at least for this).
> 
> You are right when you say that in a configuration with A being parent
> of B and C, A being over its hard limit will affect reclaim in B and C,
> and soft limits should work the same.
> 
> However, "will affect reclaim" is a big vague. More specifically, if the
> sum of B and C's hard limit is smaller or equal A's hard limit, the only
> way of either B or C to trigger A's hard limit is for them, themselves,
> to go over their hard limit.

Which is an expectation that you cannot guarantee. You can have B+C>A.

> *This* is the case you you are breaking when you try to establish a
> comparison between soft and hard limits - which is, per se, sane.
> 
> Translating this to the soft limit speech, if the sum of B and C's soft
> limit is smaller or equal A's soft limit, and one of them is over the
> soft limit, that one should be reclaimed. The other should be left alone.

And yet again. Nothing will prevent you from setting B+C>A. Sure if you
configure your hierarchy sanely then everything will just work.

> I understand perfectly fine that soft limit is a best effort, not a
> guarantee. But if we don't do that, I understand that we are doing
> effort, not best effort.
> 
> This would only be attempted in our first pass. In the second pass, we
> reclaim from whoever.
> 
> It is also not that hard to do it: Flatten the tree in a list, with the
> leaves always being placed before the inner nodes.

Glauber, I have already pointed out that bottom-up reclaim doesn't make
much sense because it is a bigger chance that useful data is stored in
the leaf nodes rather than inner nodes which usually contain mostly
reparented pages.

> Start reclaiming from nodes over the soft limit, hierarchically. This
> means that whenever we reach an inner node and it is *still* over
> the soft limit, we are guaranteed to have scanned their children
> already. In the case I described, the children over its soft limit
> would have been reclaimed, without the well behaving children being
> touched. Now all three are okay.
> 
> If we reached an inner node and we still have a soft limit problem, then
> we are effectively talking about the case you have been describing.
> Reclaim from whoever you want.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

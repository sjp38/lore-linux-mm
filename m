Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E65C86B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 14:30:25 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id bh4so3811786pad.12
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:30:25 -0700 (PDT)
Date: Mon, 22 Apr 2013 11:30:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422183020.GF12543@htj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422162012.GI18286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

Hey,

On Mon, Apr 22, 2013 at 06:20:12PM +0200, Michal Hocko wrote:
> Although the default limit is correct it is impractical for use
> because it doesn't allow for "I behave do not reclaim me if you can"
> cases. And we can implement such a behavior really easily with backward
> compatibility and new interfaces (aka reuse the soft limit for that).

Okay, now we're back to square one and I'm reinstating all the mean
things I said in this thread. :P No wonder everyone is so confused
about this.  Michal, you can't overload two controls which exert
pressure on the opposite direction onto a single knob and define a
sane hierarchical behavior for it.  You're making it a point control
rather than range one.  Maybe you can define some twisted rules
serving certain specific use case, but it's gonna be confusing /
broken for different use cases.

You're so confused that you don't even know you're confused.

> I am approaching this from a simple perspective. Reclaim from everybody

No, you're just thinking about two immediate problems you're given and
trying to jam them into something you already have not realizing those
two can't be expressed with a single knob.

> who doesn't care about the soft limit (it hasn't been set for that
> group) or who is above the soft limit. If that is sufficient to meet the
> reclaim target then there is no reason to touch groups that _do_ care
> about soft limit and they are under. Although this doesn't give you
> any guarantee it can give a certain prioritization for groups in the
> overcommit situations and that is what soft limit was intended for from
> the very beginning.

For $DEITY's sake, soft limit should exert reclaim pressure.  That's
it.  If a group is over limit, it'll feel *extra* pressure until it's
back to the limit.  Once under the limit, it should be treated equally
to any other tasks which are under the limit including the ones
without any softlimit configured.  It is not different from hardlimit.
There's nothing "interesting" about it.

Even for flat hierarchy, with your interpretation of the knob, it is
impossible to say "I don't really care about this thing, if it goes
over 30M, hammer on it", which is a completely reasonable thing to
want.

> > And, if people want a mechanism for isolation / lessening of pressure,
> > which looks like a valid use case to me, add another knob for that
> > which is prioritized under both hard and soft limits.  That is the
> > only sensible way to do it.
> 
> No, please no yet another knob. We have too many of them already. And
> even those that are here for a long time can be confusing as one can
> see.

Yes, sure, knobs are hard, let's combine two controls in the opposite
directions into one.

That is the crux of the confusion - trying to combine two things which
can't and shouldn't be combined.  Just forget about the other thing or
separate it out.  Please take a step back and look at it again.
You're really epitomizing the confusion on this subject.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

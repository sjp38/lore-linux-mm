Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 2CA176B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:30:01 -0400 (EDT)
Date: Tue, 23 Apr 2013 11:29:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130423092944.GA8001@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422183020.GF12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Mon 22-04-13 11:30:20, Tejun Heo wrote:
> Hey,
> 
> On Mon, Apr 22, 2013 at 06:20:12PM +0200, Michal Hocko wrote:
> > Although the default limit is correct it is impractical for use
> > because it doesn't allow for "I behave do not reclaim me if you can"
> > cases. And we can implement such a behavior really easily with backward
> > compatibility and new interfaces (aka reuse the soft limit for that).
> 
> Okay, now we're back to square one and I'm reinstating all the mean
> things I said in this thread. :P No wonder everyone is so confused
> about this.  Michal, you can't overload two controls which exert
> pressure on the opposite direction onto a single knob and define a
> sane hierarchical behavior for it.

Ohh, well and we are back in the circle again. Nobody is proposing
overloading soft reclaim for any bottom-up (if that is what you mean by
your opposite direction) pressure handling.

> You're making it a point control rather than range one.

Be more specific here, please?

> Maybe you can define some twisted rules serving certain specific use
> case, but it's gonna be confusing / broken for different use cases.

Tejun, your argumentation is really hand wavy here. Which use cases will
be broken and which one will be confusing. Name one for an illustration.

> You're so confused that you don't even know you're confused.

Yes, you keep repeating that. But you haven't pointed out any single
confusing use case so far. Please please stop this, it is not productive.
We are still talking about using soft limit to control overcommit
situation as gracefully as possible. I hope we are on the same page
about that at least.

I will post my series as a reply to this email so that we can get to
a more specific discussion because this "you are so confused because
something, something, something, dark..." is not funny, nor productive.

> > I am approaching this from a simple perspective. Reclaim from everybody
> 
> No, you're just thinking about two immediate problems you're given and
> trying to jam them into something you already have not realizing those
> two can't be expressed with a single knob.

Yes, I am thinking in context of several use cases, all right. One
of them is memory isolation via soft limit prioritization. Something
that is possible already but it is major PITA to do right. What we
have currently is optimized for "let's hammer something". Although
useful, not a primary usecase according to my experiences. The primary
motivation for the soft limit was to have something to control
overcommit situations gracefully AFAIR and let's hammer something and
hope it will work doesn't sound gracefully to me.

> > who doesn't care about the soft limit (it hasn't been set for that
> > group) or who is above the soft limit. If that is sufficient to meet the
> > reclaim target then there is no reason to touch groups that _do_ care
> > about soft limit and they are under. Although this doesn't give you
> > any guarantee it can give a certain prioritization for groups in the
> > overcommit situations and that is what soft limit was intended for from
> > the very beginning.
> 
> For $DEITY's sake, soft limit should exert reclaim pressure.  That's
> it.  If a group is over limit, it'll feel *extra* pressure until it's
> back to the limit.  Once under the limit, it should be treated equally
> to any other tasks which are under the limit

And yet again agreed and nobody is claiming otherwise. Except that

> including the ones without any softlimit configured.

I haven't seen any specific argument why the default limit shouldn't
allow to always reclaim.
Having soft unreclaimable groups by default makes it hard to use soft
limit reclaim for something more interesting. See the last patch
in the series ("memcg: Ignore soft limit until it is explicitly
specified"). With this approach you end up setting soft limit for every
single group (even those you do not care about) just to make balancing
work reasonably for all hierarchies.

Anyway, this is just one part of the series and it doesn't make sense to
postpone the whole work just for this. If _more people_ really think that
the default limit change is really _so_ confusing and unusable then I
will not push it over dead bodies of course.

> It is not different from hardlimit. There's nothing "interesting"
> about it.
> 
> Even for flat hierarchy, with your interpretation of the knob, it is
> impossible to say "I don't really care about this thing, if it goes
> over 30M, hammer on it", which is a completely reasonable thing to
> want.

Nothing prevents from this setting. I am just claiming that this is not
the most interesting use case for the soft limit and I would like to
optimize for more interesting use cases.

The patch set will follow
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

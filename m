Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B53ED6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:05:49 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w16so1457200pde.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 01:05:49 -0700 (PDT)
Date: Wed, 5 Jun 2013 01:05:45 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130605080545.GF7303@mtj.dyndns.org>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
 <20130605073728.GC15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605073728.GC15997@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Hey, Michal.

On Wed, Jun 05, 2013 at 09:37:28AM +0200, Michal Hocko wrote:
> Tejun, I do not have infinite amount of time and this is barely a
> priority for the patchset. The core part is to be able to skip
> nodes/subtrees which are not worth reclaiming, remember?
>
> I have already expressed my priorities for inside skipping
> decisions. You are just throwing "let's try a different way" handwavy
> suggestions. I have no problem to pull the skip logic outside of
> iterators if more people think that this is _really_ important. But
> until then I take it as a really low priority that shouldn't delay the
> patchset without a good reason.
> 
> So please try to focus on the technical parts of the patchset if you
> want to help with the review. I really appreciate suggestions but please
> do not get down to bike scheding.

Well, so, I know I've been pain in the ass but here's the thing.  I
don't think you've been doing a good job of maintaining memcg.  Among
the code pieces that I look at, it really ranks very close to the
bottom in terms of readability and general messiness.  One of the core
jobs of being a maintainer is ensuring the code stays in readable and
maintainable state.

Maybe memcg is really really really special and it does require the
level of complication that you've been adding; however, I can't see
that.  Not yet anyway.  What I see is a subsystem which is slurping in
complexity without properly evaluating the benefits such complexity
brings and its overhead.  Why do you have several archaic barrier
dancings buried in memcg?  If you do really need them and yes I can
see that you might need them, build proper abstractions and update
code properly even if that takes more time because otherwise we'll end
up with something which is painful to maintain, and you're never gonna
get enough reviews and testing for the scary stuff you buried inside
memcg.

If you think I'm going overboard with the barrier stuff, what about
the css and memcg refcnts?  memcg had and still has this layered
refcnting, which is obviously bonkers if you just take one step back
and look at it.  What about the css_id addition?  Why has memcg added
so many fundamentally broken things to memcg itself and cgroup core?

At this point, I'm fairly doubtful that memcg is being properly
maintained and hope that someone else would take control of what code
goes in.  You probably had all the good technical reasons when you
were committing all those broken stuff.  I don't know why it's been
going this way.  It almost feels like you can see the details but
never the larger picture.

So, yes, I agree this isn't the biggest technical point in the series
and understand that you could be frustrated with me throwing in
wrenches, but I think going a bit slower in itself could be helpful.
Have you tried just implementing skipping interface?  Really, I'm
almost sure it's gonna be much more readable than the predicate thing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

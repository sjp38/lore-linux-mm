Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id A8C126B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 13:09:06 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so623695pad.30
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:09:05 -0700 (PDT)
Date: Tue, 23 Apr 2013 10:09:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130423170900.GH12543@htj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
 <20130423092944.GA8001@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423092944.GA8001@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

Hello, Michal.

On Tue, Apr 23, 2013 at 11:29:56AM +0200, Michal Hocko wrote:
> Ohh, well and we are back in the circle again. Nobody is proposing
> overloading soft reclaim for any bottom-up (if that is what you mean by
> your opposite direction) pressure handling.
> 
> > You're making it a point control rather than range one.
> 
> Be more specific here, please?
> 
> > Maybe you can define some twisted rules serving certain specific use
> > case, but it's gonna be confusing / broken for different use cases.
> 
> Tejun, your argumentation is really hand wavy here. Which use cases will
> be broken and which one will be confusing. Name one for an illustration.
> 
> > You're so confused that you don't even know you're confused.
> 
> Yes, you keep repeating that. But you haven't pointed out any single
> confusing use case so far. Please please stop this, it is not productive.
> We are still talking about using soft limit to control overcommit
> situation as gracefully as possible. I hope we are on the same page
> about that at least.

Hmmm... I think I was at least somewhat clear on my points.  I'll try
again.  Let's see if I can at least make you understand what my point
is.  Maybe some diagrams will help.

Let's consider hardlimit first as there seems to be consensus on what
it means.  By default, hardlimit is set at max and exerts pressure
downwards.

 <--------------------------------------------------------|
 0                                                      max

When you configure a hard limit, the diagram becomes.

 <-----------------------------------------|
 0                                       limit          max
 
The configuration now became more specific, right?  Now let's say
there's one parent and one child.  The parent looks like the above and
the child like the below.

 <---------------------|
 0                   limit'                             max

When you combine the two, you get

 <---------------------|
 0                   limit'                             max

In fact, it doesn't matter whether parent is more limited or child is.
When composing multiple limits, the only logical thing to do is
calculating the intersection - ie. take the most specific of the
limits, which naturally doesn't violate both configurations.  In
hierarchy setup, children need to be summed and all, so it becomes
different, but that's the principle.  I hope you're with me upto this
point.

Now, let's think about the other direction.  I don't care whether it's
strict guarantee, soft protection or just a gentle preferential
treatment.  The focus is the direction of specificity.  Please forget
about "softlimit" for now.  Just think at the interface level.  You
don't want to give protection by default, right?  The specificity
increases along with the amount of memory to "protect".  So, the
default looks like.

 |-------------------------------------------------------->
 0                                                      max

When you configure certain amount, it becomes

              |------------------------------------------->
 0          prot                                        max

The direction of specificity is self-evident from what the default
should be.  Now, when you combine it with another such protection, say
prot'.

                              |--------------------------->
 0                          prot'                       max

Regardless of what the nesting order is, what you should get is.

                              |--------------------------->
 0                          prot'                       max

It's exactly the same as limit.  When you combine multiple of them,
the most specific one wins.  This is the basic of composing multiple
ranges and it is the same principle that cgroup hierarchy limit
configuration follows.  When you compose configurations across
hierarchy, you get the intersection.

Now, when you put both into a single configuration knob, a given
config would look like the following.

  specificity                specificity
  of limit                   of protection
 <----------------|--------------------------------------->
 0              config                                  max
 
Now, if you try to combine it with another one - config'

         specificity                  specificity
         of limit                     of protection
 <-------------------------------|------------------------>
 0                             config'                  max

The intersection is no longer clearly defined.  If you choose config,
you violate the protection specificity of config', if you choose
config', you violate the limit specificity of config.  This is what I
meant by you're making it a point configuration rather than a range
one.

A ranged config allows for well-defined composition through
intersection.  People tend to do this intuitively which makes it
easier and more useful.

I don't really care all that much about memcg internals but I do care
about maintaining general sanity and consistency of cgroup control
knobs especially in hierarchical settings which we traditionally have
been horrible at, and I hope you at least can see the problem I'm
seeing as it's evident as fire from where I stand.  It's breaking the
very basic principle which makes hierarchy sensible and useful.

The fact that you think "switching the default value to the other end"
is just a detail is very bothering because the default value is not
determined according to one's whim.  It's determined by the direction
of specificity and in turn clearly marks and determines further
operations including how they are composed.

This really illumuniates the intricate and fragile tweaks you're
trying to perform in an attemp to make the above point control to suit
the use cases that you immediately face - you're choosing the
direction of specificity that the knob is gonna follow on
instance-by-instance basis - it's one direction for default and leaves
if parent is not over limit; however, if it's over limit, you flip the
direction, so that it somehow works for the use cases that you have
right now.  Sure, there are cases where such greedy engineering
approach is useful or at least cases where we just have to make do
with that, but this is nothing like that.  It is a basic interface
design which isn't complicated or difficult in itself.

> Yes, I am thinking in context of several use cases, all right. One
> of them is memory isolation via soft limit prioritization. Something
> that is possible already but it is major PITA to do right. What we
> have currently is optimized for "let's hammer something". Although
> useful, not a primary usecase according to my experiences. The primary
> motivation for the soft limit was to have something to control
> overcommit situations gracefully AFAIR and let's hammer something and
> hope it will work doesn't sound gracefully to me.

As I've said multiple times now, I'm not saying any of the presented
use cases are invalid.  They all look valid to me and I think it's
logical to support them; however, combining the two directions of
specificities into one knob can't be the solution.  Right now, both
google and parallels want isolation, so that's the direction they're
pushing - the arrows which are headed to the right of the screen.

The problem becomes self-evident when you consider use cases which
will want the arrows heading to the left of the screen, where
over-provision of softlimit would be a natural thing to do just as
hardlimit is, and such use cases won't call for and most likely will
be hurt by reducing reclaim pressure when under limit.

Say, a server or mobile configuration where a couple background jobs -
say, indexing and back up - are running, both of which may create
sizable amount of dirty data.  They need to be done but aren't of high
priority.  Given the size of the machine and the type of the batch
tasks, you wanna give X amount of memory to the batch tasks but want
to make sure neither takes too much of it, so configure each to have Y
and Z, where Y < X, Z < X but Y + Z > X.  This is a reasonable
configuration and when the system, as a whole, gets put under memory
pressure - say the user launches a memory hog game - you first want
the batch tasks to give away memory as fast as possible until the
composition of limits is met and then you want them to feel the same
pressure as everyone else.

You can't combine "soft limit prioritization" and "isolation" into the
same knob.  Not because of implementation deatils but because they
have the opposite directions of specificity.  They're two
fundamentally incompatible knobs.

> > including the ones without any softlimit configured.
> 
> I haven't seen any specific argument why the default limit shouldn't
> allow to always reclaim.
> Having soft unreclaimable groups by default makes it hard to use soft
> limit reclaim for something more interesting. See the last patch
> in the series ("memcg: Ignore soft limit until it is explicitly
> specified"). With this approach you end up setting soft limit for every
> single group (even those you do not care about) just to make balancing
> work reasonably for all hierarchies.

I think, well at least hope, that it's clear by now, but the above is
exactly the kind of twisting and tweaking that I was talking about
above.  You're flipping things at different places trying to somehow
meet the conflicting requirements which currently is put forth by
mostly people using it as an isolation mechanism.

> Anyway, this is just one part of the series and it doesn't make sense to
> postpone the whole work just for this. If _more people_ really think that
> the default limit change is really _so_ confusing and unusable then I
> will not push it over dead bodies of course.

So, here's my problem with the patchset.  As sucky as the current
situation is, "softlimit" currently doesn't explicitly implement or
suggest isolation.  People wanting isolation would of course want to
push it to do isolation.  They just want to get the functionality and
interface doesn't matter all that much, which is fine and completely
punderstandable, but by pushing it towards isolation, you're cementing
the duality of the knob.  Frankly, I don't care which direction
"softlimit" chooses but you can't put both "limit" and "protection"
into the same knob.  It's fundamentally broken especially in
hierarchies.

> Nothing prevents from this setting. I am just claiming that this is not
> the most interesting use case for the soft limit and I would like to
> optimize for more interesting use cases.

Michal, it really is not about optimizing for anything.  It is the
basic semantics of the knob, which isn't part of what one may call
"implementation details".  You can't "optimize" them.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

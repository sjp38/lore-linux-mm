Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C5B016B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 17:19:12 -0400 (EDT)
Received: by dakp5 with SMTP id p5so514213dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:19:12 -0700 (PDT)
Date: Tue, 26 Jun 2012 14:19:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626211907.GX3869@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626185542.GE27816@cmpxchg.org>
 <20120626191450.GT3869@google.com>
 <20120626205924.GH27816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120626205924.GH27816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

Hello, Johannes.

On Tue, Jun 26, 2012 at 10:59:24PM +0200, Johannes Weiner wrote:
> > How do we know that?  At least from what I see from blkcg usage,
> > people do crazy stuff when given crazy interface and we've been
> > providing completely crazy interface for years.  We cannot switch that
> > implicitly - the changed default behavior is drastically different and
> > even could be difficult to chase down.  Transitions towards good
> > behavior are good but they have to be explicit.
> 
> I can't really argue against this because this can't be anything but a
> handwaving contest.  We simply have no data.

The problem is that we can't know for sure until we make it explode
and, once we make it explode, well, it has exploded.

> Backward compatibility is a really good idea but I think it depends on
> the situation:
> 
>   I don't expect such a configuration to happen by accident because
>   this behaviour is against fundamental expectations users have toward
>   a filesystem, which is the hierarchical nature of nested entities.
> 
>   I also don't expect it to happen intentionnaly, simply because there
>   is nothing to gain from a more complicated nested setup.

I agree it's a feature which no sane person should be using but if you
look at the cgroup interface as whole, sadly, sanity is fairly scarce.
Nothing prevents one from mounting cpu and mem on the same hierarchy
expecting hierarchical control for cpus while using flat enforcement
on mem.  That was the default behavior after all.

>   And because there is nothing to gain, it is in addition really
>   trivial to fix the insane setups by simply undoing the nesting,
>   there is no downside for them.

I have to disagree with that.  Deployment sometimes can be very
painful.  In some cases, even flipping single parameter in sysfs
depending on kernel version takes considerable effort.  The behavior
has been the contract that we offered userland for quite some time
now.  We shouldn't be changing that underneath them without any clear
way for them to notice it.

> The only point where I agree with you is that it may indeed be
> non-obvious to detect in case you were relying on the filesystem
> hierarchy not being reflected in the controller hierarchy.  But even
> that depends on the usecase, whether it's a subtle performance
> regression or a total failure to execute a previously supported
> workload, which would be pretty damn obvious.

And imagine that happening in serveral thousand machine cluster with
fairly complicated cgroup setup and kernel update rolling out for
subset of machine types.  I would be screaming bloody murder.

> > > I would hate if people had to jump through hoops to get the only
> > > behaviour we want to end up supporting and to not get yelled at, it
> > > sends all the wrong signals.
> > 
> > It is inconvenient but that's the price that we have to pay for having
> > been stupid.  Kernel flipping behavior implicitly is far worse than
> > any such inconvenience.
> 
> That's a matter of taste.  It's not inconvenient for us, but for every
> normal person trying to use the feature in a sane way, just to support
> hypothetical crazy people when there is a really trivial solution for
> the crazy people's problem.

To me, this doesn't seem to be a matter of taste.  This is crossing
the line.  Note that the said inconvenience is likely to be felt only
by distros or admins and what should be done to remedy the situation
will be obvious.  I agree it isn't ideal but such is life, I suppose.

> > The kernel should nudge mainline users towards new behavior while
> > providing distros / admins a way to move to the new behavior.  The
> > kernel itself can't flip it like that.
> 
> I thought it was the kernel's job to provide sensible defaults and the
> distro's job to ease transitions...

Yeah, sure, and we failed horribly at providing sensible default here.
The right thing to do now is to gradually move towards the better
default.

> > Ah... yeah, flat hierarchy probably is the wrong way to describe it.
> > I don't know.  Superficial hierarchy?
> 
> Not sure there really is an appropriate two-word name for this
> artifact.  How about, pardon my German,
> Cgroupfilesystemcontrollerhierarchysemanticsdiscrepancy?

I'd like more Scheisse in there please.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

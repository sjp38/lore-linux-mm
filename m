From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v5] Soft limit rework
Date: Tue, 17 Sep 2013 15:56:15 -0400
Message-ID: <20130917195615.GC856@cmpxchg.org>
References: <20130819163512.GB712@cmpxchg.org>
 <20130820091414.GC31552@dhcp22.suse.cz>
 <20130820141339.GA31419@cmpxchg.org>
 <20130822105856.GA21529@dhcp22.suse.cz>
 <20130903161550.GA856@cmpxchg.org>
 <20130904163823.GA30851@dhcp22.suse.cz>
 <20130906192311.GE856@cmpxchg.org>
 <20130913144953.GA23857@dhcp22.suse.cz>
 <20130913161709.GV856@cmpxchg.org>
 <20130916164405.GG3674@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130916164405.GG3674-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ying Han <yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Michel Lespinasse <walken-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Sep 16, 2013 at 06:44:05PM +0200, Michal Hocko wrote:
> On Fri 13-09-13 12:17:09, Johannes Weiner wrote:
> > On Fri, Sep 13, 2013 at 04:49:53PM +0200, Michal Hocko wrote:
> > > On Fri 06-09-13 15:23:11, Johannes Weiner wrote:
> [...]
> > > > I would really like to deprecate soft limits and introduce something
> > > > new that has the proper semantics we want from the get-go.  Its
> > > > implementation could very much look like your code, so we can easily
> > > > reuse that.  But the interface and its semantics should come first.
> > > 
> > > I am open to discussin such a change I just do not see any reason to
> > > have a crippled soft reclaim implementation for the mean time.
> > > Especially when it doesn't look like such a new interface is easy to
> > > agree on.
> > 
> > We had a crippled soft limit implementation from the time it was
> > merged, it never worked better than now.
> > 
> > You seem to think that this is an argument *for* finally fixing it.  I
> > disagree.  We should absolutely *avoid* steering people toward it now,
> > when the long term plan is already to get rid of it.
> 
> It is not just about fixing it. It is also about getting rid of the
> bloat that the previous implementation depended on. Not only LoC but
> also the resulting binary:
> 
> $ size mm/built-in.o 
> base:
>    text    data     bss     dec     hex filename
>    534283  233703  163456  931442   e3672 mm/built-in.o
> rework:
>    text    data     bss     dec     hex filename
>    532866  229591  163456  925913   e20d9 mm/built-in.o
> 
> I would like to get rid of as much of a special code as possible.
> Especially this one which I hate personally because it is a crude hack
> that shouldn't have existed.

The interface is, not the implementation.

> > There is a concensus that cgroups and the controllers were merged
> > before they were ready and we are now struggling heavily to iron out
> > the design mistakes with the minimum amount of disruption we can get
> > away with.
> > 
> > We are also at this time coordinating with all the other controllers
> > and the cgroup core to do exactly that, where Tejun is providing us
> > with tools to revamp the problematic interfaces.
> > 
> > And we agree that soft limits were such a design mistake that should
> > be ironed out.
> > 
> > So for the love of everything we hold dear, why would you think that
> > NOW is a good time to fix the implemantion and get people to use it?
> 
> There are users who already use this feature and it will take some (read
> a lot of) time to move them to something else. And that something else
> still doesn't exist and I suspect it will take some time to push it into
> a proper shape (and be sure we do not screw it this time).

Yet you could not name a single sensible use case.  So no, we have no
known users, except maybe Google, who actually want guarantees.

> So while I agree that we need something more (semantically) reasonable
> there is no need to keep this crippled implementation around especially
> when it is non-trivial amount of code.

You traded a non-trivial amount of code for non-trivial code.  And you
moved the cost from optional memcg code to essential memory management
code.  All for a feature that needs to be redesigned and has a
questionable userbase.

> > > > > > You have not shown that prio-0 scans are a problem. 
> > > > > 
> > > > > OK, I thought this was self evident but let me be more specific.
> > > > > 
> > > > > The scan the world is almost always a problem. We are no longer doing
> > > > > proportional anon/file reclaim (swappiness is ignored). This is wrong
> > > > > from at least two points of view. Firstly it makes the reclaim decisions
> > > > > different a lot for groups that are under the soft limit and those
> > > > > that are over. Secondly, and more importantly, this might lead to a
> > > > > pre-mature swapping, especially when there is a lot of IO going on.
> > > > > 
> > > > > The global reclaim suffers from the very same problem and that is why
> > > > > we try to prevent from prio-0 reclaim as much as possible and use it
> > > > > only as a last resort.
> > > > 
> > > > I know that and I can see that this should probably be fixed, but
> > > > there is no quantification for this.  We have no per-memcg reclaim
> > > > statistics
> > > 
> > > Not having statistic is a separate issue. It makes the situation worse
> > > but that is not a new thing. The old implementation is even worse
> > > because the soft reclaim activity is basically hidden from global
> > > reclaim counters. So a lot of pages might get scanned and we will have
> > > no way to find out. That part is inherently fixed by the series because
> > > of the integration.
> > 
> > Because it's in the *global* reclaim counters?  That's great but it
> > does not address the problem at all.  This is about pressure balance
> > between groups and you don't have any numbers for that.
> 
> yes, but the point was that if somebody uses soft reclaim currently you
> would miss a big part of reclaim activity because soft reclaim is not
> accounted even in the global counters. So you can see a long stall
> during direct reclaim while the counters look all good.

This is not going anywhere :(

> > This series is a grab bag of fixes that drag a lot of complexity from
> > memcg code into generic reclaim, to repair the age old implementation
> > of a user-visible interface that we already agree sucks balls and
> > should be deprecated.  The fact that you did not even demonstrate that
> > the repair itself was successful is a secondary issue at this point,
> > but it certainly didn't help your case.
> 
> I will follow up with the testing results later. I hope I manage to have
> them before I leave on vacation.
> 
> The question, though, is whether even results supporting my claims about
> enhancements would make any difference. To be honest I thought that the
> integration would be non-controversial topic even without performance
> improvements which could have be expected due to removing prio-0 reclaim
> which is a pure evil. Also the natural fairness of the s.r. sounds like
> a good thing.
> 
> Anyway. Your wording that nothing should be done about the soft reclaim
> seems to be quite clear though. If this position is really firm then go
> ahead and NACK the series _explicitly_ so that Andrew or you can send a
> revert request to Linus. I would really like to not waste a lot of time
> on testing right now when it wouldn't lead to anything.

Nacked-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>

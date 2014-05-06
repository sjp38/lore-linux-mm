Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id ED19D6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:12:59 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so6569856eek.36
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:12:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si13809803eeo.217.2014.05.06.09.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 09:12:58 -0700 (PDT)
Date: Tue, 6 May 2014 18:12:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140506161256.GE19672@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
 <20140506132932.GF19914@cmpxchg.org>
 <20140506143242.GB19672@dhcp22.suse.cz>
 <20140506152112.GG19914@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140506152112.GG19914@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

I am adding Rik to CC (sorry to put you in the middle of a thread -
we have started here: https://lkml.org/lkml/2014/4/28/237). You were
stressing out risks of using lowlimit as a hard guarantee at LSF. Could
you repeat your concerns here as well, please?

Short summary:
We are basically discussing how to handle lowlimit overcommit situation,
when no group is reclaimable because it either doesn't have any pages on
the LRU or it is bellow its lowlimit (aka guaranteed memory).

The solution proposed in this series is to fallback and reclaim
everybody rather than OOM with a note that if somebody really needs an
OOM then we can add a per-memcg knob which tells whether to fallback or oom.

Previously I was suggesting OOM as a default but I realized that this
might be too risky for the default behavior although I can see some
point in that behavior as well (it would allow to have a group which
would never reclaim memory and rather go OOM where the memory demand can
be handled more specifically). I do not have any call for such a hard
guarantee requirement usecase now and it would be quite trivial to build
it on top of the more relaxed implementation so I am more inclined to
the fallback default now.

More comments inlined below.

On Tue 06-05-14 11:21:12, Johannes Weiner wrote:
> On Tue, May 06, 2014 at 04:32:42PM +0200, Michal Hocko wrote:
> > On Tue 06-05-14 09:29:32, Johannes Weiner wrote:
> > > On Fri, May 02, 2014 at 06:00:56PM -0400, Johannes Weiner wrote:
> > > > On Fri, May 02, 2014 at 06:49:30PM +0200, Michal Hocko wrote:
> > > > > On Fri 02-05-14 11:58:05, Johannes Weiner wrote:
> > > > > > This is not even guarantees anymore, but rather another reclaim
> > > > > > prioritization scheme with best-effort semantics.  That went over
> > > > > > horribly with soft limits, and I don't want to repeat this.
> > > > > > 
> > > > > > Overcommitting on guarantees makes no sense, and you even agree you
> > > > > > are not interested in it.  We also agree that we can always add a knob
> > > > > > later on to change semantics when an actual usecase presents itself,
> > > > > > so why not start with the clear and simple semantics, and the simpler
> > > > > > implementation?
> > > > > 
> > > > > So you are really preferring an OOM instead? That was the original
> > > > > implementation posted at the end of last year and some people
> > > > > had concerns about it. This is the primary reason I came up with a
> > > > > weaker version which fallbacks rather than OOM.
> > > > 
> > > > I'll dig through the archives on this then, thanks.
> > > 
> > > The most recent discussion on this I could find was between you and
> > > Greg, where the final outcome was (excerpt):
> > > 
> > > ---
> > > 
> > > From: Greg Thelen <gthelen@google.com>
> > > To: Michal Hocko <mhocko@suse.cz>
> > > Cc: linux-mm@kvack.org,  Johannes Weiner <hannes@cmpxchg.org>,  Andrew Morton <akpm@linux-foundation.org>,  KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,  LKML <linux-kernel@vger.kernel.org>,  Ying Han <yinghan@google.com>,  Hugh Dickins <hughd@google.com>,  Michel Lespinasse <walken@google.com>,  KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,  Tejun Heo <tj@kernel.org>
> > > Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
> > > References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
> > > 	<xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
> > > 	<20140130123044.GB13509@dhcp22.suse.cz>
> > > 	<xr931tzphu50.fsf@gthelen.mtv.corp.google.com>
> > > 	<20140203144341.GI2495@dhcp22.suse.cz>
> > > Date: Mon, 03 Feb 2014 17:33:13 -0800
> > > Message-ID: <xr93zjm7br1i.fsf@gthelen.mtv.corp.google.com>
> > > List-ID: <linux-mm.kvack.org>
> > > 
> > > On Mon, Feb 03 2014, Michal Hocko wrote:
> > > 
> > > > On Thu 30-01-14 16:28:27, Greg Thelen wrote:
> > > >> But this soft_limit,priority extension can be added later.
> > > >
> > > > Yes, I would like to have the strong semantic first and then deal with a
> > > > weaker form. Either by a new limit or a flag.
> > > 
> > > Sounds good.
> > > 
> > > ---
> > > 
> > > So I think everybody involved in the discussions so far are preferring
> > > a hard guarantee, and then later, if needed, to either add a knob to
> > > make it a soft guarantee or to actually implement a usable soft limit.
> > 
> > I am afraid the most of that discussion happened off-list :( Sadly not
> > much of a discussion happened on the list.
> 
> Time to do it now, then :)
> 
> > Sorry I should have been specific and mention that the discussions
> > happened at LSF and partly at the KS.
> > 
> > The strongest point was made by Rik when he claimed that memcg is not
> > aware of memory zones and so one memcg with lowlimit larger than the
> > size of a zone can eat up that zone without any way to free it.
> 
> But who actually cares if an individual zone can be reclaimed?
> 
> Userspace allocations can fall back to any other zone.  Unless there
> are hard bindings, but hopefully nobody binds a memcg to a node that
> is smaller than that memcg's guarantee. 

The protected group might spill over to another group and eat it when
another group would be simply pushed out from the node it is bound to.

> And while the pages are not
> reclaimable, they are still movable, so the NUMA balancer is free to
> correct any allocation mistakes later on.

Do we want to depend on NUMA balancer, though?

> As to kernel allocations, watermarks and lowmem protection prevent any
> single zone from filling up with userspace pages, regardless of their
> reclaimability.

Yes but that protects kernel allocations so it wouldn't help with
competing userspace in different memcgs.

> > This can cause additional troubles (permanent reclaim on that zone
> > and OOM in an extreme situations).
> 
> We have protection against wasting CPU cycles on unreclaimable zones.
> 
> So how is it different than anonymous/shared memory without swap?  Or
> mlocked memory?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

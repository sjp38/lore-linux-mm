Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 944A76B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 08:59:49 -0400 (EDT)
Date: Thu, 12 Sep 2013 08:59:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130912125938.GP856@cmpxchg.org>
References: <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904101852.58E70042@pobox.sk>
 <20130905115430.GB856@cmpxchg.org>
 <20130905124352.GB13666@dhcp22.suse.cz>
 <20130905161817.GD856@cmpxchg.org>
 <20130909123625.GC22212@dhcp22.suse.cz>
 <20130909125659.GD22212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130909125659.GD22212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, azurIt <azurit@pobox.sk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 09, 2013 at 02:56:59PM +0200, Michal Hocko wrote:
> [Adding Glauber - the full patch is here https://lkml.org/lkml/2013/9/5/319]
> 
> On Mon 09-09-13 14:36:25, Michal Hocko wrote:
> > On Thu 05-09-13 12:18:17, Johannes Weiner wrote:
> > [...]
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: [patch] mm: memcg: do not trap chargers with full callstack on OOM
> > > 
> > [...]
> > > 
> > > To fix this, never do any OOM handling directly in the charge context.
> > > When an OOM situation is detected, let the task remember the memcg and
> > > then handle the OOM (kill or wait) only after the page fault stack is
> > > unwound and about to return to userspace.
> > 
> > OK, this is indeed nicer because the oom setup is trivial and the
> > handling is not split into two parts and everything happens close to
> > out_of_memory where it is expected.
> 
> Hmm, wait a second. I have completely forgot about the kmem charging
> path during the review.
> 
> So while previously memcg_charge_kmem could have oom killed a
> task if the it couldn't charge to the u-limit after it managed
> to charge k-limit, now it would simply fail because there is no
> mem_cgroup_{enable,disable}_oom around __mem_cgroup_try_charge it relies
> on. The allocation will fail in the end but I am not sure whether the
> missing oom is an issue or not for existing use cases.

Kernel sites should be able to handle -ENOMEM, right?  And if this
nests inside a userspace fault, it'll still enter OOM.

> My original objection about oom triggered from kmem paths was that oom
> is not kmem aware so the oom decisions might be totally bogus. But we
> still have that:

Well, k should be a fraction of u+k on any reasonable setup, so there
are always appropriate candidates to take down.

>         /*
>          * Conditions under which we can wait for the oom_killer. Those are
>          * the same conditions tested by the core page allocator
>          */
>         may_oom = (gfp & __GFP_FS) && !(gfp & __GFP_NORETRY);
> 
>         _memcg = memcg;
>         ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
>                                       &_memcg, may_oom);
> 
> I do not mind having may_oom = false unconditionally in that path but I
> would like to hear fromm Glauber first.

The patch I just sent to azur puts this conditional into try_charge(),
so I'd just change the kmem site to pass `true'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

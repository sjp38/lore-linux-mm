Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 248DD6B0036
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 10:03:21 -0400 (EDT)
Date: Mon, 16 Sep 2013 16:03:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130916140318.GB3674@dhcp22.suse.cz>
References: <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904101852.58E70042@pobox.sk>
 <20130905115430.GB856@cmpxchg.org>
 <20130905124352.GB13666@dhcp22.suse.cz>
 <20130905161817.GD856@cmpxchg.org>
 <20130909123625.GC22212@dhcp22.suse.cz>
 <20130909125659.GD22212@dhcp22.suse.cz>
 <20130912125938.GP856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130912125938.GP856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@gmail.com>, azurIt <azurit@pobox.sk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

[Sorry for the late reply. I am in pre-long-vacation mode trying to
clean up my desk]

On Thu 12-09-13 08:59:38, Johannes Weiner wrote:
> On Mon, Sep 09, 2013 at 02:56:59PM +0200, Michal Hocko wrote:
[...]
> > Hmm, wait a second. I have completely forgot about the kmem charging
> > path during the review.
> > 
> > So while previously memcg_charge_kmem could have oom killed a
> > task if the it couldn't charge to the u-limit after it managed
> > to charge k-limit, now it would simply fail because there is no
> > mem_cgroup_{enable,disable}_oom around __mem_cgroup_try_charge it relies
> > on. The allocation will fail in the end but I am not sure whether the
> > missing oom is an issue or not for existing use cases.
> 
> Kernel sites should be able to handle -ENOMEM, right?  And if this
> nests inside a userspace fault, it'll still enter OOM.

Yes, I am not concerned about page faults or the kernel not being able
to handle ENOMEM. I was more worried about somebody relying on kmalloc
allocation trigger OOM (e.g. fork bomb hitting kmem limit). This
wouldn't be a good idea in the first place but I wanted to hear back
from those who use kmem accounting for something real.

I would rather see no-oom from kmalloc until oom is kmem aware.

> > My original objection about oom triggered from kmem paths was that oom
> > is not kmem aware so the oom decisions might be totally bogus. But we
> > still have that:
> 
> Well, k should be a fraction of u+k on any reasonable setup, so there
> are always appropriate candidates to take down.
>
> >         /*
> >          * Conditions under which we can wait for the oom_killer. Those are
> >          * the same conditions tested by the core page allocator
> >          */
> >         may_oom = (gfp & __GFP_FS) && !(gfp & __GFP_NORETRY);
> > 
> >         _memcg = memcg;
> >         ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
> >                                       &_memcg, may_oom);
> > 
> > I do not mind having may_oom = false unconditionally in that path but I
> > would like to hear fromm Glauber first.
> 
> The patch I just sent to azur puts this conditional into try_charge(),
> so I'd just change the kmem site to pass `true'.

It seems that your previous patch got merged already (3812c8c8). Could
you post your new version on top of the merged one, please? I am getting
lost in the current patch flow.

I will try to review it before I leave (on Friday).

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

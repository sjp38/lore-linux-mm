Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC316B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 08:59:20 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so5233387wib.3
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:59:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk8si8432504wib.13.2014.06.16.05.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 05:59:18 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:59:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616125915.GB16915@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612161733.GC23606@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612161733.GC23606@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Thu 12-06-14 12:17:33, Tejun Heo wrote:
> Hello, Michal.
> 
> On Thu, Jun 12, 2014 at 04:22:37PM +0200, Michal Hocko wrote:
> > The primary question would be, whether this is is the best transition
> > strategy. I do not know how many users apart from developers are really
> > using unified hierarchy. I would be worried that we merge a feature which
> > will not be used for a long time.
> 
> I'm planning to drop __DEVEL__ mask from the unified hierarchy in a
> cycle, at most two. 

OK, I am obviously behind the current cgroup core changes. I thought
that unified hierarchy will be for development only for much more time.

> The biggest hold up at the moment is
> straightening out the interfaces and interaction between memcg and
> blkcg because I think it'd be silly to have to go through another
> round of interface versioning effort right after transitioning to
> unified hierarchy.  I'm not too confident whether it'd be possible to
> get blkcg completely in shape by that time, but, if that takes too
> long, I'll just leave blkcg behind temporarily.  So, at least from
> kernel side, it's not gonna be too long.
> 
> There sure is a question of how fast userland will move to the new
> interface. 

Yeah, I was mostly thinking about those who would need to to bigger
changes. AFAIR threads will no longer be distributable between groups.

> Some are already playing with unified hierarchy and
> planning to migrate as soon as possible but there sure will be others
> who will take more time.  Can't tell for sure, but the thing is that
> migration to min/low/high/max scheme is a signficant migration effort
> too, so I'm not sure how much we'd gain by doing that separately.
> It'd be an extra transition step for userland (optional but still),
> more combinations of configration to handle for memcg, and it's not
> like unified hierarchy is that difficult to transition to.
> 
> > Moreover, if somebody wants to transition from soft limit then it would
> > be really hard because switching to unified hierarchy might be a no-go.
> 
> Why would that be a no-go? 

I remember discussions about per-thread distributions and some other
things missing from the new API.

> Its usage is mostly similar with
> tranditional hierarchies and can be used with other hierarchies, so
> while it'd take some adaptation, in most cases gradual transition
> shouldn't be a big problem.

OK

> > I think that it is clear that we should deprecate soft_limit ASAP. I
> > also think it wont't hurt to have min, low, high in both old and unified
> > API and strongly warn if somebody tries to use soft_limit along with any
> > of the new APIs in the first step. Later we can even forbid any
> > combination by a hard failure.
> 
> I don't quite understand how you plan to deprecate it.  Sure you can
> fail with -EINVAL or whatnot when the wrong combination

Yes, I was thinking that direction. First warn and then EINVAL later.

> is used but I don't think there's any chance of removing the knob.
> There's a reason why we're introducing a new version of the whole
> cgroup interface which can co-exist with the existing one after all.
> If you wanna version memcg interface separately, maybe that'd work but
> it sounds like a lot of extra hassle for not much gain.

No, I didn't mean to version the interface. I just wanted to have
gradual transition for potential soft_limit users.

Maybe I am misunderstanding something but I thought that new version of
API will contain all knobs which are not marked .flags = CFTYPE_INSANE
while the old API will contain all of them.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

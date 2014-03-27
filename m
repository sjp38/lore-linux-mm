Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 644B06B0035
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:38:36 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id n12so2939140wgh.24
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:38:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce2si3616266wib.115.2014.03.27.13.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 13:38:35 -0700 (PDT)
Date: Thu, 27 Mar 2014 13:38:29 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/4] sl[au]b: charge slabs to memcg explicitly
Message-ID: <20140327203829.GA28590@dhcp22.suse.cz>
References: <cover.1395846845.git.vdavydov@parallels.com>
 <1d0196602182e5284f3289eaea0219e62a51d1c4.1395846845.git.vdavydov@parallels.com>
 <20140326215848.GB22656@dhcp22.suse.cz>
 <5333D576.1050106@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5333D576.1050106@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Thu 27-03-14 11:38:30, Vladimir Davydov wrote:
> On 03/27/2014 01:58 AM, Michal Hocko wrote:
> > On Wed 26-03-14 19:28:05, Vladimir Davydov wrote:
> >> We have only a few places where we actually want to charge kmem so
> >> instead of intruding into the general page allocation path with
> >> __GFP_KMEMCG it's better to explictly charge kmem there. All kmem
> >> charges will be easier to follow that way.
> >>
> >> This is a step towards removing __GFP_KMEMCG. It removes __GFP_KMEMCG
> >> from memcg caches' allocflags. Instead it makes slab allocation path
> >> call memcg_charge_kmem directly getting memcg to charge from the cache's
> >> memcg params.
> > Yes, removing __GFP_KMEMCG is definitely a good step. I am currently at
> > a conference and do not have much time to review this properly (even
> > worse will be on vacation for the next 2 weeks) but where did all the
> > static_key optimization go? What am I missing.
> 
> I expected this question, because I want somebody to confirm if we
> really need such kind of optimization in the slab allocation path. From
> my POV, since we thrash cpu caches there anyway by calling alloc_pages,
> wrapping memcg_charge_slab in a static branch wouldn't result in any
> noticeable performance boost.
> 
> I do admit we benefit from static branching in memcg_kmem_get_cache,
> because this one is called on every kmem object allocation, but slab
> allocations happen much rarer.
> 
> I don't insist on that though, so if you say "no", I'll just add
> __memcg_charge_slab and make memcg_charge_slab call it if the static key
> is on, but may be, we can avoid such code bloating?

I definitely do not insist on static branching at places where it
doesn't help much. The less tricky code we will have the better. Please
document this in the changelog and drop a comment in memcg_charge_slab
which would tell us why we do not have to check for kmem enabling.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

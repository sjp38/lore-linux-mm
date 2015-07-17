Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 21CFA280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:28:50 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so81004148wgk.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:28:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id du7si8984953wib.95.2015.07.17.05.28.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 05:28:48 -0700 (PDT)
Date: Fri, 17 Jul 2015 08:28:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150717122819.GA14895@cmpxchg.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
 <20150716225639.GA11131@cmpxchg.org>
 <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 16, 2015 at 04:03:58PM -0700, Andrew Morton wrote:
> On Thu, 16 Jul 2015 18:56:39 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Thu, Jul 16, 2015 at 02:34:33PM -0700, Andrew Morton wrote:
> > > On Thu, 16 Jul 2015 09:19:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > > I agree with Johannes who originally suggested to expose mem_cgroup that
> > > > it will allow for a better code later.
> > > 
> > > Sure, but how *much* better?  Are there a significant number of
> > > fastpath functions involved?
> > > 
> > > From a maintainability/readability point of view, this is quite a bad
> > > patch.  It exposes a *lot* of stuff to the whole world.  We need to get
> > > a pretty good runtime benefit from doing this to ourselves.  I don't
> > > think that saving 376 bytes on a fatconfig build is sufficient
> > > justification?
> > 
> > It's not a performance issue for me.  Some stuff is hard to read when
> > you have memcg functions with klunky names interrupting the code flow
> > to do something trivial to a struct mem_cgroup member, like
> > mem_cgroup_lruvec_online() and mem_cgroup_get_lru_size().
> > 
> > Maybe we can keep thresholds private and encapsulate the softlimit
> > tree stuff in mem_cgroup_per_zone into something private as well, as
> > this is not used - and unlikely to be used - outside of memcg proper.
> > 
> > But otherwise, I think struct mem_cgroup should have mm-scope.
> 
> Meaning a new mm/memcontrol.h?  That's a bit better I suppose.

I meant as opposed to being private to memcontrol.c.  I'm not sure I
quite see the problem of having these definitions in include/linux, as
long as we keep the stuff that is genuinely only used in memcontrol.c
private to that file.  But mm/memcontrol.h would probably work too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

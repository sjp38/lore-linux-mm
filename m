Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D6875280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 18:57:14 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so28742294wib.0
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:57:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mn10si16246382wjc.72.2015.07.16.15.57.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 15:57:13 -0700 (PDT)
Date: Thu, 16 Jul 2015 18:56:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150716225639.GA11131@cmpxchg.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 16, 2015 at 02:34:33PM -0700, Andrew Morton wrote:
> On Thu, 16 Jul 2015 09:19:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > I agree with Johannes who originally suggested to expose mem_cgroup that
> > it will allow for a better code later.
> 
> Sure, but how *much* better?  Are there a significant number of
> fastpath functions involved?
> 
> From a maintainability/readability point of view, this is quite a bad
> patch.  It exposes a *lot* of stuff to the whole world.  We need to get
> a pretty good runtime benefit from doing this to ourselves.  I don't
> think that saving 376 bytes on a fatconfig build is sufficient
> justification?

It's not a performance issue for me.  Some stuff is hard to read when
you have memcg functions with klunky names interrupting the code flow
to do something trivial to a struct mem_cgroup member, like
mem_cgroup_lruvec_online() and mem_cgroup_get_lru_size().

Maybe we can keep thresholds private and encapsulate the softlimit
tree stuff in mem_cgroup_per_zone into something private as well, as
this is not used - and unlikely to be used - outside of memcg proper.

But otherwise, I think struct mem_cgroup should have mm-scope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

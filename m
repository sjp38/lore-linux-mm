Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 04FC590008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 13:42:44 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so4723727lbv.14
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 10:42:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ky4si13151231lbc.28.2014.10.30.10.42.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 10:42:42 -0700 (PDT)
Date: Thu, 30 Oct 2014 18:42:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030174241.GD3639@dhcp22.suse.cz>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
 <20141030082712.GB4664@dhcp22.suse.cz>
 <54523DDE.9000904@oracle.com>
 <20141030141401.GA24520@phnom.home.cmpxchg.org>
 <54524A2F.5050907@oracle.com>
 <20141030153159.GA3639@dhcp22.suse.cz>
 <20141030172632.GA25217@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030172632.GA25217@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Thu 30-10-14 13:26:32, Johannes Weiner wrote:
> On Thu, Oct 30, 2014 at 04:31:59PM +0100, Michal Hocko wrote:
> > On Thu 30-10-14 10:24:47, Sasha Levin wrote:
> > > On 10/30/2014 10:14 AM, Johannes Weiner wrote:
> > > >> The problem is that you are attempting to read 'locked' when you call
> > > >> > mem_cgroup_end_page_stat(), so it gets used even before you enter the
> > > >> > function - and using uninitialized variables is undefined.
> > > > We are not using that value anywhere if !memcg.  What path are you
> > > > referring to?
> > > 
> > > You're using that value as soon as you are passing it to a function, it
> > > doesn't matter what happens inside that function.
> > 
> > I have discussed that with our gcc guys and you are right. Strictly
> > speaking the compiler is free to do
> > if (!memcg) abort();
> > mem_cgroup_end_page_stat(...);
> > 
> > but it is highly unlikely that this will ever happen. Anyway better be
> > safe than sorry. I guess the following should be sufficient and even
> > more symmetric:
> 
> The functional aspect of this is a terrible motivation for this
> change.  Sure the compiler could, but it doesn't, and it won't.
> 
> But there is some merit in keeping the checker's output meaningful as
> long as it doesn't obfuscate the interface too much.
> 
> > From 6c3e748af7ee24984477e850bb93d65f83914903 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 30 Oct 2014 16:18:23 +0100
> > Subject: [PATCH] mm, memcg: fix potential undefined when for page stat
> >  accounting
> > 
> > since d7365e783edb (mm: memcontrol: fix missed end-writeback page
> > accounting) mem_cgroup_end_page_stat consumes locked and flags variables
> > directly rather than via pointers which might trigger C undefined
> > behavior as those variables are initialized only in the slow path of
> > mem_cgroup_begin_page_stat.
> > Although mem_cgroup_end_page_stat handles parameters correctly and
> > touches them only when they hold a sensible value it is caller which
> > loads a potentially uninitialized value which then might allow compiler
> > to do crazy things.
> 
> I'm not opposed to passing pointers into end_page_stat(), but please
> mention the checker in the changelog.

Done.
 
> > Fix this by using pointer parameters for both locked and flags. This is
> > even better from the API point of view because it is symmetrical to
> > mem_cgroup_begin_page_stat.
> 
> Uhm, locked and flags are return values in begin_page_stat() but input
> arguments in end_page_stat().  Symmetry obfuscates that, so that's not
> an upside at all.  It's a cost that we can pay to keep the checker

Well, I would use a typedef to obfuscate those values because nobody
except for mem_cgroup_{begin,end}_page_stat should touch them. But we
are not doing typedefs in kernel...

> benefits, but the underlying nastiness remains.  It comes from the
> fact that we use conditional locking to avoid the read-side spinlock,
> rather than using a reader-friendly lock to begin with.
 
> So let's change it to pointers, but at the same time be clear that
> this doesn't make the code better.  It just fixes the checker.

No it is not about the checker which is correct here actually. A simple
load to setup parameter from an uninitialized variable is an undefined
behavior (that load happens unconditionally). This has nothing to do
with the way how we use locked and flags inside the function.

New version with an updated changelog
---

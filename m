Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8095D90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 13:27:12 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id z12so4781321wgg.37
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 10:27:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gn9si11453605wib.62.2014.10.30.10.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 10:27:11 -0700 (PDT)
Date: Thu, 30 Oct 2014 13:26:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030172632.GA25217@phnom.home.cmpxchg.org>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
 <20141030082712.GB4664@dhcp22.suse.cz>
 <54523DDE.9000904@oracle.com>
 <20141030141401.GA24520@phnom.home.cmpxchg.org>
 <54524A2F.5050907@oracle.com>
 <20141030153159.GA3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030153159.GA3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 04:31:59PM +0100, Michal Hocko wrote:
> On Thu 30-10-14 10:24:47, Sasha Levin wrote:
> > On 10/30/2014 10:14 AM, Johannes Weiner wrote:
> > >> The problem is that you are attempting to read 'locked' when you call
> > >> > mem_cgroup_end_page_stat(), so it gets used even before you enter the
> > >> > function - and using uninitialized variables is undefined.
> > > We are not using that value anywhere if !memcg.  What path are you
> > > referring to?
> > 
> > You're using that value as soon as you are passing it to a function, it
> > doesn't matter what happens inside that function.
> 
> I have discussed that with our gcc guys and you are right. Strictly
> speaking the compiler is free to do
> if (!memcg) abort();
> mem_cgroup_end_page_stat(...);
> 
> but it is highly unlikely that this will ever happen. Anyway better be
> safe than sorry. I guess the following should be sufficient and even
> more symmetric:

The functional aspect of this is a terrible motivation for this
change.  Sure the compiler could, but it doesn't, and it won't.

But there is some merit in keeping the checker's output meaningful as
long as it doesn't obfuscate the interface too much.

> From 6c3e748af7ee24984477e850bb93d65f83914903 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 30 Oct 2014 16:18:23 +0100
> Subject: [PATCH] mm, memcg: fix potential undefined when for page stat
>  accounting
> 
> since d7365e783edb (mm: memcontrol: fix missed end-writeback page
> accounting) mem_cgroup_end_page_stat consumes locked and flags variables
> directly rather than via pointers which might trigger C undefined
> behavior as those variables are initialized only in the slow path of
> mem_cgroup_begin_page_stat.
> Although mem_cgroup_end_page_stat handles parameters correctly and
> touches them only when they hold a sensible value it is caller which
> loads a potentially uninitialized value which then might allow compiler
> to do crazy things.

I'm not opposed to passing pointers into end_page_stat(), but please
mention the checker in the changelog.

> Fix this by using pointer parameters for both locked and flags. This is
> even better from the API point of view because it is symmetrical to
> mem_cgroup_begin_page_stat.

Uhm, locked and flags are return values in begin_page_stat() but input
arguments in end_page_stat().  Symmetry obfuscates that, so that's not
an upside at all.  It's a cost that we can pay to keep the checker
benefits, but the underlying nastiness remains.  It comes from the
fact that we use conditional locking to avoid the read-side spinlock,
rather than using a reader-friendly lock to begin with.

So let's change it to pointers, but at the same time be clear that
this doesn't make the code better.  It just fixes the checker.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

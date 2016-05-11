Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 854156B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 07:32:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so40051064wme.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:32:31 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k203si22459347wmd.110.2016.05.11.04.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 04:32:30 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so8849038wmn.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:32:30 -0700 (PDT)
Date: Wed, 11 May 2016 13:32:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
Message-ID: <20160511113228.GJ16677@dhcp22.suse.cz>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
 <57331275.9000805@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57331275.9000805@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org

On Wed 11-05-16 13:07:33, Peter Zijlstra wrote:
> 
> 
> On 05/13/2015 04:38 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.cz>
> > 
> > MAP_LOCKED had a subtly different semantic from mmap(2)+mlock(2) since
> > it has been introduced.
> > mlock(2) fails if the memory range cannot get populated to guarantee
> > that no future major faults will happen on the range. mmap(MAP_LOCKED) on
> > the other hand silently succeeds even if the range was populated only
> > partially.
> > 
> > Fixing this subtle difference in the kernel is rather awkward because
> > the memory population happens after mm locks have been dropped and so
> > the cleanup before returning failure (munlock) could operate on something
> > else than the originally mapped area.
> > 
> > E.g. speculative userspace page fault handler catching SEGV and doing
> > mmap(fault_addr, MAP_FIXED|MAP_LOCKED) might discard portion of a racing
> > mmap and lead to lost data. Although it is not clear whether such a
> > usage would be valid, mmap page doesn't explicitly describe requirements
> > for threaded applications so we cannot exclude this possibility.
> > 
> > This patch makes the semantic of MAP_LOCKED explicit and suggest using
> > mmap + mlock as the only way to guarantee no later major page faults.
> > 
> 
> URGH, this really blows chunks. It basically means MAP_LOCKED is pointless
> cruft and we might as well remove it.

Yeah, the usefulness of MAP_LOCKED is somehow reduced. Everybody who
wants the full semantic really have to use mlock(2).

> Why not fix it proper?

I have tried but it turned out to be a problem because we are dropping
mmap_sem after we initialized VMA and as Linus pointed out there
are multithreaded applications which are doing opportunistic memory
management[1]. So we would have to hold the mmap_sem for write during
the whole VMA setup + population and that doesn't seem to be worth
all the trouble when we are even not sure whether somebody relies on
MAP_LOCKED to have the hard mlock semantic.

---
[1] http://lkml.kernel.org/r/CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

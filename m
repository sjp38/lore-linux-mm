Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 237BF6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 04:01:48 -0400 (EDT)
Received: by wgnd10 with SMTP id d10so64266346wgn.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 01:01:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg7si2393746wib.78.2015.05.14.01.01.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 01:01:46 -0700 (PDT)
Date: Thu, 14 May 2015 10:01:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
Message-ID: <20150514080145.GB6433@dhcp22.suse.cz>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
 <20150513144506.GD1227@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150513144506.GD1227@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org

On Wed 13-05-15 10:45:06, Eric B Munson wrote:
> On Wed, 13 May 2015, Michal Hocko wrote:
> 
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
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Does the problem still happend when MAP_POPULATE | MAP_LOCKED is used
> (AFAICT MAP_POPULATE will cause the mmap to fail if all the pages cannot
> be made present).

No, there is no difference because MAP_POPULATE is implicit when
MAP_LOCKED is used and as pointed in the cover, we cannot fail after the
vma is created and locks dropped. The second patch tries to clarify that
MAP_POPULATE is just a best effort.

> Either way this is a good catch.
> 
> Acked-by: Eric B Munson <emunson@akamai.com>
 
Thanks!


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

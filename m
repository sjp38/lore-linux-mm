Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7E46B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 03:59:20 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so4634680wje.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 00:59:20 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id mp16si53300469wjb.279.2016.12.14.00.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 00:59:18 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id he10so3106779wjc.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 00:59:18 -0800 (PST)
Date: Wed, 14 Dec 2016 09:59:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161214085916.GB25573@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161213101451.GB10492@dhcp22.suse.cz>
 <1481666853.29291.33.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481666853.29291.33.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Mikulas Patocka <mpatocka@redhat.com>, Joe Perches <joe@perches.com>

On Tue 13-12-16 14:07:33, Joe Perches wrote:
> On Tue, 2016-12-13 at 11:14 +0100, Michal Hocko wrote:
> > Are there any more comments or objections to this patch? Is this a good
> > start or kv[mz]alloc has to provide a way to cover GFP_NOFS users as
> > well in the initial version.
> 
> Did Andrew Morton ever comment on this?
> I believe he was the primary objector in the past.
> 
> Last I recollect was over a year ago:
> 
> https://lkml.org/lkml/2015/7/7/1050

Let me quote:
: Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
: thing, and we don't want to make it easy for people to do bad things.
: 
: And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
: allocations for page tables and c) it is susceptible to arena
: fragmentation.
: 
: We'd prefer that people fix their junk so it doesn't depend upon large
: contiguous allocations.  This isn't userspace - kernel space is hostile
: and kernel code should be robust.
: 
: So I dunno.  Should we continue to make it a bit more awkward to use
: vmalloc()?  Probably that tactic isn't being very successful - people
: will just go ahead and open-code it.  And given the surprising amount
: of stuff you've placed in kvmalloc_node(), they'll implement it
: incorrectly...
: 
: How about we compromise: add kvmalloc_node(), but include a BUG_ON("you
: suck") to it?

While I agree with some of those points, the reality really sucks,
though. We have tried the same tactic with __GFP_NOFAIL and failed as
well. I guess we should just bite the bullet and provide an api which is
so common that people keep reinventing their own ways around that, many
times wrongly or suboptimally. BUG_ON("you suck") is just not going to
help much I am afraid.

What do you think Andrew?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

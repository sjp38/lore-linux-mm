Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D86966B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 03:24:53 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id iq1so32044538wjb.1
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:24:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w206si53354925wmb.82.2016.12.29.00.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 00:24:52 -0800 (PST)
Date: Thu, 29 Dec 2016 09:24:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161229082449.GC29208@dhcp22.suse.cz>
References: <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
 <20161226090211.GA11455@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
 <20161227094008.GC1308@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612271324300.67790@chino.kir.corp.google.com>
 <20161228084823.GB11470@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612281332320.13632@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612281332320.13632@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 28-12-16 13:33:49, David Rientjes wrote:
> On Wed, 28 Dec 2016, Michal Hocko wrote:
> 
> > I do care more about _users_ and their _experience_ than what
> > application _writers_ think is the best. This is the whole point
> > of giving the defrag tunable. madvise(MADV_HUGEPAGE) is just a hint to
> > the system that using transparent hugepages is _preferable_, not
> > mandatory. We have an option to allow stalls for those vmas to increase
> > the allocation success rate. We also have tunable to completely ignore
> > it. And we should also have an option to not stall.
> > 
> 
> The application developer who uses madvise(MADV_HUGEPAGE) is doing so for 
> a reason.

and nobody questions that... But the application developer can hardly
forsee the environment where the application runs. And what might
look as a reasonable cost/benefit balance in one setup can turn out
completely wrong in a different one - just consider the fragmentation
which is the primary contributor to stalls. It is hardly predictable
and vary between different workloads/setups a lot. While we have a way
(policty if you will) to tell that madvise should be honored as much
as possible (defrag=madvise) we do not have a way to tell that even
madvised vmas are not worth stalling over because the benefit would not
offset the cost.

> We lack the ability to defragment in the background for all users who 
> don't want to block while allowing madvise(MADV_HUGEPAGE) users to block, 
> as the changelog for this patch clearly indicates.

And I agree that this is something to be addressed. I just disagree that
this patch is the way how to achieve that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

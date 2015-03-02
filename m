Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D066B6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 16:42:50 -0500 (EST)
Received: by wgha1 with SMTP id a1so36233274wgh.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:42:50 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com. [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id w8si24438470wjf.122.2015.03.02.13.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 13:42:49 -0800 (PST)
Received: by wesk11 with SMTP id k11so36057425wes.11
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:42:49 -0800 (PST)
Date: Mon, 2 Mar 2015 22:42:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/4] jbd2: revert must-not-fail allocation loops back to
 GFP_NOFAIL
Message-ID: <20150302214247.GB31974@dhcp22.suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
 <1425304483-7987-3-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1503021225090.20808@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503021225090.20808@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon 02-03-15 12:33:21, David Rientjes wrote:
> On Mon, 2 Mar 2015, Michal Hocko wrote:
> 
> > This basically reverts 47def82672b3 (jbd2: Remove __GFP_NOFAIL from jbd2
> > layer). The deprecation of __GFP_NOFAIL was a bad choice because it led
> > to open coding the endless loop around the allocator rather than
> > removing the dependency on the non failing allocation. So the
> > deprecation was a clear failure and the reality tells us that
> > __GFP_NOFAIL is not even close to go away.
> > 
> > It is still true that __GFP_NOFAIL allocations are generally discouraged
> > and new uses should be evaluated and an alternative (pre-allocations or
> > reservations) should be considered but it doesn't make any sense to lie
> > the allocator about the requirements. Allocator can take steps to help
> > making a progress if it knows the requirements.
> > 
> 
> The changelog should state that this only changes the source code, there 
> is no functional change since alloc_buffer_head() and 
> kmem_cache_zalloc(transaction_cache) are already implicitly nofail due to 
> the allocation order.  The failure code added by the commit you cite are 
> never executed.

Well, even when those allocation would fail the resulting behavior is
basically the same (modulo congestion_wait which imho doesn't make much
difference). So I would prefer not getting that way and simply stay with
the external loop vs. looping within the allocator.

> I agree that if the implementation of the page allocator were to change 
> with respect to PAGE_ALLOC_COSTLY_ORDER that we'd need __GFP_NOFAIL and 
> that such an allocation is better handled in the page allocator.
> 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks

> GFP_NOFS|__GFP_NOFAIL is scary.

Yes it is but as I've learned nothing unusual in the fs land and the
situation should be improved a lot if we go reservation way suggested by
David. Then __GFP_NOFAIL would consume the pre-reserved memory rather
than trigger OOM killer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

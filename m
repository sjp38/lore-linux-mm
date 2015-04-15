Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 11FFE6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 18:54:28 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so62308338wgs.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 15:54:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si10726718wjr.71.2015.04.15.15.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 15:54:26 -0700 (PDT)
Date: Wed, 15 Apr 2015 23:53:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
Message-ID: <20150415225354.GK14842@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-3-git-send-email-mgorman@suse.de>
 <20150415222006.GS2366@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150415222006.GS2366@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 12:20:06AM +0200, Andi Kleen wrote:
> 
> I did a quick read and it looks good to me.
> 

Thanks. Does that also include a guarantee that a write to a clean TLB
entry will fault if the underlying PTE is unmapped?

> It's a bit ugly to bloat current with the ubc pointer,
> but i guess there's no good way around that.
> 

I didn't see a better alternative.

> Also not nice to use GFP_ATOMIC for the allocation,
> but again there's no way around it and it will
> eventually recover if it fails. There may be
> a slightly better GFP flag for this situation that
> doesn't dip into the interrupt pools?
> 

I can use GFP_KERNEL|__GFP_NOWARN. In the kswapd case, it's early in the
lifetime of the system so it's not going to enter direct reclaim.  In the
direct reclaim path, the allocation will not recurse due to PF_MEMALLOC. It
ends up achieving the same effect without being as obvious as GFP_ATOMIC was.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

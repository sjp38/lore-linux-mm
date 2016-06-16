Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id C04BD6B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:03:58 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so5334165lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:03:58 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gh2si3933564wjd.127.2016.06.16.01.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:03:57 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so9350950wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:03:57 -0700 (PDT)
Date: Thu, 16 Jun 2016 10:03:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160616080355.GB6836@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616002302.GK12670@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 16-06-16 10:23:02, Dave Chinner wrote:
> On Mon, Jun 06, 2016 at 01:32:16PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> > so it relied on the default page allocator behavior for the given set
> > of flags. This means that small allocations actually never failed.
> > 
> > Now that we have __GFP_RETRY_HARD flags which works independently on the
> > allocation request size we can map KM_MAYFAIL to it. The allocator will
> > try as hard as it can to fulfill the request but fails eventually if
> > the progress cannot be made.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/xfs/kmem.h | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> > index 689f746224e7..34e6b062ce0e 100644
> > --- a/fs/xfs/kmem.h
> > +++ b/fs/xfs/kmem.h
> > @@ -54,6 +54,9 @@ kmem_flags_convert(xfs_km_flags_t flags)
> >  			lflags &= ~__GFP_FS;
> >  	}
> >  
> > +	if (flags & KM_MAYFAIL)
> > +		lflags |= __GFP_RETRY_HARD;
> > +
> 
> I don't understand. KM_MAYFAIL means "caller handles
> allocation failure, so retry on failure is not required." To then
> map KM_MAYFAIL to a flag that implies the allocation will internally
> retry to try exceptionally hard to prevent failure seems wrong.

The primary point, which I've tried to describe in the changelog, is
that the default allocator behavior is to retry endlessly for small
orders. You can override this by using __GFP_NORETRY which doesn't retry
at all and fails quite early. My understanding of KM_MAYFAIL is that
it can cope with allocation failures. The lack of __GFP_NORETRY made me
think that the failure should be prevented as much as possible.
__GFP_RETRY_HARD is semantically somwhere in the middle between
__GFP_NORETRY and __GFP_NOFAIL semantic independently on the allocation
size.

Does that make more sense now?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

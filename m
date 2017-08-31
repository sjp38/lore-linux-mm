Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 657596B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 01:21:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w62so11552095wrc.9
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 22:21:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si3061600wma.253.2017.08.30.22.21.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 22:21:36 -0700 (PDT)
Date: Thu, 31 Aug 2017 07:21:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/slub: don't use reserved highatomic pageblock for
 optimistic try
Message-ID: <20170831052133.g6ds3nfelljgwnv2@dhcp22.suse.cz>
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1503882675-17910-2-git-send-email-iamjoonsoo.kim@lge.com>
 <b50bd39f-931f-7016-f380-62d65babb03f@suse.cz>
 <20170828130829.GL17097@dhcp22.suse.cz>
 <20170829003344.GB14489@js1304-P5Q-DELUXE>
 <20170831014241.GB24271@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170831014241.GB24271@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Thu 31-08-17 10:42:41, Joonsoo Kim wrote:
> On Tue, Aug 29, 2017 at 09:33:44AM +0900, Joonsoo Kim wrote:
> > On Mon, Aug 28, 2017 at 03:08:29PM +0200, Michal Hocko wrote:
> > > On Mon 28-08-17 13:29:29, Vlastimil Babka wrote:
> > > > On 08/28/2017 03:11 AM, js1304@gmail.com wrote:
> > > > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > > 
> > > > > High-order atomic allocation is difficult to succeed since we cannot
> > > > > reclaim anything in this context. So, we reserves the pageblock for
> > > > > this kind of request.
> > > > > 
> > > > > In slub, we try to allocate higher-order page more than it actually
> > > > > needs in order to get the best performance. If this optimistic try is
> > > > > used with GFP_ATOMIC, alloc_flags will be set as ALLOC_HARDER and
> > > > > the pageblock reserved for high-order atomic allocation would be used.
> > > > > Moreover, this request would reserve the MIGRATE_HIGHATOMIC pageblock
> > > > > ,if succeed, to prepare further request. It would not be good to use
> > > > > MIGRATE_HIGHATOMIC pageblock in terms of fragmentation management
> > > > > since it unconditionally set a migratetype to request's migratetype
> > > > > when unreserving the pageblock without considering the migratetype of
> > > > > used pages in the pageblock.
> > > > > 
> > > > > This is not what we don't intend so fix it by unconditionally setting
> > > > > __GFP_NOMEMALLOC in order to not set ALLOC_HARDER.
> > > > 
> > > > I wonder if it would be more robust to strip GFP_ATOMIC from alloc_gfp.
> > > > E.g. __GFP_NOMEMALLOC does seem to prevent ALLOC_HARDER, but not
> > > > ALLOC_HIGH. Or maybe we should adjust __GFP_NOMEMALLOC implementation
> > > > and document it more thoroughly? CC Michal Hocko
> > > 
> > > Yeah, __GFP_NOMEMALLOC is rather inconsistent. It has been added to
> > > override __GFP_MEMALLOC resp. PF_MEMALLOC AFAIK. In this particular
> > > case I would agree that dropping __GFP_HIGH and __GFP_ATOMIC would
> > > be more precise. I am not sure we want to touch the existing semantic of
> > > __GFP_NOMEMALLOC though. This would require auditing all the existing
> > > users (something tells me that quite some of those will be incorrect...)
> > 
> > Hmm... now I realize that there is another reason that we need to use
> > __GFP_NOMEMALLOC. Even if this allocation comes from PF_MEMALLOC user,
> > this optimistic try should not use the reserved memory below the
> > watermark. That is, it should not use ALLOC_NO_WATERMARKS. It can
> > only be accomplished by using __GFP_NOMEMALLOC.
> 
> Michal, Vlastimil, Any thought?

Hmm, I would go with a helper like below and use it in slub

gfp_t gfp_drop_reserves(gfp_t mask)
{
	mask &= ~(__GFP_HIGH|__GFP_ATOMIC)
	mask |= __GFP_NOMEMALLOC;

	return mask;
}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E14F6B0010
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 19:57:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c5so2545968pfn.17
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 16:57:21 -0700 (PDT)
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id e23si3586227pfl.112.2018.03.28.16.57.19
        for <linux-mm@kvack.org>;
        Wed, 28 Mar 2018 16:57:20 -0700 (PDT)
Date: Thu, 29 Mar 2018 10:57:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Message-ID: <20180328235702.GE1150@dastard>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
 <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
 <20180327142150.GA13604@bombadil.infradead.org>
 <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
 <20180328070113.GA9275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328070113.GA9275@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Goldwyn Rodrigues <rgoldwyn@suse.de>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 09:01:13AM +0200, Michal Hocko wrote:
> On Tue 27-03-18 10:13:53, Goldwyn Rodrigues wrote:
> > 
> > 
> > On 03/27/2018 09:21 AM, Matthew Wilcox wrote:
> [...]
> > > Maybe no real filesystem behaves that way.  We need feedback from
> > > filesystem people.
> > 
> > The idea is to:
> > * Keep a central location for check, rather than individual filesystem
> > writepage(). It should reduce code as well.
> > * Filesystem developers call memory allocations without thinking twice
> > about which GFP flag to use: GFP_KERNEL or GFP_NOFS. In essence
> > eliminate GFP_NOFS.
> 
> I do not think this is the right approach. We do want to eliminate
> explicit GFP_NOFS usage, but we also want to reduce the overal GFP_NOFS
> usage as well. The later requires that we drop the __GFP_FS only for
> those contexts that really might cause reclaim recursion problems.

As I've said before, moving to a scoped API will not reduce the
number of GFP_NOFS scope allocation points - removing individual
GFP_NOFS annotations doesn't do anything to avoid the deadlock paths
it protects against.

The issue is that GFP_NOFS is a big hammer - it stops reclaim from
all filesystem scopes, not just the one we hold locks on and are
doing the allocation for. i.e. we can be in one filesystem and quite
safely do reclaim from other filesystems. The global scope of
GFP_NOFS just doesn't allow this sort of fine-grained control to be
expressed in reclaim.

IOWs, if we want to reduce the scope of GFP_NOFS, we need a context
to be passed from allocation to reclaim so that the reclaim context
can check that it's a safe allocation context to reclaim from. e.g.
for GFP_NOFS, we can use the superblock of the allocating filesystem
as the context, and check it against the superblock that the current
reclaim context (e.g. shrinker invocation) belongs to. If they
match, we skip it. If they don't match, then we can perform reclaim
on that context.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

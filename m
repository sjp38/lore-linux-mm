Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A310D6B002E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:01:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id j25so708750wmh.1
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 00:01:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9si2282930wrf.42.2018.03.28.00.01.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 00:01:14 -0700 (PDT)
Date: Wed, 28 Mar 2018 09:01:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] fs: Perform writebacks under memalloc_nofs
Message-ID: <20180328070113.GA9275@dhcp22.suse.cz>
References: <20180321224429.15860-1-rgoldwyn@suse.de>
 <20180321224429.15860-2-rgoldwyn@suse.de>
 <20180322070808.GU23100@dhcp22.suse.cz>
 <d44ff1ea-e618-4cf6-b9b5-3e8fc7f03c14@suse.de>
 <20180327142150.GA13604@bombadil.infradead.org>
 <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a96b6ff-7d55-9bb6-8a30-f32f5dd0b054@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, david@fromorbit.com

On Tue 27-03-18 10:13:53, Goldwyn Rodrigues wrote:
> 
> 
> On 03/27/2018 09:21 AM, Matthew Wilcox wrote:
[...]
> > Maybe no real filesystem behaves that way.  We need feedback from
> > filesystem people.
> 
> The idea is to:
> * Keep a central location for check, rather than individual filesystem
> writepage(). It should reduce code as well.
> * Filesystem developers call memory allocations without thinking twice
> about which GFP flag to use: GFP_KERNEL or GFP_NOFS. In essence
> eliminate GFP_NOFS.

I do not think this is the right approach. We do want to eliminate
explicit GFP_NOFS usage, but we also want to reduce the overal GFP_NOFS
usage as well. The later requires that we drop the __GFP_FS only for
those contexts that really might cause reclaim recursion problems. So in
your example, it would be much better to add the scope into those
writepage(s) implementations which actually can trigger the writeback
from the reclaim path rather from the generic implementation which has
no means to know that.
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF5EE6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:09:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so29184501wmf.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:09:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x137si30603844wme.107.2016.05.30.06.09.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 06:09:03 -0700 (PDT)
Date: Mon, 30 May 2016 15:09:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/17] jbd2: get rid of superfluous __GFP_REPEAT
Message-ID: <20160530130901.GE3690@quack2.suse.cz>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
 <1464599699-30131-18-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464599699-30131-18-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>

On Mon 30-05-16 11:14:59, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> jbd2_alloc is explicit about its allocation preferences wrt. the
> allocation size. Sub page allocations go to the slab allocator
> and larger are using either the page allocator or vmalloc. This
> is all good but the logic is unnecessarily complex.
> 1) as per Ted, the vmalloc fallback is a left-over:
> : jbd2_alloc is only passed in the bh->b_size, which can't be >
> : PAGE_SIZE, so the code path that calls vmalloc() should never get
> : called.  When we conveted jbd2_alloc() to suppor sub-page size
> : allocations in commit d2eecb039368, there was an assumption that it
> : could be called with a size greater than PAGE_SIZE, but that's
> : certaily not true today.
> Moreover vmalloc allocation might even lead to a deadlock because
> the callers expect GFP_NOFS context while vmalloc is GFP_KERNEL.
> 
> 2) __GFP_REPEAT for requests <= PAGE_ALLOC_COSTLY_ORDER is ignored
> since the flag was introduced.
> 
> Let's simplify the code flow and use the slab allocator for sub-page
> requests and the page allocator for others. Even though order > 0 is
> not currently used as per above leave that option open.
> 
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

Since the patch is in pretty stable parts of JBD2 I think it is fine to
merge it through Andrew's tree with the rest of the series.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

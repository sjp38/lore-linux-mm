Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD5996B0299
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:22:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x44-v6so4709010edd.17
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:22:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o56-v6si4901415edc.388.2018.10.25.06.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 06:22:32 -0700 (PDT)
Date: Thu, 25 Oct 2018 15:22:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/7] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20181025132230.GD7711@quack2.suse.cz>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-8-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-8-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu 18-10-18 16:23:18, Josef Bacik wrote:
> ->page_mkwrite is extremely expensive in btrfs.  We have to reserve
> space, which can take 6 lifetimes, and we could possibly have to wait on
> writeback on the page, another several lifetimes.  To avoid this simply
> drop the mmap_sem if we didn't have the cached page and do all of our
> work and return the appropriate retry error.  If we have the cached page
> we know we did all the right things to set this page up and we can just
> carry on.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
...
> @@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  
>  	reserved_space = PAGE_SIZE;
>  
> +	/*
> +	 * We have our cached page from a previous mkwrite, check it to make
> +	 * sure it's still dirty and our file size matches when we ran mkwrite
> +	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
> +	 * otherwise do the mkwrite again.
> +	 */
> +	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
> +		lock_page(page);
> +		if (vmf->cached_size == i_size_read(inode) &&
> +		    PageDirty(page))
> +			return VM_FAULT_LOCKED;
> +		unlock_page(page);
> +	}

I guess this is similar to Dave's comment: Why is i_size so special? What
makes sure that file didn't get modified between time you've prepared
cached_page and now such that you need to do the preparation again?
And if indeed metadata prepared for a page cannot change, what's so special
about it being that particular cached_page?

Maybe to phrase my objections differently: Your preparations in
btrfs_page_mkwrite() are obviously related to your filesystem metadata. So
why cannot you infer from that metadata (extent tree, whatever - I'd use
extent status tree in ext4) whether that particular file+offset is already
prepared for writing and just bail out with success in that case?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

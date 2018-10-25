Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 085F56B02A3
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:58:55 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id f66-v6so5764810ywa.0
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:58:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor3848018ybr.124.2018.10.25.06.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 06:58:53 -0700 (PDT)
Date: Thu, 25 Oct 2018 09:58:51 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 7/7] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20181025135849.bu3cmjnrvz5yysye@macbook-pro-91.dhcp.thefacebook.com>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-8-josef@toxicpanda.com>
 <20181025132230.GD7711@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025132230.GD7711@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 25, 2018 at 03:22:30PM +0200, Jan Kara wrote:
> On Thu 18-10-18 16:23:18, Josef Bacik wrote:
> > ->page_mkwrite is extremely expensive in btrfs.  We have to reserve
> > space, which can take 6 lifetimes, and we could possibly have to wait on
> > writeback on the page, another several lifetimes.  To avoid this simply
> > drop the mmap_sem if we didn't have the cached page and do all of our
> > work and return the appropriate retry error.  If we have the cached page
> > we know we did all the right things to set this page up and we can just
> > carry on.
> > 
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ...
> > @@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
> >  
> >  	reserved_space = PAGE_SIZE;
> >  
> > +	/*
> > +	 * We have our cached page from a previous mkwrite, check it to make
> > +	 * sure it's still dirty and our file size matches when we ran mkwrite
> > +	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
> > +	 * otherwise do the mkwrite again.
> > +	 */
> > +	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
> > +		lock_page(page);
> > +		if (vmf->cached_size == i_size_read(inode) &&
> > +		    PageDirty(page))
> > +			return VM_FAULT_LOCKED;
> > +		unlock_page(page);
> > +	}
> 
> I guess this is similar to Dave's comment: Why is i_size so special? What
> makes sure that file didn't get modified between time you've prepared
> cached_page and now such that you need to do the preparation again?
> And if indeed metadata prepared for a page cannot change, what's so special
> about it being that particular cached_page?
> 
> Maybe to phrase my objections differently: Your preparations in
> btrfs_page_mkwrite() are obviously related to your filesystem metadata. So
> why cannot you infer from that metadata (extent tree, whatever - I'd use
> extent status tree in ext4) whether that particular file+offset is already
> prepared for writing and just bail out with success in that case?
> 

I was just being overly paranoid, I was afraid of the case where we would
truncate and then extend in between, but now that I actually think about it that
would end up with the page not being on the mapping anymore so we would catch
that case.  I've dropped this part from my current version.  I'm getting some
testing on these patches in production and I'll post them sometime next week
once I'm happy with them.  Thanks,

Josef

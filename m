Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 13F8B82FAC
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 01:12:23 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so197629334pab.3
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 22:12:22 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id bt3si45938971pbb.173.2015.10.05.22.12.20
        for <linux-mm@kvack.org>;
        Mon, 05 Oct 2015 22:12:21 -0700 (PDT)
Date: Tue, 6 Oct 2015 16:12:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-ID: <20151006051218.GB32150@dastard>
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
 <20151002072522.GC30354@dhcp22.suse.cz>
 <20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
 <20151005134713.GC7023@dhcp22.suse.cz>
 <20151005122936.8a3b0fe21629390c9aa8bc2a@linux-foundation.org>
 <20151005191217.48008dc7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151005191217.48008dc7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Mon, Oct 05, 2015 at 07:12:17PM -0700, Andrew Morton wrote:
> On Mon, 5 Oct 2015 12:29:36 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Maybe it would be better to add the gfp_t argument to the
> > address_space_operations.  At a minimum, writepage(), readpage(),
> > writepages(), readpages().  What a pickle.
> 
> I'm being dumb.  All we need to do is to add a new
> 
> 	address_space_operations.readpage_gfp(..., gfp_t gfp)
> 
> etc.  That should be trivial.  Each fs type only has 2-4 instances of
> address_space_operations so the overhead is miniscule.
> 
> As a background janitorial thing we can migrate filesystems over to the
> new interface then remove address_space_operations.readpage() etc.  But
> this *would* add overhead: more stack and more text for no gain.  So
> perhaps we just leave things as they are.
> 
> That's so simple that I expect we can short-term fix this bug with that
> approach.  umm, something like
> 
> --- a/fs/mpage.c~a
> +++ a/fs/mpage.c
> @@ -139,7 +139,8 @@ map_buffer_to_page(struct page *page, st
>  static struct bio *
>  do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
>  		sector_t *last_block_in_bio, struct buffer_head *map_bh,
> -		unsigned long *first_logical_block, get_block_t get_block)
> +		unsigned long *first_logical_block, get_block_t get_block,
> +		gfp_t gfp)

Simple enough, but not sufficient to avoid deadlocks because this
doesn't address the common vector for deadlock that was reported.
i.e. deadlocks due to the layering dependency the loop device
creates between two otherwise independent filesystems.

If read IO through the loop device does GFP_KERNEL allocations, then
it is susceptible to deadlock as that can force writeback and
transactions from the filesystem on top of the loop device, which
does more IO to the loop device, which then backs up on the backing
file inode mutex. Forwards progress cannot be made until the
GFP_KERNEL allocation succeeds, but that depends on the loop device
making forwards progress...

The loop device indicates this is a known problems tries to avoid
these deadlocks by doing this on it's backing file:

	mapping_set_gfp_mask(mapping, lo->old_gfp_mask & ~(__GFP_IO|__GFP_FS))

to try to ensure that mapping related allocations do not cause
inappropriate reclaim contexts to be triggered.

This is a problem independent of any specific filesystem - let's not
hack a workaround into a specific filesystem just because the
problem was reported on that filesystem....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

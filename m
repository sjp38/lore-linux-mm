Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 637B06B02F7
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 09:47:17 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so121400154wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 06:47:16 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id fo8si16553283wib.39.2015.10.05.06.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 06:47:16 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so115521852wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 06:47:15 -0700 (PDT)
Date: Mon, 5 Oct 2015 15:47:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-ID: <20151005134713.GC7023@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
 <20151002072522.GC30354@dhcp22.suse.cz>
 <20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri 02-10-15 13:49:53, Andrew Morton wrote:
[...]
> There's a lot of confusion here, so let's try to do some clear
> thinking.
> 
> mapping_gfp_mask() describes the mask to be used for allocating this
> mapping's pagecache pages.  Nothing else.  I introduced it to provide a
> clean way to ensure that blockdev inode pagecache is not allocated from
> highmem.

I am afraid this is not how it ended up being used.

> This is totally different from "I'm holding a lock so I can't do
> __GFP_FS"!  __GFP_HIGHMEM and __GFP_FS are utterly unrelated concepts -
> the only commonality is that they happen to be passed to callees in the
> same memory word.

Which is exactly how those filesytems overcome the lack of consistent
API to tell the restrictions all the way down to the allocator. AFAIR
this is the case beyond xfs.

> At present the VFS provides no way for the filesystem to specify the
> allocation mode for pagecache operations.  The VFS assumes
> __GFP_FS|__GFP_IO|__GFP_WAIT|etc.  mapping_gfp_mask() may *look* like
> it provides a way, but it doesn't.
> 
> The way for a caller to communicate "I can't do __GFP_FS from this
> particular callsite" is to pass that info in a gfp_t, in a function
> call argument.  It is very wrong to put this info into
> mapping_gfp_mask(), as XFS has done.  For obvious reasons: different
> callsites may want different values.
> 
> One can easily envision a filesystem whose read() can allocate
> pagecache with GFP_HIGHUSER but the write() needs
> GFP_HIGHUSER&~__GFP_FS.  This obviously won't fly if we're (ab)using
> mapping_gpf_mask() in this fashion.  Also callsites who *can* use the
> stronger __GFP_FS are artificially prevented from doing so.

Yes I am not happy about the state we have grown into as well.

> So.
> 
> By far the best way of addressing this bug is to fix XFS so that it can
> use __GFP_FS for allocating pagecache.  It's really quite lame that the
> filesystem cannot use the strongest memory allocation mode for the
> largest volume of allocation.  Obviously this fix is too difficult,
> otherwise it would already have been made.
> 
> 
> The second best way of solving this bug is to pass a gfp_t into the
> relevant callees, in the time-honoured manner.  That would involve
> alteration of probably several address_space_operations function
> pointers and lots of mind-numbing mechanical edits and bloat.
> 
> 
> The third best way is to pass the gfp_t via the task_struct.  See
> memalloc_noio_save() and memalloc_noio_restore().  This is a pretty
> grubby way of passing function arguments, but I'm OK with it in this
> special case, because
> 
>   a) Adding a gfp_t arg to 11 billion functions has costs of
>      several forms
> 
>   b) Adding all these costs just because one filesystem is being
>      weird doesn't make sense
> 
>   c) The mpage functions already have too many arguments.  Adding
>      yet another is getting kinda ridiculous, and will cost more stack
>      on some of our deepest paths.
> 
> 
> The fourth best way of fixing this is a nasty short-term bodge, such a
> the one you just sent ;) But if we're going to do this, it should be
> the minimal bodge which fixes this deadlock.  Is it possible to come up
> with a one-liner (plus suitable comment) to get us out of this mess?

Yes I do agree that the fix I am proposing is short-term but this seems
like the easiest way to go for stable and older kernels that might be
affected. I thought your proposal for mapping_gfp_constraint was exactly
to have all such places annotated for an easier future transition to
something more reasonable.
I can reduce the patch to fs/mpage.c chunk which would be few liners and
fix the issue in the same time but what about the other calls which are
inconsistent and broken probably?
 
> Longer-term I suggest we look at generalising the memalloc_noio_foo()
> stuff so as to permit callers to mask off (ie: zero) __GFP_ flags in
> callees.  I have a suspicion we should have done this 15 years ago
> (which is about when I started wanting to do it).

I am not sure memalloc_noio_foo is a huge win. It is an easy hack where
the whole allocation transaction is clear - like in the PM code. I am
not sure this is true also for the FS.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
